// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/theme.dart';

/// Verification-code field with an embedded "Get code" action on the right,
/// matching the common web pattern of a code input paired with a send button.
///
/// After a code is requested the button shows a short resend countdown. The
/// parent owns the validation and simulated send via [onRequestCode], which
/// should resolve to `true` only when the code was sent.
class CodeRequestField extends StatefulWidget {
  /// Controller for the six-digit code.
  final TextEditingController controller;

  /// Placeholder text inside the input.
  final String hint;

  /// Called when the user requests a code; resolve `true` once it is sent.
  final Future<bool> Function() onRequestCode;

  const CodeRequestField({
    super.key,
    required this.controller,
    required this.onRequestCode,
    this.hint = 'Enter 6-digit code',
  });

  @override
  State<CodeRequestField> createState() => _CodeRequestFieldState();
}

class _CodeRequestFieldState extends State<CodeRequestField> {
  static const int _cooldownSeconds = 30;

  Timer? _timer;
  int _remaining = 0;
  bool _busy = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _canRequest => _remaining == 0 && !_busy;

  /// Starts the resend countdown.
  void _startCountdown() {
    _timer?.cancel();
    setState(() => _remaining = _cooldownSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _remaining -= 1);
      if (_remaining <= 0) timer.cancel();
    });
  }

  /// Handles the embedded button press.
  Future<void> _request() async {
    if (!_canRequest) return;
    setState(() => _busy = true);
    final sent = await widget.onRequestCode();
    if (!mounted) return;
    setState(() => _busy = false);
    if (sent) _startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    final labelColor = _canRequest ? Colors.black : const Color(0xFFB5B5B5);
    final String label = _busy
        ? '...'
        : _remaining > 0
        ? '$_remaining s'
        : 'Get code';

    return Container(
      height: 50,
      padding: const EdgeInsets.only(left: 16),
      decoration: AppDecorations.fieldBox(),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: const TextStyle(
                  color: Color(0xFFBBBBBB),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          Container(width: 1, height: 22, color: const Color(0xFFE2E2E2)),
          SizedBox(
            width: 82,
            child: TextButton(
              onPressed: _canRequest ? _request : null,
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
