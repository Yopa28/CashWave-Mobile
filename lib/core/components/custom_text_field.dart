import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final ValueChanged<String>? onChanged;

  final bool obscureText;
  final TextInputType? keyboardType;

  final bool showLabel;

  final Widget? suffixIcon;
  final Widget? prefixIcon;

  final String? hintText;

  final bool enabled;

  final int maxLines;

  final int? maxLength;

  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.onChanged,
    this.obscureText = false,
    this.keyboardType,
    this.showLabel = true,
    this.suffixIcon,
    this.prefixIcon,
    this.hintText,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
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

  static const Color danger = Color(0xffD9534F);

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ======================================================
        // LABEL
        // ======================================================

        if (showLabel) ...[
          Text(
            label,
            style: const TextStyle(
              color: textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),
        ],

        // ======================================================
        // TEXT FIELD
        // ======================================================
        TextFormField(
          controller: controller,

          onChanged: onChanged,

          obscureText: obscureText,

          keyboardType: keyboardType,

          enabled: enabled,

          maxLines: obscureText ? 1 : maxLines,

          maxLength: maxLength,

          validator: validator,

          style: const TextStyle(
            color: textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),

          cursorColor: primary,

          textInputAction: maxLines > 1
              ? TextInputAction.newline
              : TextInputAction.next,

          decoration: InputDecoration(
            // ==================================================
            // ICON
            // ==================================================

            prefixIcon: prefixIcon,

            suffixIcon: suffixIcon,

            // ==================================================
            // HINT
            // ==================================================
            hintText: hintText ?? label,

            hintStyle: const TextStyle(
              color: textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),

            // ==================================================
            // BACKGROUND
            // ==================================================
            filled: true,

            fillColor: enabled ? background : const Color(0xffEEF1EF),

            // ==================================================
            // CONTENT PADDING
            // ==================================================
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 14,
            ),

            // ==================================================
            // DEFAULT BORDER
            // ==================================================
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: borderColor),
            ),

            // ==================================================
            // ENABLED BORDER
            // ==================================================
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: borderColor),
            ),

            // ==================================================
            // FOCUSED BORDER
            // ==================================================
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: primary, width: 1.4),
            ),

            // ==================================================
            // ERROR BORDER
            // ==================================================
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: danger),
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: danger, width: 1.4),
            ),

            // ==================================================
            // DISABLED BORDER
            // ==================================================
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: borderColor),
            ),

            // ==================================================
            // ERROR STYLE
            // ==================================================
            errorStyle: const TextStyle(
              color: danger,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),

            // ==================================================
            // PREFIX ICON STYLE
            // ==================================================
            prefixIconColor: textSecondary,

            suffixIconColor: textSecondary,

            // ==================================================
            // COUNTER
            // ==================================================
            counterStyle: const TextStyle(color: textSecondary, fontSize: 10),
          ),
        ),
      ],
    );
  }
}
