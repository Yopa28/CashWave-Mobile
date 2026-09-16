import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashwave_mobile/core/extensions/build_context_ext.dart';
import 'package:cashwave_mobile/presentation/draft_order/pages/draft_order_page.dart';
import 'package:cashwave_mobile/presentation/home/bloc/product/product_bloc.dart';
import 'package:cashwave_mobile/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../core/components/search_input.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../../data/models/response/dashboard_response_model.dart';
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
  final TextEditingController searchController = TextEditingController();

  int currentIndex = 0;

  static const int lowStockThreshold = 5;

  static const Color primary = Color(0xff087A55);
  static const Color primaryDark = Color(0xff065C40);
  static const Color background = Color(0xffF7F9F8);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xff17221E);
  static const Color textSecondary = Color(0xff7A8581);
  static const Color borderColor = Color(0xffE5EBE8);
  static const Color lightGreen = Color(0xffE8F5F0);

  @override
  void initState() {
    super.initState();

    context.read<ProductBloc>().add(const ProductEvent.fetch());
    context.read<CategoryBloc>().add(const CategoryEvent.getCategoriesLocal());

    _connectPrinter();
  }

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

  void _refreshHome() {
    context.read<DashboardBloc>().add(const DashboardEvent.fetch());

    context.read<ProductBloc>().add(const ProductEvent.fetch());

    searchController.clear();

    setState(() {
      currentIndex = 0;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

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

  void onSearchChanged(String value) {
    if (value.length > 3) {
      context.read<ProductBloc>().add(ProductEvent.searchProduct(value));
    }

    if (value.isEmpty) {
      context.read<ProductBloc>().add(const ProductEvent.fetchAllFromState());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Menu Cafe',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 21,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
        actions: [
          BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              final isLoading = state.maybeWhen(
                loading: () => true,
                orElse: () => false,
              );

              return Container(
                margin: const EdgeInsets.only(right: 8),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: isLoading ? null : _refreshHome,
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(primary),
                          ),
                        )
                      : const Icon(
                          Icons.refresh_rounded,
                          color: primary,
                          size: 22,
                        ),
                ),
              );
            },
          ),
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
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: primary,
          onRefresh: () async {
            _refreshHome();
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              const Text(
                'Pilih produk untuk membuat pesanan',
                style: TextStyle(color: textSecondary, fontSize: 13),
              ),

              const SizedBox(height: 18),

              _buildDashboard(),

              const SizedBox(height: 20),

              _buildSearch(),

              const SizedBox(height: 24),

              _buildProductContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return state.maybeWhen(
          initial: () => const SizedBox.shrink(),
          loading: () => _buildDashboardLoading(),
          success: (data) => _buildDashboardContent(data),
          error: (message) => _buildDashboardError(message),
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildDashboardContent(DashboardResponseModel response) {
    final dashboard = response.data;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSalesCard(dashboard.today),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildDashboardStatCard(
                icon: Icons.receipt_long_rounded,
                iconBackground: lightGreen,
                iconColor: primary,
                value: '${dashboard.today.transactions}',
                title: 'Transaksi',
                subtitle: 'hari ini',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildDashboardStatCard(
                icon: Icons.shopping_bag_rounded,
                iconBackground: const Color(0xffEAF1FF),
                iconColor: const Color(0xff4D7CFE),
                value: '${dashboard.today.items}',
                title: 'Item Terjual',
                subtitle: 'hari ini',
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        _buildProductStockDashboard(dashboard.products),

        if (dashboard.recentOrders.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildRecentOrders(dashboard.recentOrders),
        ],
      ],
    );
  }

  Widget _buildSalesCard(TodaySales today) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primary, primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.payments_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Penjualan Hari Ini',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatRupiah(today.sales),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${today.transactions} transaksi • ${today.items} item terjual',
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardStatCard({
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    required String value,
    required String title,
    required String subtitle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  title,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductStockDashboard(ProductStockSummary products) {
    return Row(
      children: [
        Expanded(
          child: _buildStockDashboardCard(
            icon: Icons.inventory_2_rounded,
            iconBackground: lightGreen,
            iconColor: primary,
            value: '${products.total}',
            title: 'Total Produk',
            subtitle: 'produk',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStockDashboardCard(
            icon: Icons.warning_amber_rounded,
            iconBackground: const Color(0xfffff4df),
            iconColor: const Color(0xffd99000),
            value: '${products.lowStock}',
            title: 'Low Stock',
            subtitle: 'perlu perhatian',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStockDashboardCard(
            icon: Icons.remove_shopping_cart_rounded,
            iconBackground: const Color(0xffffeaea),
            iconColor: const Color(0xffd64545),
            value: '${products.outOfStock}',
            title: 'Habis',
            subtitle: 'stok kosong',
          ),
        ),
      ],
    );
  }

  Widget _buildStockDashboardCard({
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    required String value,
    required String title,
    required String subtitle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
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
          const SizedBox(height: 9),
          Text(
            value,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 8),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders(List<RecentOrder> orders) {
    final visibleOrders = orders.take(5).toList();
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
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
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: primary,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaksi Terbaru',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Aktivitas transaksi terbaru',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(visibleOrders.length, (index) {
            final order = visibleOrders[index];

            return Column(
              children: [
                _buildRecentOrderItem(order),
                if (index != visibleOrders.length - 1)
                  const Divider(height: 18, color: borderColor),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecentOrderItem(RecentOrder order) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.shopping_bag_outlined,
            color: primary,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.orderNumber.isEmpty
                    ? 'Transaksi #${order.id}'
                    : order.orderNumber,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${order.totalItem} item • ${_paymentLabel(order.paymentMethod)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatRupiah(order.totalPrice),
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (order.transactionTime != null) ...[
              const SizedBox(height: 3),
              Text(
                _formatTime(order.transactionTime!),
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 8,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildDashboardLoading() {
    return Column(
      children: [
        _buildLoadingBox(height: 110, radius: 18),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildLoadingBox(height: 82, radius: 16)),
            const SizedBox(width: 10),
            Expanded(child: _buildLoadingBox(height: 82, radius: 16)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildLoadingBox(height: 125, radius: 16)),
            const SizedBox(width: 10),
            Expanded(child: _buildLoadingBox(height: 125, radius: 16)),
            const SizedBox(width: 10),
            Expanded(child: _buildLoadingBox(height: 125, radius: 16)),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingBox({required double height, required double radius}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(primary),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardError(String message) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xffffeaea),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.cloud_off_rounded,
              color: Color(0xffd64545),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard tidak tersedia',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(9),
            onTap: () {
              context.read<DashboardBloc>().add(const DashboardEvent.fetch());
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Text(
                'Coba Lagi',
                style: TextStyle(
                  color: primary,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductContent() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        return state.maybeWhen(
          success: (products) {
            return _buildProductSuccess(products);
          },
          loading: () {
            return _buildProductLoading();
          },
          error: (message) {
            return _buildProductError(message);
          },
          orElse: () {
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget _buildProductSuccess(List<Product> products) {
    final lowStockProducts = products
        .where(
          (product) => product.stock > 0 && product.stock <= lowStockThreshold,
        )
        .toList();

    final outOfStockProducts = products
        .where((product) => product.stock <= 0)
        .toList();

    final attentionCount = lowStockProducts.length + outOfStockProducts.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (attentionCount > 0) ...[
          _buildLowStockSection(
            lowStockProducts: lowStockProducts,
            outOfStockProducts: outOfStockProducts,
          ),
          const SizedBox(height: 26),
        ],

        _buildSectionHeader(title: 'Kategori'),

        const SizedBox(height: 14),

        _buildCategories(),

        const SizedBox(height: 26),

        _buildProductHeader(products.length),

        const SizedBox(height: 14),

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

  Widget _buildLowStockSection({
    required List<Product> lowStockProducts,
    required List<Product> outOfStockProducts,
  }) {
    final attentionProducts = [...outOfStockProducts, ...lowStockProducts];

    final visibleProducts = attentionProducts.take(4).toList();
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Perhatian Stok',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Beberapa produk perlu segera dicek',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
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
          ...visibleProducts.map((product) => _buildStockItem(product)),
        ],
      ),
    );
  }

  Widget _buildStockItem(Product product) {
    final isOutOfStock = product.stock <= 0;
    final colorScheme = Theme.of(context).colorScheme;

    final statusColor = isOutOfStock
        ? const Color(0xffd64545)
        : const Color(0xffd99000);

    final statusBackground = isOutOfStock
        ? const Color(0xffffeaea)
        : const Color(0xfffff4df);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colorScheme.outlineVariant),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  product.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
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

  void _showAllStockAlert({
    required List<Product> lowStockProducts,
    required List<Product> outOfStockProducts,
  }) {
    final products = [...outOfStockProducts, ...lowStockProducts];

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
                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 18),
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

  Widget _buildSearch() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
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

  Widget _categoryCard({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isActive = currentIndex == index;
    final colorScheme = Theme.of(context).colorScheme;

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
          color: isActive ? primary : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? primary : colorScheme.outlineVariant,
          ),
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
                color: isActive ? Colors.white : colorScheme.onSurface,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductLoading() {
    return Column(
      children: [
        _buildLoadingBox(height: 90, radius: 16),
        const SizedBox(height: 20),
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

  Widget _buildProductError(String message) {
    return Container(
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
    );
  }

  String _formatRupiah(int value) {
    final formatted = value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match.group(1)}.',
    );

    return 'Rp $formatted';
  }

  String _paymentLabel(String value) {
    if (value.isEmpty) {
      return 'Pembayaran';
    }

    final normalized = value.toLowerCase();

    switch (normalized) {
      case 'cash':
      case 'tunai':
        return 'Tunai';

      case 'qris':
        return 'QRIS';

      case 'transfer':
      case 'bank_transfer':
        return 'Transfer';

      case 'debit':
        return 'Debit';

      case 'credit':
      case 'credit_card':
        return 'Kartu Kredit';

      default:
        return value;
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }
}
