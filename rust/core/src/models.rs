//! Serde-facing data models exchanged with the Flutter client.

use serde::{Deserialize, Serialize};

/// A registered or remembered user.
#[derive(Debug, Serialize, Deserialize)]
pub struct User {
    pub id: i64,
    pub uid: Option<String>,
    pub email: Option<String>,
    pub phone: Option<String>,
    pub username: Option<String>,
    pub created_at: String,
}

/// A single authentication attempt recorded for the demo.
#[derive(Debug, Serialize, Deserialize)]
pub struct LoginRecord {
    pub id: i64,
    pub identifier: String,
    pub method: String,
    pub success: bool,
    pub created_at: String,
}

/// Parameters for recording a login.
#[derive(Debug, Deserialize)]
pub struct RecordLoginParams {
    pub identifier: String,
    #[serde(default = "default_method")]
    pub method: String,
    #[serde(default = "default_true")]
    pub success: bool,
}

fn default_method() -> String {
    "password".to_string()
}

fn default_true() -> bool {
    true
}

/// Parameters for upserting a user.
#[derive(Debug, Deserialize)]
pub struct UpsertUserParams {
    pub uid: String,
    #[serde(default)]
    pub email: Option<String>,
    #[serde(default)]
    pub phone: Option<String>,
    #[serde(default)]
    pub username: Option<String>,
}

/// Parameters carrying the database path.
#[derive(Debug, Deserialize)]
pub struct PathParams {
    pub path: String,
}

/// Parameters for limiting a listing.
#[derive(Debug, Deserialize)]
pub struct LimitParams {
    #[serde(default = "default_limit")]
    pub limit: i64,
}

fn default_limit() -> i64 {
    50
}
