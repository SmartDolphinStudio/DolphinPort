// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../widgets/auth_dialogs.dart';
import '../../widgets/code_request_field.dart';
import '../../widgets/phone_number_field.dart';

/// Account recovery screen on a plain white background.
///
/// The title, subtitle, fields and button form one block centred in the upper
/// half of the screen (the middle of the top half). The phone field carries a
/// country dial-code selector, and the "Get code" action is embedded in the
/// code field. Demo behaviour: no code is sent; any non-empty phone and any
/// six-digit code continue to the reset-password screen.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  /// Validates the phone number and simulates sending the SMS code.
  Future<bool> _requestCode() async {
    if (_phoneController.text.trim().isEmpty) {
      await showAuthDialog(
        context,
        title: 'Cannot send code',
        message: 'Please enter your phone number first.',
      );
      return false;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code sent. In the demo, any six-digit code works.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    return true;
  }

  /// Validates the two fields and continues to the reset-password screen.
  Future<void> _confirm() async {
    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim();
    if (phone.isEmpty || code.length != 6) {
      await showAuthDialog(
        context,
        title: 'Cannot continue',
        message: 'Please enter your phone number and the six-digit code.',
      );
      return;
    }
    if (mounted) Navigator.pushNamed(context, RouteNames.resetPassword);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(top: 8, left: 24, child: _backButton()),
              Align(
                // Middle of the upper half of the screen.
                alignment: const Alignment(0, -0.5),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 72, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Forgot password',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enter your phone number and the code we send you.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _label('Phone number'),
                      const SizedBox(height: 6),
                      PhoneNumberField(controller: _phoneController),
                      const SizedBox(height: 16),
                      _label('Verification code'),
                      const SizedBox(height: 6),
                      CodeRequestField(
                        controller: _codeController,
                        onRequestCode: _requestCode,
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _confirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Confirm',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Field label.
  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Color(0xFF333333),
      ),
    );
  }

  /// Back button.
  Widget _backButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
