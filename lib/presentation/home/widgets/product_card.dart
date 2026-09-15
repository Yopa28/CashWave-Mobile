import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cashwave_mobile/core/constants/variables.dart';
import 'package:cashwave_mobile/core/extensions/int_ext.dart';
import 'package:cashwave_mobile/data/models/response/product_response_model.dart';
import 'package:cashwave_mobile/presentation/home/bloc/checkout/checkout_bloc.dart';

class ProductCard extends StatelessWidget {
  final Product data;

  const ProductCard({super.key, required this.data});

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primary = Color(0xff087A55);

  static const Color primaryLight = Color(0xffE8F5F0);

  static const Color imageBackground = Color(0xffF3F7F5);

  static const Color textPrimary = Color(0xff17221E);

  static const Color textSecondary = Color(0xff7A8581);

  static const Color borderColor = Color(0xffE7ECEA);

  @override
  Widget build(BuildContext context) {
    final String imageUrl = '${Variables.imageBaseUrl}${data.image}';

    return BlocBuilder<CheckoutBloc, CheckoutState>(
      builder: (context, state) {
        // ======================================================
        // GET QUANTITY
        // ======================================================

        int quantity = 0;

        state.maybeWhen(
          success: (products, qty, price, _) {
            final productExists = products.any(
              (element) => element.product == data,
            );

            if (productExists) {
              final orderItem = products.firstWhere(
                (element) => element.product == data,
              );

              quantity = orderItem.quantity;
            }
          },
          orElse: () {},
        );

        // ======================================================
        // CARD
        // ======================================================

        return GestureDetector(
          behavior: HitTestBehavior.opaque,

          onTap: () {
            context.read<CheckoutBloc>().add(CheckoutEvent.addCheckout(data));
          },

          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(16),

              border: Border.all(color: borderColor, width: 0.8),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.035),

                  blurRadius: 12,

                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: Padding(
              padding: const EdgeInsets.all(10),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // ==================================================
                  // PRODUCT IMAGE
                  // ==================================================

                  Expanded(
                    flex: 6,

                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,

                          decoration: BoxDecoration(
                            color: imageBackground,

                            borderRadius: BorderRadius.circular(13),
                          ),

                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(13),

                            child: Image.network(
                              imageUrl,

                              width: double.infinity,

                              height: double.infinity,

                              fit: BoxFit.cover,

                              // ========================================
                              // LOADING
                              // ========================================
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }

                                    return const Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,

                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                primary,
                                              ),
                                        ),
                                      ),
                                    );
                                  },

                              // ========================================
                              // ERROR
                              // ========================================
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.restaurant_rounded,

                                    color: primary,

                                    size: 42,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // =================================================
                        // QUANTITY BADGE
                        // =================================================
                        if (quantity > 0)
                          Positioned(
                            top: 7,
                            right: 7,

                            child: Container(
                              constraints: const BoxConstraints(
                                minWidth: 28,
                                minHeight: 28,
                              ),

                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                              ),

                              decoration: BoxDecoration(
                                color: primary,

                                borderRadius: BorderRadius.circular(9),

                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),

                                boxShadow: [
                                  BoxShadow(
                                    color: primary.withOpacity(0.25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),

                              child: Center(
                                child: Text(
                                  quantity.toString(),

                                  style: const TextStyle(
                                    color: Colors.white,

                                    fontSize: 12,

                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ==================================================
                  // PRODUCT NAME
                  // ==================================================
                  Text(
                    data.name,

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      color: textPrimary,

                      fontSize: 14,

                      fontWeight: FontWeight.w700,

                      letterSpacing: -0.15,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // ==================================================
                  // CATEGORY
                  // ==================================================
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3.5,
                    ),

                    decoration: BoxDecoration(
                      color: primaryLight,

                      borderRadius: BorderRadius.circular(6),
                    ),

                    child: Text(
                      data.category,

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        color: primary,

                        fontSize: 9,

                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 9),

                  // ==================================================
                  // PRICE + ADD BUTTON
                  // ==================================================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,

                    children: [
                      // PRICE
                      Expanded(
                        child: Text(
                          data.price.currencyFormatRp,

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(
                            color: primary,

                            fontSize: 13,

                            fontWeight: FontWeight.w800,

                            letterSpacing: -0.2,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // ADD BUTTON
                      Container(
                        width: 32,
                        height: 32,

                        decoration: BoxDecoration(
                          color: primary,

                          borderRadius: BorderRadius.circular(10),

                          boxShadow: [
                            BoxShadow(
                              color: primary.withOpacity(0.18),

                              blurRadius: 7,

                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),

                        child: const Icon(
                          Icons.add_rounded,

                          color: Colors.white,

                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
