// lib/screens/credit_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../inventory/product_manager.dart';

class CreditScreen extends StatefulWidget {
  const CreditScreen({super.key});

  @override
  State<CreditScreen> createState() => _CreditScreenState();
}

class _CreditScreenState extends State<CreditScreen> {
  final TextEditingController _entityController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _creditMessage = '';
  String _selectedCreditType = 'Given';

  @override
  void dispose() {
    _entityController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text("Credit Management",
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 14),
          TextFormField(
            controller: _entityController,
            decoration: _inputDecoration("Entity Name", "Customer/Supplier"),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _amountController,
            decoration: _inputDecoration("Amount", "Enter amount"),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: _inputDecoration("Credit Type", "Select type"),
            value: _selectedCreditType,
            items: const [
              DropdownMenuItem(value: 'Given', child: Text('Credit Given')),
              DropdownMenuItem(
                  value: 'Received', child: Text('Credit Received')),
              DropdownMenuItem(value: 'CashCredit', child: Text('Cash Credit')),
            ],
            onChanged: (v) => setState(() => _selectedCreditType = v!),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descriptionController,
            decoration: _inputDecoration("Description", "Optional"),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _recordCredit,
            icon: const Icon(Icons.save),
            label: const Text("Record Credit"),
          ),
          const SizedBox(height: 16),
          Consumer<ProductManager>(
            builder: (context, manager, child) {
              final entityName = _entityController.text;
              final outstandingBalance =
                  manager.calculateOutstandingBalance(entityName);
              final transactions = manager.getAllCreditTransactions();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "Outstanding Balance for $entityName: ₹${outstandingBalance.toStringAsFixed(2)}"),
                  Text(_creditMessage,
                      style: const TextStyle(color: Colors.green)),
                  const SizedBox(height: 16),
                  Text("Credit Transactions:",
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...transactions.map((t) => Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Entity: ${t.entityName}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text("Amount: ₹${t.amount.toStringAsFixed(2)}"),
                              Text("Type: ${t.type}"),
                              Text(
                                  "Date: ${DateFormat.yMd().format(t.transactionDate)}"),
                              if (t.description != null)
                                Text("Description: ${t.description}"),
                            ],
                          ),
                        ),
                      )),
                ],
              );
            },
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

  void _recordCredit() {
    final entityName = _entityController.text;
    final amount = double.tryParse(_amountController.text) ?? 0;
    final description = _descriptionController.text;

    if (entityName.isEmpty || amount <= 0) return;

    final manager = context.read<ProductManager>();
    Future<void> action;

    switch (_selectedCreditType) {
      case 'Given':
        action = manager.recordCreditGiven(
            entityName: entityName, amount: amount, description: description);
        break;
      case 'Received':
        action = manager.recordCreditReceived(
            entityName: entityName, amount: amount, description: description);
        break;
      case 'CashCredit':
        action = manager.recordCashCredit(
            entityName: entityName, amount: amount, description: description);
        break;
      default:
        action = Future.value();
    }

    action.then((_) {
      setState(() => _creditMessage =
          "$_selectedCreditType recorded successfully for $entityName");
      _entityController.clear();
      _amountController.clear();
      _descriptionController.clear();
    });
  }
}
