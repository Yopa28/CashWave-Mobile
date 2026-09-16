import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cashwave_mobile/core/extensions/build_context_ext.dart';
import 'package:cashwave_mobile/data/datasources/auth_local_datasource.dart';
import 'package:cashwave_mobile/presentation/auth/pages/login_page.dart';
import 'package:cashwave_mobile/presentation/home/pages/dashboard_page.dart';
import 'package:cashwave_mobile/presentation/setting/bloc/report/close_cashier/close_cashier_bloc.dart';
import 'package:cashwave_mobile/presentation/setting/pages/manage_printer_page.dart';
import 'package:cashwave_mobile/presentation/setting/pages/report/report_page.dart';
import 'package:cashwave_mobile/presentation/setting/pages/sync_data_page.dart';
import 'package:cashwave_mobile/core/theme/theme_controller.dart';

import '../../home/bloc/logout/logout_bloc.dart';
import '../bloc/sync_order/sync_order_bloc.dart';
import 'manage_product_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primary = Color(0xff087A55);
  static const Color primaryDark = Color(0xff065C40);
  static const Color primaryLight = Color(0xffE8F5F0);

  static const Color background = Color(0xffF7F9F8);
  static const Color textPrimary = Color(0xff17221E);
  static const Color textSecondary = Color(0xff7A8581);
  static const Color borderColor = Color(0xffE5EBE8);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pageBackground = colorScheme.surface;
    final primaryText = colorScheme.onSurface;
    final secondaryText = colorScheme.onSurfaceVariant;

    return Scaffold(
      backgroundColor: pageBackground,

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        backgroundColor: pageBackground,
        surfaceTintColor: pageBackground,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pengaturan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: primaryText,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Kelola aplikasi CashWave',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: secondaryText,
              ),
            ),
          ],
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            _buildSectionHeader(
              icon: Icons.settings_outlined,
              title: 'Pengaturan',
              subtitle: 'Kelola fitur dan kebutuhan kasir',
            ),

            const SizedBox(height: 16),

            // ==================================================
            // PRODUCT
            // ==================================================
            _buildMenuCard(
              icon: Icons.inventory_2_outlined,
              title: 'Produk',
              subtitle: 'Kelola produk dan kategori',
              onTap: () {
                context.push(const ManageProductPage());
              },
            ),

            const SizedBox(height: 10),

            // ==================================================
            // PRINTER
            // ==================================================
            _buildMenuCard(
              icon: Icons.print_outlined,
              title: 'Printer',
              subtitle: 'Atur koneksi dan printer kasir',
              onTap: () {
                context.push(const ManagePrinterPage());
              },
            ),

            const SizedBox(height: 10),

            // ==================================================
            // SYNC DATA
            // ==================================================
            _buildMenuCard(
              icon: Icons.sync_rounded,
              title: 'Sync Data',
              subtitle: 'Sinkronisasi data transaksi',
              onTap: () {
                context.push(const SyncDataPage());
              },
            ),

            const SizedBox(height: 10),

            // ==================================================
            // REPORT
            // ==================================================
            _buildMenuCard(
              icon: Icons.bar_chart_rounded,
              title: 'Report',
              subtitle: 'Lihat laporan transaksi',
              onTap: () {
                context.push(const ReportPage());
              },
            ),

            const SizedBox(height: 10),

            _buildThemeCard(),

            const SizedBox(height: 10),

            // ==================================================
            // CLOSE KASIR
            // ==================================================
            BlocListener<SyncOrderBloc, SyncOrderState>(
              listener: (context, state) {
                state.maybeMap(
                  orElse: () {},

                  successCloseChasier: (_) {
                    // Close cashier
                    context.read<CloseCashierBloc>().add(
                      const CloseCashierEvent.closeCashier(),
                    );

                    // Go to login
                    context.pushReplacement(const LoginPage());

                    // Success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: primary,
                        behavior: SnackBarBehavior.floating,
                        content: Text('Kasir berhasil ditutup'),
                      ),
                    );
                  },
                );
              },
              child: _buildMenuCard(
                icon: Icons.lock_outline_rounded,
                title: 'Close Kasir',
                subtitle: 'Tutup sesi kasir saat selesai',
                isDanger: true,
                onTap: () {
                  _showCloseCashierDialog(context);
                },
              ),
            ),

            const SizedBox(height: 30),

            // ==================================================
            // ACCOUNT
            // ==================================================
            Text(
              'Akun',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 10),

            // ==================================================
            // LOGOUT
            // ==================================================
            BlocConsumer<LogoutBloc, LogoutState>(
              listener: (context, state) {
                state.maybeMap(
                  orElse: () {},

                  success: (_) {
                    AuthLocalDatasource().removeAuthData();

                    context.pushReplacement(const LoginPage());
                  },
                );
              },
              builder: (context, state) {
                final isLoading = state.maybeWhen(
                  loading: () => true,
                  orElse: () => false,
                );

                return SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () {
                            _showLogoutDialog(context);
                          },
                    icon: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: primary,
                            ),
                          )
                        : const Icon(Icons.logout_rounded, size: 19),
                    label: Text(
                      isLoading ? 'Memproses...' : 'Logout',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard() {
    final themeController = ThemeScope.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          secondary: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: primaryLight,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              themeController.isDarkMode
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
              color: primary,
            ),
          ),
          title: Text(
            'Mode gelap',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            'Sesuaikan tampilan aplikasi',
            style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
          ),
          value: themeController.isDarkMode,
          onChanged: themeController.setDarkMode,
        ),
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: primaryLight,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: primary, size: 22),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MENU CARD
  // ============================================================

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color iconColor = isDanger ? const Color(0xffD9534F) : primary;

    final Color iconBackground = isDanger
        ? colorScheme.errorContainer
        : colorScheme.primaryContainer;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.025),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // ICON
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),

              const SizedBox(width: 13),

              // TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // ARROW
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  size: 19,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CLOSE CASHIER DIALOG
  // ============================================================

  void _showCloseCashierDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ICON
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    color: colorScheme.onErrorContainer,
                    size: 29,
                  ),
                ),

                const SizedBox(height: 16),

                // TITLE
                Text(
                  'Tutup Kasir?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 7),

                // DESCRIPTION
                Text(
                  'Pastikan semua transaksi sudah selesai dan data sudah tersinkronisasi sebelum menutup kasir.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 20),

                // BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.onSurfaceVariant,
                            side: BorderSide(color: colorScheme.outlineVariant),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);

                            context.read<SyncOrderBloc>().add(
                              const SyncOrderEvent.sendOrderForCloseChasier(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Tutup Kasir',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // LOGOUT DIALOG
  // ============================================================

  void _showLogoutDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ICON
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: primaryLight,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: primary,
                    size: 28,
                  ),
                ),

                const SizedBox(height: 16),

                // TITLE
                Text(
                  'Logout dari CashWave?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 7),

                // DESCRIPTION
                Text(
                  'Anda akan keluar dari akun kasir saat ini.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 20),

                // BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.onSurfaceVariant,
                            side: BorderSide(color: colorScheme.outlineVariant),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);

                            context.read<LogoutBloc>().add(
                              const LogoutEvent.logout(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
