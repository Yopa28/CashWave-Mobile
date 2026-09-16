import 'dart:convert';

class DashboardResponseModel {
  final bool success;
  final String message;
  final DashboardData data;

  DashboardResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DashboardResponseModel.fromJson(String str) =>
      DashboardResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory DashboardResponseModel.fromMap(Map<String, dynamic> json) {
    return DashboardResponseModel(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      data: DashboardData.fromMap(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() => {
    'success': success,
    'message': message,
    'data': data.toMap(),
  };
}

class DashboardData {
  final TodaySales today;
  final ProductStockSummary products;
  final List<RecentOrder> recentOrders;

  DashboardData({
    required this.today,
    required this.products,
    required this.recentOrders,
  });

  factory DashboardData.fromMap(Map<String, dynamic> json) {
    return DashboardData(
      today: TodaySales.fromMap(json['today'] ?? {}),
      products: ProductStockSummary.fromMap(json['products'] ?? {}),
      recentOrders: List<RecentOrder>.from(
        (json['recent_orders'] ?? []).map((x) => RecentOrder.fromMap(x)),
      ),
    );
  }

  Map<String, dynamic> toMap() => {
    'today': today.toMap(),
    'products': products.toMap(),
    'recent_orders': recentOrders.map((x) => x.toMap()).toList(),
  };
}

class TodaySales {
  final int sales;
  final int transactions;
  final int items;

  TodaySales({
    required this.sales,
    required this.transactions,
    required this.items,
  });

  factory TodaySales.fromMap(Map<String, dynamic> json) {
    return TodaySales(
      sales: _toInt(json['sales']),
      transactions: _toInt(json['transactions']),
      items: _toInt(json['items']),
    );
  }

  Map<String, dynamic> toMap() => {
    'sales': sales,
    'transactions': transactions,
    'items': items,
  };
}

class ProductStockSummary {
  final int total;
  final int lowStock;
  final int outOfStock;

  ProductStockSummary({
    required this.total,
    required this.lowStock,
    required this.outOfStock,
  });

  factory ProductStockSummary.fromMap(Map<String, dynamic> json) {
    return ProductStockSummary(
      total: _toInt(json['total']),
      lowStock: _toInt(json['low_stock']),
      outOfStock: _toInt(json['out_of_stock']),
    );
  }

  Map<String, dynamic> toMap() => {
    'total': total,
    'low_stock': lowStock,
    'out_of_stock': outOfStock,
  };
}

class RecentOrder {
  final int id;
  final String orderNumber;
  final int totalPrice;
  final int totalItem;
  final String paymentMethod;
  final String cashier;
  final DateTime? transactionTime;
  final List<RecentOrderItem> items;

  RecentOrder({
    required this.id,
    required this.orderNumber,
    required this.totalPrice,
    required this.totalItem,
    required this.paymentMethod,
    required this.cashier,
    required this.transactionTime,
    required this.items,
  });

  factory RecentOrder.fromMap(Map<String, dynamic> json) {
    return RecentOrder(
      id: _toInt(json['id']),
      orderNumber: json['order_number']?.toString() ?? '',
      totalPrice: _toInt(json['total_price']),
      totalItem: _toInt(json['total_item']),
      paymentMethod: json['payment_method']?.toString() ?? '',
      cashier: json['cashier']?.toString() ?? '',
      transactionTime: json['transaction_time'] != null
          ? DateTime.tryParse(json['transaction_time'].toString())
          : null,
      items: List<RecentOrderItem>.from(
        (json['items'] ?? []).map((x) => RecentOrderItem.fromMap(x)),
      ),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'order_number': orderNumber,
    'total_price': totalPrice,
    'total_item': totalItem,
    'payment_method': paymentMethod,
    'cashier': cashier,
    'transaction_time': transactionTime?.toIso8601String(),
    'items': items.map((x) => x.toMap()).toList(),
  };
}

class RecentOrderItem {
  final int productId;
  final String productName;
  final int quantity;
  final int subtotal;

  RecentOrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.subtotal,
  });

  factory RecentOrderItem.fromMap(Map<String, dynamic> json) {
    return RecentOrderItem(
      productId: _toInt(json['product_id']),
      productName: json['product_name']?.toString() ?? '',
      quantity: _toInt(json['quantity']),
      subtotal: _toInt(json['subtotal']),
    );
  }

  Map<String, dynamic> toMap() => {
    'product_id': productId,
    'product_name': productName,
    'quantity': quantity,
    'subtotal': subtotal,
  };
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value?.toString() ?? '0') ?? 0;
}
