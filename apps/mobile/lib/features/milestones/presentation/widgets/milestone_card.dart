import 'package:flutter/material.dart';
import '../../domain/entities/milestone.dart';
import 'package:intl/intl.dart';

class MilestoneCard extends StatelessWidget {
  final Milestone milestone;
  final VoidCallback onDelete;

  const MilestoneCard({super.key, required this.milestone, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, yyyy').format(milestone.date);

    return Dismissible(
      key: Key(milestone.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Milestone?'),
            content: const Text('This cannot be undone.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: const Color(0xFF1E1E1E),
        child: ExpansionTile(
          leading: Text(milestone.categoryEmoji, style: const TextStyle(fontSize: 28)),
          title: Text(milestone.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          subtitle: Text(dateStr, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
            child: Text('+${milestone.xpAwarded} XP', style: const TextStyle(color: Colors.deepPurpleAccent, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          children: [
            if (milestone.description != null && milestone.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(milestone.description!, style: TextStyle(color: Colors.grey[300])),
              ),
          ],
        ),
      ),
    );
  }
}
