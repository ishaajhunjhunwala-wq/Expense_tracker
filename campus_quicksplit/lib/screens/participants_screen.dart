import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';

/// Add/remove group members. Validation (empty names, duplicates, members
/// tied to existing expenses) is enforced in ExpenseProvider, not just here.
class ParticipantsScreen extends StatefulWidget {
  const ParticipantsScreen({super.key});

  @override
  State<ParticipantsScreen> createState() => _ParticipantsScreenState();
}

class _ParticipantsScreenState extends State<ParticipantsScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addParticipant() {
    final provider = context.read<ExpenseProvider>();
    final error = provider.addParticipant(_nameController.text);
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    _nameController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Group members')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Add a member',
                      hintText: 'e.g. Priya',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addParticipant(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _addParticipant,
                  child: const Icon(Icons.add_rounded),
                ),
              ],
            ),
          ),
          Expanded(
            child: provider.participants.isEmpty
                ? const Center(child: Text('No members yet'))
                : ListView.builder(
                    itemCount: provider.participants.length,
                    itemBuilder: (context, index) {
                      final p = provider.participants[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(p.name.isNotEmpty
                              ? p.name[0].toUpperCase()
                              : '?'),
                        ),
                        title: Text(p.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded),
                          onPressed: () {
                            final error = provider.removeParticipant(p.id);
                            if (error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(error)),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
