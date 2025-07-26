import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashwave_mobile/core/extensions/string_ext.dart';
import 'package:cashwave_mobile/presentation/setting/pages/report/category_model.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/components/buttons.dart';
import '../../../core/components/custom_dropdown.dart';
import '../../../core/components/custom_text_field.dart';
import '../../../core/components/image_picker_widget.dart';
import '../../../core/components/spaces.dart';
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
  TextEditingController? nameController;
  TextEditingController? priceController;
  TextEditingController? stockController;

  Category? category;

  XFile? imageFile;

  bool isBestSeller = false;

  final List<CategoryModel> categories = [
    CategoryModel(name: 'Drink', value: 'drink'),
    CategoryModel(name: 'Food', value: 'food'),
    CategoryModel(name: 'Snack', value: 'snack'),
  ];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    priceController = TextEditingController();
    stockController = TextEditingController();

    context.read<CategoryBloc>().add(const CategoryEvent.getCategoriesLocal());
  }

  @override
  void dispose() {
    super.dispose();
    nameController!.dispose();
    priceController!.dispose();
    stockController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Add Product',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          CustomTextField(
            controller: nameController!,
            label: 'Product Name',
          ),
          const SpaceHeight(16.0),
          CustomTextField(
            controller: priceController!,
            label: 'Product Price',
            keyboardType: TextInputType.number,
            onChanged: (value) {},
          ),
          const SpaceHeight(16.0),
          ImagePickerWidget(
            label: 'Photo',
            onChanged: (file) {
              if (file == null) {
                return;
              }
              imageFile = file;
            },
          ),
          const SpaceHeight(16.0),
          CustomTextField(
            controller: stockController!,
            label: 'Stock',
            keyboardType: TextInputType.number,
          ),
          const SpaceHeight(16.0),
          Row(
            children: [
              Checkbox(
                value: isBestSeller,
                onChanged: (value) {
                  setState(() {
                    isBestSeller = value!;
                  });
                },
              ),
              const Text('Best Seller'),
            ],
          ),
          const SpaceHeight(16.0),
          BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) {
              return state.maybeWhen(
                loadedLocal: (categories) {
                  if (categories.isEmpty) {
                    return const Text('Tidak ada kategori tersedia');
                  }

                  return CustomDropdown<Category>(
                    label: 'Category',
                    value: category ?? categories.first,
                    items: categories,
                    onChanged: (value) {
                      setState(() {
                        category = value!;
                      });
                    },
                  );
                },
                orElse: () => const CircularProgressIndicator(),
              );
            },
          ),
          const SpaceHeight(16.0),
          Row(
            children: [
              Expanded(
                child: Button.outlined(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  label: 'Batal',
                ),
              ),
              const SpaceWidth(16.0),
              Expanded(
                child: BlocConsumer<ProductBloc, ProductState>(
                  listener: (context, state) {
                state.maybeMap(
                  success: (_) {
                    // Tambahkan feedback ke user
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Produk berhasil ditambahkan')),
                    );

                    // Kembali ke halaman sebelumnya
                    Navigator.pop(context);
                  },
                  orElse: () {},
                );
              },

                  builder: (context, state) {
                    return state.maybeWhen(orElse: () {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }, loading: () {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }, success: (_) {
                      return Button.filled(
                        onPressed: () {
                          final String name = nameController!.text;
                          final int price =
                              priceController!.text.toIntegerFromText;
                          final int stock =
                              stockController!.text.toIntegerFromText;
                          final Product product = Product(
                              name: name,
                              price: price,
                              stock: stock,
                              category: category!.name,
                              categoryId: category!.id,
                              isBestSeller: isBestSeller,
                              image: imageFile!.path);
                          context.read<ProductBloc>().add(
                              ProductEvent.addProduct(product, imageFile!));
                        },
                        label: 'Simpan',
                      );
                    });
                  },
                ),
              ),
            ],
          ),
          const SpaceHeight(20.0),
        ],
      ),
    );
  }
}
