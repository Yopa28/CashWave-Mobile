import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashwave_mobile/core/extensions/build_context_ext.dart';
import 'package:cashwave_mobile/core/extensions/date_time_ext.dart';
import 'package:cashwave_mobile/core/extensions/int_ext.dart';
import 'package:cashwave_mobile/presentation/home/bloc/checkout/checkout_bloc.dart';
import 'package:cashwave_mobile/presentation/home/pages/dashboard_page.dart';
import 'package:cashwave_mobile/presentation/order/bloc/order/order_bloc.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../data/dataoutputs/cwb_print.dart';

class PaymentSuccessDialog extends StatelessWidget {
  const PaymentSuccessDialog({super.key});

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
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            return state.maybeWhen(
              orElse: () {
                return const SizedBox.shrink();
              },
              success:
                  (
                    data,
                    qty,
                    total,
                    paymentType,
                    nominal,
                    idKasir,
                    nameKasir,
                    customerName,
                  ) {
                    return _buildContent(
                      context,
                      data: data,
                      qty: qty,
                      total: total,
                      paymentType: paymentType,
                      nominal: nominal,
                      idKasir: idKasir,
                      nameKasir: nameKasir,
                      customerName: customerName,
                    );
                  },
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent(
    BuildContext context, {
    required dynamic data,
    required int qty,
    required int total,
    required String paymentType,
    required int nominal,
    required dynamic idKasir,
    required String nameKasir,
    required String customerName,
  }) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ======================================================
          // SUCCESS ICON
          // ======================================================

          _buildSuccessIcon(),

          const SizedBox(height: 18),

          const Text(
            'Pembayaran Berhasil',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Transaksi berhasil diproses',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: textSecondary),
          ),

          const SizedBox(height: 22),

          // ======================================================
          // TOTAL
          // ======================================================
          _buildTotalCard(total),

          const SizedBox(height: 18),

          // ======================================================
          // TRANSACTION DETAILS
          // ======================================================
          _buildTransactionDetails(
            paymentType: paymentType,
            qty: qty,
            total: total,
            nameKasir: nameKasir,
          ),

          const SizedBox(height: 22),

          // ======================================================
          // ACTION BUTTONS
          // ======================================================
          Row(
            children: [
              Expanded(
                child: _buildOutlinedButton(
                  label: 'Cetak',
                  icon: Icons.print_outlined,
                  onTap: () async {
                    final printValue = await CwbPrint.instance.printOrderV2(
                      data,
                      qty,
                      total,
                      paymentType,
                      nominal,
                      nameKasir,
                      customerName,
                    );

                    await PrintBluetoothThermal.writeBytes(printValue);
                  },
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _buildPrimaryButton(
                  label: 'Selesai',
                  icon: Icons.check_rounded,
                  onTap: () {
                    // Reset checkout
                    context.read<CheckoutBloc>().add(
                      const CheckoutEvent.started(),
                    );

                    // Reset order
                    context.read<OrderBloc>().add(const OrderEvent.started());

                    // Back to dashboard
                    context.pushReplacement(const DashboardPage());
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUCCESS ICON
  // ============================================================

  Widget _buildSuccessIcon() {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: primaryLight,
        shape: BoxShape.circle,
        border: Border.all(color: primary.withOpacity(0.08), width: 8),
      ),
      child: Container(
        margin: const EdgeInsets.all(5),
        decoration: const BoxDecoration(color: primary, shape: BoxShape.circle),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 38),
      ),
    );
  }

  // ============================================================
  // TOTAL CARD
  // ============================================================

  Widget _buildTotalCard(int total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          const Text(
            'Total Pembayaran',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: textSecondary,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            total.currencyFormatRp,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: primary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TRANSACTION DETAILS
  // ============================================================

  Widget _buildTransactionDetails({
    required String paymentType,
    required int qty,
    required int total,
    required String nameKasir,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            icon: Icons.payments_outlined,
            label: 'Metode Pembayaran',
            value: paymentType == 'QRIS' ? 'QRIS' : 'Tunai',
          ),

          _buildDivider(),

          _buildDetailRow(
            icon: Icons.shopping_bag_outlined,
            label: 'Jumlah Item',
            value: qty.toString(),
          ),

          _buildDivider(),

          _buildDetailRow(
            icon: Icons.person_outline_rounded,
            label: 'Nama Kasir',
            value: nameKasir,
          ),

          _buildDivider(),

          _buildDetailRow(
            icon: Icons.schedule_outlined,
            label: 'Tanggal Transaksi',
            value: DateTime.now().toFormattedTime(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: primaryLight,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 17, color: primary),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(width: 8),

        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 11),
      child: Divider(height: 1, color: borderColor),
    );
  }

  // ============================================================
  // PRIMARY BUTTON
  // ============================================================

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 19),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // OUTLINED BUTTON
  // ============================================================

  Widget _buildOutlinedButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: borderColor),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
