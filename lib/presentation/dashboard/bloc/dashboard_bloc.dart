import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../data/datasources/dashboard_remote_datasource.dart';
import '../../../../data/models/response/dashboard_response_model.dart';

part 'dashboard_bloc.freezed.dart';
part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRemoteDatasource _dashboardRemoteDatasource;

  DashboardBloc(this._dashboardRemoteDatasource)
    : super(const DashboardState.initial()) {
    // ============================================================
    // FETCH DASHBOARD
    // ============================================================

    on<_Fetch>((event, emit) async {
      emit(const DashboardState.loading());

      try {
        print('[DashboardBloc] Calling API getDashboard()');

        final response = await _dashboardRemoteDatasource.getDashboard();

        print('[DashboardBloc] API Response: $response');

        response.fold(
          (error) {
            print('[DashboardBloc] API Error: $error');

            emit(DashboardState.error(error));
          },
          (data) {
            print('[DashboardBloc] API Success');

            emit(DashboardState.success(data));
          },
        );
      } catch (e) {
        print('[DashboardBloc] Unexpected error: $e');

        emit(DashboardState.error("Unexpected error: $e"));
      }
    });
  }
}
