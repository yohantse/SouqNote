import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'models.dart';

class ProductManager extends ChangeNotifier {
  List<RawMaterial> _rawMaterials = [];
  List<Product> _products = [];
  List<Sale> _sales = [];
  int? _selectedProductId;
  int? _selectedMaterialId;

  List<RawMaterial> get rawMaterials => _rawMaterials;
  List<Product> get products => _products;
  List<Sale> get sales => _sales;
  int? get selectedProductId => _selectedProductId;
  int? get selectedMaterialId => _selectedMaterialId;

  ProductManager() {
    _loadData();
  }

  Future<void> _loadData() async {
    final db = await DBHelper().database;
    final rawMaterialsData = await db!.query('raw_materials');
    final productsData = await db.query('products');
    final salesData = await db.query('sales');

    _rawMaterials =
        rawMaterialsData.map((e) => RawMaterial.fromMap(e)).toList();
    _products = productsData.map((e) => Product.fromMap(e)).toList();
    _sales = salesData.map((e) => Sale.fromMap(e)).toList();

    notifyListeners();
  }

  void setSelectedProductId(int id) {
    _selectedProductId = id;
    notifyListeners();
  }

  void setSelectedMaterialId(int id) {
    _selectedMaterialId = id;
    notifyListeners();
  }

  Future<void> addRawMaterial(String name, double cost) async {
    final db = await DBHelper().database;
    final id = await db!.insert('raw_materials', {'name': name, 'cost': cost});
    final rawMaterial = RawMaterial(id: id, name: name, cost: cost);
    _rawMaterials.add(rawMaterial);
    notifyListeners();
  }

  Future<void> addProduct(
      String name, int materialId, int count, double sellingPrice) async {
    final db = await DBHelper().database;
    var product = Product(
      id: 0,
      name: name,
      rawMaterialId: materialId,
      count: count,
      sellingPrice: sellingPrice,
      createdAt: DateTime.now(),
    );
    final id = await db!.insert('products', product.toMap());
    product = Product(
      id: id,
      name: name,
      rawMaterialId: materialId,
      count: count,
      sellingPrice: sellingPrice,
      createdAt: DateTime.now(),
    );
    _products.add(product);
    notifyListeners();
  }

  Future<void> recordSale(
      int productId, String buyer, int quantity, bool isPaid) async {
    final db = await DBHelper().database;
    final product = _products.firstWhere((p) => p.id == productId);
    final amount = product.sellingPrice * quantity;
    var sale = Sale(
      id: 0,
      productId: productId,
      buyer: buyer,
      quantity: quantity,
      amount: amount,
      isPaid: isPaid,
      saleDate: DateTime.now(),
    );
    try {
      final id = await db!.insert('sales', sale.toMap());
      sale = Sale(
        id: id,
        productId: productId,
        buyer: buyer,
        quantity: quantity,
        amount: amount,
        isPaid: isPaid,
        saleDate: DateTime.now(),
      );
      _sales.add(sale);

      // Update product count
      final updatedProduct = Product(
        id: product.id,
        name: product.name,
        rawMaterialId: product.rawMaterialId,
        count: product.count - quantity,
        sellingPrice: product.sellingPrice,
        createdAt: product.createdAt,
      );
      await db.update('products', updatedProduct.toMap(),
          where: 'id = ?', whereArgs: [productId]);
      final index = _products.indexWhere((p) => p.id == productId);
      _products[index] = updatedProduct;

      notifyListeners();
    } catch (e) {
      print('Error recording sale: $e');
      rethrow; // Re-throw the error so it can be caught and displayed in the UI
    }
  }

  double calculateProfitOrLoss() {
    double totalCost = _products.fold(0, (sum, product) {
      RawMaterial material =
          _rawMaterials.firstWhere((m) => m.id == product.rawMaterialId);
      return sum + material.cost;
    });

    double totalSales = _sales.fold(0, (sum, sale) => sum + sale.amount);

    return totalSales - totalCost;
  }

  Future<void> deleteRawMaterial(int id) async {
    final db = await DBHelper().database;
    await db!.delete('raw_materials', where: 'id = ?', whereArgs: [id]);
    _rawMaterials.removeWhere((material) => material.id == id);
    notifyListeners();
  }

  Future<void> updateProduct(int id,
      {String? name, int? count, double? sellingPrice}) async {
    final db = await DBHelper().database;
    final index = _products.indexWhere((product) => product.id == id);
    if (index != -1) {
      final updatedProduct = Product(
        id: _products[index].id,
        name: name ?? _products[index].name,
        rawMaterialId: _products[index].rawMaterialId,
        count: count ?? _products[index].count,
        sellingPrice: sellingPrice ?? _products[index].sellingPrice,
        createdAt: _products[index].createdAt,
      );
      await db!.update('products', updatedProduct.toMap(),
          where: 'id = ?', whereArgs: [id]);
      _products[index] = updatedProduct;
      notifyListeners();
    }
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
}
