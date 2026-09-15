import 'dart:io' as io;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatefulWidget {
  final String label;
  final void Function(XFile? file) onChanged;
  final bool showLabel;

  const ImagePickerWidget({
    super.key,
    required this.label,
    required this.onChanged,
    this.showLabel = true,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  XFile? _file;
  Uint8List? _webImage;

  bool _isPicking = false;

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primary = Color(0xff087A55);

  static const Color primaryLight = Color(0xffE8F5F0);

  static const Color background = Color(0xffF7F9F8);

  static const Color textPrimary = Color(0xff17221E);

  static const Color textSecondary = Color(0xff7A8581);

  static const Color borderColor = Color(0xffE5EBE8);

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> _pickImage() async {
    if (_isPicking) return;

    setState(() {
      _isPicking = true;
    });

    try {
      final ImagePicker picker = ImagePicker();

      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      if (pickedFile == null) {
        widget.onChanged(null);
        return;
      }

      if (kIsWeb) {
        final Uint8List bytes = await pickedFile.readAsBytes();

        if (!mounted) return;

        setState(() {
          _webImage = bytes;
          _file = pickedFile;
        });
      } else {
        if (!mounted) return;

        setState(() {
          _file = pickedFile;
        });
      }

      widget.onChanged(pickedFile);
    } catch (e) {
      debugPrint('[ImagePicker] Error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xffD9534F),
              elevation: 0,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              content: const Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Gagal memilih gambar.',
                      style: TextStyle(
                        color: Colors.white,
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
    } finally {
      if (mounted) {
        setState(() {
          _isPicking = false;
        });
      }
    }
  }

  // ============================================================
  // IMAGE PREVIEW
  // ============================================================

  Widget _buildImagePreview() {
    // ----------------------------------------------------------
    // WEB
    // ----------------------------------------------------------

    if (kIsWeb && _webImage != null) {
      return Image.memory(_webImage!, fit: BoxFit.cover);
    }

    // ----------------------------------------------------------
    // MOBILE / DESKTOP
    // ----------------------------------------------------------

    if (!kIsWeb && _file != null) {
      return Image.file(io.File(_file!.path), fit: BoxFit.cover);
    }

    // ----------------------------------------------------------
    // EMPTY
    // ----------------------------------------------------------

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: primaryLight,
      child: const Center(
        child: Icon(
          Icons.add_photo_alternate_outlined,
          color: primary,
          size: 30,
        ),
      ),
    );
  }

  // ============================================================
  // PREVIEW CONTAINER
  // ============================================================

  Widget _buildPreview() {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        color: primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildImagePreview(),
    );
  }

  // ============================================================
  // CHOOSE BUTTON
  // ============================================================

  Widget _buildChooseButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isPicking ? null : _pickImage,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(13),
          ),
          child: _isPicking
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Pilih Foto',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ======================================================
        // LABEL
        // ======================================================

        if (widget.showLabel) ...[
          Text(
            widget.label,
            style: const TextStyle(
              color: textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),
        ],

        // ======================================================
        // PICKER CARD
        // ======================================================
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              // IMAGE
              _buildPreview(),

              const SizedBox(width: 13),

              // DESCRIPTION
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _file == null ? 'Foto Produk' : 'Foto Dipilih',
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      _file == null
                          ? 'Tambahkan foto produk dari galeri.'
                          : 'Foto produk siap digunakan.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 10,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 10),

                    _buildChooseButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
