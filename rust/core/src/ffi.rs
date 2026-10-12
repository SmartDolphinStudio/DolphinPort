//! C ABI surface consumed by Dart through `dart:ffi`.

use std::ffi::{c_char, CStr, CString};

use serde_json::{json, Value};

use crate::rpc;

/// Entry point.
///
/// Accepts a null-terminated UTF-8 JSON request of the form
/// `{ "method": "...", "params": { ... } }` and returns a heap-allocated,
/// null-terminated JSON response. The caller **must** release the returned
/// pointer with [dp_free]; otherwise the allocation leaks.
///
/// # Safety
/// A non-null request must point to a readable, NUL-terminated UTF-8 buffer
/// for the duration of this call. The returned allocation must be freed once.
#[no_mangle]
pub unsafe extern "C" fn dp_call(request: *const c_char) -> *mut c_char {
    std::panic::catch_unwind(|| {
        let response = if request.is_null() {
            json!({ "ok": false, "error": "null request" })
        } else {
            match CStr::from_ptr(request).to_str() {
                Ok(text) => handle(text),
                Err(_) => json!({ "ok": false, "error": "invalid UTF-8 request" }),
            }
        };
        into_c_string(response)
    })
    .unwrap_or_else(|_| into_c_string(json!({"ok":false,"error":"native panic contained"})))
}

/// Reclaims a string previously returned by [dp_call]. Passing a null pointer
/// is a no-op.
///
/// # Safety
/// A non-null pointer must be an unfreed pointer returned by dp_call. Do not
/// pass another allocator's pointer or release an allocation more than once.
#[no_mangle]
pub unsafe extern "C" fn dp_free(pointer: *mut c_char) {
    if pointer.is_null() {
        return;
    }
    drop(CString::from_raw(pointer));
}

/// Parses and dispatches one request, turning any parse failure into a
/// well-formed error response.
fn handle(text: &str) -> Value {
    match serde_json::from_str::<Value>(text) {
        Ok(value) => {
            let method = value.get("method").and_then(|m| m.as_str()).unwrap_or("");
            let params = value.get("params").cloned().unwrap_or(Value::Null);
            rpc::dispatch(method, params)
        }
        Err(error) => json!({ "ok": false, "error": format!("invalid JSON: {error}") }),
    }
}

/// Converts a JSON value into an owned C string pointer.
fn into_c_string(value: Value) -> *mut c_char {
    let text = serde_json::to_string(&value)
        .unwrap_or_else(|_| r#"{"ok":false,"error":"serialisation failed"}"#.to_string());
    CString::new(text)
        .map(CString::into_raw)
        .unwrap_or(std::ptr::null_mut())
}
