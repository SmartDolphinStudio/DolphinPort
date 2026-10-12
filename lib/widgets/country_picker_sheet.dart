// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'package:flutter/material.dart';

import '../app/theme.dart';
import 'country_codes.dart';

/// Shows a searchable country picker as a modal bottom sheet.
///
/// Each row shows the flag, country name and dial code; the currently selected
/// country carries a check mark. Resolves to the chosen [Country] or `null`.
Future<Country?> showCountryPickerSheet(
  BuildContext context, {
  required Country selected,
}) {
  return showModalBottomSheet<Country>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (sheetContext) => _CountryPickerSheet(selected: selected),
  );
}

class _CountryPickerSheet extends StatefulWidget {
  final Country selected;

  const _CountryPickerSheet({required this.selected});

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  late Country _selected = widget.selected;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filters by name, ISO code or dial code.
  List<Country> get _matches {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return kCountries;
    return kCountries
        .where(
          (country) =>
              country.name.toLowerCase().contains(q) ||
              country.isoCode.toLowerCase().contains(q) ||
              country.dialCode.contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final matches = _matches;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        minChildSize: 0.45,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Grab handle.
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Select country',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.only(left: 14),
                  decoration: AppDecorations.fieldBox(),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: Color(0xFF999999),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => setState(() => _query = value),
                          decoration: const InputDecoration(
                            hintText: 'Search country or code',
                            hintStyle: TextStyle(
                              color: Color(0xFFBBBBBB),
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            isCollapsed: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      if (_query.isNotEmpty)
                        IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: Color(0xFF999999),
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: matches.isEmpty
                    ? const Center(
                        child: Text(
                          'No matching country',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: matches.length,
                        itemBuilder: (context, index) {
                          final country = matches[index];
                          final isSelected =
                              country.isoCode == _selected.isoCode;
                          return InkWell(
                            onTap: () {
                              setState(() => _selected = country);
                              Navigator.of(context).pop(country);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 11,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    country.flag,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      country.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '+${country.dialCode}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    width: 20,
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check_rounded,
                                            size: 18,
                                            color: Colors.black,
                                          )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
