import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../inventory/product_manager.dart';
import '../models/models.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productCountController = TextEditingController();
  final TextEditingController _sellingPriceController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _productCountController.dispose();
    _sellingPriceController.dispose();
    _costController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _getFilteredProducts(List<Product> products) {
    if (_searchQuery.isEmpty) return products;
    return products
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Add Products", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 14),
          TextFormField(
            controller: _productNameController,
            decoration: _inputDecoration("Product Name", "Enter product name"),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _productCountController,
            decoration:
                _inputDecoration("Product Count", "Enter product count"),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _sellingPriceController,
            decoration:
                _inputDecoration("Selling Price", "Enter selling price"),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _costController,
            decoration: _inputDecoration("Cost", "Enter cost"),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _addProduct,
            icon: const Icon(Icons.add),
            label: const Text("Add Product"),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _searchController,
            decoration: _inputDecoration("Search", "Search product name"),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer<ProductManager>(
              builder: (context, manager, child) {
                final products =
                    _getFilteredProducts(List.from(manager.products));
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) =>
                      _productCard(products[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _productCard(Product product) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text("Price: ₹${product.sellingPrice.toStringAsFixed(2)}"),
            Text("Cost: ₹${product.cost.toStringAsFixed(2)}"),
            Text("Stock: ${product.count}"),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  void _addProduct() {
    final name = _productNameController.text;
    final count = int.tryParse(_productCountController.text) ?? 0;
    final price = double.tryParse(_sellingPriceController.text) ?? 0;
    final cost = double.tryParse(_costController.text) ?? 0;

    if (name.isNotEmpty && count > 0 && price > 0 && cost > 0) {
      context.read<ProductManager>().addProduct(name, count, price, cost);
      _productNameController.clear();
      _productCountController.clear();
      _sellingPriceController.clear();
      _costController.clear();
    }
  }
}
