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
    return Scaffold(
      backgroundColor: background,

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textPrimary,
            size: 19,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pengaturan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Kelola aplikasi CashWave',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: textSecondary,
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
            const Text(
              'Akun',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: textPrimary,
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
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: borderColor),
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

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
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
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: textSecondary),
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
    final Color iconColor = isDanger ? const Color(0xffD9534F) : primary;

    final Color iconBackground = isDanger
        ? const Color(0xfffff1f0)
        : primaryLight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
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
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: textSecondary,
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
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
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
                    color: const Color(0xfffff1f0),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: Color(0xffD9534F),
                    size: 29,
                  ),
                ),

                const SizedBox(height: 16),

                // TITLE
                const Text(
                  'Tutup Kasir?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),

                const SizedBox(height: 7),

                // DESCRIPTION
                const Text(
                  'Pastikan semua transaksi sudah selesai dan data sudah tersinkronisasi sebelum menutup kasir.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: textSecondary,
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
                            foregroundColor: textSecondary,
                            side: const BorderSide(color: borderColor),
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
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
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
                const Text(
                  'Logout dari CashWave?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),

                const SizedBox(height: 7),

                // DESCRIPTION
                const Text(
                  'Anda akan keluar dari akun kasir saat ini.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: textSecondary,
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
                            foregroundColor: textSecondary,
                            side: const BorderSide(color: borderColor),
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
