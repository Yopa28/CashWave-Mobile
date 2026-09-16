import 'dart:convert';

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

  static const Color primary = Color(0xff087A55);
  static const Color primaryDark = Color(0xff065C40);
  static const Color primaryLight = Color(0xffE8F5F0);

  static const Color background = Color(0xffF7F9F8);
  static const Color textPrimary = Color(0xff17221E);
  static const Color textSecondary = Color(0xff7A8581);
  static const Color borderColor = Color(0xffE5EBE8);

  bool _isProcessing = false;

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

  int get _enteredAmount {
    return priceController.text.toIntegerFromText;
  }

  int get _change {
    final change = _enteredAmount - widget.price;
    return change < 0 ? 0 : change;
  }

  bool get _isEnough {
    return _enteredAmount >= widget.price;
  }

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
              const SizedBox(height: 16),
              _buildChangePreview(),
              const SizedBox(height: 24),
              _buildPayButton(),
            ],
          ),
        ),
      ),
    );
  }

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
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isProcessing ? null : () => Navigator.pop(context),
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
            border: Border.all(
              color: _isEnough ? primary.withOpacity(0.35) : borderColor,
            ),
          ),
          child: TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            enabled: !_isProcessing,
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
            onChanged: (value) {
              _formatPrice(value);
              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  void _formatPrice(String value) {
    final int priceValue = value.toIntegerFromText;

    final formatted = priceValue.currencyFormatRp;

    if (priceController.text == formatted) {
      return;
    }

    priceController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  Widget _buildQuickAmountButtons() {
    final amounts = <int>[
      widget.price,
      _roundUp(widget.price, 5000),
      _roundUp(widget.price, 10000),
      _roundUp(widget.price, 50000),
    ];

    final uniqueAmounts = amounts.toSet().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nominal Cepat',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: uniqueAmounts.map((amount) {
            final isExact = amount == widget.price;

            return _quickAmountButton(
              label: isExact ? 'Uang Pas' : amount.currencyFormatRp,
              amount: amount,
            );
          }).toList(),
        ),
      ],
    );
  }

  int _roundUp(int value, int multiple) {
    return ((value + multiple - 1) ~/ multiple) * multiple;
  }

  Widget _quickAmountButton({required String label, required int amount}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isProcessing
            ? null
            : () {
                final formatted = amount.currencyFormatRp;

                priceController.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );

                setState(() {});
              },
        borderRadius: BorderRadius.circular(11),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          decoration: BoxDecoration(
            color: amount == widget.price ? primaryLight : background,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: amount == widget.price
                  ? primary.withOpacity(0.15)
                  : borderColor,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChangePreview() {
    final enough = _isEnough;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: enough ? primaryLight : const Color(0xfffff1f0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: enough ? primary.withOpacity(0.10) : const Color(0xfff2d2d0),
        ),
      ),
      child: Row(
        children: [
          Icon(
            enough
                ? Icons.check_circle_outline_rounded
                : Icons.info_outline_rounded,
            size: 20,
            color: enough ? primary : const Color(0xffD9534F),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              enough ? 'Kembalian' : 'Nominal pembayaran masih kurang',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: enough ? textPrimary : const Color(0xffD9534F),
              ),
            ),
          ),
          if (enough)
            Text(
              _change.currencyFormatRp,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: primary,
              ),
            ),
        ],
      ),
    );
  }

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
                if (!mounted) return;

                try {
                  final transactionTime = DateFormat(
                    'yyyy-MM-ddTHH:mm:ss',
                  ).format(DateTime.now());

                  // Simpan transaksi ke local
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

                  // Kirim transaksi ke server
                  final orderRequestModel = OrderRequestModel(
                    transactionTime: transactionTime,
                    kasirId: idKasir,
                    totalPrice: total,
                    totalItem: qty,
                    paymentMethod: payment,
                    orderItems: data
                        .map(
                          (e) => OrderItemModel(
                            productId: e.product.id!,
                            quantity: e.quantity,
                            totalPrice: e.product.price * e.quantity,
                          ),
                        )
                        .toList(),
                  );

                  print('📦 ORDER REQUEST:');
                  print(jsonEncode(orderRequestModel.toMap()));

                  final sent = await OrderRemoteDatasource().sendOrder(
                    orderRequestModel,
                  );

                  if (!sent) {
                    if (!mounted) return;

                    setState(() {
                      _isProcessing = false;
                    });

                    _showError(
                      context,
                      title: 'Order Gagal',
                      message:
                          'Pesanan tersimpan di perangkat, '
                          'tetapi belum berhasil dikirim ke server.',
                    );

                    return;
                  }

                  print('✅ Order berhasil dikirim ke server');

                  if (!mounted) return;

                  setState(() {
                    _isProcessing = false;
                  });

                  context.pop();

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return const PaymentSuccessDialog();
                    },
                  );
                } catch (e) {
                  print('❌ Error proses pembayaran: $e');

                  if (!mounted) return;

                  setState(() {
                    _isProcessing = false;
                  });

                  _showError(
                    context,
                    title: 'Pembayaran Gagal',
                    message: 'Pesanan gagal diproses. Silakan coba lagi.',
                  );
                }
              },
          error: (message) {
            if (!mounted) return;

            setState(() {
              _isProcessing = false;
            });

            _showError(context, title: 'Pembayaran Gagal', message: message);
          },
        );
      },
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: (!_isEnough || _isProcessing)
                ? null
                : () => _handlePayment(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              disabledBackgroundColor: const Color(0xffDDE5E1),
              foregroundColor: Colors.white,
              disabledForegroundColor: const Color(0xff9AA5A1),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: _isProcessing
                ? const SizedBox(
                    width: 21,
                    height: 21,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _change > 0
                            ? 'Bayar • ${_change.currencyFormatRp}'
                            : 'Bayar Sekarang',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  void _handlePayment(BuildContext context) {
    if (_isProcessing) return;

    final nominal = _enteredAmount;
    final total = widget.price;

    if (nominal <= 0) {
      _showError(
        context,
        title: 'Nominal Belum Diisi',
        message: 'Silakan masukkan nominal pembayaran terlebih dahulu.',
      );
      return;
    }

    if (nominal < total) {
      _showError(
        context,
        title: 'Nominal Tidak Cukup',
        message:
            'Nominal pembayaran tidak boleh lebih kecil '
            'dari total pesanan.',
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    context.read<OrderBloc>().add(OrderEvent.addNominalBayar(nominal));
  }

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
