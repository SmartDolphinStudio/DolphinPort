# Architecture

DolphinPort is a front-end-only Flutter application. There is no back end:
all wallet data is generated in memory on the device. This document
describes the layering, routing, data flow and the boundary reserved for a
future Rust service.

## Overview

The application is organised into a small number of layers so that the user
interface stays independent of where the data comes from:

```text
┌──────────────────────────────────────────────┐
│ Screens (features)                           │
│ auth · home · transactions · charts · splash │
├──────────────────────────────────────────────┤
│ Widgets (reusable presentation components)   │
├──────────────────────────────────────────────┤
│ Repositories (data boundary)                 │
├──────────────────────────────────────────────┤
│ Models and the in-memory data source         │
└──────────────────────────────────────────────┘
```

## Layering

- **`lib/app/`** holds the root application widget, the global theme and the
  centralised route table.
- **`lib/core/`** holds cross-cutting constants, such as the brand details
  and the login curve points.
- **`lib/models/`** holds the domain models (`Transaction`, chart data) and
  the deterministic `MockData` source.
- **`lib/data/repositories/`** defines the `WalletRepository` interface and
  its in-memory implementation. Screens depend on the interface rather than
  on the data source directly.
- **`lib/screens/`** groups widgets by feature. Each feature has its own
  directory, and the splash screen lives under `screens/splash/`.
- **`lib/widgets/`** holds reusable components shared across features.

## Routing

Routes are declared once in `lib/app/routes.dart` as named routes and wired
through `onGenerateRoute` on the root application:

| Name               | Path               | Arguments     |
| ------------------ | ------------------ | ------------- |
| login              | `/login`           | —             |
| forgotPassword     | `/forgot-password` | —             |
| home               | `/home`            | —             |
| allTransactions    | `/transactions`    | —             |
| transactionDetail  | `/transaction`     | `Transaction` |
| analytics          | `/analytics`       | —             |

Centralising the routes removes duplicated `MaterialPageRoute` construction
and gives a single place to review navigation.

## Data Flow

1. A screen requests data from the shared `walletRepository`.
2. The repository reads from `MockData`, applies the requested window or
   aggregation and returns model objects.
3. The screen renders the models using reusable widgets.

The repository exposes reporting windows through the `TransactionRange`
enumeration (`today`, `thisWeek`, `thisMonth`, `thisYear`, `custom`). The
reporting week starts on Monday, and the custom window uses a
`DateTimeRange`. Because filtering is based on the transaction timestamp,
the summaries and the visible list always agree.

## Theming

Colours and shared decorations live in `lib/app/theme.dart`. Screens use the
shared tokens instead of hardcoding colours, which keeps the monochrome
visual language consistent and makes future changes straightforward.

## Android Host

The Android host application lives under `android/`. The single activity is
`MainActivity`, a `FlutterFragmentActivity`, under the
`astraeus.smartdolphin.dolphinport` package. Release signing is externalised
to `key.properties`, and release builds use R8 with the keep rules in
`proguard-rules.pro`.

## Rust Boundary

The `rust/` crate is intentionally separate and is not compiled into the
Android application. It reserves the location for a small service that may
later provide an administrative console, security helpers such as
short-lived token minting, and brief, on-demand data retrieval. Until that
work begins, the crate contains only a placeholder `main.rs`.

## Testing

- Unit tests under `test/` cover the transaction model and the repository
  filtering and aggregation.
- Widget tests cover the boot, login, home and detail flows across several
  viewport sizes.
- The integration test under `integration_test/` performs a sign-in smoke
  test and reaches the transactions and analytics screens.
