//! SQLite connection management, migrations and queries.

use std::sync::{Mutex, OnceLock};

use rusqlite::Connection;

use crate::models::{LoginRecord, RecordLoginParams, UpsertUserParams, User};

/// Schema version applied by [migrate]. Bump and add statements when the
/// embedded schema changes.
const SCHEMA_VERSION: &str = "1";

/// Returns the process-wide connection holder.
///
/// The mobile core is single-tenant, so one connection guarded by a mutex is
/// sufficient. It is opened once via `db.migrate` and reused thereafter.
fn holder() -> &'static Mutex<Option<Connection>> {
    static HOLDER: OnceLock<Mutex<Option<Connection>>> = OnceLock::new();
    HOLDER.get_or_init(|| Mutex::new(None))
}

/// Opens (or creates) the database at [path], applies migrations and stores
/// the connection.
pub fn migrate(path: &str) -> Result<serde_json::Value, String> {
    let connection = Connection::open(path).map_err(|e| e.to_string())?;
    connection
        .pragma_update(None, "foreign_keys", "ON")
        .map_err(|e| e.to_string())?;
    connection
        .execute_batch(SCHEMA)
        .map_err(|e| e.to_string())?;

    *holder().lock().map_err(|e| e.to_string())? = Some(connection);
    Ok(serde_json::json!({ "schema_version": SCHEMA_VERSION }))
}

/// Records an authentication attempt and returns its new row id.
pub fn record_login(params: RecordLoginParams) -> Result<serde_json::Value, String> {
    with_connection(|connection| {
        let now = unix_now();
        connection
            .query_row(
                "INSERT INTO login_records (identifier, method, success, created_at)
                 VALUES (?1, ?2, ?3, ?4)
                 RETURNING id",
                rusqlite::params!["demo-login", params.method, i64::from(params.success), now,],
                |row| row.get::<_, i64>(0),
            )
            .map(|id| serde_json::json!({ "id": id }))
            .map_err(|e| e.to_string())
    })
}

/// Lists the most recent login records.
pub fn list_logins(limit: i64) -> Result<serde_json::Value, String> {
    if !(1..=100).contains(&limit) {
        return Err("limit must be between 1 and 100".into());
    }
    with_connection(|connection| {
        let mut statement = connection
            .prepare(
                "SELECT id, identifier, method, success, created_at
                 FROM login_records ORDER BY id DESC LIMIT ?1",
            )
            .map_err(|e| e.to_string())?;
        let rows = statement
            .query_map(rusqlite::params![limit], map_login)
            .map_err(|e| e.to_string())?;
        let mut records = Vec::new();
        for row in rows {
            records.push(row.map_err(|e| e.to_string())?);
        }
        serde_json::to_value(records).map_err(|e| e.to_string())
    })
}

/// Inserts or updates a remembered user keyed by its UID.
pub fn upsert_user(params: UpsertUserParams) -> Result<serde_json::Value, String> {
    with_connection(|connection| {
        let now = unix_now();
        connection
            .query_row(
                "INSERT INTO users (uid, email, phone, username, created_at)
                 VALUES (?1, ?2, ?3, ?4, ?5)
                 ON CONFLICT(uid) DO UPDATE SET
                    email = excluded.email,
                    phone = excluded.phone,
                    username = excluded.username
                 RETURNING id",
                rusqlite::params![params.uid, params.email, params.phone, params.username, now,],
                |row| row.get::<_, i64>(0),
            )
            .map(|id| serde_json::json!({ "id": id }))
            .map_err(|e| e.to_string())
    })
}

/// Lists all remembered users.
pub fn list_users() -> Result<serde_json::Value, String> {
    list_users_page(100, 0)
}
pub fn list_users_page(limit: i64, after_id: i64) -> Result<serde_json::Value, String> {
    if !(1..=100).contains(&limit) || after_id < 0 {
        return Err("invalid pagination".into());
    }
    with_connection(|connection| {
        let mut statement = connection
            .prepare(
                "SELECT id, uid, email, phone, username, created_at
                 FROM users WHERE id > ?2 ORDER BY id ASC LIMIT ?1",
            )
            .map_err(|e| e.to_string())?;
        let rows = statement
            .query_map(rusqlite::params![limit, after_id], map_user)
            .map_err(|e| e.to_string())?;
        let mut users = Vec::new();
        for row in rows {
            users.push(row.map_err(|e| e.to_string())?);
        }
        serde_json::to_value(users).map_err(|e| e.to_string())
    })
}

/// Runs [action] against the current connection, reporting a clear error when
/// the database has not been initialised.
fn with_connection<T>(action: impl FnOnce(&Connection) -> Result<T, String>) -> Result<T, String> {
    let guard = holder().lock().map_err(|e| e.to_string())?;
    match guard.as_ref() {
        Some(connection) => action(connection),
        None => Err("database not initialised; call db.migrate first".to_string()),
    }
}

/// Maps a row onto a [LoginRecord].
fn map_login(row: &rusqlite::Row<'_>) -> rusqlite::Result<LoginRecord> {
    let success: i64 = row.get(3)?;
    Ok(LoginRecord {
        id: row.get(0)?,
        identifier: row.get(1)?,
        method: row.get(2)?,
        success: success != 0,
        created_at: row.get(4)?,
    })
}

/// Maps a row onto a [User].
fn map_user(row: &rusqlite::Row<'_>) -> rusqlite::Result<User> {
    Ok(User {
        id: row.get(0)?,
        uid: row.get(1)?,
        email: row.get(2)?,
        phone: row.get(3)?,
        username: row.get(4)?,
        created_at: row.get(5)?,
    })
}

/// Returns the current UNIX timestamp in seconds as a string.
fn unix_now() -> String {
    std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|d| d.as_secs().to_string())
        .unwrap_or_else(|_| "0".to_string())
}

/// Database definition language.
const SCHEMA: &str = r#"
CREATE TABLE IF NOT EXISTS users (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    uid        TEXT NOT NULL UNIQUE,
    email      TEXT,
    phone      TEXT,
    username   TEXT,
    created_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS login_records (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    identifier TEXT NOT NULL,
    method     TEXT NOT NULL,
    success    INTEGER NOT NULL,
    created_at TEXT NOT NULL
);
"#;

pub fn clear_personal_data() -> Result<serde_json::Value, String> {
    with_connection(|connection| {
        connection
            .execute_batch("BEGIN; DELETE FROM login_records; DELETE FROM users; COMMIT; VACUUM;")
            .map_err(|e| e.to_string())?;
        Ok(serde_json::json!({"cleared":true}))
    })
}
#[cfg(test)]
mod audit_tests {
    use super::*;
    #[test]
    fn database_boundaries_and_privacy() {
        migrate(":memory:").unwrap();
        record_login(RecordLoginParams {
            identifier: "private@example.com".into(),
            method: "demo".into(),
            success: true,
        })
        .unwrap();
        let rows = list_logins(20).unwrap();
        assert_eq!(rows[0]["identifier"], "demo-login");
        assert!(list_logins(-1).is_err());
        assert!(list_logins(101).is_err());
        assert!(list_users_page(1, -1).is_err());
        clear_personal_data().unwrap();
        assert!(list_logins(20).unwrap().as_array().unwrap().is_empty());
    }
}
