//! JSON-RPC style dispatch shared by the FFI surface.
//!
//! Every request carries a `method` and a `params` object; every response is
//! either `{ "ok": true, "data": ... }` or `{ "ok": false, "error": ... }`.
//! Adding a capability is a matter of extending [dispatch].

use serde_json::{json, Value};

use crate::{
    db,
    models::{LimitParams, PathParams, RecordLoginParams, UpsertUserParams},
};

/// Dispatches one request.
pub fn dispatch(method: &str, params: Value) -> Value {
    let result = match method {
        "core.ping" => Ok(json!({
            "name": "dolphinport-core",
            "version": env!("CARGO_PKG_VERSION"),
        })),

        "db.migrate" => match serde_json::from_value::<PathParams>(params) {
            Ok(arguments) => db::migrate(&arguments.path),
            Err(error) => Err(error.to_string()),
        },

        "auth.recordLogin" => match serde_json::from_value::<RecordLoginParams>(params) {
            Ok(arguments) => db::record_login(arguments),
            Err(error) => Err(error.to_string()),
        },

        "auth.listLogins" => {
            let limit = if params.is_null() {
                50
            } else {
                serde_json::from_value::<LimitParams>(params)
                    .map(|arguments| arguments.limit)
                    .unwrap_or(50)
            };
            db::list_logins(limit)
        }

        "auth.upsertUser" => match serde_json::from_value::<UpsertUserParams>(params) {
            Ok(arguments) => db::upsert_user(arguments),
            Err(error) => Err(error.to_string()),
        },

        "auth.listUsers" => db::list_users_page(
            params.get("limit").and_then(Value::as_i64).unwrap_or(50),
            params.get("after_id").and_then(Value::as_i64).unwrap_or(0),
        ),
        "db.clearPersonalData" => db::clear_personal_data(),

        _ => Err(format!("unknown method '{method}'")),
    };

    match result {
        Ok(data) => json!({ "ok": true, "data": data }),
        Err(error) => json!({ "ok": false, "error": error }),
    }
}
