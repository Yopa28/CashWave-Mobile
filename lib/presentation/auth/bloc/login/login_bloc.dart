import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cashwave_mobile/data/models/response/auth_response_model.dart';
import 'package:cashwave_mobile/data/datasources/auth_remote_datasource.dart';

part 'login_bloc.freezed.dart';
part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRemoteDatasource authRemoteDatasource;

  // ✅ pastikan kamu inject AuthRemoteDatasource
  LoginBloc(this.authRemoteDatasource) : super(const _Initial()) {
    on<_Login>((event, emit) async {
      emit(const _Loading());

      // panggil API login
      final result = await authRemoteDatasource.login(event.email, event.password);

      result.fold(
            (errorMessage) {
          emit(_Error(errorMessage));
        },
            (authResponse) {
          emit(_Success(authResponse));
        },
      );
    });
  }
}
