import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'db_helper.dart';
import 'models.dart';
import 'product_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper().database;
  runApp(SLRApp());
}

class SLRApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductManager(),
      child: MaterialApp(
        title: 'SLR - Sales and Inventory Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        themeMode: ThemeMode.system,
        home: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text("SLR - Sales and Inventory Tracker"),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.category), text: "Materials"),
              Tab(icon: Icon(Icons.inventory), text: "Products"),
              Tab(icon: Icon(Icons.shopping_cart), text: "Sales"),
              Tab(icon: Icon(Icons.analytics), text: "Analytics"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            RawMaterialScreen(),
            ProductScreen(),
            SaleScreen(),
            AnalyticsScreen(),
          ],
        ),
      ),
    );
  }
}

class RawMaterialScreen extends StatelessWidget {
  final TextEditingController _materialNameController = TextEditingController();
  final TextEditingController _materialCostController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Raw Materials", style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 16),
          TextField(
            controller: _materialNameController,
            decoration: InputDecoration(
              labelText: "Material Name",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _materialCostController,
            decoration: InputDecoration(
              labelText: "Material Cost",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              String name = _materialNameController.text;
              double cost = double.tryParse(_materialCostController.text) ?? 0;
              if (name.isNotEmpty && cost > 0) {
                context.read<ProductManager>().addRawMaterial(name, cost);
                _materialNameController.clear();
                _materialCostController.clear();
              }
            },
            icon: Icon(Icons.add),
            label: Text("Add Raw Material"),
          ),
          SizedBox(height: 16),
          Expanded(
            child: Consumer<ProductManager>(
              builder: (context, manager, child) {
                return ListView.builder(
                  itemCount: manager.rawMaterials.length,
                  itemBuilder: (context, index) {
                    final material = manager.rawMaterials[index];
                    return Card(
                      child: ListTile(
                        title: Text(material.name),
                        subtitle:
                            Text("Cost: \₹${material.cost.toStringAsFixed(2)}"),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            context
                                .read<ProductManager>()
                                .deleteRawMaterial(material.id);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProductScreen extends StatelessWidget {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productCountController = TextEditingController();
  final TextEditingController _sellingPriceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Products", style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 16),
          Consumer<ProductManager>(
            builder: (context, manager, child) {
              return DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: "Raw Material",
                  border: OutlineInputBorder(),
                ),
                value: manager.selectedMaterialId,
                items: manager.rawMaterials.map((material) {
                  return DropdownMenuItem<int>(
                    value: material.id,
                    child: Text(material.name),
                  );
                }).toList(),
                onChanged: (value) {
                  manager.setSelectedMaterialId(value!);
                },
              );
            },
          ),
          SizedBox(height: 8),
          TextField(
            controller: _productNameController,
            decoration: InputDecoration(
              labelText: "Product Name",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _productCountController,
            decoration: InputDecoration(
              labelText: "Product Count",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 8),
          TextField(
            controller: _sellingPriceController,
            decoration: InputDecoration(
              labelText: "Selling Price",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              String name = _productNameController.text;
              int count = int.tryParse(_productCountController.text) ?? 0;
              double price = double.tryParse(_sellingPriceController.text) ?? 0;
              if (name.isNotEmpty && count > 0 && price > 0) {
                context.read<ProductManager>().addProduct(
                      name,
                      context.read<ProductManager>().selectedMaterialId!,
                      count,
                      price,
                    );
                _productNameController.clear();
                _productCountController.clear();
                _sellingPriceController.clear();
              }
            },
            icon: Icon(Icons.add),
            label: Text("Add Product"),
          ),
          SizedBox(height: 16),
          Expanded(
            child: Consumer<ProductManager>(
              builder: (context, manager, child) {
                return ListView.builder(
                  itemCount: manager.products.length,
                  itemBuilder: (context, index) {
                    final product = manager.products[index];
                    return Card(
                      child: ListTile(
                        title: Text(product.name),
                        subtitle: Text(
                            "Count: ${product.count}, Price: \₹${product.sellingPrice.toStringAsFixed(2)}"),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _showEditProductDialog(context, product);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    final TextEditingController nameController =
        TextEditingController(text: product.name);
    final TextEditingController countController =
        TextEditingController(text: product.count.toString());
    final TextEditingController priceController =
        TextEditingController(text: product.sellingPrice.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Product"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Product Name"),
              ),
              TextField(
                controller: countController,
                decoration: InputDecoration(labelText: "Count"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: "Selling Price"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Save"),
              onPressed: () {
                context.read<ProductManager>().updateProduct(
                      product.id,
                      name: nameController.text,
                      count: int.tryParse(countController.text),
                      sellingPrice: double.tryParse(priceController.text),
                    );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class SaleScreen extends StatelessWidget {
  final TextEditingController _buyerController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Sales", style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 16),
          Consumer<ProductManager>(
            builder: (context, manager, child) {
              return DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: "Product",
                  border: OutlineInputBorder(),
                ),
                value: manager.selectedProductId,
                items: manager.products.map((product) {
                  return DropdownMenuItem<int>(
                    value: product.id,
                    child: Text(product.name),
                  );
                }).toList(),
                onChanged: (value) {
                  manager.setSelectedProductId(value!);
                },
              );
            },
          ),
          SizedBox(height: 8),
          TextField(
            controller: _buyerController,
            decoration: InputDecoration(
              labelText: "Buyer Name",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _quantityController,
            decoration: InputDecoration(
              labelText: "Quantity",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _recordSale(context),
            icon: Icon(Icons.add),
            label: Text("Record Sale"),
          ),
          SizedBox(height: 16),
          Expanded(
            child: Consumer<ProductManager>(
              builder: (context, manager, child) {
                return ListView.builder(
                  itemCount: manager.sales.length,
                  itemBuilder: (context, index) {
                    final sale = manager.sales[index];
                    final product = manager.products
                        .firstWhere((p) => p.id == sale.productId);
                    return Card(
                      child: ListTile(
                        title: Text("${sale.buyer} bought ${product.name}"),
                        subtitle: Text(
                            "Quantity: ${sale.quantity}, Amount: \₹${sale.amount.toStringAsFixed(2)}"),
                        trailing:
                            Text("${DateFormat.yMd().format(sale.saleDate)}"),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _recordSale(BuildContext context) {
    final manager = context.read<ProductManager>();
    final productId = manager.selectedProductId;
    final buyer = _buyerController.text;
    final quantity = int.tryParse(_quantityController.text);

    if (productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a product")),
      );
      return;
    }

    if (buyer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a buyer name")),
      );
      return;
    }

    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid quantity")),
      );
      return;
    }

    manager.recordSale(productId, buyer, quantity, true).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sale recorded successfully")),
      );
      _buyerController.clear();
      _quantityController.clear();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error recording sale: $error")),
      );
    });
  }
}

class AnalyticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Consumer<ProductManager>(
        builder: (context, manager, child) {
          final totalSales = manager.getTotalSalesAmount();
          final totalProducts = manager.getTotalProductsSold();
          final profitOrLoss = manager.calculateProfitOrLoss();
          final topSellingProduct = manager.getTopSellingProduct();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Analytics", style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Total Sales: \₹${totalSales.toStringAsFixed(2)}",
                          style: Theme.of(context).textTheme.titleMedium),
                      Text("Total Products Sold: $totalProducts",
                          style: Theme.of(context).textTheme.titleMedium),
                      Text("Profit/Loss: \₹${profitOrLoss.toStringAsFixed(2)}",
                          style: Theme.of(context).textTheme.titleMedium),
                      if (topSellingProduct != null)
                        Text("Top Selling Product: ${topSellingProduct.name}",
                            style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text("Sales by Product",
                  style: Theme.of(context).textTheme.titleMedium),
              Expanded(
                child: ListView.builder(
                  itemCount: manager.products.length,
                  itemBuilder: (context, index) {
                    final product = manager.products[index];
                    final sales = manager.getSalesForProduct(product.id);
                    final totalAmount =
                        sales.fold<double>(0, (sum, sale) => sum + sale.amount);
                    final totalQuantity =
                        sales.fold<int>(0, (sum, sale) => sum + sale.quantity);

                    return Card(
                      child: ListTile(
                        title: Text(product.name),
                        subtitle: Text(
                            "Total Sales: \₹${totalAmount.toStringAsFixed(2)}"),
                        trailing: Text("Quantity: $totalQuantity"),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// You may want to add this utility function at the end of the file
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
