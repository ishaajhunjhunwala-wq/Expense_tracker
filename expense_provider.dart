import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../models/participant.dart';

/// Single source of truth for the app's in-memory state.
///
/// Everything is local-first: no network calls, no persistence layer yet
/// (that's a Phase 2/3 concern). Kept as one ChangeNotifier so widgets can
/// subscribe with `context.watch<ExpenseProvider>()` and rebuild only when
/// notifyListeners() actually fires — clean separation between UI and logic.
class ExpenseProvider extends ChangeNotifier {
  final List<Participant> _participants = [];
  final List<Expense> _expenses = [];

  int _idCounter = 0;
  String _nextId(String prefix) => '$prefix-${_idCounter++}-${DateTime.now().microsecondsSinceEpoch}';

  UnmodifiableListView<Participant> get participants =>
      UnmodifiableListView(_participants);

  /// Most recent first — this powers the Activity Log.
  UnmodifiableListView<Expense> get expenses => UnmodifiableListView(
        [..._expenses]..sort((a, b) => b.timestamp.compareTo(a.timestamp)),
      );

  double get totalSpent => _expenses.fold(0.0, (sum, e) => sum + e.amount);

  /// Net standing per participant: what they paid minus what they owe.
  /// Positive => group owes them. Negative => they owe the group.
  Map<String, double> get balances {
    final Map<String, double> paid = {for (final p in _participants) p.id: 0};
    final Map<String, double> owed = {for (final p in _participants) p.id: 0};

    for (final e in _expenses) {
      paid[e.paidById] = (paid[e.paidById] ?? 0) + e.amount;
      final share = e.perPersonShare;
      for (final id in e.splitAmongIds) {
        owed[id] = (owed[id] ?? 0) + share;
      }
    }

    return {
      for (final p in _participants) p.id: (paid[p.id] ?? 0) - (owed[p.id] ?? 0)
    };
  }

  // ---------------------------------------------------------------------
  // Participant management
  // ---------------------------------------------------------------------

  /// Returns an error message on failure, or null on success.
  String? addParticipant(String rawName) {
    final name = rawName.trim();
    if (name.isEmpty) return 'Name cannot be empty.';
    final duplicate = _participants
        .any((p) => p.name.toLowerCase() == name.toLowerCase());
    if (duplicate) return 'That person is already in the group.';

    _participants.add(Participant(id: _nextId('p'), name: name));
    notifyListeners();
    return null;
  }

  String? removeParticipant(String id) {
    final inUse = _expenses.any(
      (e) => e.paidById == id || e.splitAmongIds.contains(id),
    );
    if (inUse) {
      return 'Cannot remove — this person is tied to existing expenses.';
    }
    _participants.removeWhere((p) => p.id == id);
    notifyListeners();
    return null;
  }

  // ---------------------------------------------------------------------
  // Expense management
  // ---------------------------------------------------------------------

  /// Strict input sanitization lives here, in the logic layer — never
  /// trusted purely to UI-side form validators. Returns an error message
  /// on failure, or null on success.
  String? addExpense({
    required String description,
    required double? amount,
    required ExpenseCategory category,
    required String? paidById,
    required List<String> splitAmongIds,
  }) {
    final desc = description.trim();
    if (desc.isEmpty) return 'Description cannot be empty.';

    if (amount == null || amount.isNaN) return 'Enter a valid amount.';
    if (amount <= 0) return 'Amount must be greater than zero.';

    if (paidById == null || paidById.isEmpty) {
      return 'Select who paid.';
    }
    if (!_participants.any((p) => p.id == paidById)) {
      return 'Payer is not a valid group member.';
    }

    if (splitAmongIds.isEmpty) {
      return 'Invalid group size — select at least one person to split with.';
    }
    final validIds = _participants.map((p) => p.id).toSet();
    if (!splitAmongIds.every(validIds.contains)) {
      return 'Split group contains an invalid member.';
    }

    _expenses.add(
      Expense(
        id: _nextId('e'),
        description: desc,
        amount: double.parse(amount.toStringAsFixed(2)),
        category: category,
        timestamp: DateTime.now(),
        paidById: paidById,
        splitAmongIds: List.unmodifiable(splitAmongIds),
      ),
    );
    notifyListeners();
    return null;
  }

  Participant? participantById(String id) {
    for (final p in _participants) {
      if (p.id == id) return p;
    }
    return null;
  }
}
