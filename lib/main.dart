import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'db_helper.dart';
import 'models/models.dart';
import 'inventory/product_manager.dart';
import 'settings/settings_screen.dart';
import 'theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper().database;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ProductManager()),
      ],
      child: const SLRApp(),
    ),
  );
}

class SLRApp extends StatelessWidget {
  const SLRApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SouqNote',
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
      themeMode: themeProvider.themeMode,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    ProductScreen(),
    SaleScreen(),
    AnalyticsScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SouqNote"),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Sales',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class ProductScreen extends StatelessWidget {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productCountController = TextEditingController();
  final TextEditingController _sellingPriceController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Products", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextFormField(
            controller: _productNameController,
            decoration: InputDecoration(
              labelText: "Product Name",
              hintText: "Enter product name",
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
            controller: _productCountController,
            decoration: InputDecoration(
              labelText: "Product Count",
              hintText: "Enter product count",
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
          const SizedBox(height: 8),
          TextFormField(
            controller: _sellingPriceController,
            decoration: InputDecoration(
              labelText: "Selling Price",
              hintText: "Enter selling price",
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
          const SizedBox(height: 8),
          TextFormField(
            controller: _costController,
            decoration: InputDecoration(
              labelText: "Cost",
              hintText: "Enter cost",
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
              String name = _productNameController.text;
              int count = int.tryParse(_productCountController.text) ?? 0;
              double price = double.tryParse(_sellingPriceController.text) ?? 0;
              double cost = double.tryParse(_costController.text) ?? 0;
              if (name.isNotEmpty && count > 0 && price > 0 && cost > 0) {
                context.read<ProductManager>().addProduct(
                      name,
                      count,
                      price,
                      cost,
                    );
                _productNameController.clear();
                _productCountController.clear();
                _sellingPriceController.clear();
                _costController.clear();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text("Add Product"),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer<ProductManager>(
              builder: (context, manager, child) {
                return ListView.builder(
                  itemCount: manager.products.length,
                  itemBuilder: (context, index) {
                    final product = manager.products[index];
                    return Card(
                      elevation: 4.0,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text("Price: ₹${product.sellingPrice.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 16.0,
                                )),
                            Text("Cost: ₹${product.cost.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 16.0,
                                )),
                            Text("Stock: ${product.count}",
                                style: const TextStyle(
                                  fontSize: 16.0,
                                )),
                          ],
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
  final TextEditingController nameController = TextEditingController(text: product.name);
  final TextEditingController countController = TextEditingController(text: product.count.toString());
  final TextEditingController priceController = TextEditingController(text: product.sellingPrice.toString());
  final TextEditingController costController = TextEditingController(text: product.cost.toString());

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Edit Product"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Product Name"),
            ),
            TextFormField(
              controller: countController,
              decoration: const InputDecoration(labelText: "Count"),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: priceController,
              decoration: const InputDecoration(labelText: "Selling Price"),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: costController,
              decoration: const InputDecoration(labelText: "Cost"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text("Save"),
            onPressed: () {
              // Parse values safely
              final parsedCount = int.tryParse(countController.text) ?? product.count;
              final parsedPrice = double.tryParse(priceController.text) ?? product.sellingPrice;
              final parsedCost = double.tryParse(costController.text) ?? product.cost;

              context.read<ProductManager>().updateProduct(
                    product.id!,
                    name: nameController.text,
                    count: parsedCount,
                    sellingPrice: parsedPrice,
                    cost: parsedCost,
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

  SaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Sales", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Consumer<ProductManager>(
            builder: (context, manager, child) {
              return DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: "Product",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
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
          const SizedBox(height: 8),
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
            controller: _quantityController,
            decoration: InputDecoration(
              labelText: "Quantity",
              hintText: "Enter quantity",
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
            onPressed: () => _recordSale(context),
            icon: const Icon(Icons.add),
            label: const Text("Record Sale"),
          ),
          const SizedBox(height: 16),
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
                      elevation: 4.0,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${sale.buyer} bought ${product.name}",
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              "Quantity: ${sale.quantity}, Amount: ₹${sale.amount.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              DateFormat.yMd().format(sale.saleDate),
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey,
                              ),
                            ),
                          ],
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

  void _recordSale(BuildContext context) {
    final manager = context.read<ProductManager>();
    final productId = manager.selectedProductId;
    final buyer = _buyerController.text;
    final quantity = int.tryParse(_quantityController.text);

    if (productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a product")),
      );
      return;
    }

    if (buyer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a buyer name")),
      );
      return;
    }

    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid quantity")),
      );
      return;
    }

    manager.recordSale(productId, buyer, quantity, true).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sale recorded successfully")),
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
  const AnalyticsScreen({super.key});

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
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Total Sales: ₹${totalSales.toStringAsFixed(2)}",
                          style: Theme.of(context).textTheme.titleMedium),
                      Text("Total Products Sold: $totalProducts",
                          style: Theme.of(context).textTheme.titleMedium),
                      Text("Profit/Loss: ₹${profitOrLoss.toStringAsFixed(2)}",
                          style: Theme.of(context).textTheme.titleMedium),
                      if (topSellingProduct != null)
                        Text("Top Selling Product: ${topSellingProduct.name}",
                            style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text("Sales by Product",
                  style: Theme.of(context).textTheme.titleMedium),
              Expanded(
                child: ListView.builder(
                  itemCount: manager.products.length,
                  itemBuilder: (context, index) {
                    final product = manager.products[index];
                    final sales = manager.getSalesForProduct(product.id!);
                    final totalAmount =
                        sales.fold<double>(0, (sum, sale) => sum + sale.amount);
                    final totalQuantity =
                        sales.fold<int>(0, (sum, sale) => sum + sale.quantity);

                    return Card(
                      child: ListTile(
                        title: Text(product.name),
                        subtitle: Text(
                            "Total Sales: ₹${totalAmount.toStringAsFixed(2)}"),
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