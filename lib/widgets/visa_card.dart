// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'package:flutter/material.dart';

import 'card_verify_dialog.dart';

/// Silver payment card shown on the home screen.
///
/// The card number is masked by default and only the last four digits are
/// shown. Tapping the number opens a verification dialog; the full number is
/// revealed only after a password (any input in the demo) or system biometric
/// verification.
class VisaCard extends StatefulWidget {
  /// Brand name shown on the card.
  final String brand;

  const VisaCard({super.key, required this.brand});

  @override
  State<VisaCard> createState() => _VisaCardState();
}

class _VisaCardState extends State<VisaCard> {
  /// Whether the full number has been verified and revealed.
  bool _revealed = false;

  /// Handles a tap on the masked number and reveals it after verification.
  Future<void> _requestReveal() async {
    final passed = await showCardVerifyDialog(context);
    if (passed == true) setState(() => _revealed = true);
  }

  @override
  Widget build(BuildContext context) {
    // Before verification the first three groups are dots; the last group
    // keeps the final four digits.
    final maskedGroup = _revealed ? '0000' : '••••';
    return AspectRatio(
      aspectRatio: 1.586,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE6E7E9), Color(0xFFD2D4D8), Color(0xFFC2C5CA)],
            stops: [0.0, 0.55, 1.0],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand name and contactless symbol.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.brand,
                  style: const TextStyle(
                    color: Color(0xFF6E7176),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                Transform.rotate(
                  angle: 1.5708,
                  child: const Icon(
                    Icons.wifi,
                    size: 22,
                    color: Color(0xFF6E7176),
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Card number; tappable before verification.
            GestureDetector(
              onTap: _revealed ? null : _requestReveal,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _cardNumber(maskedGroup),
                    const SizedBox(width: 16),
                    _cardNumber(maskedGroup),
                    const SizedBox(width: 16),
                    _cardNumber(maskedGroup),
                    const SizedBox(width: 16),
                    _cardNumber('0000'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // VISA mark.
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'VISA',
                style: TextStyle(
                  color: Color(0xFF2B2D30),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Monospaced-style card number or mask text.
  Widget _cardNumber(String digits) {
    return Text(
      digits,
      style: const TextStyle(
        color: Color(0xFF5A5D62),
        fontSize: 21,
        fontWeight: FontWeight.w600,
        letterSpacing: 2,
      ),
    );
  }
}
