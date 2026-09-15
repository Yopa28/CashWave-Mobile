import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/colors.dart';

class MenuButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final bool isActive;
  final VoidCallback onPressed;
  final bool isImage;
  final double size;

  const MenuButton({
    super.key,
    required this.iconPath,
    required this.label,
    this.isActive = false,
    required this.onPressed,
    this.isImage = false,
    this.size = 90,
  });

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primary = Color(0xff087A55);

  static const Color primaryDark = Color(0xff065C40);

  static const Color primaryLight = Color(0xffE8F5F0);

  static const Color textPrimary = Color(0xff17221E);

  static const Color textSecondary = Color(0xff7A8581);

  static const Color borderColor = Color(0xffE5EBE8);

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,

        borderRadius: BorderRadius.circular(16),

        splashColor: primary.withOpacity(0.08),

        highlightColor: primary.withOpacity(0.04),

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),

          curve: Curves.easeOut,

          width: double.infinity,

          padding: const EdgeInsets.all(14),

          decoration: BoxDecoration(
            color: isActive ? primary : Colors.white,

            borderRadius: BorderRadius.circular(16),

            border: Border.all(color: isActive ? primary : borderColor),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isActive ? 0.08 : 0.035),
                blurRadius: isActive ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              // ==================================================
              // ICON
              // ==================================================

              AnimatedContainer(
                duration: const Duration(milliseconds: 180),

                width: 64,
                height: 64,

                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withOpacity(0.12)
                      : primaryLight,

                  borderRadius: BorderRadius.circular(16),
                ),

                child: Center(child: _buildIcon()),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // LABEL
              // ==================================================
              Text(
                label,

                maxLines: 2,

                overflow: TextOverflow.ellipsis,

                textAlign: TextAlign.center,

                style: TextStyle(
                  color: isActive ? Colors.white : textPrimary,

                  fontSize: 12,

                  fontWeight: FontWeight.w700,

                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ICON
  // ============================================================

  Widget _buildIcon() {
    final Color iconColor = isActive ? Colors.white : primary;

    if (isImage) {
      return Image.asset(
        iconPath,

        width: size > 64 ? 42 : size,

        height: size > 64 ? 42 : size,

        fit: BoxFit.contain,

        color: iconColor,
      );
    }

    return SvgPicture.asset(
      iconPath,

      width: 28,

      height: 28,

      fit: BoxFit.contain,

      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
    );
  }
}
