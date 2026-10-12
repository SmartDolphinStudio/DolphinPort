# Dependency decisions

Dependabot now targets maintained `master`. Closed PRs on unrelated `main` are not evidence that current master was updated. The proposed rusqlite major upgrade is deferred until SQLite/Android compatibility is tested; existing bundled SQLite is covered by native tests and the Android packaging check. Cupertino icons stays within the existing compatible constraint and is resolved by pubspec.lock. These decisions do not dismiss future security advisories.
