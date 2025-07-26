import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashwave_mobile/core/constants/colors.dart';
import 'package:cashwave_mobile/core/extensions/build_context_ext.dart';
import 'package:cashwave_mobile/core/extensions/string_ext.dart';
import 'package:cashwave_mobile/data/datasources/auth_local_datasource.dart';
import 'package:cashwave_mobile/presentation/home/bloc/checkout/checkout_bloc.dart';
import 'package:cashwave_mobile/presentation/home/models/order_item.dart';
import 'package:cashwave_mobile/presentation/home/pages/dashboard_page.dart';

import '../../../core/assets/assets.gen.dart';
import '../../../core/components/buttons.dart';
import '../../../core/components/menu_button.dart';
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
  final indexValue = ValueNotifier(0);
  final TextEditingController orderNameController = TextEditingController();
  final TextEditingController tableNumberController = TextEditingController();

  List<OrderItem> orders = [];
  int totalPrice = 0;

  int calculateTotalPrice(List<OrderItem> orders) {
    return orders.fold(
      0,
          (prev, e) => prev + (e.product.price * e.quantity),
    );
  }

  @override
  void dispose() {
    orderNameController.dispose();
    tableNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const paddingHorizontal = EdgeInsets.symmetric(horizontal: 16.0);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.push(const DashboardPage());
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text(
          'Order Detail',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Open Bill'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Table Number',
                          ),
                          keyboardType: TextInputType.number,
                          controller: tableNumberController,
                        ),
                        const SpaceHeight(12),
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Order Name',
                          ),
                          controller: orderNameController,
                          textCapitalization: TextCapitalization.words,
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      BlocBuilder<CheckoutBloc, CheckoutState>(
                        builder: (context, state) {
                          return state.maybeWhen(
                            success: (data, qty, total, draftName) {
                              return Button.outlined(
                                onPressed: () async {
                                  final authData = await AuthLocalDatasource().getAuthData();

                                  // event simpan draft order
                                  context.read<CheckoutBloc>().add(
                                    CheckoutEvent.saveDraftOrder(
                                      tableNumberController.text.toIntegerFromText,
                                      orderNameController.text,
                                    ),
                                  );

                                  // cetak
                                  final printInt = await CwbPrint.instance.printChecker(
                                    data,
                                    tableNumberController.text.toInt,
                                    orderNameController.text,
                                    authData?.user.name ?? '',
                                  );

                                  CwbPrint.instance.printReceipt(printInt);

                                  // reset checkout
                                  context.read<CheckoutBloc>().add(
                                    const CheckoutEvent.started(),
                                  );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Save Draft Order Success'),
                                      backgroundColor: AppColors.primary,
                                    ),
                                  );

                                  context.pushReplacement(const DashboardPage());
                                },
                                label: 'Save',
                                fontSize: 14,
                                height: 40,
                                width: 140,
                              );
                            },
                            orElse: () => const SizedBox.shrink(),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.save_as_outlined, color: Colors.white),
          ),
          const SpaceWidth(8),
        ],
      ),
      body: BlocBuilder<CheckoutBloc, CheckoutState>(
        builder: (context, state) {
          return state.maybeWhen(
            success: (data, qty, total, draftName) {
              if (data.isEmpty) {
                return const Center(child: Text('No Data'));
              }
              totalPrice = total;
              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                itemCount: data.length,
                separatorBuilder: (context, index) => const SpaceHeight(20.0),
                itemBuilder: (context, index) {
                  return OrderCard(
                    padding: paddingHorizontal,
                    data: data[index],
                    onDeleteTap: () {
                      context.read<CheckoutBloc>().add(
                        CheckoutEvent.removeProduct(data[index].product),
                      );
                    },
                  );
                },
              );
            },
            orElse: () => const Center(child: Text('No Data')),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocBuilder<CheckoutBloc, CheckoutState>(
              builder: (context, state) {
                return state.maybeWhen(
                  success: (data, qty, total, draftName) {
                    return ValueListenableBuilder<int>(
                      valueListenable: indexValue,
                      builder: (context, value, _) {
                        return Row(
                          children: [
                            Flexible(
                              child: MenuButton(
                                iconPath: Assets.icons.cash.path,
                                label: 'CASH',
                                isActive: value == 1,
                                onPressed: () {
                                  indexValue.value = 1;
                                  context.read<OrderBloc>().add(
                                    OrderEvent.addPaymentMethod(
                                      'Tunai',
                                      data,
                                      draftName,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SpaceWidth(16.0),
                          ],
                        );
                      },
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                );
              },
            ),
            const SpaceHeight(20.0),
            ProcessButton(
              price: totalPrice,
              onPressed: () async {
                if (indexValue.value == 1) {
                  showDialog(
                    context: context,
                    builder: (context) => PaymentCashDialog(
                      price: totalPrice,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
