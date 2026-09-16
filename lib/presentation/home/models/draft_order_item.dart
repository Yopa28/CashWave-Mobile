import 'dart:convert';

import 'package:cashwave_mobile/data/models/request/order_request_model.dart';
import 'package:cashwave_mobile/data/models/response/product_response_model.dart';

class DraftOrderItem {
  final Product product;
  int quantity;

  DraftOrderItem({required this.product, required this.quantity});

  Map<String, dynamic> toMap() {
    return {'product': product.toMap(), 'quantity': quantity};
  }

  Map<String, dynamic> toMapForLocal(int orderId) {
    final savedProductId = (product.productId != null && product.productId! > 0)
        ? product.productId!
        : product.id;

    if (savedProductId == null || savedProductId <= 0) {
      throw Exception(
        'ID produk tidak valid: '
        'id=${product.id}, '
        'productId=${product.productId}, '
        'name=${product.name}',
      );
    }

    print(
      '[DraftOrder] save product '
      'id=${product.id}, '
      'productId=${product.productId}, '
      'savedId=$savedProductId, '
      'name=${product.name}',
    );

    return {
      'id_draft_order': orderId,
      'id_product': savedProductId,
      'quantity': quantity,
      'price': product.price,
    };
  }

  static OrderItemModel fromMapLocal(Map<String, dynamic> map) {
    final price = map['price']?.toInt() ?? 0;
    final quantity = map['quantity']?.toInt() ?? 0;

    return OrderItemModel(
      productId: map['id_product']?.toInt() ?? 0,
      quantity: quantity,
      totalPrice: price * quantity,
    );
  }

  factory DraftOrderItem.fromMap(Map<String, dynamic> map) {
    return DraftOrderItem(
      product: Product.fromMap(map['product']),
      quantity: map['quantity']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory DraftOrderItem.fromJson(String source) =>
      DraftOrderItem.fromMap(json.decode(source));
}
