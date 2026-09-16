import 'package:cashwave_mobile/data/models/response/product_response_model.dart';
import 'package:cashwave_mobile/presentation/order/models/order_model.dart';
import 'package:sqflite/sqflite.dart';

import '../../presentation/home/models/draft_order_item.dart';
import '../../presentation/home/models/order_item.dart';
import '../../presentation/order/models/draft_order_model.dart';
import '../models/request/order_request_model.dart';
import '../models/response/category_response_model.dart';

class ProductLocalDatasource {
  ProductLocalDatasource._init();

  static final ProductLocalDatasource instance = ProductLocalDatasource._init();

  final String tableProducts = 'products';

  static Database? _database;

  // =========================
  // DATABASE
  // =========================

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = dbPath + filePath;

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableProducts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER,
        name TEXT,
        price INTEGER,
        stock INTEGER,
        image TEXT,
        category TEXT,
        category_id INTEGER,
        is_best_seller INTEGER,
        is_sync INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nominal INTEGER,
        payment_method TEXT,
        total_item INTEGER,
        id_kasir INTEGER,
        nama_kasir TEXT,
        transaction_time TEXT,
        is_sync INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER,
        name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_order INTEGER,
        id_product INTEGER,
        quantity INTEGER,
        price INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE draft_orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total_item INTEGER,
        nominal INTEGER,
        transaction_time TEXT,
        table_number INTEGER,
        draft_name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE draft_order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_draft_order INTEGER,
        id_product INTEGER,
        quantity INTEGER,
        price INTEGER
      )
    ''');
  }

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('pos13.db');

    return _database!;
  }

  // =========================
  // CATEGORY
  // =========================

  Future<void> insertAllCategories(List<Category> categories) async {
    final db = await instance.database;

    for (final category in categories) {
      await db.insert('categories', category.toMap());
    }
  }

  Future<void> removeAllCategories() async {
    final db = await instance.database;

    await db.delete('categories');
  }

  Future<List<Category>> getAllCategories() async {
    final db = await instance.database;

    final result = await db.query('categories');

    return result.map((e) => Category.fromLocal(e)).toList();
  }

  // =========================
  // PRODUCT
  // =========================

  Future<void> removeAllProduct() async {
    final db = await instance.database;

    await db.delete(tableProducts);
  }

  Future<void> insertAllProduct(List<Product> products) async {
    final db = await instance.database;

    for (final product in products) {
      await db.insert(tableProducts, product.toLocalMap());
    }
  }

  Future<Product> insertProduct(Product product) async {
    final db = await instance.database;

    final id = await db.insert(tableProducts, product.toMap());

    return product.copyWith(id: id);
  }

  Future<List<Product>> getAllProduct() async {
    final db = await instance.database;

    final result = await db.query(tableProducts);

    return result.map((e) => Product.fromMap(e)).toList();
  }

  Future<Product?> getProductById(int id) async {
    final db = await instance.database;

    // Coba cari berdasarkan product_id dari API
    var result = await db.query(
      tableProducts,
      where: 'product_id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return Product.fromMap(result.first);
    }

    // Kalau tidak ketemu, coba berdasarkan id lokal SQLite
    result = await db.query(
      tableProducts,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return Product.fromMap(result.first);
    }

    return null;
  }

  // =========================
  // ORDER
  // =========================

  Future<int> saveOrder(OrderModel order) async {
    final db = await instance.database;

    final id = await db.insert('orders', order.toMapForLocal());

    for (final orderItem in order.orders) {
      await db.insert('order_items', orderItem.toMapForLocal(id));
    }

    return id;
  }

  // Get order yang belum sync
  Future<List<OrderModel>> getOrderByIsSync() async {
    final db = await instance.database;

    final result = await db.query(
      'orders',
      where: 'is_sync = ?',
      whereArgs: [0],
    );

    return result.map((e) => OrderModel.fromLocalMap(e)).toList();
  }

  // Get semua order
  Future<List<OrderModel>> getAllOrder() async {
    final db = await instance.database;

    final result = await db.query('orders', orderBy: 'id DESC');

    final results = await Future.wait(
      result.map((item) async {
        final orderId = item['id'] as int;

        final orderItems = await getOrderItemByOrderId(orderId);

        return OrderModel.newFromLocalMap(item, orderItems);
      }),
    );

    return results;
  }

  // Get item order berdasarkan ID order
  Future<List<OrderItem>> getOrderItemByOrderId(int idOrder) async {
    final db = await instance.database;

    final result = await db.query(
      'order_items',
      where: 'id_order = ?',
      whereArgs: [idOrder],
    );

    final results = <OrderItem>[];

    for (final item in result) {
      final productId = item['id_product'] as int?;
      final quantity = item['quantity'] as int? ?? 0;

      if (productId == null) {
        continue;
      }

      final product = await getProductById(productId);

      if (product == null) {
        print(
          '[Order] Product tidak ditemukan: '
          'productId=$productId, orderId=$idOrder',
        );

        continue;
      }

      results.add(OrderItem(product: product, quantity: quantity));
    }

    return results;
  }

  // Method ini digunakan SyncOrderBloc
  Future<List<OrderItemModel>> getOrderItemByOrderIdLocal(int idOrder) async {
    final db = await instance.database;

    final result = await db.query(
      'order_items',
      where: 'id_order = ?',
      whereArgs: [idOrder],
    );

    return result.map((e) => OrderItem.fromMapLocal(e)).toList();
  }

  // Update status sync
  Future<int> updateIsSyncOrderById(int id) async {
    final db = await instance.database;

    return await db.update(
      'orders',
      {'is_sync': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================
  // DRAFT ORDER
  // =========================

  Future<int> saveDraftOrder(DraftOrderModel order) async {
    final db = await instance.database;

    final id = await db.insert('draft_orders', order.toMapForLocal());

    for (final orderItem in order.orders) {
      await db.insert('draft_order_items', orderItem.toMapForLocal(id));
    }

    return id;
  }

  // Get semua draft
  Future<List<DraftOrderModel>> getAllDraftOrder() async {
    final db = await instance.database;

    final result = await db.query('draft_orders', orderBy: 'id ASC');

    final results = await Future.wait(
      result.map((item) async {
        final draftOrderId = item['id'] as int;

        final draftOrderItems = await getDraftOrderItemByOrderId(draftOrderId);

        return DraftOrderModel.newFromLocalMap(item, draftOrderItems);
      }),
    );

    return results;
  }

  // Get item draft berdasarkan ID draft
  Future<List<DraftOrderItem>> getDraftOrderItemByOrderId(int idOrder) async {
    final db = await instance.database;

    final result = await db.query(
      'draft_order_items',
      where: 'id_draft_order = ?',
      whereArgs: [idOrder],
    );

    final results = <DraftOrderItem>[];

    for (final item in result) {
      final productId = item['id_product'] as int?;
      final quantity = item['quantity'] as int? ?? 0;

      if (productId == null) {
        print(
          '[DraftOrder] id_product null '
          'draftOrderId=$idOrder',
        );

        continue;
      }

      final product = await getProductById(productId);

      if (product == null) {
        print(
          '[DraftOrder] Product tidak ditemukan: '
          'productId=$productId, '
          'draftOrderId=$idOrder',
        );

        throw Exception('Product dengan ID $productId tidak ditemukan');
      }

      results.add(DraftOrderItem(product: product, quantity: quantity));
    }

    return results;
  }

  // Hapus draft
  Future<void> removeDraftOrderById(int id) async {
    final db = await instance.database;

    await db.delete('draft_orders', where: 'id = ?', whereArgs: [id]);

    await db.delete(
      'draft_order_items',
      where: 'id_draft_order = ?',
      whereArgs: [id],
    );
  }

  Future<void> debugDraftOrder() async {
    final db = await instance.database;

    final products = await db.query(tableProducts);

    final draftItems = await db.query('draft_order_items');

    print('========== PRODUCTS ==========');

    for (final product in products) {
      print(product);
    }

    print('====== DRAFT ORDER ITEMS ======');

    for (final item in draftItems) {
      print(item);
    }

    print('================================');
  }

  Future<void> clearDraftOrders() async {
    final db = await instance.database;

    await db.delete('draft_order_items');
    await db.delete('draft_orders');

    print('[DraftOrder] Semua draft berhasil dihapus');
  }
}
