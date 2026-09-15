# Changelog

All notable changes to DolphinPort are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-09-21

### Added

- Centralised named routing in `lib/app/routes.dart`, replacing ad-hoc
  `MaterialPageRoute` construction.
- A repository layer (`lib/data/repositories/wallet_repository.dart`) with an
  abstract `WalletRepository` and an in-memory implementation, defining a
  clear boundary between the user interface and the data source.
- A `timestamp` field on the transaction model so that filtering reflects
  real dates.
- Working Today, This week, This month, This year and Custom date-range
  filters on the transactions screen, with a live income and expense
  summary.
- Unit tests for the transaction model and the repository, and an
  integration smoke test.
- Adaptive launcher icons with vector foreground and background layers, plus
  a monochrome layer for themed icons.
- A placeholder Rust crate under `rust/` for a future administrative and
  security service.
- `SECURITY.md`, `.editorconfig`, `CODEOWNERS`, issue and pull-request
  templates, Dependabot configuration and a release workflow.
- Architecture, platform-support and build-and-release documentation.

### Changed

- Renamed the project and Dart package from SmartDolphin to DolphinPort,
  including the application class, Android namespace and Kotlin package.
- Rewrote all documentation and code comments in standard British English.
- Release builds now read signing details from `android/key.properties` and
  fall back to debug signing when it is absent.
- Enabled R8 minification and resource shrinking for release builds, with
  dedicated keep rules.
- Replaced the Gradle `-all` distribution with the smaller `-bin` distribution.
- Enabled Gradle build caching and parallel execution.

### Removed

- Removed the hardcoded signing passwords and the keystore from the project
  root; signing material is no longer committed.
- Removed the stale `dist/` output directory and other generated files.
- Disabled Jetifier, as all dependencies are AndroidX-native.
- Removed stale web and iOS references from the project metadata.

### Security

- Rotated the upload key after the previous key and its password were found
  in the repository history and in a distributed archive. The old key must be
  considered compromised.

## [1.0.6] - 2026-09-19

### Added

- Initial public demonstration of the wallet interface.
- Login and sign-up flow, home dashboard, payment card, transactions and
  analytics screens.

[1.1.0]: https://github.com/astraeus/dolphinport/releases/tag/v1.1.0
[1.0.6]: https://github.com/astraeus/dolphinport/releases/tag/v1.0.6
