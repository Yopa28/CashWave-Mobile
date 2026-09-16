import 'dart:convert';

class OrderRequestModel {
  final String transactionTime;
  final int kasirId;
  final int totalPrice;
  final int totalItem;
  final String paymentMethod;
  final List<OrderItemModel> orderItems;

  OrderRequestModel({
    required this.transactionTime,
    required this.kasirId,
    required this.totalPrice,
    required this.totalItem,
    required this.paymentMethod,
    required this.orderItems,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': kasirId,
      'payment_method': paymentMethod,
      'order_produk': orderItems.map((item) => item.toMap()).toList(),
    };
  }

  String toJson() {
    return jsonEncode(toMap());
  }
}

class OrderItemModel {
  final int productId;
  final int quantity;
  final int totalPrice;

  OrderItemModel({
    required this.productId,
    required this.quantity,
    required this.totalPrice,
  });

  Map<String, dynamic> toMap() {
    return {'produk_id': productId, 'quantity': quantity};
  }
}
