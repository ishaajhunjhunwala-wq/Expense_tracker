import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';

/// Standard Equal Distribution entry form, with input sanitization both
/// at the UI layer (form validators, immediate feedback) and re-checked
/// in ExpenseProvider (the real source of truth for validity).
class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _amountController = TextEditingController();

  ExpenseCategory _category = ExpenseCategory.food;
  String? _paidById;
  final Set<String> _splitAmong = {};

  @override
  void dispose() {
    // Proper memory management — controllers must be disposed.
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Default: everyone in the group is included in the split.
    if (_splitAmong.isEmpty) {
      final provider = context.read<ExpenseProvider>();
      _splitAmong.addAll(provider.participants.map((p) => p.id));
      _paidById ??=
          provider.participants.isNotEmpty ? provider.participants.first.id : null;
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ExpenseProvider>();
    final error = provider.addExpense(
      description: _descController.text,
      amount: double.tryParse(_amountController.text.trim()),
      category: _category,
      paidById: _paidById,
      splitAmongIds: _splitAmong.toList(),
    );

    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final participants = provider.participants;

    return Scaffold(
      appBar: AppBar(title: const Text('Add expense')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'e.g. Auto ride to campus',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Description cannot be empty';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (₹)',
                border: OutlineInputBorder(),
                prefixText: '₹ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Amount cannot be empty';
                }
                final parsed = double.tryParse(value.trim());
                if (parsed == null) return 'Enter a valid number';
                if (parsed <= 0) return 'Amount must be greater than zero';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ExpenseCategory>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: ExpenseCategory.values
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            Icon(c.icon, size: 18),
                            const SizedBox(width: 8),
                            Text(c.label),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _paidById,
              decoration: const InputDecoration(
                labelText: 'Paid by',
                border: OutlineInputBorder(),
              ),
              items: participants
                  .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                  .toList(),
              onChanged: (value) => setState(() => _paidById = value),
              validator: (value) => value == null ? 'Select who paid' : null,
            ),
            const SizedBox(height: 20),
            Text(
              'Split among (${_splitAmong.length} selected)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'Equal share is applied automatically across everyone selected.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Column(
                children: participants
                    .map(
                      (p) => CheckboxListTile(
                        title: Text(p.name),
                        value: _splitAmong.contains(p.id),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _splitAmong.add(p.id);
                            } else {
                              _splitAmong.remove(p.id);
                            }
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.check_rounded),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text('Save expense'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
