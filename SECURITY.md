# Security Policy

DolphinPort is a learning and demonstration project. It deliberately keeps
all wallet data in memory on the device and ships with no real accounts, no
network calls and no payment processing.

## Supported Versions

Only the latest tagged release is supported with security fixes.

| Version | Supported          |
| ------- | ------------------ |
| 1.1.x   | :white_check_mark: |
| < 1.1   | :x:                |

## Reporting a Vulnerability

Please report suspected security vulnerabilities **privately** rather than
opening a public issue.

1. Email the maintainer at **smartdolphinstudio@il.com** with a description
   of the issue, the steps to reproduce it and, where possible, a proof of
   concept.
2. You should receive an acknowledgement within five working days.
3. The maintainer will investigate, aim to provide an initial assessment
   within ten working days and keep you informed of the progress.
4. Once a fix is ready, it will be released in a new tagged version. Public
   disclosure is coordinated after the fix is available, and reporters are
   credited unless they prefer to remain anonymous.

Please avoid actions that affect other users, such as denial-of-service
testing, accessing data that does not belong to you or any form of social
engineering.

## Signing Material

Release builds are signed with an upload keystore that is never committed.
Signing configuration is read from `android/key.properties`; see
`android/key.properties.example` for the expected format. If a signing key
or its password is ever exposed, it must be considered compromised, rotated
immediately and removed from history where practical.

## Scope

This policy covers the Flutter application under `lib/`, the Android
configuration under `android/` and the placeholder Rust service under
`rust/`. Third-party packages are governed by their own security policies.
