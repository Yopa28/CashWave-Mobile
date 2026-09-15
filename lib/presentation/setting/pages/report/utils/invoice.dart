import 'dart:io';

import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:cashwave_mobile/core/extensions/int_ext.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../../data/models/response/product_sales_report.dart';
import '../../../../../data/models/response/summary_response_model.dart';
import 'helper_pdf_service.dart';

class Invoice {
  // ============================================================
  // CASHWAVE COLORS
  // ============================================================

  static const PdfColor primary = PdfColor.fromInt(0xff087A55);

  static const PdfColor primaryLight = PdfColor.fromInt(0xffE8F5F0);

  static const PdfColor textPrimary = PdfColor.fromInt(0xff17221E);

  static const PdfColor textSecondary = PdfColor.fromInt(0xff7A8581);

  static const PdfColor borderColor = PdfColor.fromInt(0xffE5EBE8);

  // ============================================================
  // HELPER PARSE INT
  // ============================================================

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    final String text = value.toString();

    // Ambil angka saja.
    //
    // Contoh:
    // "10"       -> 10
    // "10.000"   -> 10000
    // "Rp 10.000" -> 10000
    final String cleaned = text.replaceAll(RegExp(r'[^0-9-]'), '');

    return int.tryParse(cleaned) ?? 0;
  }

  // ============================================================
  // GENERATE PDF
  // ============================================================

  static Future<File> generate(
    List<ProductSales> itemSales,
    Summary summary,
  ) async {
    final pdf = pw.Document();

    // ==========================================================
    // LOAD LOGO
    // ==========================================================

    final ByteData dataImage = await rootBundle.load('assets/images/logo.png');

    final Uint8List bytes = dataImage.buffer.asUint8List();

    final image = pw.MemoryImage(bytes);

    // ==========================================================
    // PDF PAGE
    // ==========================================================

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),

        build: (context) => [
          // HEADER
          buildHeader(image),

          pw.SizedBox(height: 25),

          // SUMMARY TITLE
          pw.Text(
            'Summary',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: textPrimary,
            ),
          ),

          pw.SizedBox(height: 8),

          // SUMMARY
          buildSummary(summary),

          pw.SizedBox(height: 35),

          // PRODUCT SALES TITLE
          pw.Text(
            'Product Sales',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: textPrimary,
            ),
          ),

          pw.SizedBox(height: 10),

          // PRODUCT SALES TABLE
          buildInvoice(itemSales),

          pw.SizedBox(height: 10),

          pw.Divider(color: borderColor),
        ],

        footer: (context) => buildFooter(),
      ),
    );

    // ==========================================================
    // SAVE PDF
    // ==========================================================

    return HelperPdfService.saveDocument(
      name: 'CashWave Report | ${DateTime.now().millisecondsSinceEpoch}.pdf',
      pdf: pdf,
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  static pw.Widget buildHeader(pw.MemoryImage image) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'CashWave',
              style: pw.TextStyle(
                fontSize: 25,
                fontWeight: pw.FontWeight.bold,
                color: primary,
              ),
            ),

            pw.SizedBox(height: 4),

            pw.Text(
              'Sales Report',
              style: pw.TextStyle(
                fontSize: 15,
                fontWeight: pw.FontWeight.bold,
                color: textPrimary,
              ),
            ),

            pw.SizedBox(height: 7),

            pw.Text(
              'Created At: ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
              style: pw.TextStyle(fontSize: 10, color: textSecondary),
            ),
          ],
        ),

        pw.Container(
          width: 70,
          height: 70,
          padding: const pw.EdgeInsets.all(7),
          decoration: pw.BoxDecoration(
            color: primaryLight,
            borderRadius: pw.BorderRadius.circular(12),
          ),
          child: pw.Image(image, fit: pw.BoxFit.contain),
        ),
      ],
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  static pw.Widget buildSummary(Summary summary) {
    final int revenue = _toInt(summary.totalRevenue);

    final int soldItems = _toInt(summary.totalSoldQuantity);

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: primaryLight,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        children: [
          buildTextPrice(
            title: 'Revenue',
            value: revenue.currencyFormatRp,
            unite: true,
          ),

          pw.SizedBox(height: 10),

          buildTextPrice(
            title: 'Sold Items',
            value: soldItems.toString(),
            unite: true,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRODUCT SALES TABLE
  // ============================================================

  static pw.Widget buildInvoice(List<ProductSales> itemSales) {
    final headers = ['No', 'ID', 'Product', 'Price', 'Qty', 'Total'];

    final data = List.generate(itemSales.length, (index) {
      final item = itemSales[index];

      final int price = _toInt(item.productPrice);

      final int quantity = _toInt(item.totalQuantity);

      final int total = _toInt(item.totalPrice);

      return [
        (index + 1).toString(),
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

      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
        fontSize: 9,
      ),

      headerDecoration: const pw.BoxDecoration(color: primary),

      cellStyle: pw.TextStyle(color: textPrimary, fontSize: 8),

      cellHeight: 30,

      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 7),

      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.center,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.center,
        5: pw.Alignment.centerRight,
      },

      columnWidths: {
        0: const pw.FixedColumnWidth(30),
        1: const pw.FixedColumnWidth(45),
        2: const pw.FlexColumnWidth(3),
        3: const pw.FlexColumnWidth(2),
        4: const pw.FixedColumnWidth(40),
        5: const pw.FlexColumnWidth(2),
      },
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  static pw.Widget buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Divider(color: borderColor),

        pw.SizedBox(height: 5),

        buildSimpleText(
          title: 'Address',
          value: 'Jalan Palagan No. 12, Sleman, DI Yogyakarta, 12345',
        ),

        pw.SizedBox(height: 3),

        pw.Text(
          'CashWave • Sales Management System',
          style: pw.TextStyle(fontSize: 8, color: textSecondary),
        ),
      ],
    );
  }

  // ============================================================
  // SIMPLE TEXT
  // ============================================================

  static pw.Widget buildSimpleText({
    required String title,
    required String value,
  }) {
    final style = pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      color: textPrimary,
      fontSize: 8,
    );

    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(title, style: style),

        pw.SizedBox(width: 6),

        pw.Text(value, style: pw.TextStyle(fontSize: 8, color: textSecondary)),
      ],
    );
  }

  // ============================================================
  // PRICE ROW
  // ============================================================

  static pw.Widget buildTextPrice({
    required String title,
    required String value,
    double width = double.infinity,
    pw.TextStyle? titleStyle,
    bool unite = false,
  }) {
    final style =
        titleStyle ??
        pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          color: textPrimary,
          fontSize: 11,
        );

    return pw.Container(
      width: width,
      child: pw.Row(
        children: [
          pw.Expanded(child: pw.Text(title, style: style)),

          pw.Text(
            value,
            style: unite
                ? style
                : pw.TextStyle(color: textPrimary, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
