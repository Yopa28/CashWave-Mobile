import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashwave_mobile/core/extensions/build_context_ext.dart';
import 'package:cashwave_mobile/presentation/home/pages/dashboard_page.dart';

import '../../home/bloc/product/product_bloc.dart';
import '../widgets/menu_product_item.dart';
import 'add_product_page.dart';

class ManageProductPage extends StatefulWidget {
  const ManageProductPage({super.key});

  @override
  State<ManageProductPage> createState() => _ManageProductPageState();
}

class _ManageProductPageState extends State<ManageProductPage> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  // =========================
  // COLORS
  // =========================
  static const Color primary = Color(0xff087A55);
  static const Color primaryDark = Color(0xff065C40);
  static const Color primaryLight = Color(0xffE8F5F0);

  static const Color background = Color(0xffF7F9F8);
  static const Color cardColor = Colors.white;

  static const Color textPrimary = Color(0xff17221E);
  static const Color textSecondary = Color(0xff7A8581);

  static const Color borderColor = Color(0xffE5EBE8);

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // ============================================================
      // APP BAR
      // ============================================================
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,

        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: textPrimary,
            ),
          ),
        ),

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Produk',
              style: TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Kelola produk cafe',
              style: TextStyle(
                color: textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        centerTitle: false,

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: borderColor),
        ),
      ),

      // ============================================================
      // BODY
      // ============================================================
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          return state.maybeWhen(
            // ======================================================
            // SUCCESS
            // ======================================================
            success: (products) {
              final filteredProducts = products.where((product) {
                final name = product.name.toString().toLowerCase();
                final category = product.category.toString().toLowerCase();

                return name.contains(_searchQuery) ||
                    category.contains(_searchQuery);
              }).toList();

              return RefreshIndicator(
                color: primary,
                onRefresh: () async {
                  context.read<ProductBloc>().add(const ProductEvent.fetch());

                  // Beri waktu agar state berubah
                  await Future.delayed(const Duration(milliseconds: 700));
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                  children: [
                    // ==================================================
                    // HEADER
                    // ==================================================
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Daftar Produk',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${filteredProducts.length} produk tersedia',
                                style: const TextStyle(
                                  color: textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Total product badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.inventory_2_outlined,
                                size: 17,
                                color: primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${products.length}',
                                style: const TextStyle(
                                  color: primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // ==================================================
                    // SEARCH
                    // ==================================================
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.025),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        style: const TextStyle(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Cari produk atau kategori...',
                          hintStyle: const TextStyle(
                            color: textSecondary,
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: primary,
                            size: 22,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    color: textSecondary,
                                    size: 19,
                                  ),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 15,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // EMPTY SEARCH RESULT
                    // ==================================================
                    if (filteredProducts.isEmpty)
                      _buildEmptyState()
                    else
                      // ==================================================
                      // PRODUCT LIST
                      // ==================================================
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredProducts.length,
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 12);
                        },
                        itemBuilder: (context, index) {
                          return MenuProductItem(data: filteredProducts[index]);
                        },
                      ),
                  ],
                ),
              );
            },

            // ======================================================
            // LOADING
            // ======================================================
            orElse: () {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 20),

                  _buildLoadingHeader(),

                  const SizedBox(height: 20),

                  ...List.generate(
                    5,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildProductSkeleton(),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),

      // ============================================================
      // ADD PRODUCT BUTTON
      // ============================================================
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const AddProductPage();
                },
              ),
            );

            // Refresh produk setelah kembali
            if (!mounted) return;

            context.read<ProductBloc>().add(const ProductEvent.fetch());
          },
          icon: const Icon(Icons.add_rounded, size: 22),
          label: const Text(
            'Tambah Produk',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // EMPTY STATE
  // ==============================================================
  Widget _buildEmptyState() {
    final bool isSearching = _searchQuery.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 45),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: primaryLight,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 36,
              color: primary,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            isSearching ? 'Produk Tidak Ditemukan' : 'Belum Ada Produk',
            style: const TextStyle(
              color: textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            isSearching
                ? 'Tidak ada produk yang sesuai dengan pencarian.'
                : 'Belum ada produk yang tersedia.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),

          if (isSearching) ...[
            const SizedBox(height: 18),
            TextButton.icon(
              onPressed: () {
                _searchController.clear();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'Reset Pencarian',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: TextButton.styleFrom(foregroundColor: primary),
            ),
          ],
        ],
      ),
    );
  }

  // ==============================================================
  // LOADING HEADER
  // ==============================================================
  Widget _buildLoadingHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 150,
          height: 22,
          decoration: BoxDecoration(
            color: borderColor,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 110,
          height: 13,
          decoration: BoxDecoration(
            color: borderColor,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // PRODUCT SKELETON
  // ==============================================================
  Widget _buildProductSkeleton() {
    return Container(
      height: 105,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: BorderRadius.circular(14),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 140,
                  height: 15,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 9),
                Container(
                  width: 90,
                  height: 12,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 110,
                  height: 14,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
