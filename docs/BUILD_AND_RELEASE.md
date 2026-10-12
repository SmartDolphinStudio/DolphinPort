# Build and Release

This document describes how to build DolphinPort locally and how a signed
release is produced.

## Prerequisites

- Flutter 3.44.6 (stable) with Dart 3.12 or newer
- JDK 17
- Android SDK with platform 37 and build tools 37.0.0; NDK 28.2.13676358
- Rust toolchain in rust/rust-toolchain.toml and cargo-ndk 4.1.2, required for native SQLite

Install the dependencies:

```bash
flutter pub get
```

## Debug Builds

```bash
flutter run --debug
flutter build apk --debug
```

## Release Builds

```bash
flutter build apk --release --target-platform android-arm64
```

The APK is written to
`build/app/outputs/flutter-apk/app-release.apk`. Release builds enable R8
minification and resource shrinking. The keep rules are in
`android/app/proguard-rules.pro`; update them if a plugin requires reflective
access.

## Configuring Signing

Release signing is read from `android/key.properties`, which is never
committed:

```bash
cp android/key.properties.example android/key.properties
```

Fill in the keystore location, passwords and alias. To generate a new
upload keystore:

```bash
keytool -genkeypair -v \
  -keystore android/app/upload-keystore.jks \
  -alias upload -keyalg RSA -keysize 2048 -validity 10000
```

When `key.properties` is absent or incomplete, release tasks fail. CI validates a debug APK. A release package requires the separate private release signing key.

## Continuous Integration

- The **CI** workflow runs formatting, analysis, tests and a debug
  APK build on every push and pull request. It also runs Rust formatting,
  clippy and checks.
- The **Release** workflow runs when a tag matching `v*` is pushed. It
  decodes the keystore from repository secrets, builds a signed APK and
  verifies its signature and digest. Publication is a separate release action.

Configure the following repository secrets for signed releases:

| Secret            | Description                                   |
| ----------------- | --------------------------------------------- |
| `KEYSTORE_BASE64` | The keystore file encoded as base64          |
| `STORE_PASSWORD`  | The keystore password                         |
| `KEY_ALIAS`       | The signing key alias                         |
| `KEY_PASSWORD`    | The key password                              |

## Cutting a Release

1. Update the version in `pubspec.yaml` and the Android build configuration.
2. Update `CHANGELOG.md` following the Keep a Changelog format.
3. Ensure `flutter analyze`, `flutter test` and the Rust checks pass.
4. Commit the changes and tag the release, for example `git tag v1.1.0`.
5. Push the tag to trigger the release workflow. In this repository the
   release may also be built and attached manually.

## Handling a Compromised Key

If a keystore or its password is exposed, treat it as compromised:

1. Generate a new keystore and update the signing configuration.
2. Remove the exposed material from any distributed archive and, where
   practical, from history.
3. Inform users and replace previously published artefacts.


Native setup: `cargo install cargo-ndk --version 4.1.2 --locked`. The Gradle preBuild task builds and packages arm64 Rust with Cargo.lock. Debug APKs are the unsigned-release CI alternative; release tasks require valid private signing material and never use debug signing. Persistence runs on a dedicated Dart isolate. The local-record button removes saved logins/users; login identifiers are replaced with `demo-login`. Android backup is disabled. This app stores demo data and does not authenticate financial accounts.

## SDK package naming

Google publishes API 37 as `platforms;android-37.0`. Install that exact package, build-tools 37.0.0 and the pinned NDK. On hosts that resolve integer compileSdk 37 to `platforms/android-37`, the CI creates a symlink to the same official android-37.0 platform. It does not change the API level or use a third-party platform. See the [runner-image maintainers’ explanation](https://github.com/actions/runner-images/issues/13859) and [SDK package manager documentation](https://developer.android.com/tools/sdkmanager).
