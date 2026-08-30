import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';

/// One row in the time-ordered Activity Log.
class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final ExpenseProvider provider;

  const ExpenseTile({super.key, required this.expense, required this.provider});

  @override
  Widget build(BuildContext context) {
    final payer = provider.participantById(expense.paidById);
    final formattedTime = DateFormat('MMM d, h:mm a').format(expense.timestamp);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: Icon(expense.category.icon,
              color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(expense.description,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${expense.category.label} • Paid by ${payer?.name ?? 'Unknown'} • '
          'Split ${expense.splitAmongIds.length} ways\n$formattedTime',
        ),
        isThreeLine: true,
        trailing: Text(
          '₹${expense.amount.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
