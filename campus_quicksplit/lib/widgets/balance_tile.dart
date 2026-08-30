import 'package:flutter/material.dart';
import '../models/participant.dart';

/// One row in the Aggregated Balance View: a participant's net standing.
class BalanceTile extends StatelessWidget {
  final Participant participant;
  final double balance;

  const BalanceTile({
    super.key,
    required this.participant,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    final bool settled = balance.abs() < 0.005;
    final bool isOwed = balance > 0;

    final Color color = settled
        ? Colors.grey.shade600
        : isOwed
            ? Colors.green.shade700
            : Colors.red.shade600;

    final String statusText = settled
        ? 'Settled up'
        : isOwed
            ? 'Gets back ₹${balance.toStringAsFixed(2)}'
            : 'Owes ₹${(-balance).toStringAsFixed(2)}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Text(
            participant.name.isNotEmpty
                ? participant.name[0].toUpperCase()
                : '?',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(participant.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Text(
          statusText,
          style: TextStyle(color: color, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
