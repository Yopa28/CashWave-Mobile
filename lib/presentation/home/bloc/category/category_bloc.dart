import 'package:bloc/bloc.dart';
import 'package:cashwave_mobile/data/datasources/product_local_datasource.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:cashwave_mobile/data/datasources/product_remote_datasource.dart';
import '../../../../data/models/response/category_response_model.dart';

part 'category_bloc.freezed.dart';
part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final ProductRemoteDatasource productRemoteDatasource;
  List<Category> categories = [];

  CategoryBloc(
    this.productRemoteDatasource,
  ) : super(const _Initial()) {
    /// Event: getCategories from remote API
    on<_GetCategories>((event, emit) async {
      emit(const _Loading());
      final result = await productRemoteDatasource.getCategories();
      result.fold(
        (l) => emit(_Error(l)),
        (r) => emit(_Loaded(r.data)),
      );
    });

    /// Event: getCategoriesLocal — ambil dari local storage,
    /// tapi jika kosong, isi default (Makanan, Minuman, Snack)
    on<_GetCategoriesLocal>((event, emit) async {
      emit(const _Loading());

      try {
        categories = await ProductLocalDatasource.instance.getAllCategories();

        if (categories.isEmpty) {
          categories = [
            Category(id: 1, name: 'makanan'),
            Category(id: 2, name: 'minuman'),
            Category(id: 3, name: 'snack'),
          ];

          // Opsional: Simpan ke local jika kamu punya method-nya
          // await ProductLocalDatasource.instance.saveCategories(categories);
        }

        emit(_LoadedLocal(categories));
      } catch (e) {
        emit(const _Error('Gagal memuat kategori'));
      }
    });
  }
}
