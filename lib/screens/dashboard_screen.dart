import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../inventory/product_manager.dart';
import '../models/models.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedTimeFrame = 'all';
  String _selectedProductFilter = 'name';

  List<Product> _getFilteredProducts(
      List<Product> products, ProductManager manager) {
    switch (_selectedProductFilter) {
      case 'name':
        products.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'total_sales':
        products.sort((a, b) {
          final totalA = manager
              .getSalesForProduct(a.id!)
              .fold<double>(0, (sum, s) => sum + s.amount);
          final totalB = manager
              .getSalesForProduct(b.id!)
              .fold<double>(0, (sum, s) => sum + s.amount);
          return totalB.compareTo(totalA);
        });
        break;
      case 'quantity_sold':
        products.sort((a, b) {
          final totalA = manager
              .getSalesForProduct(a.id!)
              .fold<int>(0, (sum, s) => sum + s.quantity);
          final totalB = manager
              .getSalesForProduct(b.id!)
              .fold<int>(0, (sum, s) => sum + s.quantity);
          return totalB.compareTo(totalA);
        });
        break;
      case 'profit':
        products.sort((a, b) {
          final profitA =
              manager.getSalesForProduct(a.id!).fold<double>(0, (sum, s) {
            final p =
                manager.products.firstWhere((prod) => prod.id == s.productId);
            return sum + (p.sellingPrice - p.cost) * s.quantity;
          });
          final profitB =
              manager.getSalesForProduct(b.id!).fold<double>(0, (sum, s) {
            final p =
                manager.products.firstWhere((prod) => prod.id == s.productId);
            return sum + (p.sellingPrice - p.cost) * s.quantity;
          });
          return profitB.compareTo(profitA);
        });
        break;
    }
    return products;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<ProductManager>(
          builder: (context, manager, child) {
            final totalSales = manager.getTotalSalesAmount();
            final totalProducts = manager.getTotalProductsSold();
            final profitOrLoss =
                manager.calculateProfitOrLoss(timeFrame: _selectedTimeFrame);
            final topSellingProduct = manager.getTopSellingProduct();

            final filteredProducts =
                _getFilteredProducts(List.from(manager.products), manager);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _summaryCard(
                          "Total Sales",
                          "ETB${totalSales.toStringAsFixed(2)}",
                          Colors.blue.shade100),
                      _summaryCard("Total Products", "$totalProducts",
                          Colors.orange.shade100),
                      _summaryCard(
                          "Profit",
                          "ETB${profitOrLoss.toStringAsFixed(2)}",
                          Colors.green.shade100),
                      if (topSellingProduct != null)
                        _summaryCard("Top Product", topSellingProduct.name,
                            Colors.purple.shade100),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Timeframe and Filter Dropdowns
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: _inputDecoration("Time Frame"),
                        value: _selectedTimeFrame,
                        items: const [
                          DropdownMenuItem(
                              value: 'all', child: Text("All Time")),
                          DropdownMenuItem(
                              value: 'daily', child: Text("Daily")),
                          DropdownMenuItem(
                              value: 'weekly', child: Text("Weekly")),
                          DropdownMenuItem(
                              value: 'monthly', child: Text("Monthly")),
                          DropdownMenuItem(
                              value: 'yearly', child: Text("Yearly")),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedTimeFrame = value!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: _inputDecoration("Sort Products by"),
                        value: _selectedProductFilter,
                        items: const [
                          DropdownMenuItem(value: 'name', child: Text('Name')),
                          DropdownMenuItem(
                              value: 'total_sales', child: Text('Total Sales')),
                          DropdownMenuItem(
                              value: 'quantity_sold',
                              child: Text('Quantity Sold')),
                          DropdownMenuItem(
                              value: 'profit', child: Text('Profit')),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedProductFilter = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Product List
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      final sales = manager.getSalesForProduct(product.id!);
                      final totalAmount =
                          sales.fold<double>(0, (sum, s) => sum + s.amount);
                      final totalQuantity =
                          sales.fold<int>(0, (sum, s) => sum + s.quantity);
                      final profit = sales.fold<double>(0, (sum, s) {
                        final p = manager.products
                            .firstWhere((prod) => prod.id == s.productId);
                        return sum + (p.sellingPrice - p.cost) * s.quantity;
                      });

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          title: Text(product.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              "Total Sales: ETB${totalAmount.toStringAsFixed(2)}"),
                          trailing: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 60),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Chip(
                                    label: Text("Qty: $totalQuantity"),
                                    backgroundColor: Colors.blue.shade50,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Flexible(
                                  child: Chip(
                                    label: Text(
                                        "Profit: ETB${profit.toStringAsFixed(2)}"),
                                    backgroundColor: Colors.green.shade50,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _summaryCard(String title, String value, Color color) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 6, offset: const Offset(2, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
