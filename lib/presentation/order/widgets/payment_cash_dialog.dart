import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashwave_mobile/core/extensions/build_context_ext.dart';
import 'package:cashwave_mobile/core/extensions/int_ext.dart';
import 'package:cashwave_mobile/core/extensions/string_ext.dart';
import 'package:cashwave_mobile/data/datasources/order_remote_datasource.dart';
import 'package:cashwave_mobile/data/datasources/product_local_datasource.dart';
import 'package:cashwave_mobile/data/models/request/order_request_model.dart';
import 'package:cashwave_mobile/presentation/order/bloc/order/order_bloc.dart';
import 'package:cashwave_mobile/presentation/order/models/order_model.dart';
import 'package:cashwave_mobile/presentation/order/widgets/payment_success_dialog.dart';
import 'package:intl/intl.dart';

class PaymentCashDialog extends StatefulWidget {
  final int price;

  const PaymentCashDialog({super.key, required this.price});

  @override
  State<PaymentCashDialog> createState() => _PaymentCashDialogState();
}

class _PaymentCashDialogState extends State<PaymentCashDialog> {
  late final TextEditingController priceController;

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
  void initState() {
    super.initState();

    priceController = TextEditingController(
      text: widget.price.currencyFormatRp,
    );
  }

  @override
  void dispose() {
    priceController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 22),

              _buildTotalCard(),

              const SizedBox(height: 20),

              _buildPaymentInput(),

              const SizedBox(height: 12),

              _buildQuickAmountButtons(),

              const SizedBox(height: 24),

              _buildPayButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: primaryLight,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.payments_outlined, color: primary, size: 23),
        ),

        const SizedBox(width: 12),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pembayaran Tunai',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Masukkan nominal pembayaran',
                style: TextStyle(fontSize: 12, color: textSecondary),
              ),
            ],
          ),
        ),

        // CLOSE
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.pop(),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 20,
                color: textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TOTAL CARD
  // ============================================================

  Widget _buildTotalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: primary,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total yang harus dibayar',
                  style: TextStyle(
                    fontSize: 11,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Total Pesanan',
                  style: TextStyle(
                    fontSize: 13,
                    color: textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Text(
            widget.price.currencyFormatRp,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: primary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAYMENT INPUT
  // ============================================================

  Widget _buildPaymentInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nominal Pembayaran',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),

        const SizedBox(height: 9),

        Container(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: borderColor),
          ),
          child: TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
            decoration: const InputDecoration(
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 16, right: 8),
                child: Text(
                  'Rp',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: primary,
                  ),
                ),
              ),
              prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
              hintText: '0',
              hintStyle: TextStyle(color: Color(0xffAAB3AF)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 17,
              ),
            ),
            onChanged: _formatPrice,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FORMAT PRICE
  // ============================================================

  void _formatPrice(String value) {
    final int priceValue = value.toIntegerFromText;

    final formatted = priceValue.currencyFormatRp;

    priceController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  // ============================================================
  // QUICK AMOUNT
  // ============================================================

  Widget _buildQuickAmountButtons() {
    return Row(
      children: [
        Expanded(
          child: _quickAmountButton(
            label: 'Uang Pas',
            onTap: () {
              priceController.text = widget.price.currencyFormatRp;

              priceController.selection = TextSelection.collapsed(
                offset: priceController.text.length,
              );
            },
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: _quickAmountButton(
            label: widget.price.currencyFormatRp,
            onTap: () {
              priceController.text = widget.price.currencyFormatRp;

              priceController.selection = TextSelection.collapsed(
                offset: priceController.text.length,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _quickAmountButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: primaryLight,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: primary,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PAY BUTTON
  // ============================================================

  Widget _buildPayButton() {
    return BlocConsumer<OrderBloc, OrderState>(
      listener: (context, state) {
        state.maybeWhen(
          orElse: () {},
          success:
              (
                data,
                qty,
                total,
                payment,
                nominal,
                idKasir,
                namaKasir,
                _,
              ) async {
                final transactionTime = DateFormat(
                  'yyyy-MM-ddTHH:mm:ss',
                ).format(DateTime.now());

                // ==================================================
                // SAVE LOCAL ORDER
                // ==================================================

                final orderModel = OrderModel(
                  paymentMethod: payment,
                  nominalBayar: nominal,
                  orders: data,
                  totalQuantity: qty,
                  totalPrice: total,
                  idKasir: idKasir,
                  namaKasir: namaKasir,
                  transactionTime: transactionTime,
                  isSync: true,
                );

                await ProductLocalDatasource.instance.saveOrder(orderModel);

                // ==================================================
                // SEND ORDER TO SERVER
                // ==================================================

                final orderRequestModel = OrderRequestModel(
                  transactionTime: transactionTime,
                  kasirId: idKasir,
                  totalPrice: total,
                  totalItem: qty,
                  paymentMethod: payment,
                  orderItems: data
                      .map(
                        (e) => OrderItemModel(
                          productId: e.product.productId!,
                          quantity: e.quantity,
                          totalPrice: e.product.price * e.quantity,
                        ),
                      )
                      .toList(),
                );

                await OrderRemoteDatasource().sendOrder(orderRequestModel);

                if (!context.mounted) return;

                context.pop();

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return const PaymentSuccessDialog();
                  },
                );
              },
        );
      },
      builder: (context, state) {
        return state.maybeWhen(
          orElse: () {
            return _payButton(context, enabled: true);
          },
          error: (message) {
            return _payButton(context, enabled: true);
          },
          success: (data, qty, total, payment, _, idKasir, namaKasir, __) {
            return _payButton(context, enabled: true, total: total);
          },
        );
      },
    );
  }

  Widget _payButton(BuildContext context, {required bool enabled, int? total}) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: enabled ? () => _handlePayment(context, total) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 20),
            SizedBox(width: 8),
            Text(
              'Bayar Sekarang',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HANDLE PAYMENT
  // ============================================================

  void _handlePayment(BuildContext context, int? totalFromState) {
    final text = priceController.text.trim();

    // EMPTY
    if (text.isEmpty) {
      _showError(
        context,
        title: 'Nominal Belum Diisi',
        message: 'Silakan masukkan nominal pembayaran terlebih dahulu.',
      );
      return;
    }

    final nominal = text.toIntegerFromText;

    final total = totalFromState ?? widget.price;

    // LESS THAN TOTAL
    if (nominal < total) {
      _showError(
        context,
        title: 'Nominal Tidak Cukup',
        message:
            'Nominal pembayaran tidak boleh lebih kecil dari total pesanan.',
      );
      return;
    }

    // SEND EVENT
    context.read<OrderBloc>().add(OrderEvent.addNominalBayar(nominal));
  }

  // ============================================================
  // ERROR DIALOG
  // ============================================================

  void _showError(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xfffff1f0),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: Color(0xffD9534F),
                    size: 28,
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: textSecondary,
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Mengerti',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
