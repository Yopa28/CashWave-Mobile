import 'package:flutter/material.dart';
import 'package:cashwave_mobile/core/extensions/int_ext.dart';
import 'package:cashwave_mobile/core/extensions/string_ext.dart';
import 'package:cashwave_mobile/data/dataoutputs/cwb_print.dart';
import 'package:cashwave_mobile/presentation/order/models/order_model.dart';

class HistoryTransactionCard extends StatelessWidget {
  final OrderModel data;
  final EdgeInsetsGeometry? padding;

  const HistoryTransactionCard({super.key, required this.data, this.padding});

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primary = Color(0xff087A55);
  static const Color primaryDark = Color(0xff065C40);
  static const Color primaryLight = Color(0xffE8F5F0);

  static const Color background = Color(0xffF7F9F8);
  static const Color textPrimary = Color(0xff17221E);
  static const Color textSecondary = Color(0xff7A8581);
  static const Color borderColor = Color(0xffE5EBE8);

  @override
  Widget build(BuildContext context) {
    final bool isQris = data.paymentMethod == 'QRIS';
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: padding,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: colorScheme.outlineVariant,
          splashColor: primaryLight,
          highlightColor: primaryLight,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          childrenPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          iconColor: primary,
          collapsedIconColor: textSecondary,

          // ======================================================
          // HEADER
          // ======================================================
          title: Row(
            children: [
              // Payment Icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isQris ? Icons.qr_code_2_rounded : Icons.payments_outlined,
                  color: primary,
                  size: 21,
                ),
              ),

              const SizedBox(width: 12),

              // Transaction info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            data.transactionTime.toFormattedTime,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),

                        const SizedBox(width: 7),

                        // Payment badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: primaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isQris ? 'QRIS' : 'CASH',
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '${data.totalQuantity} item${data.totalQuantity > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Total
              Text(
                data.totalPrice.currencyFormatRp,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: primary,
                ),
              ),
            ],
          ),

          // ======================================================
          // DETAILS
          // ======================================================
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(color: borderColor, height: 1),

                  const SizedBox(height: 14),

                  // Transaction info
                  _buildTransactionInfo(isQris),

                  const SizedBox(height: 16),

                  // Items
                  _buildItems(),

                  const SizedBox(height: 16),

                  // Print button
                  _buildPrintButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TRANSACTION INFO
  // ============================================================

  Widget _buildTransactionInfo(bool isQris) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: _infoItem(
              icon: isQris ? Icons.qr_code_rounded : Icons.payments_outlined,
              label: 'Pembayaran',
              value: isQris ? 'QRIS' : 'Cash',
            ),
          ),

          Container(width: 1, height: 32, color: borderColor),

          Expanded(
            child: _infoItem(
              icon: Icons.person_outline_rounded,
              label: 'Kasir',
              value: data.namaKasir,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        const SizedBox(width: 10),

        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: primaryLight,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 16, color: primary),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 9, color: textSecondary),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ITEMS
  // ============================================================

  Widget _buildItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Detail Pesanan',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
        ),

        const SizedBox(height: 10),

        ...data.orders.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return Padding(
            padding: EdgeInsets.only(
              bottom: index == data.orders.length - 1 ? 0 : 10,
            ),
            child: _buildItem(
              name: item.product.name,
              quantity: item.quantity,
              price: item.product.price,
              total: item.quantity * item.product.price,
            ),
          );
        }),
      ],
    );
  }

  // ============================================================
  // SINGLE ITEM
  // ============================================================

  Widget _buildItem({
    required String name,
    required int quantity,
    required int price,
    required int total,
  }) {
    return Row(
      children: [
        // Quantity
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$quantity',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: primary,
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Name + price
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                '${quantity} × ${price.currencyFormatRp}',
                style: const TextStyle(fontSize: 9, color: textSecondary),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Subtotal
        Text(
          total.currencyFormatRp,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: primary,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PRINT BUTTON
  // ============================================================

  Widget _buildPrintButton() {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton.icon(
        onPressed: () async {
          final printValue = await CwbPrint.instance.printOrderV2(
            data.orders,
            data.totalQuantity,
            data.totalPrice,
            data.paymentMethod,
            data.nominalBayar,
            data.namaKasir,
            'Customer',
          );

          CwbPrint.instance.printReceipt(printValue);
        },
        icon: const Icon(Icons.print_outlined, size: 18),
        label: const Text(
          'Cetak Struk',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          backgroundColor: Colors.white,
          side: const BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
