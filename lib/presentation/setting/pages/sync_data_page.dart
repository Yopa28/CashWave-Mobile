import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashwave_mobile/core/extensions/build_context_ext.dart';
import 'package:cashwave_mobile/presentation/home/bloc/category/category_bloc.dart';
import 'package:cashwave_mobile/presentation/home/bloc/product/product_bloc.dart';
import 'package:cashwave_mobile/presentation/setting/bloc/sync_order/sync_order_bloc.dart';

import '../../../data/datasources/product_local_datasource.dart';

class SyncDataPage extends StatefulWidget {
  const SyncDataPage({super.key});

  @override
  State<SyncDataPage> createState() => _SyncDataPageState();
}

class _SyncDataPageState extends State<SyncDataPage> {
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
          onPressed: () {
            context.pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textPrimary,
            size: 19,
          ),
        ),

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sync Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Sinkronisasi data CashWave',
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
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        children: [
          // ======================================================
          // INFO CARD
          // ======================================================

          _buildInfoCard(),

          const SizedBox(height: 20),

          const Text(
            'Data',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),

          const SizedBox(height: 10),

          // ======================================================
          // PRODUCT
          // ======================================================
          BlocConsumer<ProductBloc, ProductState>(
            listener: (context, state) {
              state.maybeMap(
                orElse: () {},

                success: (data) async {
                  await ProductLocalDatasource.instance.removeAllProduct();

                  await ProductLocalDatasource.instance.insertAllProduct(
                    data.products.toList(),
                  );

                  if (!context.mounted) return;

                  _showSuccessSnackBar(
                    context,
                    'Data produk berhasil disinkronisasi',
                  );
                },
              );
            },

            builder: (context, state) {
              final isLoading = state.maybeWhen(
                loading: () => true,
                orElse: () => false,
              );

              return _buildSyncCard(
                icon: Icons.inventory_2_outlined,
                title: 'Produk',
                subtitle: 'Sinkronisasi daftar produk dari server',
                isLoading: isLoading,
                onTap: isLoading
                    ? null
                    : () {
                        context.read<ProductBloc>().add(
                          const ProductEvent.fetch(),
                        );
                      },
              );
            },
          ),

          const SizedBox(height: 10),

          // ======================================================
          // ORDERS
          // ======================================================
          BlocConsumer<SyncOrderBloc, SyncOrderState>(
            listener: (context, state) {
              state.maybeMap(
                orElse: () {},

                success: (_) {
                  _showSuccessSnackBar(
                    context,
                    'Data order berhasil disinkronisasi',
                  );
                },
              );
            },

            builder: (context, state) {
              final isLoading = state.maybeWhen(
                loading: () => true,
                orElse: () => false,
              );

              return _buildSyncCard(
                icon: Icons.receipt_long_outlined,
                title: 'Orders',
                subtitle: 'Kirim transaksi lokal ke server',
                isLoading: isLoading,
                onTap: isLoading
                    ? null
                    : () {
                        context.read<SyncOrderBloc>().add(
                          const SyncOrderEvent.sendOrder(),
                        );
                      },
              );
            },
          ),

          const SizedBox(height: 10),

          // ======================================================
          // CATEGORIES
          // ======================================================
          BlocConsumer<CategoryBloc, CategoryState>(
            listener: (context, state) {
              state.maybeMap(
                orElse: () {},

                loaded: (data) async {
                  await ProductLocalDatasource.instance.removeAllCategories();

                  await ProductLocalDatasource.instance.insertAllCategories(
                    data.categories,
                  );

                  if (!context.mounted) return;

                  // Refresh local categories
                  context.read<CategoryBloc>().add(
                    const CategoryEvent.getCategoriesLocal(),
                  );

                  _showSuccessSnackBar(
                    context,
                    'Data kategori berhasil disinkronisasi',
                  );
                },
              );
            },

            builder: (context, state) {
              final isLoading = state.maybeWhen(
                loading: () => true,
                orElse: () => false,
              );

              return _buildSyncCard(
                icon: Icons.category_outlined,
                title: 'Kategori',
                subtitle: 'Sinkronisasi kategori produk dari server',
                isLoading: isLoading,
                onTap: isLoading
                    ? null
                    : () {
                        context.read<CategoryBloc>().add(
                          const CategoryEvent.getCategories(),
                        );
                      },
              );
            },
          ),

          const SizedBox(height: 24),

          // ======================================================
          // NOTE
          // ======================================================
          _buildNoteCard(),
        ],
      ),
    );
  }

  // ============================================================
  // INFO CARD
  // ============================================================

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: primaryLight,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: primary.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.sync_rounded, color: primary, size: 23),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sinkronisasi Data',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Pastikan perangkat terhubung ke internet sebelum melakukan sinkronisasi.',
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.45,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SYNC CARD
  // ============================================================

  Widget _buildSyncCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isLoading,
    required VoidCallback? onTap,
  }) {
    return Container(
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
          // ==================================================
          // ICON
          // ==================================================

          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: primaryLight,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: primary, size: 22),
          ),

          const SizedBox(width: 13),

          // ==================================================
          // TEXT
          // ==================================================
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    height: 1.35,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // ==================================================
          // BUTTON
          // ==================================================
          SizedBox(
            height: 38,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: primaryLight,
                disabledForegroundColor: primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primary,
                      ),
                    )
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sync_rounded, size: 16),
                        SizedBox(width: 5),
                        Text(
                          'Sync',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NOTE CARD
  // ============================================================

  Widget _buildNoteCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: textSecondary,
          ),

          const SizedBox(width: 10),

          const Expanded(
            child: Text(
              'Sync Product dan Kategori akan memperbarui data lokal dengan data terbaru dari server. Sync Orders digunakan untuk mengirim transaksi yang tersimpan di perangkat.',
              style: TextStyle(fontSize: 10, height: 1.5, color: textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUCCESS SNACKBAR
  // ============================================================

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: primary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
