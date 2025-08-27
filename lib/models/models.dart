class RawMaterial {
  final int id;
  final String name;
  final double cost;

  RawMaterial({required this.id, required this.name, required this.cost});

  factory RawMaterial.fromMap(Map<String, dynamic> map) {
    return RawMaterial(
      id: map['id'],
      name: map['name'],
      cost: map['cost'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'cost': cost};
  }
}

class Product {
  final int id;
  final String name;
  final int rawMaterialId;
  final int count;
  final double sellingPrice;
  final double cost;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.rawMaterialId,
    required this.count,
    required this.sellingPrice,
    required this.cost,
    required this.createdAt,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      rawMaterialId: map['raw_material_id'],
      count: map['count'],
      sellingPrice: map['selling_price'],
      cost: map['cost'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'raw_material_id': rawMaterialId,
      'count': count,
      'selling_price': sellingPrice,
      'cost': cost,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Sale {
  final int id;
  final int productId;
  final String buyer;
  final int quantity;
  final double amount;
  final bool isPaid;
  final DateTime saleDate;

  Sale({
    required this.id,
    required this.productId,
    required this.buyer,
    required this.quantity,
    required this.amount,
    required this.isPaid,
    required this.saleDate,
  });

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      productId: map['product_id'],
      buyer: map['buyer'],
      quantity: map['quantity'],
      amount: map['amount'],
      isPaid: map['is_paid'] == 1,
      saleDate: DateTime.parse(map['sold_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'buyer': buyer,
      'quantity': quantity,
      'amount': amount,
      'is_paid': isPaid ? 1 : 0,
      'sold_at': saleDate.toIso8601String(),
    };
  }
}
