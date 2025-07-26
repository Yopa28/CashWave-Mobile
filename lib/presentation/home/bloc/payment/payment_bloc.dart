import 'package:flutter_bloc/flutter_bloc.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc() : super(const PaymentState.initial()) {
    on<PaymentEvent>((event, emit) async {
      await event.map(
        bayarPdam: (e) async {
          // saat tombol ditekan -> ubah state ke loading
          emit(const PaymentState.loading());

          try {
            // simulasi proses bayar (bisa diganti call API)
            await Future.delayed(const Duration(seconds: 2));

            // contoh sukses
            emit(const PaymentState.success(message: 'Pembayaran berhasil'));
          } catch (e) {
            emit(PaymentState.error(message: 'Gagal: ${e.toString()}'));
          }
        },
      );
    });
  }
}
