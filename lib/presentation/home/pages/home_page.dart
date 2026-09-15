import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashwave_mobile/core/constants/colors.dart';
import 'package:cashwave_mobile/core/extensions/build_context_ext.dart';
import 'package:cashwave_mobile/presentation/draft_order/pages/draft_order_page.dart';
import 'package:cashwave_mobile/presentation/home/bloc/product/product_bloc.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../core/components/search_input.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../bloc/category/category_bloc.dart';
import '../widgets/product_card.dart';
import '../widgets/product_empty.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController searchController = TextEditingController();

  // ============================================================
  // STATE
  // ============================================================

  int currentIndex = 0;

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primary = Color(0xff087A55);
  static const Color primaryDark = Color(0xff065C40);

  static const Color background = Color(0xffF7F9F8);
  static const Color cardColor = Colors.white;

  static const Color textPrimary = Color(0xff17221E);
  static const Color textSecondary = Color(0xff7A8581);

  static const Color borderColor = Color(0xffE5EBE8);
  static const Color lightGreen = Color(0xffE8F5F0);

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    // Load products
    context.read<ProductBloc>().add(const ProductEvent.fetch());

    // Load categories
    context.read<CategoryBloc>().add(const CategoryEvent.getCategoriesLocal());

    // Connect printer
    _connectPrinter();
  }

  // ============================================================
  // PRINTER
  // ============================================================

  Future<void> _connectPrinter() async {
    try {
      final printerAddress = await AuthLocalDatasource().getPrinter();

      if (printerAddress.isNotEmpty) {
        await PrintBluetoothThermal.connect(macPrinterAddress: printerAddress);
      }
    } catch (e) {
      debugPrint('Printer connection error: $e');
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // CATEGORY
  // ============================================================

  void onCategoryTap(int index) {
    setState(() {
      currentIndex = index;
    });

    searchController.clear();

    switch (index) {
      case 0:
        context.read<ProductBloc>().add(const ProductEvent.fetch());
        break;

      case 1:
        context.read<ProductBloc>().add(
          const ProductEvent.fetchByCategory('minuman'),
        );
        break;

      case 2:
        context.read<ProductBloc>().add(
          const ProductEvent.fetchByCategory('makanan'),
        );
        break;

      case 3:
        context.read<ProductBloc>().add(
          const ProductEvent.fetchByCategory('snack'),
        );
        break;
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void onSearchChanged(String value) {
    if (value.length > 3) {
      context.read<ProductBloc>().add(ProductEvent.searchProduct(value));
    }

    if (value.isEmpty) {
      context.read<ProductBloc>().add(const ProductEvent.fetchAllFromState());
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,

        // Tidak ada logo CashWave
        title: const Text(
          'Menu Cafe',
          style: TextStyle(
            color: textPrimary,
            fontSize: 21,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),

        centerTitle: false,

        actions: [
          // Draft Order
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              splashRadius: 22,
              onPressed: () {
                context.push(const DraftOrderPage());
              },
              icon: const Icon(
                Icons.receipt_long_rounded,
                color: primary,
                size: 22,
              ),
            ),
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: SafeArea(
        top: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),

          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),

          children: [
            // ==================================================
            // SUBTITLE
            // ==================================================

            const Text(
              'Pilih produk untuk membuat pesanan',
              style: TextStyle(
                color: textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // SEARCH
            // ==================================================
            _buildSearch(),

            const SizedBox(height: 28),

            // ==================================================
            // CATEGORY TITLE
            // ==================================================
            _buildSectionHeader(title: 'Kategori'),

            const SizedBox(height: 14),

            // ==================================================
            // CATEGORY
            // ==================================================
            _buildCategories(),

            const SizedBox(height: 28),

            // ==================================================
            // PRODUCT HEADER
            // ==================================================
            BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                return state.maybeWhen(
                  success: (products) {
                    return _buildProductHeader(products.length);
                  },
                  orElse: () {
                    return _buildSectionHeader(title: 'Daftar Menu');
                  },
                );
              },
            ),

            const SizedBox(height: 14),

            // ==================================================
            // PRODUCT LIST
            // ==================================================
            BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                return state.maybeWhen(
                  // ============================================
                  // LOADING
                  // ============================================

                  loading: () {
                    return _buildLoading();
                  },

                  // ============================================
                  // ERROR
                  // ============================================
                  error: (message) {
                    return _buildError(message);
                  },

                  // ============================================
                  // SUCCESS
                  // ============================================
                  success: (products) {
                    if (products.isEmpty) {
                      return const ProductEmpty();
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),

                      itemCount: products.length,

                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,

                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,

                            // Card lebih proporsional
                            childAspectRatio: 0.70,
                          ),

                      itemBuilder: (context, index) {
                        return ProductCard(data: products[index]);
                      },
                    );
                  },

                  // ============================================
                  // DEFAULT
                  // ============================================
                  orElse: () {
                    return const SizedBox();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearch() {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: borderColor, width: 1),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: SearchInput(
        controller: searchController,
        onChanged: onSearchChanged,
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader({required String title}) {
    return Text(
      title,
      style: const TextStyle(
        color: textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
    );
  }

  // ============================================================
  // PRODUCT HEADER
  // ============================================================

  Widget _buildProductHeader(int productCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Daftar Menu',
          style: TextStyle(
            color: textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),

        // Product count
        Text(
          '$productCount produk',
          style: const TextStyle(
            color: textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CATEGORIES
  // ============================================================

  Widget _buildCategories() {
    return SizedBox(
      height: 76,

      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),

        children: [
          _categoryCard(index: 0, icon: Icons.apps_rounded, label: 'Semua'),

          const SizedBox(width: 10),

          _categoryCard(
            index: 1,
            icon: Icons.local_cafe_rounded,
            label: 'Minuman',
          ),

          const SizedBox(width: 10),

          _categoryCard(
            index: 2,
            icon: Icons.restaurant_rounded,
            label: 'Makanan',
          ),

          const SizedBox(width: 10),

          _categoryCard(index: 3, icon: Icons.fastfood_rounded, label: 'Snack'),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORY CARD
  // ============================================================

  Widget _categoryCard({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () {
        onCategoryTap(index);
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),

        curve: Curves.easeOut,

        width: 90,

        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),

        decoration: BoxDecoration(
          color: isActive ? primary : Colors.white,

          borderRadius: BorderRadius.circular(14),

          border: Border.all(color: isActive ? primary : borderColor),

          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: primary.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(icon, size: 23, color: isActive ? Colors.white : primary),

            const SizedBox(height: 6),

            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,

              style: TextStyle(
                color: isActive ? Colors.white : textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoading() {
    return Padding(
      padding: const EdgeInsets.only(top: 50),

      child: Column(
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(primary),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Memuat menu...',
            style: TextStyle(color: textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(String message) {
    return Container(
      margin: const EdgeInsets.only(top: 10),

      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: borderColor),
      ),

      child: Column(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,

            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 25,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Gagal memuat menu',
            style: TextStyle(
              color: textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            message,
            textAlign: TextAlign.center,

            style: const TextStyle(color: textSecondary, fontSize: 12),
          ),

          const SizedBox(height: 15),

          SizedBox(
            height: 38,

            child: ElevatedButton(
              onPressed: () {
                onCategoryTap(currentIndex);
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                elevation: 0,

                padding: const EdgeInsets.symmetric(horizontal: 18),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              child: const Text(
                'Coba Lagi',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
