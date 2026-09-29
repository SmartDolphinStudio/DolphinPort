// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/theme.dart';
import 'country_codes.dart';
import 'country_picker_sheet.dart';

/// Phone number field with an embedded, custom country selector.
///
/// The collapsed selector shows the flag, dial code and a chevron and stays
/// inside the field; tapping it opens a searchable country picker. The number
/// input accepts digits only. The default selection is the United States (+1).
class PhoneNumberField extends StatefulWidget {
  /// Holds the local number digits (without the dial code).
  final TextEditingController controller;

  /// Placeholder for the number input.
  final String numberHint;

  /// Called when the selected country changes.
  final ValueChanged<Country>? onCountryChanged;

  const PhoneNumberField({
    super.key,
    required this.controller,
    this.numberHint = 'Phone number',
    this.onCountryChanged,
  });

  @override
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> {
  Country _country = kDefaultCountry;

  /// Opens the country picker and applies the selection.
  Future<void> _openPicker() async {
    final chosen = await showCountryPickerSheet(context, selected: _country);
    if (chosen == null || !mounted) return;
    setState(() => _country = chosen);
    widget.onCountryChanged?.call(chosen);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.only(right: 6),
      decoration: AppDecorations.fieldBox(),
      child: Row(
        children: [
          // Compact, in-container country selector.
          GestureDetector(
            onTap: _openPicker,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Text(_country.flag, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Text(
                    '+${_country.dialCode}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: Color(0xFF888888),
                  ),
                ],
              ),
            ),
          ),
          Container(width: 1, height: 22, color: const Color(0xFFE2E2E2)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: widget.controller,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: widget.numberHint,
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
        ],
      ),
    );
  }
}
