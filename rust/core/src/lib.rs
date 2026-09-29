//! DolphinPort native core.
//!
//! A small, self-contained Rust library bundled into the Android client as a
//! shared object. It exposes a single JSON entry point through the C ABI (see
//! [ffi]) and owns local persistence through embedded SQLite (see [db]).
//! There is no network and no server: all state lives in the application's
//! private storage.
//!
//! Flutter calls `dp_call` with `{ "method", "params" }` and releases the
//! returned string with `dp_free`. New capabilities are added in [rpc] without
//! changing the FFI contract.

pub mod db;
pub mod ffi;
pub mod models;
pub mod rpc;
