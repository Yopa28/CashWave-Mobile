import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashwave_mobile/core/extensions/int_ext.dart';
import 'package:cashwave_mobile/presentation/home/bloc/checkout/checkout_bloc.dart';
import 'package:cashwave_mobile/presentation/home/models/order_item.dart';

import '../../../core/constants/variables.dart';

class OrderCard extends StatelessWidget {
  final OrderItem data;
  final VoidCallback onDeleteTap;
  final EdgeInsetsGeometry? padding;

  const OrderCard({
    super.key,
    required this.data,
    required this.onDeleteTap,
    this.padding,
  });

  static const Color primary = Color(0xff087A55);
  static const Color primaryLight = Color(0xffE8F5F0);
  static const Color imageBackground = Color(0xffF1F6F4);
  static const Color textPrimary = Color(0xff17221E);
  static const Color borderColor = Color(0xffE5EBE8);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: padding,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // =====================================================
          // IMAGE
          // =====================================================

          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 76,
              height: 76,
              color: imageBackground,
              child: CachedNetworkImage(
                imageUrl: '${Variables.imageBaseUrl}${data.product.image}',
                width: 76,
                height: 76,
                fit: BoxFit.cover,
                placeholder: (context, url) {
                  return const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primary,
                      ),
                    ),
                  );
                },
                errorWidget: (context, url, error) {
                  return const Center(
                    child: Icon(
                      Icons.fastfood_outlined,
                      size: 32,
                      color: primary,
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 14),

          // =====================================================
          // CONTENT
          // =====================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name
                Text(
                  data.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 5),

                // Price
                Text(
                  data.product.price.currencyFormatRp,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: primary,
                  ),
                ),

                const SizedBox(height: 12),

                // =================================================
                // QUANTITY
                // =================================================
                Row(
                  children: [
                    // MINUS
                    _quantityButton(
                      context: context,
                      icon: Icons.remove,
                      onTap: () {
                        context.read<CheckoutBloc>().add(
                          CheckoutEvent.removeCheckout(data.product),
                        );
                      },
                    ),

                    const SizedBox(width: 8),

                    // QUANTITY
                    Container(
                      width: 36,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: primaryLight,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        data.quantity.toString(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: primary,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // PLUS
                    _quantityButton(
                      context: context,
                      icon: Icons.add,
                      onTap: () {
                        context.read<CheckoutBloc>().add(
                          CheckoutEvent.addCheckout(data.product),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // =====================================================
          // DELETE
          // =====================================================
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onDeleteTap,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xffFFF3F1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  size: 19,
                  color: Color(0xffD9534F),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // QUANTITY BUTTON
  // =============================================================

  static Widget _quantityButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: primaryLight,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 17, color: primary),
        ),
      ),
    );
  }
}
