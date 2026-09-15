import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cashwave_mobile/data/models/response/product_response_model.dart';

import '../../../core/components/buttons.dart';
import '../../../core/constants/variables.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../pages/edit_product_page.dart';

class MenuProductItem extends StatelessWidget {
  final Product data;

  const MenuProductItem({super.key, required this.data});

  static const Color primary = Color(0xff087A55);
  static const Color primaryLight = Color(0xffE8F5F0);
  static const Color background = Color(0xffF7F9F8);
  static const Color textPrimary = Color(0xff17221E);
  static const Color textSecondary = Color(0xff7A8581);
  static const Color borderColor = Color(0xffE5EBE8);

  String get imageUrl {
    if (data.image == null || data.image!.isEmpty) {
      return '';
    }

    return '${Variables.imageBaseUrl}${data.image}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductImage(),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),

                const SizedBox(height: 7),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    data.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: primary,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Rp ${data.price}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: primary,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: Button.outlined(
                        onPressed: () {
                          _showDetailDialog(context);
                        },
                        label: 'Detail',
                        fontSize: 9,
                        height: 32,
                      ),
                    ),

                    const SizedBox(width: 6),

                    Expanded(
                      child: Button.outlined(
                        onPressed: () {
                          context.push(EditProductPage(data: data));
                        },
                        label: 'Edit',
                        fontSize: 9,
                        height: 32,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 82,
        height: 82,
        color: background,
        child: imageUrl.isEmpty
            ? const Icon(
                Icons.fastfood_outlined,
                size: 36,
                color: textSecondary,
              )
            : CachedNetworkImage(
                imageUrl: imageUrl,
                width: 82,
                height: 82,
                fit: BoxFit.cover,
                placeholder: (context, url) {
                  return const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primary,
                      ),
                    ),
                  );
                },
                errorWidget: (context, url, error) {
                  return const Icon(
                    Icons.fastfood_outlined,
                    size: 36,
                    color: textSecondary,
                  );
                },
              ),
      ),
    );
  }

  void _showDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Detail Produk',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(dialogContext);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: background,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 19,
                          color: textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 150,
                      height: 150,
                      color: background,
                      child: imageUrl.isEmpty
                          ? const Icon(
                              Icons.fastfood_outlined,
                              size: 55,
                              color: textSecondary,
                            )
                          : CachedNetworkImage(
                              imageUrl: imageUrl,
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                              placeholder: (context, url) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: primary,
                                  ),
                                );
                              },
                              errorWidget: (context, url, error) {
                                return const Icon(
                                  Icons.fastfood_outlined,
                                  size: 55,
                                  color: textSecondary,
                                );
                              },
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  data.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),

                const SizedBox(height: 12),

                _detailRow(
                  icon: Icons.category_outlined,
                  label: 'Kategori',
                  value: data.category,
                ),

                const SizedBox(height: 10),

                _detailRow(
                  icon: Icons.payments_outlined,
                  label: 'Harga',
                  value: 'Rp ${data.price}',
                ),

                const SizedBox(height: 10),

                _detailRow(
                  icon: Icons.inventory_2_outlined,
                  label: 'Stok',
                  value: data.stock.toString(),
                ),

                const SizedBox(height: 10),

                _detailRow(
                  icon: Icons.star_outline_rounded,
                  label: 'Best Seller',
                  value: data.isBestSeller ? 'Ya' : 'Tidak',
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: Button.filled(
                    onPressed: () {
                      Navigator.pop(dialogContext);

                      context.push(EditProductPage(data: data));
                    },
                    label: 'Edit Produk',
                    height: 46,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.info_outline, size: 18, color: primary),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
