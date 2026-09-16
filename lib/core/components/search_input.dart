import 'package:flutter/material.dart';

import 'package:cashwave_mobile/core/extensions/build_context_ext.dart';

import '../../presentation/home/pages/scanner_page.dart';

class SearchInput extends StatelessWidget {
  final TextEditingController controller;

  final Function(String value)? onChanged;

  final VoidCallback? onTap;

  const SearchInput({
    super.key,
    required this.controller,
    this.onChanged,
    this.onTap,
  });

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primary = Color(0xff087A55);

  static const Color primaryLight = Color(0xffE8F5F0);

  static const Color background = Color(0xffF7F9F8);

  static const Color textPrimary = Color(0xff17221E);

  static const Color textSecondary = Color(0xff7A8581);

  static const Color borderColor = Color(0xffE5EBE8);

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,

      onChanged: onChanged,

      onTap: onTap,

      readOnly: onTap != null,

      cursorColor: primary,

      style: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),

      decoration: InputDecoration(
        // ======================================================
        // HINT
        // ======================================================

        hintText: 'Cari produk...',

        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),

        // ======================================================
        // PREFIX SEARCH ICON
        // ======================================================
        prefixIcon: const Icon(Icons.search_rounded, color: primary, size: 21),

        // ======================================================
        // QR SCANNER
        // ======================================================
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 7),
          child: IconButton(
            tooltip: 'Scan Barcode',

            onPressed: () {
              context.push(const ScannerPage());
            },

            style: IconButton.styleFrom(
              backgroundColor: colorScheme.primaryContainer,

              foregroundColor: primary,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),

            icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
          ),
        ),

        // ======================================================
        // PADDING
        // ======================================================
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),

        // ======================================================
        // DEFAULT BORDER
        // ======================================================
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderColor),
        ),

        // ======================================================
        // ENABLED BORDER
        // ======================================================
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderColor),
        ),

        // ======================================================
        // FOCUSED BORDER
        // ======================================================
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.4),
        ),

        // ======================================================
        // ERROR BORDER
        // ======================================================
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xffD9534F)),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xffD9534F), width: 1.4),
        ),

        // ======================================================
        // BACKGROUND
        // ======================================================
        filled: true,

        fillColor: colorScheme.surfaceContainerHighest,

        // ======================================================
        // ERROR
        // ======================================================
        errorStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }
}
