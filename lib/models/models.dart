import 'package:isar/isar.dart';

part 'models.g.dart';

@Collection()
class Product {
  Id? id;
  late String name;
  late int count;
  late double sellingPrice;
  late double cost;
  late DateTime createdAt;

  Product({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.count,
    required this.sellingPrice,
    required this.cost,
    required this.createdAt,
  });
}

@Collection()
class Sale {
  Id? id;
  late int productId;
  late String buyer;
  late int quantity;
  late double amount;
  late bool isPaid;
  late DateTime saleDate;
  double? creditGiven; // Track credit given during the sale
  double? creditReceived; // Track credit received for the sale

  Sale({
    this.id = Isar.autoIncrement,
    required this.productId,
    required this.buyer,
    required this.quantity,
    required this.amount,
    required this.isPaid,
    required this.saleDate,
    this.creditGiven = 0.0,
    this.creditReceived = 0.0,
  });
}

@Collection()
class CreditTransaction {
  Id? id;
  late String entityName; // Customer or Supplier name
  late double amount;
  late DateTime transactionDate;
  late String type; // "Given", "Received", "CashCredit"
  String? description;

  CreditTransaction({
    this.id = Isar.autoIncrement,
    required this.entityName,
    required this.amount,
    required this.transactionDate,
    required this.type,
    this.description,
  });
}
