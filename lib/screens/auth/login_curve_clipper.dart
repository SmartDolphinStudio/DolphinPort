// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'package:flutter/material.dart';

import '../../core/constants.dart';

/// Black curved background clipper for the login screen.
///
/// Uses the normalised key points in [kLoginCurvePoints], smoothed with a
/// Catmull-Rom spline to reproduce the hand-drawn curve. The start and end
/// are extrapolated along the tangent to the screen edges so no horizontal
/// straight segment appears.
class LoginCurveClipper extends CustomClipper<Path> {
  /// Vertical compression factor for the curve, moving the header upwards.
  static const double _verticalScale = 0.70;

  /// Catmull-Rom spline interpolation; [samplesPerSegment] points per segment.
  List<Offset> _catmullRom(List<Offset> points, {int samplesPerSegment = 30}) {
    if (points.length < 2) return points;

    // Mirror control points at both ends so the curve reaches the edges.
    final extended = <Offset>[
      points.first - (points[1] - points.first),
      ...points,
      points.last + (points.last - points[points.length - 2]),
    ];

    final result = <Offset>[];
    for (var i = 1; i < extended.length - 2; i++) {
      final p0 = extended[i - 1];
      final p1 = extended[i];
      final p2 = extended[i + 1];
      final p3 = extended[i + 2];

      for (var j = 0; j < samplesPerSegment; j++) {
        final t = j / samplesPerSegment;
        final t2 = t * t;
        final t3 = t2 * t;
        double axis(double a, double b, double c, double d) =>
            0.5 *
            ((2 * b) +
                (-a + c) * t +
                (2 * a - 5 * b + 4 * c - d) * t2 +
                (-a + 3 * b - 3 * c + d) * t3);
        result.add(
          Offset(
            axis(p0.dx, p1.dx, p2.dx, p3.dx),
            axis(p0.dy, p1.dy, p2.dy, p3.dy),
          ),
        );
      }
    }
    result.add(points.last);
    return result;
  }

  @override
  Path getClip(Size size) {
    final points = [
      for (final point in kLoginCurvePoints)
        Offset(point[0] * size.width, point[1] * size.height * _verticalScale),
    ];
    final smoothed = _catmullRom(points);
    final count = smoothed.length;

    // Extrapolate the first point along its tangent to the left edge.
    var yLeft = smoothed.first.dy;
    if (smoothed[1].dx != smoothed[0].dx) {
      final t = (0 - smoothed[0].dx) / (smoothed[1].dx - smoothed[0].dx);
      yLeft = smoothed[0].dy + t * (smoothed[1].dy - smoothed[0].dy);
    }

    // Extrapolate the last point along its tangent to the right edge.
    var yRight = smoothed.last.dy;
    if (smoothed[count - 1].dx != smoothed[count - 2].dx) {
      final t =
          (size.width - smoothed[count - 1].dx) /
          (smoothed[count - 1].dx - smoothed[count - 2].dx);
      yRight =
          smoothed[count - 1].dy +
          t * (smoothed[count - 1].dy - smoothed[count - 2].dy);
    }

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, yRight);
    for (final point in smoothed.reversed) {
      path.lineTo(point.dx, point.dy);
    }
    path
      ..lineTo(0, yLeft)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
