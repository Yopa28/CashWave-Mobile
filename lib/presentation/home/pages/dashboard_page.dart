import 'package:flutter/material.dart';

import 'package:cashwave_mobile/presentation/history/pages/history_page.dart';
import 'package:cashwave_mobile/presentation/home/pages/home_page.dart';
import 'package:cashwave_mobile/presentation/order/pages/order_page.dart';
import 'package:cashwave_mobile/presentation/setting/pages/setting_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // ============================================================
  // STATE
  // ============================================================

  int _selectedIndex = 0;

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primary = Color(0xff087A55);

  static const Color primaryLight = Color(0xffE8F5F0);

  static const Color background = Color(0xffF7F9F8);

  static const Color inactive = Color(0xff9AA5A1);

  static const Color border = Color(0xffE5EBE8);

  // ============================================================
  // PAGES
  // ============================================================

  final List<Widget> _pages = const [
    HomePage(),
    OrderPage(),
    HistoryPage(),
    SettingPage(),
  ];

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,

      // ========================================================
      // PAGE
      // ========================================================
      body: IndexedStack(index: _selectedIndex, children: _pages),

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigation() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,

        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant, width: 0.7),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),

      child: SafeArea(
        top: false,

        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),

          child: Row(
            children: [
              Expanded(
                child: _buildNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                ),
              ),

              Expanded(
                child: _buildNavItem(
                  index: 1,
                  icon: Icons.shopping_bag_outlined,
                  activeIcon: Icons.shopping_bag_rounded,
                  label: 'Orders',
                ),
              ),

              Expanded(
                child: _buildNavItem(
                  index: 2,
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long_rounded,
                  label: 'History',
                ),
              ),

              Expanded(
                child: _buildNavItem(
                  index: 3,
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings_rounded,
                  label: 'Setting',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // NAV ITEM
  // ============================================================

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final bool isActive = _selectedIndex == index;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      onTap: () {
        _onItemTapped(index);
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),

        curve: Curves.easeOut,

        margin: const EdgeInsets.symmetric(horizontal: 5),

        padding: const EdgeInsets.symmetric(vertical: 7),

        decoration: BoxDecoration(
          color: isActive ? colorScheme.primaryContainer : Colors.transparent,

          borderRadius: BorderRadius.circular(14),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            // ==================================================
            // ICON
            // ==================================================

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),

              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },

              child: Icon(
                isActive ? activeIcon : icon,

                key: ValueKey(isActive),

                size: 23,

                color: isActive ? colorScheme.primary : inactive,
              ),
            ),

            const SizedBox(height: 3),

            // ==================================================
            // LABEL
            // ==================================================
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),

              style: TextStyle(
                color: isActive ? colorScheme.primary : inactive,

                fontSize: 10,

                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),

              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
