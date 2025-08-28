import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';
import 'dart:io';
import 'package:provider/provider.dart';

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
      [ProductSchema, SaleSchema],
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
    final updatedProduct = product
      ..count = product.count - quantity;
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

    List<Sale> filteredSales = _sales.where((sale) => sale.saleDate.isAfter(startDate)).toList();

    double totalRevenue = filteredSales.fold(0, (sum, sale) => sum + sale.amount);
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

  // Credit Management Functions
  double calculateOutstandingBalance(String buyerName) {
    double totalCreditGiven = _sales
        .where((sale) => sale.buyer == buyerName)
        .fold(0, (sum, sale) => sum + (sale.creditGiven ?? 0));
    double totalCreditReceived = _sales
        .where((sale) => sale.buyer == buyerName)
        .fold(0, (sum, sale) => sum + (sale.creditReceived ?? 0));
    return totalCreditGiven - totalCreditReceived;
  }

  Future<void> recordCreditPayment(String buyerName, double amount) async {
    if (isar == null) return;

    // Find the most recent sale with outstanding credit for this buyer
    Sale? sale = _sales.lastWhere((s) => s.buyer == buyerName && (s.creditGiven ?? 0) > (s.creditReceived ?? 0),
        orElse: () => Sale(
            productId: 0, buyer: buyerName, quantity: 0, amount: 0, isPaid: true, saleDate: DateTime.now())); // Return a default sale object if none is found

    if (sale.productId == 0) {
      // No outstanding credit found for this buyer
      print("No outstanding credit found for $buyerName");
      return;
    }

    double outstandingCredit = (sale.creditGiven ?? 0) - (sale.creditReceived ?? 0);
    double paymentAmount = amount;

    if (paymentAmount > outstandingCredit) {
      paymentAmount = outstandingCredit; // Limit payment to outstanding credit
    }

    // Update the sale with the credit received
    sale.creditReceived = (sale.creditReceived ?? 0) + paymentAmount;

    await isar!.writeTxn(() async {
      await isar!.sales.put(sale);
    });

    notifyListeners();
  }
}

class CreditScreen extends StatefulWidget {
  const CreditScreen({Key? key}) : super(key: key);

  @override
  State<CreditScreen> createState() => _CreditScreenState();
}

class _CreditScreenState extends State<CreditScreen> {
  final TextEditingController _buyerController = TextEditingController();
  final TextEditingController _paymentController = TextEditingController();
  String _creditMessage = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Credit Management", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextFormField(
            controller: _buyerController,
            decoration: InputDecoration(
              labelText: "Buyer Name",
              hintText: "Enter buyer name",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 2.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _paymentController,
            decoration: InputDecoration(
              labelText: "Payment Amount",
              hintText: "Enter payment amount",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 2.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              final buyer = _buyerController.text;
              final amount = double.tryParse(_paymentController.text) ?? 0;
              if (buyer.isNotEmpty && amount > 0) {
                context.read<ProductManager>().recordCreditPayment(buyer, amount).then((_) {
                   setState(() {
                    _creditMessage = "Payment recorded successfully for $buyer";
                  });
                }).catchError((error) {
                   setState(() {
                    _creditMessage = "Error recording payment: $error";
                  });
                });
                _buyerController.clear();
                _paymentController.clear();
              }
            },
            icon: const Icon(Icons.money),
            label: const Text("Record Payment"),
          ),
          const SizedBox(height: 16),
          Consumer<ProductManager>(
            builder: (context, manager, child) {
              final buyerName = _buyerController.text;
              final outstandingBalance =
                  manager.calculateOutstandingBalance(buyerName);
              return Column(children: [
                 Text(
                  "Outstanding Balance for $buyerName: ₹${outstandingBalance.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  _creditMessage,
                  style: const TextStyle(fontSize: 14, color: Colors.green),
                )
              ],);
            },
          ),
        ],
      ),
    );
  }
}