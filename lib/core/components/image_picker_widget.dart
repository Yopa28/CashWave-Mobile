import 'dart:typed_data';
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../assets/assets.gen.dart';
import '../constants/colors.dart';
import 'buttons.dart';
import 'spaces.dart';

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

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
          _file = pickedFile;
        });
      } else {
        setState(() {
          _file = pickedFile;
        });
      }
      widget.onChanged(pickedFile);
    } else {
      debugPrint('No image selected.');
      widget.onChanged(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = Container(
      padding: const EdgeInsets.all(16.0),
      color: AppColors.black.withOpacity(0.05),
      child: Assets.icons.image.svg(),
    );

    if (_file != null) {
      if (kIsWeb && _webImage != null) {
        imageWidget = Image.memory(_webImage!, fit: BoxFit.cover);
      } else if (!kIsWeb) {
        imageWidget = Image.file(io.File(_file!.path), fit: BoxFit.cover);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel) ...[
          Text(
            widget.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SpaceHeight(12.0),
        ],
        Container(
          padding: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: AppColors.primary),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 80.0,
                height: 80.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: imageWidget,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Button.filled(
                  height: 30.0,
                  width: 127.0,
                  onPressed: _pickImage,
                  label: 'Choose Photo',
                  fontSize: 10.0,
                  borderRadius: 5.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
