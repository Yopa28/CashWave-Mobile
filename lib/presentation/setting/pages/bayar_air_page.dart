import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashwave_mobile/core/components/spaces.dart';
import 'package:cashwave_mobile/core/extensions/build_context_ext.dart';
import 'package:cashwave_mobile/core/constants/colors.dart';
import 'package:cashwave_mobile/presentation/home/bloc/payment/payment_bloc.dart';
import 'package:cashwave_mobile/presentation/home/bloc/payment/payment_event.dart';
import 'package:cashwave_mobile/presentation/home/bloc/payment/payment_state.dart';




class BayarAirPage extends StatefulWidget {
  const BayarAirPage({super.key});

  @override
  State<BayarAirPage> createState() => _BayarAirPageState();
}

class _BayarAirPageState extends State<BayarAirPage> {
  final TextEditingController idPelangganController = TextEditingController();

  @override
  void dispose() {
    idPelangganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text('Bayar Air PDAM'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          TextField(
            controller: idPelangganController,
            decoration: const InputDecoration(
              labelText: 'ID Pelanggan PDAM',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SpaceHeight(20),
          BlocConsumer<PaymentBloc, PaymentState>(
            listener: (context, state) {
              state.maybeMap(
                orElse: () {},
                success: (data) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.primary,
                      content: Text('Pembayaran PDAM berhasil'),
                    ),
                  );
                },
                error: (message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text('Gagal: $message'),
                    ),
                  );
                },
              );
            },
            builder: (context, state) {
              return state.maybeWhen(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                orElse: () {
                  return ElevatedButton(
                    onPressed: () {
                      final idPelanggan = idPelangganController.text.trim();
                      if (idPelanggan.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.orange,
                            content: Text('ID pelanggan tidak boleh kosong'),
                          ),
                        );
                        return;
                      }
                      context.read<PaymentBloc>().add(
                        PaymentEvent.bayarPdam(idPelanggan: idPelanggan),
                      );
                    },
                    child: const Text('Bayar Air PDAM'),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
