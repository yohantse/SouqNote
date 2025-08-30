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
  double? creditGiven;
  double? creditReceived;

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
  Id id = Isar.autoIncrement; // <-- note: not nullable if using auto increment
  late String entityName;
  late double amount;
  late DateTime transactionDate;
  late String type; // "Given", "Received", "CashCredit"
  String? description;
  DateTime? dueDate;
  late String status;

  CreditTransaction({
    required this.entityName,
    required this.amount,
    required this.transactionDate,
    required this.type,
    this.description,
    this.dueDate,
    this.status = 'Pending',
  });
}

@Collection()
class AppUser {
  Id id = Isar.autoIncrement;

  late String username;
  late String email;
  late String passwordHash; // Store hashed password
  late DateTime createdAt;

  AppUser({
    required this.username,
    required this.email,
    required this.passwordHash,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
