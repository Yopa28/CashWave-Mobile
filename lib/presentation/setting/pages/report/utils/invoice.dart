import 'dart:io';

import 'package:cashwave_mobile/core/extensions/int_ext.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../../data/models/response/product_sales_report.dart';
import '../../../../../data/models/response/summary_response_model.dart';
import 'helper_pdf_service.dart';

class Invoice {
  static const PdfColor primary = PdfColor.fromInt(0xff087A55);
  static const PdfColor primaryDark = PdfColor.fromInt(0xff065C40);
  static const PdfColor primaryLight = PdfColor.fromInt(0xffE8F5F0);

  static const PdfColor background = PdfColor.fromInt(0xffF7F9F8);
  static const PdfColor textPrimary = PdfColor.fromInt(0xff17221E);
  static const PdfColor textSecondary = PdfColor.fromInt(0xff7A8581);
  static const PdfColor borderColor = PdfColor.fromInt(0xffE5EBE8);

  static int _toInt(dynamic value) {
    if (value is int) return value;

    if (value is double) {
      return value.toInt();
    }

    final text = value.toString();

    final cleaned = text.replaceAll(RegExp(r'[^0-9-]'), '');

    return int.tryParse(cleaned) ?? 0;
  }

  static Future<File> generate(
    List<ProductSales> itemSales,
    Summary summary, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final pdf = pw.Document();

    final reportStart = startDate ?? DateTime.now();
    final reportEnd = endDate ?? DateTime.now();

    final dateFormat = DateFormat('dd MMM yyyy');

    final totalRevenue = _toInt(summary.totalRevenue);
    final totalSold = _toInt(summary.totalSoldQuantity);

    int totalProductRevenue = 0;
    int totalQuantity = 0;

    for (final item in itemSales) {
      totalProductRevenue += _toInt(item.totalPrice);
      totalQuantity += _toInt(item.totalQuantity);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(32, 32, 32, 42),
        theme: pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
          bold: pw.Font.helveticaBold(),
        ),
        build: (context) {
          return [
            _buildHeader(reportStart: reportStart, reportEnd: reportEnd),

            pw.SizedBox(height: 24),

            _buildSummary(
              revenue: totalRevenue,
              soldItems: totalSold,
              productCount: itemSales.length,
            ),

            pw.SizedBox(height: 28),

            _buildSectionTitle(
              title: 'Penjualan Produk',
              subtitle: 'Detail produk yang terjual pada periode laporan',
            ),

            pw.SizedBox(height: 12),

            _buildProductTable(itemSales),

            pw.SizedBox(height: 14),

            _buildTableSummary(
              totalQuantity: totalQuantity,
              totalRevenue: totalProductRevenue,
            ),

            pw.SizedBox(height: 24),

            _buildReportNote(),
          ];
        },
        footer: (context) {
          return _buildFooter(context);
        },
      ),
    );

    return HelperPdfService.saveDocument(
      name:
          'CashWave_Report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf',
      pdf: pdf,
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  static pw.Widget _buildHeader({
    required DateTime reportStart,
    required DateTime reportEnd,
  }) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: primary,
        borderRadius: pw.BorderRadius.circular(16),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'CashWave',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 26,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 4),

                pw.Text(
                  'Sales Report',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 12),

                pw.Text(
                  'Periode Laporan',
                  style: pw.TextStyle(color: PdfColors.white, fontSize: 8),
                ),

                pw.SizedBox(height: 3),

                pw.Text(
                  '${dateFormat.format(reportStart)} - ${dateFormat.format(reportEnd)}',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          pw.Container(
            width: 58,
            height: 58,
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(14),
            ),
            alignment: pw.Alignment.center,
            child: pw.Text(
              'CW',
              style: pw.TextStyle(
                color: primary,
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  static pw.Widget _buildSummary({
    required int revenue,
    required int soldItems,
    required int productCount,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          title: 'Ringkasan Laporan',
          subtitle: 'Ikhtisar penjualan pada periode yang dipilih',
        ),

        pw.SizedBox(height: 12),

        pw.Row(
          children: [
            pw.Expanded(
              child: _summaryCard(
                title: 'Total Revenue',
                value: revenue.currencyFormatRp,
                icon: 'Rp',
              ),
            ),

            pw.SizedBox(width: 10),

            pw.Expanded(
              child: _summaryCard(
                title: 'Produk Terjual',
                value: '$soldItems item',
                icon: 'QTY',
              ),
            ),

            pw.SizedBox(width: 10),

            pw.Expanded(
              child: _summaryCard(
                title: 'Jenis Produk',
                value: '$productCount produk',
                icon: 'PRD',
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _summaryCard({
    required String title,
    required String value,
    required String icon,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: primaryLight,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: borderColor, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 30,
            height: 30,
            decoration: pw.BoxDecoration(
              color: primary,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            alignment: pw.Alignment.center,
            child: pw.Text(
              icon,
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: icon.length > 2 ? 6 : 9,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),

          pw.SizedBox(height: 9),

          pw.Text(
            title,
            style: pw.TextStyle(color: textSecondary, fontSize: 8),
          ),

          pw.SizedBox(height: 3),

          pw.Text(
            value,
            maxLines: 1,
            style: pw.TextStyle(
              color: textPrimary,
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  static pw.Widget _buildSectionTitle({
    required String title,
    required String subtitle,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            color: textPrimary,
            fontSize: 15,
            fontWeight: pw.FontWeight.bold,
          ),
        ),

        pw.SizedBox(height: 3),

        pw.Text(
          subtitle,
          style: pw.TextStyle(color: textSecondary, fontSize: 8),
        ),
      ],
    );
  }

  // ============================================================
  // PRODUCT TABLE
  // ============================================================

  static pw.Widget _buildProductTable(List<ProductSales> itemSales) {
    final headers = ['No', 'ID', 'Produk', 'Harga', 'Qty', 'Total'];

    final data = List.generate(itemSales.length, (index) {
      final item = itemSales[index];

      final price = _toInt(item.productPrice);
      final quantity = _toInt(item.totalQuantity);
      final total = _toInt(item.totalPrice);

      return [
        '${index + 1}',
        item.productId.toString(),
        item.productName.toString(),
        price.currencyFormatRp,
        quantity.toString(),
        total.currencyFormatRp,
      ];
    });

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,

      border: pw.TableBorder.all(color: borderColor, width: 0.5),

      headerDecoration: const pw.BoxDecoration(color: primary),

      headerStyle: pw.TextStyle(
        color: PdfColors.white,
        fontSize: 8,
        fontWeight: pw.FontWeight.bold,
      ),

      cellStyle: pw.TextStyle(color: textPrimary, fontSize: 8),

      cellHeight: 28,

      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),

      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.center,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.center,
        5: pw.Alignment.centerRight,
      },

      columnWidths: {
        0: const pw.FixedColumnWidth(28),
        1: const pw.FixedColumnWidth(40),
        2: const pw.FlexColumnWidth(3),
        3: const pw.FlexColumnWidth(2),
        4: const pw.FixedColumnWidth(38),
        5: const pw.FlexColumnWidth(2),
      },
    );
  }

  // ============================================================
  // TABLE SUMMARY
  // ============================================================

  static pw.Widget _buildTableSummary({
    required int totalQuantity,
    required int totalRevenue,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: pw.BoxDecoration(
        color: background,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: borderColor, width: 0.5),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Row(
              children: [
                pw.Text(
                  'Total Quantity',
                  style: pw.TextStyle(color: textSecondary, fontSize: 8),
                ),
                pw.SizedBox(width: 6),
                pw.Text(
                  '$totalQuantity item',
                  style: pw.TextStyle(
                    color: textPrimary,
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          pw.Container(width: 1, height: 20, color: borderColor),

          pw.SizedBox(width: 14),

          pw.Row(
            children: [
              pw.Text(
                'Total',
                style: pw.TextStyle(color: textSecondary, fontSize: 8),
              ),

              pw.SizedBox(width: 6),

              pw.Text(
                totalRevenue.currencyFormatRp,
                style: pw.TextStyle(
                  color: primary,
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NOTE
  // ============================================================

  static pw.Widget _buildReportNote() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: primaryLight,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 22,
            height: 22,
            decoration: pw.BoxDecoration(
              color: primary,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            alignment: pw.Alignment.center,
            child: pw.Text(
              'i',
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),

          pw.SizedBox(width: 8),

          pw.Expanded(
            child: pw.Text(
              'Laporan ini dibuat secara otomatis oleh CashWave Sales Management System.',
              style: pw.TextStyle(color: textSecondary, fontSize: 8),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Column(
      children: [
        pw.Divider(color: borderColor, thickness: 0.5),

        pw.SizedBox(height: 5),

        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'CashWave Sales Management System',
              style: pw.TextStyle(color: textSecondary, fontSize: 7),
            ),

            pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: pw.TextStyle(color: textSecondary, fontSize: 7),
            ),
          ],
        ),
      ],
    );
  }
}
