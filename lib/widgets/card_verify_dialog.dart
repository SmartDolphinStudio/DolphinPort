// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

/// Dialog for verifying identity before the card number is revealed.
///
/// Returns `true` when verification succeeds: entering any password and
/// pressing Confirm passes in the demo. The "Screen lock" entry invokes the
/// system-provided local authentication — fingerprint or face when available,
/// otherwise the device's lock-screen PIN, pattern or password. It only
/// launches the system UI and reads no biometric data. If the device supports
/// neither, the user is directed back to the password field.
Future<bool?> showCardVerifyDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final passwordController = TextEditingController();
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Verify identity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _authenticateWithDevice(context, dialogContext),
                    child: const Text(
                      'Screen lock',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your password to reveal the card number.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF777777),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
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
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF777777), fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Launches system local authentication: fingerprint or face when available,
/// otherwise the device lock-screen credential. Success closes the dialog and
/// passes; an unsupported device or a failure is reported and the user can
/// fall back to the password field.
Future<void> _authenticateWithDevice(
  BuildContext outerContext,
  BuildContext dialogContext,
) async {
  final authenticator = LocalAuthentication();

  bool supported;
  try {
    supported = await authenticator.isDeviceSupported();
  } catch (_) {
    supported = false;
  }
  if (!supported) {
    if (outerContext.mounted) {
      ScaffoldMessenger.of(outerContext).showSnackBar(
        const SnackBar(
          content: Text('Screen lock unavailable. Use your password.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    return;
  }

  var succeeded = false;
  String? message;
  try {
    succeeded = await authenticator.authenticate(
      localizedReason: 'Verify to reveal the card number',
      // Allow the lock-screen PIN, pattern or password as well as biometrics.
      biometricOnly: false,
      persistAcrossBackgrounding: true,
    );
  } catch (_) {
    message = 'Screen lock unavailable. Use your password.';
  }

  if (succeeded) {
    if (dialogContext.mounted) Navigator.pop(dialogContext, true);
    return;
  }
  if (!outerContext.mounted) return;
  message ??= 'Verification failed. Try again.';
  ScaffoldMessenger.of(outerContext).showSnackBar(
    SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
  );
}
