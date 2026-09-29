// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'dart:async';

import 'package:flutter/material.dart';

import 'card_stack_loader.dart';

/// Full-screen, non-dismissible loading overlay that shows the compact
/// [CardStackLoader] in the centre of the screen while briefly blocking
/// interaction.
///
/// Use [runThen] to play the loader for a short moment and then perform the
/// navigation or action once it is hidden. The overlay lives in the root
/// Overlay and is removed automatically by [hide].
class LoadingOverlay {
  static OverlayEntry? _entry;

  /// Whether the loader is currently on screen.
  static bool get isShowing => _entry != null;

  /// Inserts the loading overlay. Has no effect if one is already showing.
  static void show(BuildContext context) {
    if (_entry != null) return;
    final entry = OverlayEntry(builder: (_) => const _LoadingOverlayView());
    _entry = entry;
    Overlay.of(context, rootOverlay: true).insert(entry);
  }

  /// Removes the loading overlay. Safe to call when none is showing.
  static void hide() {
    _entry?.remove();
    _entry = null;
  }

  /// Shows the loader for at least [minimum], hides it, and then runs [action].
  ///
  /// This keeps the destination screen from appearing underneath the loader
  /// and guarantees the animation is visible even for instant actions.
  static Future<void> runThen(
    BuildContext context,
    FutureOr<void> Function() action, {
    Duration minimum = const Duration(milliseconds: 900),
  }) async {
    show(context);
    await Future<void>.delayed(minimum);
    hide();
    await action();
  }
}

/// Visual presentation of the overlay: a dim scrim with the centred loader.
class _LoadingOverlayView extends StatelessWidget {
  const _LoadingOverlayView();

  @override
  Widget build(BuildContext context) {
    // The opaque gesture detector swallows taps so the UI cannot be used
    // while loading.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.45),
        child: const Center(child: CardStackLoader()),
      ),
    );
  }
}
