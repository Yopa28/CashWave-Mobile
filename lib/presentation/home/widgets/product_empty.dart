import 'package:flutter/material.dart';

class ProductEmpty extends StatelessWidget {
  const ProductEmpty({super.key});

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primary = Color(0xff087A55);

  static const Color primaryLight = Color(0xffE8F5F0);

  static const Color textPrimary = Color(0xff17221E);

  static const Color textSecondary = Color(0xff7A8581);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),

      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          // ======================================================
          // ICON CONTAINER
          // ======================================================

          Container(
            width: 88,
            height: 88,

            decoration: BoxDecoration(
              color: primaryLight,

              borderRadius: BorderRadius.circular(26),
            ),

            child: const Icon(
              Icons.inventory_2_outlined,
              color: primary,
              size: 42,
            ),
          ),

          const SizedBox(height: 18),

          // ======================================================
          // TITLE
          // ======================================================
          const Text(
            'Belum Ada Produk',
            textAlign: TextAlign.center,

            style: TextStyle(
              color: textPrimary,

              fontSize: 16,

              fontWeight: FontWeight.w700,

              letterSpacing: -0.2,
            ),
          ),

          const SizedBox(height: 6),

          // ======================================================
          // DESCRIPTION
          // ======================================================
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 35),

            child: Text(
              'Belum ada produk yang tersedia pada kategori ini.',

              textAlign: TextAlign.center,

              style: TextStyle(
                color: textSecondary,

                fontSize: 12,

                height: 1.5,

                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
