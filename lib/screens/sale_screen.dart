import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../inventory/product_manager.dart';

class SaleScreen extends StatefulWidget {
  SaleScreen({Key? key}) : super(key: key);

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  final TextEditingController _buyerController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _creditGivenController = TextEditingController();
  final TextEditingController _creditReceivedController =
      TextEditingController();

  @override
  void dispose() {
    _buyerController.dispose();
    _quantityController.dispose();
    _creditGivenController.dispose();
    _creditReceivedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Sales", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Consumer<ProductManager>(
            builder: (context, manager, child) {
              return DropdownButtonFormField<int>(
                decoration: _inputDecoration("Product", "Select product"),
                value: manager.selectedProductId,
                items: manager.products.map((product) {
                  return DropdownMenuItem<int>(
                    value: product.id,
                    child: Text(product.name),
                  );
                }).toList(),
                onChanged: (value) => manager.setSelectedProductId(value!),
              );
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _buyerController,
            decoration: _inputDecoration("Buyer Name", "Enter buyer name"),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _quantityController,
            decoration: _inputDecoration("Quantity", "Enter quantity"),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _creditGivenController,
            decoration: _inputDecoration("Credit Given", "Enter credit given"),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _creditReceivedController,
            decoration:
                _inputDecoration("Credit Received", "Enter credit received"),
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
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${sale.buyer} bought ${product.name}",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(
                                "Quantity: ${sale.quantity}, Amount: ₹${sale.amount.toStringAsFixed(2)}"),
                            Text(
                                "Credit Given: ₹${sale.creditGiven?.toStringAsFixed(2) ?? '0.00'}, Credit Received: ₹${sale.creditReceived?.toStringAsFixed(2) ?? '0.00'}"),
                            const SizedBox(height: 8),
                            Text(
                                DateTime.fromMillisecondsSinceEpoch(
                                        sale.saleDate.millisecondsSinceEpoch)
                                    .toString(),
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey)),
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

  void _recordSale(BuildContext context) {
    final manager = context.read<ProductManager>();
    final productId = manager.selectedProductId;
    final buyer = _buyerController.text;
    final quantity = int.tryParse(_quantityController.text);
    final creditGiven = double.tryParse(_creditGivenController.text) ?? 0.0;
    final creditReceived =
        double.tryParse(_creditReceivedController.text) ?? 0.0;

    if (productId == null ||
        buyer.isEmpty ||
        quantity == null ||
        quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields correctly")),
      );
      return;
    }

    manager
        .recordSale(productId, buyer, quantity, true,
            creditGiven: creditGiven, creditReceived: creditReceived)
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sale recorded successfully")),
      );
      _buyerController.clear();
      _quantityController.clear();
      _creditGivenController.clear();
      _creditReceivedController.clear();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error recording sale: $error")),
      );
    });
  }
}
