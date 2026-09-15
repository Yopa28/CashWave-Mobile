import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cashwave_mobile/presentation/home/bloc/checkout/checkout_bloc.dart';

class NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const NavItem({
    super.key,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primary = Color(0xff087A55);

  static const Color primaryLight = Color(0xffE8F5F0);

  static const Color inactive = Color(0xff9AA5A1);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,

        onTap: onTap,

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),

          curve: Curves.easeOut,

          margin: const EdgeInsets.symmetric(horizontal: 4),

          padding: const EdgeInsets.symmetric(vertical: 7),

          decoration: BoxDecoration(
            color: isActive ? primaryLight : Colors.transparent,

            borderRadius: BorderRadius.circular(14),
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              // ==================================================
              // ICON
              // ==================================================

              Stack(
                clipBehavior: Clip.none,

                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),

                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },

                    child: Icon(
                      isActive ? activeIcon : icon,

                      key: ValueKey(isActive),

                      size: 23,

                      color: isActive ? primary : inactive,
                    ),
                  ),

                  // =================================================
                  // ORDER BADGE
                  // =================================================
                  if (label == 'Orders') _buildOrderBadge(context),
                ],
              ),

              const SizedBox(height: 3),

              // ==================================================
              // LABEL
              // ==================================================
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),

                style: TextStyle(
                  color: isActive ? primary : inactive,

                  fontSize: 10,

                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),

                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ORDER BADGE
  // ============================================================

  Widget _buildOrderBadge(BuildContext context) {
    return BlocBuilder<CheckoutBloc, CheckoutState>(
      builder: (context, state) {
        return state.maybeWhen(
          // ====================================================
          // SUCCESS
          // ====================================================

          success: (products, qty, total, _) {
            if (products.isEmpty || qty <= 0) {
              return const SizedBox();
            }

            return Positioned(
              top: -7,
              right: -10,

              child: Container(
                constraints: const BoxConstraints(minWidth: 17, minHeight: 17),

                padding: const EdgeInsets.symmetric(horizontal: 4),

                decoration: BoxDecoration(
                  color: primary,

                  borderRadius: BorderRadius.circular(9),

                  border: Border.all(color: Colors.white, width: 1.5),
                ),

                child: Center(
                  child: Text(
                    qty > 99 ? '99+' : '$qty',

                    style: const TextStyle(
                      color: Colors.white,

                      fontSize: 8,

                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            );
          },

          // ====================================================
          // DEFAULT
          // ====================================================
          orElse: () {
            return const SizedBox();
          },
        );
      },
    );
  }
}
