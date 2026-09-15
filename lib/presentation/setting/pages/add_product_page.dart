import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:cashwave_mobile/core/components/custom_dropdown.dart';
import 'package:cashwave_mobile/core/components/custom_text_field.dart';

import '../../../data/models/response/category_response_model.dart';
import '../../../data/models/response/product_response_model.dart';

import '../../home/bloc/category/category_bloc.dart';
import '../../home/bloc/product/product_bloc.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
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
  // CONTROLLERS
  // ============================================================

  late final TextEditingController nameController;
  late final TextEditingController priceController;
  late final TextEditingController stockController;

  // ============================================================
  // STATE
  // ============================================================

  final ImagePicker imagePicker = ImagePicker();

  XFile? image;

  Category? category;

  bool isBestSeller = false;

  bool isSubmitting = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController();
    priceController = TextEditingController();
    stockController = TextEditingController();

    context.read<CategoryBloc>().add(const CategoryEvent.getCategoriesLocal());
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    stockController.dispose();

    super.dispose();
  }

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> _pickImage() async {
    try {
      final XFile? pickedImage = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (pickedImage == null) return;

      setState(() {
        image = pickedImage;
      });
    } catch (e) {
      _showSnackBar('Gagal memilih gambar', isError: true);
    }
  }

  // ============================================================
  // VALIDATE
  // ============================================================

  bool _validateForm() {
    final name = nameController.text.trim();
    final price = priceController.text.trim();
    final stock = stockController.text.trim();

    // Nama
    if (name.isEmpty) {
      _showSnackBar('Nama produk wajib diisi', isError: true);

      return false;
    }

    // Harga
    if (price.isEmpty) {
      _showSnackBar('Harga produk wajib diisi', isError: true);

      return false;
    }

    final parsedPrice = int.tryParse(price.replaceAll(RegExp(r'[^0-9]'), ''));

    if (parsedPrice == null || parsedPrice <= 0) {
      _showSnackBar('Harga produk tidak valid', isError: true);

      return false;
    }

    // Stock
    if (stock.isEmpty) {
      _showSnackBar('Stok produk wajib diisi', isError: true);

      return false;
    }

    final parsedStock = int.tryParse(stock);

    if (parsedStock == null || parsedStock < 0) {
      _showSnackBar('Stok produk tidak valid', isError: true);

      return false;
    }

    // Category
    if (category == null) {
      _showSnackBar('Silakan pilih kategori produk', isError: true);

      return false;
    }

    // Image
    if (image == null) {
      _showSnackBar('Silakan pilih foto produk', isError: true);

      return false;
    }

    return true;
  }

  // ============================================================
  // SUBMIT PRODUCT
  // ============================================================

  void _submitProduct() {
    if (isSubmitting) return;

    if (!_validateForm()) return;

    final selectedCategory = category;

    if (selectedCategory == null) {
      return;
    }

    final selectedImage = image;

    if (selectedImage == null) {
      return;
    }

    final price = int.parse(
      priceController.text.replaceAll(RegExp(r'[^0-9]'), ''),
    );

    final stock = int.parse(stockController.text.trim());

    final product = Product(
      id: 0,
      name: nameController.text.trim(),
      price: price,
      stock: stock,
      category: selectedCategory.name,
      categoryId: selectedCategory.id,
      isBestSeller: isBestSeller,
      image: '',
    );

    setState(() {
      isSubmitting = true;
    });

    context.read<ProductBloc>().add(
      ProductEvent.addProduct(product, selectedImage),
    );
  }

  // ============================================================
  // FORMAT PRICE
  // ============================================================

  String _formatPrice(String value) {
    final number = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));

    if (number == null) {
      return '';
    }

    final text = number.toString();

    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) {
        buffer.write('.');
      }

      buffer.write(text[i]);
    }

    return buffer.toString();
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
  // IMAGE PICKER SECTION
  // ============================================================

  Widget _buildImagePicker() {
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
          const Text(
            'Foto Produk',
            style: TextStyle(
              color: textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Gunakan foto produk yang jelas',
            style: TextStyle(color: textSecondary, fontSize: 12),
          ),

          const SizedBox(height: 14),

          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              height: 210,
              decoration: BoxDecoration(
                color: const Color(0xffF3F7F5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              clipBehavior: Clip.antiAlias,
              child: image != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(File(image!.path), fit: BoxFit.cover),

                        // Overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.15),
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.15),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Edit button
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Material(
                            color: Colors.black.withOpacity(0.55),
                            shape: const CircleBorder(),
                            child: IconButton(
                              onPressed: _pickImage,
                              icon: const Icon(
                                Icons.edit_rounded,
                                color: Colors.white,
                                size: 19,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: primaryLight,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.add_photo_alternate_outlined,
                            color: primary,
                            size: 30,
                          ),
                        ),

                        const SizedBox(height: 14),

                        const Text(
                          'Tambah Foto',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 4),

                        const Text(
                          'Tap untuk memilih dari galeri',
                          style: TextStyle(color: textSecondary, fontSize: 12),
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
  // BEST SELLER
  // ============================================================

  Widget _buildBestSeller() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.star_outline_rounded, color: primary),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Produk Best Seller',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(height: 3),

                Text(
                  'Tandai produk sebagai menu favorit',
                  style: TextStyle(color: textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),

          Switch.adaptive(
            value: isBestSeller,
            activeColor: primary,
            onChanged: isSubmitting
                ? null
                : (bool value) {
                    setState(() {
                      isBestSeller = value;
                    });
                  },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          subtitle,
          style: const TextStyle(color: textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  // ============================================================
  // CATEGORY LOADING
  // ============================================================

  Widget _buildCategoryLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori',
          style: TextStyle(
            color: textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 12),

        Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xffF7F9F8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: const Row(
            children: [
              SizedBox(
                width: 19,
                height: 19,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: primary,
                ),
              ),

              SizedBox(width: 12),

              Text(
                'Memuat kategori...',
                style: TextStyle(color: textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CATEGORY ERROR
  // ============================================================

  Widget _buildCategoryError(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dangerLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: danger.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: danger, size: 21),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: danger,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORY DROPDOWN
  // ============================================================

  Widget _buildCategoryDropdown(List<Category> categories) {
    if (categories.isEmpty) {
      return _buildCategoryError('Belum ada kategori tersedia');
    }

    return CustomDropdown<Category>(
      label: 'Kategori',
      value: category,
      items: categories,
      onChanged: isSubmitting
          ? null
          : (Category? value) {
              setState(() {
                category = value;
              });
            },
    );
  }

  // ============================================================
  // SAVE BUTTON
  // ============================================================

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: borderColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isSubmitting ? null : _submitProduct,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              disabledBackgroundColor: primary.withOpacity(0.5),
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: 23,
                    height: 23,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_rounded, size: 20),

                      SizedBox(width: 9),

                      Text(
                        'Simpan Produk',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
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
    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        state.when(
          // ------------------------------------------------------
          // INITIAL
          // ------------------------------------------------------

          initial: () {},

          // ------------------------------------------------------
          // LOADING
          // ------------------------------------------------------
          loading: () {},

          // ------------------------------------------------------
          // SUCCESS
          // ------------------------------------------------------
          success: (_) {
            // Jangan melakukan apa-apa jika success
            // bukan berasal dari proses submit halaman ini.
            if (!isSubmitting) {
              return;
            }

            setState(() {
              isSubmitting = false;
            });

            _showSnackBar('Produk berhasil ditambahkan');

            Navigator.pop(context);
          },

          // ------------------------------------------------------
          // ERROR
          // ------------------------------------------------------
          error: (message) {
            if (!isSubmitting) {
              return;
            }

            setState(() {
              isSubmitting = false;
            });

            _showSnackBar(message, isError: true);
          },
        );
      },

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
            onPressed: isSubmitting
                ? null
                : () {
                    Navigator.pop(context);
                  },
            icon: const Icon(Icons.arrow_back_rounded, color: textPrimary),
          ),

          titleSpacing: 0,

          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tambah Produk',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              SizedBox(height: 2),

              Text(
                'Tambahkan menu baru ke cafe',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // ======================================================
        // BODY
        // ======================================================
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =================================================
                // FOTO PRODUK
                // =================================================

                _buildImagePicker(),

                const SizedBox(height: 24),

                // =================================================
                // SECTION TITLE
                // =================================================
                _buildSectionTitle(
                  'Informasi Produk',
                  'Masukkan informasi dasar produk',
                ),

                const SizedBox(height: 14),

                // =================================================
                // FORM
                // =================================================
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      // ===========================================
                      // NAMA
                      // ===========================================

                      CustomTextField(
                        controller: nameController,
                        label: 'Nama Produk',
                        keyboardType: TextInputType.text,
                      ),

                      const SizedBox(height: 18),

                      // ===========================================
                      // HARGA
                      // ===========================================
                      CustomTextField(
                        controller: priceController,
                        label: 'Harga',
                        keyboardType: TextInputType.number,
                        onChanged: (String value) {
                          final digits = value.replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          );

                          if (digits.isEmpty) {
                            return;
                          }

                          final formatted = _formatPrice(digits);

                          if (formatted == value) {
                            return;
                          }

                          priceController.value = TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(
                              offset: formatted.length,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 18),

                      // ===========================================
                      // STOCK
                      // ===========================================
                      CustomTextField(
                        controller: stockController,
                        label: 'Stok',
                        keyboardType: TextInputType.number,
                      ),

                      const SizedBox(height: 18),

                      // ===========================================
                      // CATEGORY
                      // ===========================================
                      BlocBuilder<CategoryBloc, CategoryState>(
                        builder: (context, state) {
                          return state.when(
                            initial: () {
                              return _buildCategoryLoading();
                            },

                            loading: () {
                              return _buildCategoryLoading();
                            },

                            loaded: (categories) {
                              return _buildCategoryDropdown(categories);
                            },

                            loadedLocal: (categories) {
                              return _buildCategoryDropdown(categories);
                            },

                            error: (message) {
                              return _buildCategoryError(message);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // =================================================
                // BEST SELLER
                // =================================================
                _buildBestSeller(),

                const SizedBox(height: 24),

                // =================================================
                // INFO
                // =================================================
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: primaryLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: primary.withOpacity(0.12)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: primary,
                        size: 21,
                      ),

                      SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          'Pastikan informasi produk sudah benar sebelum disimpan.',
                          style: TextStyle(
                            color: primaryDark,
                            fontSize: 12,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ======================================================
        // SAVE BUTTON
        // ======================================================
        bottomNavigationBar: _buildSaveButton(),
      ),
    );
  }
}
