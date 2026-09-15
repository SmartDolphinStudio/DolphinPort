# Contributing

Thank you for your interest in DolphinPort. It is a front-end demonstration
and learning project, and contributions that improve the code, the
documentation or the developer experience are welcome.

## Before You Start

1. Look through the [open issues](https://github.com/astraeus/dolphinport/issues)
   to see whether your idea is already being discussed.
2. For substantial changes, open an issue first to discuss the proposal.
3. For security concerns, follow the [security policy](SECURITY.md) rather
   than posting publicly.

## Development Workflow

1. Fork the repository and create a branch from `main`.
2. Make your changes, keeping each pull request focused on a single concern.
3. Add or update tests where behaviour changes.
4. Ensure the checks below pass locally.
5. Update the documentation and the [changelog](CHANGELOG.md) as appropriate.
6. Open a pull request and complete the pull-request checklist.

## Local Checks

The continuous-integration pipeline runs the following commands, and they
should pass before you open a pull request:

```bash
flutter pub get
dart format .
flutter analyze
flutter test
```

For changes to the Rust service under `rust/`:

```bash
cargo fmt --all -- --check
cargo clippy --all-targets -- -D warnings
cargo check --all-targets
```

## Commit Messages

This project follows [Conventional Commits](https://www.conventionalcommits.org/).
Use one of the types `feat`, `fix`, `docs`, `style`, `refactor`, `perf`,
`test`, `build`, `ci`, `chore` or `revert`:

```text
feat(transactions): add a custom date-range filter
fix(home): prevent the card from overlapping the balance
docs: rewrite the README in British English
```

Write commit subjects in the imperative mood, keep them concise and add a
more detailed body when the change needs explanation.

## Coding Conventions

- Follow the effective Dart style and the lint rules in
  `analysis_options.yaml`.
- Use descriptive names and prefer small, single-responsibility widgets and
  methods.
- Keep colours and shared styles in `lib/app/theme.dart` rather than
  hardcoding them.
- Route through the named routes in `lib/app/routes.dart`.
- Access data through the repository layer rather than reading `MockData`
  directly from screens.
- Write prose, comments and documentation in standard British English. Code
  identifiers follow the platform conventions (for example, `color`).

## Reporting Bugs and Requesting Features

Please use the issue templates and include as much relevant detail as you
can, including the device, the Android version and clear reproduction steps.

## Licensing

By contributing, you agree that your contributions will be licensed under
the [MIT License](LICENSE).
