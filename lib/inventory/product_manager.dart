import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';
import 'dart:io';

class ProductManager extends ChangeNotifier {
  List<Product> _products = [];
  List<Sale> _sales = [];
  int? _selectedProductId;
  static Isar? isar; // Make isar static

  List<Product> get products => _products;
  List<Sale> get sales => _sales;
  int? get selectedProductId => _selectedProductId;

  ProductManager() {
    openIsar();
  }

  Future<void> openIsar() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [ProductSchema, SaleSchema, CreditTransactionSchema],
      directory: dir.path,
      inspector: true,
    );
    await _loadData();
  }

  Future<void> _loadData() async {
    if (isar == null) return;
    _products = await isar!.products.where().findAll();
    _sales = await isar!.sales.where().findAll();
    notifyListeners();
  }

  void setSelectedProductId(int id) {
    _selectedProductId = id;
    notifyListeners();
  }

  Future<void> addProduct(
      String name, int count, double sellingPrice, double cost) async {
    if (isar == null) return;
    var product = Product(
      id: Isar.autoIncrement,
      name: name,
      count: count,
      sellingPrice: sellingPrice,
      cost: cost,
      createdAt: DateTime.now(),
    );
    await isar!.writeTxn(() async {
      await isar!.products.put(product);
    });
    _products.add(product);
    notifyListeners();
  }

  Future<void> recordSale(
    int productId,
    String buyer,
    int quantity,
    bool isPaid, {
    double creditGiven = 0.0,
    double creditReceived = 0.0,
  }) async {
    if (isar == null) return;
    final product = _products.firstWhere((p) => p.id == productId);
    final amount = product.sellingPrice * quantity;

    var sale = Sale(
      id: Isar.autoIncrement,
      productId: productId,
      buyer: buyer,
      quantity: quantity,
      amount: amount,
      isPaid: isPaid,
      saleDate: DateTime.now(),
      creditGiven: creditGiven,
      creditReceived: creditReceived,
    );

    try {
      await isar!.writeTxn(() async {
        await isar!.sales.put(sale);
      });
      _sales.add(sale);

      // Update product count
      final updatedProduct = product..count = product.count - quantity;
      await isar!.writeTxn(() async {
        await isar!.products.put(updatedProduct);
      });
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = updatedProduct;
      }

      notifyListeners();
    } catch (e) {
      print('Error recording sale: $e');
      rethrow; // Re-throw the error so it can be caught and displayed in the UI
    }
  }

  double calculateProfitOrLoss({String timeFrame = 'all'}) {
    DateTime now = DateTime.now();
    DateTime startDate;

    switch (timeFrame) {
      case 'daily':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'weekly':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case 'monthly':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'yearly':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = DateTime(1970); // Beginning of time
        break;
    }

    List<Sale> filteredSales =
        _sales.where((sale) => sale.saleDate.isAfter(startDate)).toList();

    double totalRevenue =
        filteredSales.fold(0, (sum, sale) => sum + sale.amount);
    double totalCostOfSoldItems = 0;
    for (var sale in filteredSales) {
      final product = _products.firstWhere((p) => p.id == sale.productId);
      totalCostOfSoldItems += product.cost * sale.quantity;
    }
    return totalRevenue - totalCostOfSoldItems;
  }

  Future<void> updateProduct(
    int id, {
    required String name,
    required int count,
    required double sellingPrice,
    required double cost,
  }) async {
    if (isar == null) return;

    final product = _products.firstWhere((p) => p.id == id);

    // Update product fields
    product
      ..name = name
      ..count = count
      ..sellingPrice = sellingPrice
      ..cost = cost;

    await isar!.writeTxn(() async {
      await isar!.products.put(product);
    });

    // Update local list
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products[index] = product;
    }

    notifyListeners();
  }

  List<Sale> getSalesForProduct(int productId) {
    return _sales.where((sale) => sale.productId == productId).toList();
  }

  double getTotalSalesAmount() {
    return _sales.fold(0, (sum, sale) => sum + sale.amount);
  }

  int getTotalProductsSold() {
    return _sales.fold(0, (sum, sale) => sum + sale.quantity);
  }

  Product? getTopSellingProduct() {
    if (_sales.isEmpty) return null;

    Map<int, int> productSalesCount = {};
    for (var sale in _sales) {
      productSalesCount[sale.productId] =
          (productSalesCount[sale.productId] ?? 0) + sale.quantity;
    }

    int topSellingProductId = productSalesCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return _products.firstWhere((product) => product.id == topSellingProductId);
  }

  Future<void> recordCreditGiven({
    required String entityName,
    required double amount,
    String? description,
  }) async {
    await recordCreditTransaction(
      entityName: entityName,
      amount: amount,
      type: 'Given',
      description: description,
    );
  }

  Future<void> recordCreditReceived({
    required String entityName,
    required double amount,
    String? description,
  }) async {
    await recordCreditTransaction(
      entityName: entityName,
      amount: amount,
      type: 'Received',
      description: description,
    );
  }

  Future<void> recordCashCredit({
    required String entityName,
    required double amount,
    String? description,
  }) async {
    await recordCreditTransaction(
      entityName: entityName,
      amount: amount,
      type: 'CashCredit',
      description: description,
    );
  }

  Future<void> recordCreditTransaction({
    required String entityName,
    required double amount,
    required String type,
    String? description,
  }) async {
    if (isar == null) return;

    final transaction = CreditTransaction(
      entityName: entityName,
      amount: amount,
      transactionDate: DateTime.now(),
      type: type,
      description: description,
    );

    await isar!.writeTxn(() async {
      await isar!.creditTransactions.put(transaction);
    });
    notifyListeners();
  }

  double calculateOutstandingBalance(String entityName) {
    if (isar == null) return 0;

    double totalCreditGiven = 0;
    double totalCreditReceived = 0;
    double totalCashCredit = 0;

    List<CreditTransaction> transactions = isar!.creditTransactions
        .filter()
        .entityNameEqualTo(entityName)
        .findAllSync();

    for (var transaction in transactions) {
      switch (transaction.type) {
        case 'Given':
          totalCreditGiven += transaction.amount;
          break;
        case 'Received':
          totalCreditReceived += transaction.amount;
          break;
        case 'CashCredit':
          totalCashCredit += transaction.amount;
          break;
      }
    }

    return totalCreditGiven - totalCreditReceived + totalCashCredit;
  }

  List<CreditTransaction> getAllCreditTransactions() {
    if (isar == null) return [];
    return isar!.creditTransactions.where().findAllSync();
  }
}
