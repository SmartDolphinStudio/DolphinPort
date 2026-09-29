// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'package:flutter/material.dart';

/// Three-dot bouncing loading indicator.
///
/// Used in the loading state after the login button shrinks; the three dots
/// bounce in sequence.
class ThreeDotsLoader extends StatefulWidget {
  final Color color;

  const ThreeDotsLoader({super.key, this.color = Colors.white});

  @override
  State<ThreeDotsLoader> createState() => _ThreeDotsLoaderState();
}

class _ThreeDotsLoaderState extends State<ThreeDotsLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final start = index * 0.2;
            final t = ((_controller.value - start) / 0.6).clamp(0.0, 1.0);
            // Rises from 0 to 0.5, then falls from 0.5 to 1.
            final bounce = t < 0.5 ? t * 2 : (1 - t) * 2;
            return Padding(
              padding: EdgeInsets.only(right: index < 2 ? 5 : 0),
              child: Transform.translate(
                offset: Offset(0, -4 * bounce),
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
