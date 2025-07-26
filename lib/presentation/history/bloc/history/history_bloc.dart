import 'package:bloc/bloc.dart';
import 'package:cashwave_mobile/data/datasources/product_local_datasource.dart';
import 'package:cashwave_mobile/presentation/order/models/order_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'history_event.dart';
part 'history_state.dart';
part 'history_bloc.freezed.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc() : super(const HistoryState.initial()) {
    on<_Fetch>((event, emit) async {
      print('[HistoryBloc] Event fetch() dipanggil');
      emit(const HistoryState.loading());

      try {
        // Sementara: simulasikan delay & dummy data
        await Future.delayed(const Duration(seconds: 1));

        // ✅ Ganti ini ke datasource asli jika sudah OK
        final data = await ProductLocalDatasource.instance.getAllOrder();

        print('[HistoryBloc] Data didapat: ${data.length} item');
        emit(HistoryState.success(data));
      } catch (e, st) {
        print('[HistoryBloc] ERROR: $e\n$st');
        emit(HistoryState.error(e.toString()));
      }
    });
  }
}
