import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../home/bloc/product/product_bloc.dart';
import '../../home/bloc/category/category_bloc.dart';
import '../../../data/models/response/product_response_model.dart';
import '../../../data/models/response/category_response_model.dart';

class EditProductPage extends StatefulWidget {
  final Product data;

  const EditProductPage({super.key, required this.data});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  late final TextEditingController nameController;
  late final TextEditingController priceController;
  late final TextEditingController stockController;

  Category? selectedCategory;
  XFile? selectedImage;
  bool isBestSeller = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.data.name);

    priceController = TextEditingController(text: widget.data.price.toString());

    stockController = TextEditingController(text: widget.data.stock.toString());

    isBestSeller = widget.data.isBestSeller;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryBloc>().add(const CategoryEvent.getCategories());
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
      maxHeight: 1600,
    );

    if (image != null) {
      setState(() {
        selectedImage = image;
      });
    }
  }

  void _saveProduct() {
    final name = nameController.text.trim();
    final price = int.tryParse(
      priceController.text.replaceAll(RegExp(r'[^0-9]'), ''),
    );
    final stock = int.tryParse(
      stockController.text.replaceAll(RegExp(r'[^0-9]'), ''),
    );

    if (name.isEmpty) {
      _showMessage('Nama produk wajib diisi.');
      return;
    }

    if (price == null || price <= 0) {
      _showMessage('Harga produk tidak valid.');
      return;
    }

    if (stock == null || stock < 0) {
      _showMessage('Stok produk tidak valid.');
      return;
    }

    if (selectedCategory == null) {
      _showMessage('Silakan pilih kategori.');
      return;
    }

    final updatedProduct = Product(
      id: widget.data.id,
      name: name,
      price: price,
      stock: stock,
      category: selectedCategory!.name,
      categoryId: selectedCategory!.id,
      isBestSeller: isBestSeller,
      image: widget.data.image,
    );

    setState(() {
      isSaving = true;
    });

    context.read<ProductBloc>().add(
      ProductEvent.updateProduct(updatedProduct, selectedImage),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CategoryBloc, CategoryState>(
          listener: (context, state) {
            state.when(
              initial: () {},
              loading: () {},
              loaded: (categories) {
                _setInitialCategory(categories);
              },
              loadedLocal: (categories) {
                _setInitialCategory(categories);
              },
              error: (message) {
                _showMessage(message);
              },
            );
          },
        ),
        BlocListener<ProductBloc, ProductState>(
          listener: (context, state) {
            state.when(
              initial: () {},
              loading: () {
                if (mounted) {
                  setState(() {
                    isSaving = true;
                  });
                }
              },
              success: (_) {
                if (!mounted) return;

                setState(() {
                  isSaving = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Produk berhasil diperbarui.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );

                Navigator.pop(context, true);
              },
              error: (message) {
                if (!mounted) return;

                setState(() {
                  isSaving = false;
                });

                _showMessage(message);
              },
            );
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Theme.of(context).colorScheme.surface,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xff17221E),
            ),
          ),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Produk',
                style: TextStyle(
                  color: Color(0xff17221E),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Perbarui informasi produk',
                style: TextStyle(
                  color: Color(0xff7A8581),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSection(),
                const SizedBox(height: 20),
                _buildField(
                  controller: nameController,
                  label: 'Nama Produk',
                  hint: 'Contoh: Es Kopi Susu',
                  icon: Icons.restaurant_menu_rounded,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        controller: priceController,
                        label: 'Harga',
                        hint: '25000',
                        icon: Icons.payments_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField(
                        controller: stockController,
                        label: 'Stok',
                        hint: '10',
                        icon: Icons.inventory_2_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildCategorySection(),
                const SizedBox(height: 16),
                _buildBestSellerSection(),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : _saveProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff087A55),
                      disabledBackgroundColor: const Color(0xffA9BDB5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Simpan Perubahan',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _setInitialCategory(List<Category> categories) {
    if (selectedCategory != null) return;

    for (final category in categories) {
      if (category.id == widget.data.categoryId) {
        if (mounted) {
          setState(() {
            selectedCategory = category;
          });
        }
        return;
      }
    }
  }

  Widget _buildImageSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffE5EBE8)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 88,
              height: 88,
              color: const Color(0xffE8F5F0),
              child: selectedImage != null
                  ? FutureBuilder(
                      future: selectedImage!.readAsBytes(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        }

                        return Image.memory(snapshot.data!, fit: BoxFit.cover);
                      },
                    )
                  : const Icon(
                      Icons.image_outlined,
                      size: 36,
                      color: Color(0xff087A55),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Foto Produk',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff17221E),
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Pilih foto baru jika ingin mengganti foto produk.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: Color(0xff7A8581),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library_outlined, size: 17),
                  label: const Text('Pilih Foto'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xff087A55),
                    side: const BorderSide(color: Color(0xff087A55)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: const Color(0xff087A55)),
            filled: true,
            fillColor: colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xffE5EBE8)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xffE5EBE8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xff087A55),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE5EBE8)),
      ),
      child: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          return state.when(
            initial: () => _categoryContent('Memuat kategori...'),
            loading: () => _categoryContent('Memuat kategori...'),
            loaded: (categories) => _categoryDropdown(categories),
            loadedLocal: (categories) => _categoryDropdown(categories),
            error: (message) => _categoryContent(message),
          );
        },
      ),
    );
  }

  Widget _categoryContent(String text) {
    return Row(
      children: [
        const Icon(Icons.category_outlined, color: Color(0xff087A55)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Color(0xff7A8581), fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _categoryDropdown(List<Category> categories) {
    return DropdownButtonFormField<Category>(
      value: selectedCategory,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Kategori',
        prefixIcon: Icon(Icons.category_outlined, color: Color(0xff087A55)),
        border: InputBorder.none,
      ),
      items: categories.map((category) {
        return DropdownMenuItem<Category>(
          value: category,
          child: Text(category.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedCategory = value;
        });
      },
    );
  }

  Widget _buildBestSellerSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE5EBE8)),
      ),
      child: SwitchListTile(
        value: isBestSeller,
        onChanged: (value) {
          setState(() {
            isBestSeller = value;
          });
        },
        activeThumbColor: const Color(0xff087A55),
        title: const Text(
          'Produk Best Seller',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xff17221E),
          ),
        ),
        subtitle: const Text(
          'Tandai produk sebagai menu favorit.',
          style: TextStyle(fontSize: 11, color: Color(0xff7A8581)),
        ),
        secondary: const Icon(
          Icons.star_outline_rounded,
          color: Color(0xff087A55),
        ),
      ),
    );
  }
}
