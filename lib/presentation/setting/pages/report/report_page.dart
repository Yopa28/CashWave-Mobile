import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart' as hdt;
import 'package:intl/intl.dart';

import 'package:cashwave_mobile/core/extensions/build_context_ext.dart';
import 'package:cashwave_mobile/core/extensions/int_ext.dart';

import 'package:cashwave_mobile/data/models/response/product_sales_report.dart';
import 'package:cashwave_mobile/data/models/response/summary_response_model.dart';

import 'package:cashwave_mobile/presentation/setting/bloc/report/product_sales/product_sales_bloc.dart';
import 'package:cashwave_mobile/presentation/setting/bloc/report/summary/summary_bloc.dart';

import 'utils/helper_pdf_service.dart';
import 'utils/invoice.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primary = Color(0xff087A55);
  static const Color primaryDark = Color(0xff065C40);
  static const Color primaryLight = Color(0xffE8F5F0);

  static const Color background = Color(0xffF7F9F8);
  static const Color card = Color(0xffFFFFFF);

  static const Color textPrimary = Color(0xff17221E);
  static const Color textSecondary = Color(0xff7A8581);

  static const Color borderColor = Color(0xffE5EBE8);

  static const Color danger = Color(0xffD9534F);
  static const Color dangerLight = Color(0xffFFF1F0);

  // ============================================================
  // DATE
  // ============================================================

  DateTime selectedStartDate = DateTime.now().subtract(const Duration(days: 1));

  DateTime selectedEndDate = DateTime.now();

  // ============================================================
  // DATA
  // ============================================================

  List<ProductSales> productSales = [];

  Summary? summary;

  // ============================================================
  // STATE
  // ============================================================

  bool isFiltering = false;
  bool isExporting = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReport();
    });
  }

  // ============================================================
  // LOAD REPORT
  // ============================================================

  void _loadReport() {
    final String startDate = DateFormat('yyyy-MM-dd').format(selectedStartDate);

    final String endDate = DateFormat('yyyy-MM-dd').format(selectedEndDate);

    context.read<SummaryBloc>().add(
      SummaryEvent.getSummary(startDate, endDate),
    );

    context.read<ProductSalesBloc>().add(
      ProductSalesEvent.getProductSales(startDate, endDate),
    );
  }

  // ============================================================
  // START DATE
  // ============================================================

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedStartDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: Theme.of(context).colorScheme),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      selectedStartDate = picked;
    });
  }

  // ============================================================
  // END DATE
  // ============================================================

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedEndDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: Theme.of(context).colorScheme),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      selectedEndDate = picked;
    });
  }

  // ============================================================
  // APPLY FILTER
  // ============================================================

  void _applyFilter() {
    if (selectedStartDate.isAfter(selectedEndDate)) {
      _showSnackBar(
        'Tanggal mulai tidak boleh lebih besar dari tanggal akhir.',
        isError: true,
      );

      return;
    }

    setState(() {
      isFiltering = true;
      summary = null;
      productSales = [];
    });

    _loadReport();
  }

  // ============================================================
  // EXPORT PDF
  // ============================================================

  Future<void> _generatePdf() async {
    if (isExporting) return;

    if (productSales.isEmpty || summary == null) {
      _showSnackBar('Data laporan belum tersedia.', isError: true);

      return;
    }

    setState(() {
      isExporting = true;
    });

    try {
      log('Generating PDF report...');

      final pdfFile = await Invoice.generate(
        productSales,
        summary!,
        startDate: selectedStartDate,
        endDate: selectedEndDate,
      );

      log('PDF file: $pdfFile');

      await HelperPdfService.openFile(pdfFile);

      if (!mounted) return;

      _showSnackBar('Laporan PDF berhasil dibuat.');
    } catch (e, stackTrace) {
      log('Generate PDF error: $e', stackTrace: stackTrace);

      if (!mounted) return;

      _showSnackBar('Gagal membuat PDF laporan.', isError: true);
    } finally {
      if (!mounted) return;

      setState(() {
        isExporting = false;
      });
    }
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          backgroundColor: isError ? danger : primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 21,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  // ============================================================
  // DATE CARD
  // ============================================================

  Widget _buildDateCard({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_today_rounded,
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
                        label,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        DateFormat('dd MMM yyyy').format(date),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 4),

                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FILTER SECTION
  // ============================================================

  Widget _buildFilterSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_alt_outlined, color: primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Periode Laporan',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          Text(
            'Pilih periode transaksi yang ingin ditampilkan.',
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              _buildDateCard(
                label: 'Tanggal Mulai',
                date: selectedStartDate,
                onTap: _selectStartDate,
              ),

              const SizedBox(width: 10),

              _buildDateCard(
                label: 'Tanggal Akhir',
                date: selectedEndDate,
                onTap: _selectEndDate,
              ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isFiltering ? null : _applyFilter,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                disabledBackgroundColor: primary.withOpacity(0.5),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isFiltering
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_rounded, size: 19),
                        SizedBox(width: 8),
                        Text(
                          'Tampilkan Laporan',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
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
  // SUMMARY HEADER
  // ============================================================

  Widget _buildSummaryHeader() {
    return const Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ringkasan',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Performa penjualan pada periode terpilih',
                style: TextStyle(color: textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
        Icon(Icons.analytics_outlined, color: primary, size: 24),
      ],
    );
  }

  // ============================================================
  // REVENUE CARD
  // ============================================================

  Widget _buildRevenueCard(Summary data) {
    final int revenue = int.tryParse(data.totalRevenue.toString()) ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.payments_outlined,
              color: Colors.white,
              size: 25,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Revenue',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  revenue.currencyFormatRp,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
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
  // SOLD ITEM CARD
  // ============================================================

  Widget _buildSoldItemCard(Summary data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: primary,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Text(
              'Produk Terjual',
              style: TextStyle(
                color: textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Text(
            '${data.totalSoldQuantity} item',
            style: const TextStyle(
              color: primary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: BlocBuilder<SummaryBloc, SummaryState>(
        builder: (context, state) {
          return state.maybeWhen(
            success: (data) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryHeader(),

                  const SizedBox(height: 16),

                  _buildRevenueCard(data.data),

                  const SizedBox(height: 10),

                  _buildSoldItemCard(data.data),
                ],
              );
            },

            error: (message) {
              return _buildErrorState(message);
            },

            orElse: () {
              return const SizedBox(
                height: 150,
                child: Center(child: CircularProgressIndicator(color: primary)),
              );
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // PRODUCT SALES HEADER
  // ============================================================

  Widget _buildProductSalesHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Penjualan Produk',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),

              SizedBox(height: 3),

              Text(
                'Detail produk yang terjual',
                style: TextStyle(color: textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),

        if (productSales.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${productSales.length} produk',
              style: const TextStyle(
                color: primary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // PRODUCT SALES CARD
  // ============================================================

  Widget _buildProductSalesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductSalesHeader(),

          const SizedBox(height: 16),

          BlocBuilder<ProductSalesBloc, ProductSalesState>(
            builder: (context, state) {
              return state.maybeWhen(
                success: (data) {
                  if (data.data.isEmpty) {
                    return _buildEmptyProductSales();
                  }

                  int totalQty = 0;
                  int totalPrice = 0;

                  for (final element in data.data) {
                    totalPrice +=
                        int.tryParse(element.totalPrice.toString()) ?? 0;

                    totalQty +=
                        int.tryParse(element.totalQuantity.toString()) ?? 0;
                  }

                  return Column(
                    children: [
                      tableProductSales(data),

                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          color: background,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),

                            const Spacer(),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: primaryLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$totalQty item',
                                style: const TextStyle(
                                  color: primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Text(
                              totalPrice.currencyFormatRp,
                              style: const TextStyle(
                                color: primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },

                error: (message) {
                  return _buildErrorState(message);
                },

                orElse: () {
                  return const SizedBox(
                    height: 180,
                    child: Center(
                      child: CircularProgressIndicator(color: primary),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY PRODUCT SALES
  // ============================================================

  Widget _buildEmptyProductSales() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.bar_chart_rounded,
              color: primary,
              size: 32,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'Belum Ada Penjualan',
            style: TextStyle(
              color: textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Tidak ada transaksi pada periode ini.',
            textAlign: TextAlign.center,
            style: TextStyle(color: textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: dangerLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: danger.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, color: danger, size: 30),

          const SizedBox(height: 10),

          const Text(
            'Gagal Memuat Data',
            style: TextStyle(
              color: textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABLE HEADER
  // ============================================================

  List<Widget> _getTitleHeaderWidget() {
    return [
      _getTitleItemWidget('No', 58),
      _getTitleItemWidget('ID', 58),
      _getTitleItemWidget('Product', 140),
      _getTitleItemWidget('Price', 140),
      _getTitleItemWidget('Quantity', 80),
      _getTitleItemWidget('Total', 140),
    ];
  }

  // ============================================================
  // TABLE HEADER ITEM
  // ============================================================

  Widget _getTitleItemWidget(String label, double width) {
    return Container(
      width: width,
      height: 56,
      color: primary,
      alignment: Alignment.center,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ============================================================
  // TABLE
  // ============================================================

  Widget tableProductSales(ProductSalesResponseModel data) {
    const double itemHeight = 55.0;
    final colorScheme = Theme.of(context).colorScheme;

    final double tableHeight = itemHeight * data.data.length;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: tableHeight + itemHeight,
        child: hdt.HorizontalDataTable(
          leftHandSideColumnWidth: 58,
          rightHandSideColumnWidth: 558,
          isFixedHeader: true,

          headerWidgets: _getTitleHeaderWidget(),

          // ==================================================
          // LEFT COLUMN
          // ==================================================
          leftSideItemBuilder: (context, index) {
            return Container(
              width: 58,
              height: 52,
              color: Colors.white,
              alignment: Alignment.center,
              child: Text(
                (index + 1).toString(),
                style: const TextStyle(
                  color: textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },

          // ==================================================
          // RIGHT COLUMN
          // ==================================================
          rightSideItemBuilder: (context, index) {
            final item = data.data[index];

            final int price = int.tryParse(item.productPrice.toString()) ?? 0;

            final int quantity =
                int.tryParse(item.totalQuantity.toString()) ?? 0;

            final int totalPrice =
                int.tryParse(item.totalPrice.toString()) ?? 0;

            return Container(
              color: Colors.white,
              child: Row(
                children: [
                  // ID

                  _buildTableCell(width: 58, value: item.productId.toString()),

                  // PRODUCT
                  _buildTableCell(
                    width: 140,
                    value: item.productName,
                    alignLeft: true,
                  ),

                  // PRICE
                  _buildTableCell(width: 140, value: price.currencyFormatRp),

                  // QUANTITY
                  _buildTableCell(width: 80, value: quantity.toString()),

                  // TOTAL
                  _buildTableCell(
                    width: 140,
                    value: totalPrice.currencyFormatRp,
                    isTotal: true,
                  ),
                ],
              ),
            );
          },

          itemCount: data.data.length,

          rowSeparatorWidget: const Divider(
            color: borderColor,
            height: 1,
            thickness: 1,
          ),

          leftHandSideColBackgroundColor: colorScheme.surfaceContainerHighest,

          rightHandSideColBackgroundColor: colorScheme.surfaceContainerHighest,

          itemExtent: 55,
        ),
      ),
    );
  }

  // ============================================================
  // TABLE CELL
  // ============================================================

  Widget _buildTableCell({
    required double width,
    required String value,
    bool isTotal = false,
    bool alignLeft = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: width,
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: alignLeft ? Alignment.centerLeft : Alignment.center,
      child: Text(
        value,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: alignLeft ? TextAlign.left : TextAlign.center,
        style: TextStyle(
          color: isTotal ? primary : colorScheme.onSurface,
          fontSize: 10,
          fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
    );
  }

  // ============================================================
  // EXPORT BUTTON
  // ============================================================

  Widget _buildExportButton() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: const Border(top: BorderSide(color: borderColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: isExporting ? null : _generatePdf,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              disabledBackgroundColor: primary.withOpacity(0.6),
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white70,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: isExporting
                ? const SizedBox(
                    width: 21,
                    height: 21,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.picture_as_pdf_rounded, size: 21),
                      SizedBox(width: 9),
                      Text(
                        'Export Laporan PDF',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // ======================================================
        // SUMMARY LISTENER
        // ======================================================

        BlocListener<SummaryBloc, SummaryState>(
          listener: (context, state) {
            state.maybeWhen(
              success: (data) {
                if (!mounted) return;

                setState(() {
                  summary = data.data;
                  isFiltering = false;
                });
              },
              error: (message) {
                if (!mounted) return;

                setState(() {
                  isFiltering = false;
                });
              },
              orElse: () {},
            );
          },
        ),

        // ======================================================
        // PRODUCT SALES LISTENER
        // ======================================================
        BlocListener<ProductSalesBloc, ProductSalesState>(
          listener: (context, state) {
            state.maybeWhen(
              success: (data) {
                if (!mounted) return;

                setState(() {
                  productSales = data.data;
                  isFiltering = false;
                });
              },
              error: (message) {
                if (!mounted) return;

                setState(() {
                  isFiltering = false;
                });
              },
              orElse: () {},
            );
          },
        ),
      ],

      child: Scaffold(
        backgroundColor: background,

        // ======================================================
        // APP BAR
        // ======================================================
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,

          leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(Icons.arrow_back_rounded, color: textPrimary),
          ),

          titleSpacing: 0,

          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Report',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              SizedBox(height: 2),

              Text(
                'Laporan penjualan cafe',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          actions: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: isExporting ? null : _generatePdf,
                icon: isExporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: primary,
                        ),
                      )
                    : const Icon(
                        Icons.picture_as_pdf_outlined,
                        color: primary,
                        size: 21,
                      ),
                tooltip: 'Export PDF',
              ),
            ),
          ],
        ),

        // ======================================================
        // BODY
        // ======================================================
        body: RefreshIndicator(
          color: primary,

          onRefresh: () async {
            if (isFiltering) return;

            setState(() {
              isFiltering = true;
              summary = null;
              productSales = [];
            });

            _loadReport();
          },

          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),

            padding: const EdgeInsets.fromLTRB(16, 18, 16, 110),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // FILTER

                _buildFilterSection(),

                const SizedBox(height: 18),

                // SUMMARY
                _buildSummaryCard(),

                const SizedBox(height: 18),

                // PRODUCT SALES
                _buildProductSalesCard(),
              ],
            ),
          ),
        ),

        // ======================================================
        // EXPORT
        // ======================================================
        bottomNavigationBar: _buildExportButton(),
      ),
    );
  }
}
