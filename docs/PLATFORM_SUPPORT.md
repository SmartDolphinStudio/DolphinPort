# Platform Support

DolphinPort is an **Android-only** application. This document records the
supported Android range and explains why the other platforms are excluded.

## Target Platform

| Property               | Value          |
| ---------------------- | -------------- |
| Platform               | Android        |
| Minimum SDK            | 24 (Android 7.0) |
| Target SDK             | 37             |
| Compile SDK            | 37             |
| Build tools            | 37.0.0         |
| Primary ABI for release | arm64-v8a     |

The minimum SDK of 24 covers the vast majority of active Android devices and
keeps the platform APIs used by the plugins available without additional
compatibility work. The release build targets arm64-v8a, which covers modern
handsets and keeps the artefact small.

## Why Android Only

DolphinPort is deliberately scoped to Android to keep the demonstration
focused:

- There is no iOS, web, desktop or embedded configuration in the repository.
- The project metadata lists only the Android platform.
- The launcher icon and the host configuration are Android-specific.

Supporting additional platforms would require separate host projects,
platform testing and interface adaptations that are outside the scope of the
demo.

## Permissions

The application requests a single permission:

- `USE_BIOMETRIC`, used by the card verification flow. The application only
  invokes the system biometric interface and never reads biometric data
  itself.

There are no network, location, contacts, storage or telephone permissions,
because the demo performs none of those operations.

## Device Features

- Biometric authentication is used when the device supports it; when it is
  unavailable, the password path remains available.
- The interface is built with Material Design and scales across phone
  viewports, from 360 dp-wide handsets to larger devices.
- Hardware acceleration is enabled for the host activity.

## Versioning

The application follows semantic versioning. The Android `versionName` uses
the public version (for example, `1.1.0`) and the `versionCode` is derived
from it (`1010100`).
