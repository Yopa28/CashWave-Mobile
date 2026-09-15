import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cashwave_mobile/core/constants/colors.dart';
import 'package:cashwave_mobile/core/extensions/build_context_ext.dart';
import 'package:cashwave_mobile/core/extensions/string_ext.dart';
import 'package:cashwave_mobile/data/datasources/auth_local_datasource.dart';
import 'package:cashwave_mobile/presentation/home/bloc/checkout/checkout_bloc.dart';
import 'package:cashwave_mobile/presentation/home/models/order_item.dart';
import 'package:cashwave_mobile/presentation/home/pages/dashboard_page.dart';

import '../../../core/components/buttons.dart';
import '../../../core/components/spaces.dart';
import '../../../data/dataoutputs/cwb_print.dart';
import '../bloc/order/order_bloc.dart';
import '../widgets/order_card.dart';
import '../widgets/payment_cash_dialog.dart';
import '../widgets/process_button.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final ValueNotifier<int> indexValue = ValueNotifier<int>(0);

  final TextEditingController orderNameController = TextEditingController();

  final TextEditingController tableNumberController = TextEditingController();

  // ============================================================
  // STATE
  // ============================================================

  int totalPrice = 0;

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

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    indexValue.dispose();

    orderNameController.dispose();

    tableNumberController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: _buildAppBar(),

      // ========================================================
      // BODY
      // ========================================================
      body: BlocBuilder<CheckoutBloc, CheckoutState>(
        builder: (context, state) {
          return state.maybeWhen(
            success: (data, qty, total, draftName) {
              if (data.isEmpty) {
                return _buildEmptyState();
              }

              totalPrice = total;

              return ListView(
                physics: const BouncingScrollPhysics(),

                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),

                children: [
                  // ==========================================
                  // ORDER HEADER
                  // ==========================================

                  _buildOrderHeader(data.length, qty),

                  const SizedBox(height: 16),

                  // ==========================================
                  // ORDER ITEMS
                  // ==========================================
                  ...List.generate(data.length, (index) {
                    final item = data[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),

                      child: OrderCard(
                        padding: EdgeInsets.zero,

                        data: item,

                        onDeleteTap: () {
                          context.read<CheckoutBloc>().add(
                            CheckoutEvent.removeProduct(item.product),
                          );
                        },
                      ),
                    );
                  }),
                ],
              );
            },

            orElse: () {
              return _buildEmptyState();
            },
          );
        },
      ),

      // ========================================================
      // BOTTOM CHECKOUT
      // ========================================================
      bottomNavigationBar: _buildCheckoutBottom(),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: background,

      surfaceTintColor: Colors.transparent,

      elevation: 0,

      scrolledUnderElevation: 0,

      leading: IconButton(
        onPressed: () {
          // Karena OrderPage adalah tab Dashboard,
          // kembali ke Dashboard/Home.
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            context.pushReplacement(const DashboardPage());
          }
        },

        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: textPrimary,
          size: 20,
        ),
      ),

      title: const Text(
        'Order',
        style: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),

      centerTitle: true,

      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),

          width: 42,
          height: 42,

          decoration: BoxDecoration(
            color: primaryLight,

            borderRadius: BorderRadius.circular(12),
          ),

          child: IconButton(
            padding: EdgeInsets.zero,

            tooltip: 'Simpan Draft',

            onPressed: () {
              _showOpenBillDialog();
            },

            icon: const Icon(Icons.save_outlined, color: primary, size: 21),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ORDER HEADER
  // ============================================================

  Widget _buildOrderHeader(int itemCount, int quantity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: borderColor),
      ),

      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,

            decoration: BoxDecoration(
              color: primaryLight,

              borderRadius: BorderRadius.circular(11),
            ),

            child: const Icon(
              Icons.shopping_bag_outlined,
              color: primary,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'Pesanan Anda',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  '$itemCount produk • $quantity item',
                  style: const TextStyle(color: textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),

          Text(
            totalPrice.toString().currencyFormatRp,
            style: const TextStyle(
              color: primary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              width: 90,
              height: 90,

              decoration: BoxDecoration(
                color: primaryLight,

                borderRadius: BorderRadius.circular(27),
              ),

              child: const Icon(
                Icons.shopping_bag_outlined,
                color: primary,
                size: 43,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Belum Ada Pesanan',
              textAlign: TextAlign.center,

              style: TextStyle(
                color: textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'Tambahkan produk dari halaman menu untuk membuat pesanan.',
              textAlign: TextAlign.center,

              style: TextStyle(color: textSecondary, fontSize: 13, height: 1.5),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 42,

              child: ElevatedButton.icon(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },

                icon: const Icon(Icons.restaurant_menu_rounded, size: 18),

                label: const Text('Pilih Produk'),

                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,

                  foregroundColor: Colors.white,

                  elevation: 0,

                  padding: const EdgeInsets.symmetric(horizontal: 18),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CHECKOUT BOTTOM
  // ============================================================

  Widget _buildCheckoutBottom() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,

        border: const Border(top: BorderSide(color: borderColor, width: 0.7)),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),

            blurRadius: 20,

            offset: const Offset(0, -5),
          ),
        ],
      ),

      child: SafeArea(
        top: false,

        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              // ================================================
              // PAYMENT TITLE
              // ================================================

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  const Text(
                    'Metode Pembayaran',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  ValueListenableBuilder<int>(
                    valueListenable: indexValue,

                    builder: (context, value, _) {
                      return Text(
                        value == 1 ? 'Tunai' : 'Pilih metode',
                        style: TextStyle(
                          color: value == 1 ? primary : textSecondary,

                          fontSize: 11,

                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ================================================
              // PAYMENT METHOD
              // ================================================
              ValueListenableBuilder<int>(
                valueListenable: indexValue,

                builder: (context, value, _) {
                  return _buildPaymentMethod(isSelected: value == 1);
                },
              ),

              const SizedBox(height: 14),

              // ================================================
              // TOTAL
              // ================================================
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),

                decoration: BoxDecoration(
                  color: background,

                  borderRadius: BorderRadius.circular(12),
                ),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    const Text(
                      'Total Pembayaran',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    Text(
                      totalPrice.toString().currencyFormatRp,

                      style: const TextStyle(
                        color: primary,

                        fontSize: 18,

                        fontWeight: FontWeight.w800,

                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ================================================
              // PROCESS BUTTON
              // ================================================
              ProcessButton(
                price: totalPrice,

                onPressed: () async {
                  if (indexValue.value == 1) {
                    showDialog(
                      context: context,

                      builder: (context) {
                        return PaymentCashDialog(price: totalPrice);
                      },
                    );
                  } else {
                    _showSelectPaymentMessage();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PAYMENT METHOD
  // ============================================================

  Widget _buildPaymentMethod({required bool isSelected}) {
    return GestureDetector(
      onTap: () {
        indexValue.value = 1;

        context.read<OrderBloc>().add(
          OrderEvent.addPaymentMethod('Tunai', _getCurrentProducts(), ''),
        );
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),

        width: double.infinity,

        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),

        decoration: BoxDecoration(
          color: isSelected ? primaryLight : Colors.white,

          borderRadius: BorderRadius.circular(13),

          border: Border.all(
            color: isSelected ? primary : borderColor,

            width: isSelected ? 1.2 : 1,
          ),
        ),

        child: Row(
          children: [
            // ICON
            Container(
              width: 38,
              height: 38,

              decoration: BoxDecoration(
                color: isSelected ? primary : background,

                borderRadius: BorderRadius.circular(10),
              ),

              child: Icon(
                Icons.payments_outlined,

                color: isSelected ? Colors.white : textSecondary,

                size: 21,
              ),
            ),

            const SizedBox(width: 11),

            // TEXT
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    'Tunai',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  SizedBox(height: 2),

                  Text(
                    'Pembayaran secara tunai',
                    style: TextStyle(color: textSecondary, fontSize: 10),
                  ),
                ],
              ),
            ),

            // CHECK
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),

              width: 22,
              height: 22,

              decoration: BoxDecoration(
                color: isSelected ? primary : Colors.transparent,

                shape: BoxShape.circle,

                border: Border.all(color: isSelected ? primary : borderColor),
              ),

              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // GET CURRENT PRODUCTS
  // ============================================================

  List<OrderItem> _getCurrentProducts() {
    final checkoutState = context.read<CheckoutBloc>().state;

    return checkoutState.maybeWhen(
      success: (data, qty, total, draftName) {
        return data;
      },
      orElse: () => [],
    );
  }

  // ============================================================
  // OPEN BILL DIALOG
  // ============================================================

  void _showOpenBillDialog() {
    showDialog(
      context: context,

      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,

          insetPadding: const EdgeInsets.symmetric(horizontal: 24),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // ============================================
                // HEADER
                // ============================================

                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,

                      decoration: BoxDecoration(
                        color: primaryLight,

                        borderRadius: BorderRadius.circular(11),
                      ),

                      child: const Icon(
                        Icons.receipt_long_outlined,
                        color: primary,
                        size: 22,
                      ),
                    ),

                    const SizedBox(width: 11),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            'Simpan Draft Order',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          SizedBox(height: 3),

                          Text(
                            'Simpan pesanan untuk diproses nanti',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // ============================================
                // TABLE NUMBER
                // ============================================
                _buildInput(
                  controller: tableNumberController,

                  label: 'Nomor Meja',

                  hint: 'Contoh: 12',

                  icon: Icons.table_restaurant_outlined,

                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 13),

                // ============================================
                // ORDER NAME
                // ============================================
                _buildInput(
                  controller: orderNameController,

                  label: 'Nama Pesanan',

                  hint: 'Contoh: Sandy',

                  icon: Icons.person_outline_rounded,

                  textCapitalization: TextCapitalization.words,
                ),

                const SizedBox(height: 22),

                // ============================================
                // BUTTONS
                // ============================================
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,

                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                          },

                          style: OutlinedButton.styleFrom(
                            foregroundColor: textSecondary,

                            side: const BorderSide(color: borderColor),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),

                          child: const Text(
                            'Batal',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: SizedBox(
                        height: 44,

                        child: ElevatedButton(
                          onPressed: () async {
                            await _saveDraftOrder(dialogContext);
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,

                            foregroundColor: Colors.white,

                            elevation: 0,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),

                          child: const Text(
                            'Simpan',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // INPUT
  // ============================================================

  Widget _buildInput({
    required TextEditingController controller,

    required String label,

    required String hint,

    required IconData icon,

    TextInputType? keyboardType,

    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          label,

          style: const TextStyle(
            color: textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 7),

        TextField(
          controller: controller,

          keyboardType: keyboardType,

          textCapitalization: textCapitalization,

          style: const TextStyle(color: textPrimary, fontSize: 13),

          decoration: InputDecoration(
            hintText: hint,

            hintStyle: const TextStyle(color: textSecondary, fontSize: 12),

            prefixIcon: Icon(icon, color: textSecondary, size: 19),

            filled: true,

            fillColor: background,

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 13,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),

              borderSide: BorderSide.none,
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),

              borderSide: const BorderSide(color: borderColor),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),

              borderSide: const BorderSide(color: primary, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SAVE DRAFT
  // ============================================================

  Future<void> _saveDraftOrder(BuildContext dialogContext) async {
    try {
      final checkoutState = context.read<CheckoutBloc>().state;

      final data = checkoutState.maybeWhen(
        success: (products, qty, total, draftName) {
          return products;
        },
        orElse: () => <OrderItem>[],
      );

      if (data.isEmpty) {
        Navigator.pop(dialogContext);

        _showMessage('Tidak ada produk untuk disimpan.', isError: true);

        return;
      }

      final authData = await AuthLocalDatasource().getAuthData();

      final int tableNumber = tableNumberController.text.toIntegerFromText;

      final String orderName = orderNameController.text.trim();

      // ========================================================
      // SAVE DRAFT
      // ========================================================

      context.read<CheckoutBloc>().add(
        CheckoutEvent.saveDraftOrder(tableNumber, orderName),
      );

      // ========================================================
      // PRINT CHECKER
      // ========================================================

      final printInt = await CwbPrint.instance.printChecker(
        data,
        tableNumber,
        orderName,
        authData?.user.name ?? '',
      );

      CwbPrint.instance.printReceipt(printInt);

      // ========================================================
      // RESET CHECKOUT
      // ========================================================

      context.read<CheckoutBloc>().add(const CheckoutEvent.started());

      // Close dialog
      if (mounted) {
        Navigator.pop(dialogContext);
      }

      // Show message
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),

              SizedBox(width: 10),

              Text('Draft order berhasil disimpan'),
            ],
          ),

          backgroundColor: primary,

          behavior: SnackBarBehavior.floating,

          margin: const EdgeInsets.all(16),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      // Back to dashboard
      context.pushReplacement(const DashboardPage());
    } catch (e) {
      debugPrint('Save draft error: $e');

      if (!mounted) return;

      Navigator.pop(dialogContext);

      _showMessage('Gagal menyimpan draft order.', isError: true);
    }
  }

  // ============================================================
  // PAYMENT MESSAGE
  // ============================================================

  void _showSelectPaymentMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Pilih metode pembayaran terlebih dahulu.'),

        backgroundColor: const Color(0xffD97706),

        behavior: SnackBarBehavior.floating,

        margin: const EdgeInsets.all(16),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ============================================================
  // GENERAL MESSAGE
  // ============================================================

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),

        backgroundColor: isError ? Colors.redAccent : primary,

        behavior: SnackBarBehavior.floating,

        margin: const EdgeInsets.all(16),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
