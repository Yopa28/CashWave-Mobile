import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cashwave_mobile/core/constants/colors.dart';
import 'package:cashwave_mobile/core/extensions/build_context_ext.dart';
import 'package:cashwave_mobile/presentation/draft_order/pages/draft_order_page.dart';
import 'package:cashwave_mobile/presentation/home/bloc/product/product_bloc.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../core/components/search_input.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../../data/models/response/product_response_model.dart';
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
  // STOCK CONFIG
  // ============================================================

  static const int lowStockThreshold = 5;

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
        child: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            return state.maybeWhen(
              success: (products) {
                return _buildHomeContent(products);
              },
              loading: () {
                return _buildHomeLoading();
              },
              error: (message) {
                return _buildHomeError(message);
              },
              orElse: () {
                return const SizedBox();
              },
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // HOME CONTENT
  // ============================================================

  Widget _buildHomeContent(List<Product> products) {
    final List<Product> lowStockProducts = products
        .where(
          (product) => product.stock > 0 && product.stock <= lowStockThreshold,
        )
        .toList();

    final List<Product> outOfStockProducts = products
        .where((product) => product.stock <= 0)
        .toList();

    final int totalProducts = products.length;

    final int attentionCount =
        lowStockProducts.length + outOfStockProducts.length;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        // ======================================================
        // SUBTITLE
        // ======================================================

        const Text(
          'Pilih produk untuk membuat pesanan',
          style: TextStyle(
            color: textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),

        const SizedBox(height: 20),

        // ======================================================
        // SEARCH
        // ======================================================
        _buildSearch(),

        const SizedBox(height: 20),

        // ======================================================
        // STOCK SUMMARY
        // ======================================================
        _buildStockSummary(
          totalProducts: totalProducts,
          lowStockCount: lowStockProducts.length,
          outOfStockCount: outOfStockProducts.length,
        ),

        // ======================================================
        // STOCK ALERT
        // ======================================================
        if (attentionCount > 0) ...[
          const SizedBox(height: 24),

          _buildLowStockSection(
            lowStockProducts: lowStockProducts,
            outOfStockProducts: outOfStockProducts,
          ),
        ],

        const SizedBox(height: 28),

        // ======================================================
        // CATEGORY TITLE
        // ======================================================
        _buildSectionHeader(title: 'Kategori'),

        const SizedBox(height: 14),

        // ======================================================
        // CATEGORY
        // ======================================================
        _buildCategories(),

        const SizedBox(height: 28),

        // ======================================================
        // PRODUCT HEADER
        // ======================================================
        _buildProductHeader(products.length),

        const SizedBox(height: 14),

        // ======================================================
        // PRODUCT LIST
        // ======================================================
        if (products.isEmpty)
          const ProductEmpty()
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.70,
            ),
            itemBuilder: (context, index) {
              return ProductCard(data: products[index]);
            },
          ),
      ],
    );
  }

  // ============================================================
  // STOCK SUMMARY
  // ============================================================

  Widget _buildStockSummary({
    required int totalProducts,
    required int lowStockCount,
    required int outOfStockCount,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.inventory_2_rounded,
            title: 'Total Produk',
            value: '$totalProducts',
            subtitle: 'produk tersedia',
            iconBackground: lightGreen,
            iconColor: primary,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _buildSummaryCard(
            icon: Icons.warning_amber_rounded,
            title: 'Low Stock',
            value: '$lowStockCount',
            subtitle: lowStockCount == 1
                ? 'perlu perhatian'
                : 'perlu perhatian',
            iconBackground: const Color(0xfffff4df),
            iconColor: const Color(0xffd99000),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _buildSummaryCard(
            icon: Icons.remove_shopping_cart_rounded,
            title: 'Habis',
            value: '$outOfStockCount',
            subtitle: 'stok kosong',
            iconBackground: const Color(0xffffeaea),
            iconColor: const Color(0xffd64545),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color iconBackground,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              color: textPrimary,
              fontSize: 21,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOW STOCK SECTION
  // ============================================================

  Widget _buildLowStockSection({
    required List<Product> lowStockProducts,
    required List<Product> outOfStockProducts,
  }) {
    final List<Product> attentionProducts = [
      ...outOfStockProducts,
      ...lowStockProducts,
    ];

    // Dashboard hanya menampilkan maksimal 4 produk
    final visibleProducts = attentionProducts.take(4).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ====================================================
          // HEADER
          // ====================================================

          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xfffff4df),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xffd99000),
                  size: 20,
                ),
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Perhatian Stok',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Beberapa produk perlu segera dicek',
                      style: TextStyle(color: textSecondary, fontSize: 10),
                    ),
                  ],
                ),
              ),

              if (attentionProducts.length > 4)
                TextButton(
                  onPressed: () {
                    _showAllStockAlert(
                      lowStockProducts: lowStockProducts,
                      outOfStockProducts: outOfStockProducts,
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Lihat Semua',
                    style: TextStyle(
                      color: primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          // ====================================================
          // PRODUCTS
          // ====================================================
          ...visibleProducts.map((product) => _buildStockItem(product)),
        ],
      ),
    );
  }

  // ============================================================
  // STOCK ITEM
  // ============================================================

  Widget _buildStockItem(Product product) {
    final bool isOutOfStock = product.stock <= 0;

    final Color statusColor = isOutOfStock
        ? const Color(0xffd64545)
        : const Color(0xffd99000);

    final Color statusBackground = isOutOfStock
        ? const Color(0xffffeaea)
        : const Color(0xfffff4df);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // ==================================================
          // IMAGE
          // ==================================================

          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: product.image.isNotEmpty
                  ? Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.inventory_2_outlined,
                          color: textSecondary,
                          size: 20,
                        );
                      },
                    )
                  : const Icon(
                      Icons.inventory_2_outlined,
                      color: textSecondary,
                      size: 20,
                    ),
            ),
          ),

          const SizedBox(width: 10),

          // ==================================================
          // PRODUCT INFO
          // ==================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  product.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: textSecondary, fontSize: 10),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ==================================================
          // STOCK
          // ==================================================
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${product.stock} pcs',
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 3),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBackground,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isOutOfStock ? 'Habis' : 'Low Stock',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SHOW ALL STOCK ALERT
  // ============================================================

  void _showAllStockAlert({
    required List<Product> lowStockProducts,
    required List<Product> outOfStockProducts,
  }) {
    final List<Product> products = [...outOfStockProducts, ...lowStockProducts];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.72,
          decoration: const BoxDecoration(
            color: background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),

                // Handle
                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 18),

                // Header
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xffd99000),
                        size: 23,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Perhatian Stok',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Daftar produk dengan stok menipis atau habis',
                      style: TextStyle(color: textSecondary, fontSize: 12),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      return _buildStockItem(products[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

  Widget _buildHomeLoading() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        const Text(
          'Pilih produk untuk membuat pesanan',
          style: TextStyle(color: textSecondary, fontSize: 13),
        ),

        const SizedBox(height: 20),

        _buildSearch(),

        const SizedBox(height: 40),

        const Center(
          child: Column(
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(primary),
                ),
              ),

              SizedBox(height: 12),

              Text(
                'Memuat menu...',
                style: TextStyle(color: textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildHomeError(String message) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        const Text(
          'Pilih produk untuk membuat pesanan',
          style: TextStyle(color: textSecondary, fontSize: 13),
        ),

        const SizedBox(height: 20),

        _buildSearch(),

        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.redAccent,
                  size: 27,
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
                    context.read<ProductBloc>().add(const ProductEvent.fetch());
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
        ),
      ],
    );
  }
}
