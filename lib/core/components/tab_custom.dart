import 'package:flutter/material.dart';

class TabCustom extends StatelessWidget {
  final List<TabMenu> children;
  final EdgeInsetsGeometry? padding;

  const TabCustom({super.key, required this.children, this.padding});

  static const Color primary = Color(0xff087A55);
  static const Color primaryLight = Color(0xffE8F5F0);
  static const Color background = Color(0xffF7F9F8);
  static const Color borderColor = Color(0xffE5EBE8);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: padding,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor),
      ),
      child: Row(children: children),
    );
  }
}

class TabMenu extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const TabMenu({
    super.key,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  static const Color primary = Color(0xff087A55);
  static const Color primaryLight = Color(0xffE8F5F0);
  static const Color textPrimary = Color(0xff17221E);
  static const Color textSecondary = Color(0xff7A8581);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isActive ? primary : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: primary.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(11),
            splashColor: primary.withOpacity(0.08),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Center(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isActive ? Colors.white : textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
