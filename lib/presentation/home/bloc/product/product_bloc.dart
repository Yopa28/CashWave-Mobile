import 'package:bloc/bloc.dart';
import 'package:cashwave_mobile/data/datasources/product_local_datasource.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:cashwave_mobile/data/datasources/product_remote_datasource.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../data/models/request/product_request_model.dart';
import '../../../../data/models/response/product_response_model.dart';

part 'product_bloc.freezed.dart';
part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRemoteDatasource _productRemoteDatasource;
  List<Product> products = [];
  ProductBloc(this._productRemoteDatasource) : super(const _Initial()) {
    on<_Fetch>((event, emit) async {
      emit(const ProductState.loading());
      try {
        print('[ProductBloc] Calling API getProducts()');
        final response = await _productRemoteDatasource.getProducts();
        print('[ProductBloc] API Response: $response');

        response.fold(
          (l) {
            print('[ProductBloc] API Error: $l');
            emit(ProductState.error(l));
          },
          (r) {
            print('[ProductBloc] API Success, product count: ${r.data.length}');
            products = r.data;
            emit(ProductState.success(r.data));
          },
        );
      } catch (e) {
        print('[ProductBloc] Unexpected error: $e');
        emit(ProductState.error("Unexpected error: $e"));
      }
    });

    on<_FetchLocal>((event, emit) async {
      emit(const ProductState.loading());
      final localPproducts = await ProductLocalDatasource.instance
          .getAllProduct();
      products = localPproducts;

      emit(ProductState.success(products));
    });

    on<_FetchByCategory>((event, emit) async {
      emit(const ProductState.loading());

      final newProducts = event.category.toLowerCase() == 'all'
          ? products
          : products.where((element) {
        final productCat = (element.category ?? '').toLowerCase();
        return productCat == event.category.toLowerCase();
      }).toList();

      emit(ProductState.success(newProducts));
    });



    on<_AddProduct>((event, emit) async {
  emit(const ProductState.loading());

  final requestData = ProductRequestModel(
    name: event.product.name,
    price: event.product.price,
    stock: event.product.stock,
    category: event.product.category,
    categoryId: event.product.categoryId,
    isBestSeller: event.product.isBestSeller ? 1 : 0,
    image: event.image,
  );

  final response = await _productRemoteDatasource.addProduct(requestData);

  response.fold(
    (l) {
      emit(ProductState.error(l));
    },
    (r) {
      // tambahkan produk baru ke list lokal
      products.add(r.data);
      emit(ProductState.success(List.from(products))); // buat copy supaya UI update
    },
  );
});


    on<_SearchProduct>((event, emit) async {
      emit(const ProductState.loading());
      final newProducts = products
          .where(
            (element) =>
                element.name.toLowerCase().contains(event.query.toLowerCase()),
          )
          .toList();

      emit(ProductState.success(newProducts));
    });

    on<_FetchAllFromState>((event, emit) async {
      emit(const ProductState.loading());

      emit(ProductState.success(products));
    });
  }
}
