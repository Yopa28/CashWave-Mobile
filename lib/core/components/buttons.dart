import 'package:flutter/material.dart';

import '../constants/colors.dart';

enum ButtonStyle { filled, outlined }

class Button extends StatelessWidget {
  const Button.filled({
    super.key,
    required this.onPressed,
    required this.label,
    this.style = ButtonStyle.filled,
    this.color = AppColors.primary,
    this.textColor = Colors.white,
    this.width = double.infinity,
    this.height = 50.0,
    this.borderRadius = 16.0,
    this.icon,
    this.disabled = false,
    this.fontSize = 14.0,
    this.borderColor,
  });

  const Button.outlined({
    super.key,
    required this.onPressed,
    required this.label,
    this.style = ButtonStyle.outlined,
    this.color = AppColors.white,
    this.textColor = AppColors.primary,
    this.width = double.infinity,
    this.height = 50.0,
    this.borderRadius = 16.0,
    this.icon,
    this.disabled = false,
    this.fontSize = 14.0,
    this.borderColor = AppColors.primary,
  });

  final VoidCallback onPressed;

  final String label;

  final ButtonStyle style;

  final Color color;

  final Color textColor;

  final double width;

  final double height;

  final double borderRadius;

  final Widget? icon;

  final bool disabled;

  final double fontSize;

  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    if (style == ButtonStyle.outlined) {
      return _buildOutlinedButton();
    }

    return _buildFilledButton();
  }

  // ============================================================
  // FILLED BUTTON
  // ============================================================

  Widget _buildFilledButton() {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          disabledBackgroundColor: color.withOpacity(0.45),
          disabledForegroundColor: Colors.white.withOpacity(0.75),
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: _buildButtonContent(),
      ),
    );
  }

  // ============================================================
  // OUTLINED BUTTON
  // ============================================================

  Widget _buildOutlinedButton() {
    final Color effectiveBorderColor = borderColor ?? AppColors.primary;

    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: disabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          disabledForegroundColor: textColor.withOpacity(0.4),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          side: BorderSide(
            color: disabled
                ? effectiveBorderColor.withOpacity(0.35)
                : effectiveBorderColor,
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: _buildButtonContent(),
      ),
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildButtonContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        if (icon != null) ...[
          IconTheme(
            data: IconThemeData(color: textColor, size: 19),
            child: icon!,
          ),
          const SizedBox(width: 9),
        ],

        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ],
    );
  }
}
