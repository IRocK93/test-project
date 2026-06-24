import 'package:flutter/material.dart';
import '../../domain/entities/health_record.dart';
import 'package:intl/intl.dart';

class HealthRecordCard extends StatelessWidget {
  final HealthRecord record;
  final VoidCallback onDelete;

  const HealthRecordCard({super.key, required this.record, required this.onDelete});

  String _emojiForCategory(String cat) {
    switch (cat) {
      case 'CHECKUP': return '\u{1FA7A}';
      case 'VACCINE': return '\u{1F489}';
      case 'MEDICATION': return '\u{1F48A}';
      case 'MEASUREMENT': return '\u{1F4CF}';
      default: return '\u{1F3E5}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = record.happenedAt != null
        ? DateFormat('MMM d, yyyy').format(record.happenedAt!)
        : 'No date';

    return Dismissible(
      key: Key(record.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Health Record?'),
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
          leading: Text(_emojiForCategory(record.category), style: const TextStyle(fontSize: 28)),
          title: Text(
            record.title ?? record.category,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(dateStr, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          trailing: record.value != null
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.teal.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                  child: Text('${record.value}${record.unit ?? ''}', style: const TextStyle(color: Colors.tealAccent, fontSize: 11)),
                )
              : null,
          children: [
            if (record.notes != null && record.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(record.notes!, style: TextStyle(color: Colors.grey[300])),
              ),
          ],
        ),
      ),
    );
  }
}
