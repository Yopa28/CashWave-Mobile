import 'package:flutter/material.dart';

class LabelValue extends StatelessWidget {
  final String label;
  final String value;

  const LabelValue({super.key, required this.label, required this.value});

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primary = Color(0xff087A55);

  static const Color textPrimary = Color(0xff17221E);

  static const Color textSecondary = Color(0xff7A8581);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        // ======================================================
        // LABEL
        // ======================================================

        Text(
          label,

          maxLines: 1,

          overflow: TextOverflow.ellipsis,

          style: const TextStyle(
            color: textSecondary,

            fontSize: 11,

            fontWeight: FontWeight.w500,

            letterSpacing: 0.1,
          ),
        ),

        const SizedBox(height: 4),

        // ======================================================
        // VALUE
        // ======================================================
        Text(
          value,

          maxLines: 2,

          overflow: TextOverflow.ellipsis,

          style: const TextStyle(
            color: textPrimary,

            fontSize: 13,

            fontWeight: FontWeight.w700,

            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }
}
