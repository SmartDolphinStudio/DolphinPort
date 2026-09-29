// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'package:flutter/material.dart';

/// Compact loading animation that plays the exact card-shuffle footage from
/// the reference video.
///
/// The cards are stored as a short loop of transparent WebP frames in
/// `assets/anim/card_loader/` (no MP4 or GIF), so the motion matches the
/// source pixel-for-pixel while staying small. The shuffling cards themselves
/// communicate the loading state, so no caption is shown.
class CardStackLoader extends StatefulWidget {
  /// Display width in logical pixels. The height follows the frame aspect.
  final double width;

  const CardStackLoader({super.key, this.width = 156});

  @override
  State<CardStackLoader> createState() => _CardStackLoaderState();
}

class _CardStackLoaderState extends State<CardStackLoader>
    with SingleTickerProviderStateMixin {
  static const int _frameCount = 116;
  static const double _frameRate = 24;
  static const double _frameAspect = 229 / 240; // height / width

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(
      milliseconds: (_frameCount / _frameRate * 1000).round(),
    ),
  )..repeat();

  @override
  void initState() {
    super.initState();
    // Warm every frame so the loop stays gapless.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      for (var i = 0; i < _frameCount; i++) {
        precacheImage(AssetImage(_framePath(i)), context);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _framePath(int index) {
    final padded = index.toString().padLeft(3, '0');
    return 'assets/anim/card_loader/f$padded.webp';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.width * _frameAspect,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final index = (_controller.value * _frameCount).floor().clamp(
                0,
                _frameCount - 1,
              );
          return Image.asset(
            _framePath(index),
            gaplessPlayback: true,
            fit: BoxFit.contain,
          );
        },
      ),
    );
  }
}
