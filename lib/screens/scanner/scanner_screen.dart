// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/random_expense.dart';
import '../../models/transaction.dart';

/// Simulated code scanner.
///
/// This is a front-end only: there is no camera plugin or permission. The
/// screen presents a scanner viewport and, two seconds after it opens, always
/// "recognises" a payment and returns a randomly generated expense, even if
/// the camera is pointed at nothing. The returned [Transaction] is added by the
/// home screen.
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  static const double _frameSize = 260;
  static const Duration _scanDuration = Duration(seconds: 2);

  late final AnimationController _laserController;
  final RandomExpenseGenerator _generator = RandomExpenseGenerator();
  Timer? _timer;
  bool _succeeded = false;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat(reverse: true);
    _timer = Timer(_scanDuration, _finish);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _laserController.dispose();
    super.dispose();
  }

  /// Produces the random expense, shows a brief success state and returns it.
  Future<void> _finish() async {
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    final transaction = _generator.next();
    setState(() => _succeeded = true);
    _laserController.stop();
    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (mounted) Navigator.of(context).pop<Transaction>(transaction);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Simulated camera field: a soft radial vignette.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.1),
                    radius: 1.1,
                    colors: [
                      const Color(0xFF1B1B1D),
                      Colors.black.withValues(alpha: 1),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  // Top bar: close and title.
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const Expanded(
                          child: Text(
                            'Scan to pay',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // Balances the close button so the title is centred.
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  const Spacer(),
                  _buildViewport(),
                  const SizedBox(height: 28),
                  Text(
                    _succeeded
                        ? 'Payment code recognised'
                        : 'Position the code within the frame',
                    style: const TextStyle(
                      color: Color(0xFFCCCCCC),
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the scanning frame with corner accents and the moving laser.
  Widget _buildViewport() {
    return SizedBox(
      width: _frameSize,
      height: _frameSize,
      child: Stack(
        children: [
          // Faint full frame.
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0x33FFFFFF)),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          // Corner accents.
          ..._corners(),
          // Moving laser line.
          if (!_succeeded)
            AnimatedBuilder(
              animation: _laserController,
              builder: (context, child) {
                final inset = 12 + _laserController.value * (_frameSize - 24);
                return Positioned(
                  left: 14,
                  right: 14,
                  top: inset,
                  child: child!,
                );
              },
              child: _laserLine(),
            ),
          // Success check.
          if (_succeeded)
            const Center(
              child: Icon(
                Icons.check_circle_outline,
                color: Colors.white,
                size: 72,
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the four bold corner brackets.
  List<Widget> _corners() {
    const length = 28.0;
    const width = 4.0;
    final accent = _succeeded ? const Color(0xFF22C55E) : Colors.white;

    Widget bracket(Alignment alignment) {
      return Align(
        alignment: alignment,
        child: SizedBox(
          width: length,
          height: length,
          child: CustomPaint(painter: _CornerPainter(alignment, accent, width)),
        ),
      );
    }

    return [
      bracket(Alignment.topLeft),
      bracket(Alignment.topRight),
      bracket(Alignment.bottomLeft),
      bracket(Alignment.bottomRight),
    ];
  }

  /// The horizontal laser line with a soft glow.
  Widget _laserLine() {
    return Container(
      height: 2.5,
      decoration: BoxDecoration(
        color: const Color(0xFF34E0B5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF34E0B5).withValues(alpha: 0.7),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

/// Paints a single right-angle bracket at a frame corner.
class _CornerPainter extends CustomPainter {
  final Alignment alignment;
  final Color color;
  final double strokeWidth;

  _CornerPainter(this.alignment, this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;
    final path = Path();

    // Determine the two edges that meet at this corner.
    final isTop =
        alignment == Alignment.topLeft || alignment == Alignment.topRight;
    final isLeft =
        alignment == Alignment.topLeft || alignment == Alignment.bottomLeft;

    final startX = isLeft ? 0.0 : w;
    final startY = isTop ? 0.0 : h;
    // Horizontal segment.
    path.moveTo(startX, startY);
    path.lineTo(isLeft ? w : 0, startY);
    // Vertical segment from the corner.
    path.moveTo(startX, startY);
    path.lineTo(startX, isTop ? h : 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) =>
      oldDelegate.color != color;
}
