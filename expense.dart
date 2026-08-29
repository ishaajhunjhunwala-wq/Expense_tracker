import 'package:flutter/material.dart';

/// Categories relevant to campus life. Extend freely for Phase 2/3.
enum ExpenseCategory { food, transport, subscription, printout, other }

extension ExpenseCategoryX on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.food:
        return 'Food';
      case ExpenseCategory.transport:
        return 'Transport';
      case ExpenseCategory.subscription:
        return 'Subscription';
      case ExpenseCategory.printout:
        return 'Printout';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.food:
        return Icons.fastfood_rounded;
      case ExpenseCategory.transport:
        return Icons.local_taxi_rounded;
      case ExpenseCategory.subscription:
        return Icons.subscriptions_rounded;
      case ExpenseCategory.printout:
        return Icons.print_rounded;
      case ExpenseCategory.other:
        return Icons.receipt_long_rounded;
    }
  }
}

/// A single logged expense, split equally among [splitAmongIds].
class Expense {
  final String id;
  final String description;
  final double amount;
  final ExpenseCategory category;
  final DateTime timestamp;
  final String paidById;
  final List<String> splitAmongIds;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.timestamp,
    required this.paidById,
    required this.splitAmongIds,
  });

  /// Standard equal distribution: total divided by group size.
  double get perPersonShare =>
      splitAmongIds.isEmpty ? 0 : amount / splitAmongIds.length;
}
