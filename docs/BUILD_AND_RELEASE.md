# Build and Release

This document describes how to build DolphinPort locally and how a signed
release is produced.

## Prerequisites

- Flutter 3.47 (stable) with Dart 3.13 or newer
- JDK 17
- Android SDK with platform 37 and build tools 37.0.0
- Rust 1.80 or newer, only for the placeholder service

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

When `key.properties` is absent, the release build falls back to the debug
signing configuration. This keeps continuous integration green, but such a
build must not be published as a formal release.

## Continuous Integration

- The **CI** workflow runs formatting, analysis, tests and an unsigned
  release build on every push and pull request. It also runs Rust formatting,
  clippy and checks.
- The **Release** workflow runs when a tag matching `v*` is pushed. It
  decodes the keystore from repository secrets, builds a signed APK and
  publishes it to a GitHub release.

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
