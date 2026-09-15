import 'dart:developer';
import 'dart:io';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class HelperPdfService {
  // ============================================================
  // SAVE PDF DOCUMENT
  // ============================================================

  static Future<File> saveDocument({
    required String name,
    required pw.Document pdf,
  }) async {
    try {
      // Generate PDF bytes
      final bytes = await pdf.save();

      // Get application documents directory
      final directory = await getApplicationDocumentsDirectory();

      // Make sure filename is safe
      final safeName = _sanitizeFileName(name);

      final file = File('${directory.path}/$safeName');

      log('[PDF] Saving document: ${file.path}');

      // Write PDF
      await file.writeAsBytes(bytes, flush: true);

      log('[PDF] Document saved successfully.');

      return file;
    } catch (e, stackTrace) {
      log('[PDF] Failed to save document: $e', stackTrace: stackTrace);

      throw Exception('Gagal menyimpan file PDF: $e');
    }
  }

  // ============================================================
  // OPEN PDF
  // ============================================================

  static Future<void> openFile(File file) async {
    try {
      if (!await file.exists()) {
        log('[PDF] File does not exist: ${file.path}');

        throw Exception('File PDF tidak ditemukan.');
      }

      log('[PDF] Opening file: ${file.path}');

      final result = await OpenFilex.open(file.path, type: 'application/pdf');

      log(
        '[PDF] Open result: '
        'type=${result.type}, '
        'message=${result.message}',
      );

      // OpenFilex returns a result even when
      // no suitable PDF application exists.
      if (result.type != ResultType.done) {
        throw Exception(result.message ?? 'Tidak dapat membuka file PDF.');
      }
    } catch (e, stackTrace) {
      log('[PDF] Failed to open document: $e', stackTrace: stackTrace);

      rethrow;
    }
  }

  // ============================================================
  // SANITIZE FILE NAME
  // ============================================================

  static String _sanitizeFileName(String name) {
    final sanitized = name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_').trim();

    if (sanitized.isEmpty) {
      return 'CashWave_Report.pdf';
    }

    if (!sanitized.toLowerCase().endsWith('.pdf')) {
      return '$sanitized.pdf';
    }

    return sanitized;
  }
}
