import 'package:bloc/bloc.dart';
import 'package:cashwave_mobile/data/datasources/auth_local_datasource.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../home/models/order_item.dart';

part 'order_event.dart';
part 'order_state.dart';
part 'order_bloc.freezed.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc() : super(const _Success([], 0, 0, '', 0, 0, '', '')) {
    // 👉 Event: Tambah Payment Method
    on<_AddPaymentMethod>((event, emit) async {
      emit(const _Loading());

      // 🔹 Ambil data auth dari local storage
      final authData = await AuthLocalDatasource().getAuthData();

      // 🔹 Pastikan authData tidak null
      final kasirId = authData?.user.id ?? 0;
      final kasirName = authData?.user.name ?? '';

      // 🔹 Hitung total quantity & total price
      final totalQty = event.orders.fold<int>(
        0,
            (prev, e) => prev + e.quantity,
      );
      final totalPrice = event.orders.fold<int>(
        0,
            (prev, e) => prev + (e.quantity * e.product.price),
      );

      emit(_Success(
        event.orders,
        totalQty,
        totalPrice,
        event.paymentMethod,
        0,
        kasirId,
        kasirName,
        event.customerName,
      ));
    });

    // 👉 Event: Tambah Nominal Bayar
    on<_AddNominalBayar>((event, emit) {
      final current = state;
      if (current is _Success) {
        emit(const _Loading());
        emit(_Success(
          current.products,
          current.totalQuantity,
          current.totalPrice,
          current.paymentMethod,
          event.nominal,
          current.idKasir,
          current.namaKasir,
          current.customerName,
        ));
      }
    });

    // 👉 Event: Reset (Started)
    on<_Started>((event, emit) {
      emit(const _Loading());
      emit(const _Success([], 0, 0, '', 0, 0, '', ''));
    });
  }
}
