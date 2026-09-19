// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

/// Injectable source of the current time.
///
/// The demo data and reporting windows read the time through [now] instead of
/// calling [DateTime.now] directly, so tests can pin the clock to a fixed
/// instant and stay deterministic. Production code uses the real system clock.
abstract final class Clock {
  static DateTime Function() _source = DateTime.now;

  /// The current time according to the active source.
  static DateTime now() => _source();

  /// Overrides the time source (used in tests).
  static void setSource(DateTime Function() source) {
    _source = source;
  }

  /// Restores the real system clock.
  static void reset() {
    _source = DateTime.now;
  }
}
