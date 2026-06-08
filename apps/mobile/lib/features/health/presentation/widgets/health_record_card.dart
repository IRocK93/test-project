import 'package:flutter/material.dart';
import '../../domain/entities/health_record.dart';
import 'package:intl/intl.dart';

class HealthRecordCard extends StatelessWidget {
  final HealthRecord record;
  final VoidCallback onDelete;

  const HealthRecordCard({super.key, required this.record, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, yyyy').format(record.date);

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
          leading: Text(record.typeEmoji, style: const TextStyle(fontSize: 28)),
          title: Text(
            record.type.name.replaceAll('_', ' '),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(dateStr, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          trailing: _statusBadge(record.status),
          children: [
            if (record.doctorName != null && record.doctorName!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.grey, size: 16),
                    const SizedBox(width: 8),
                    Text('Dr. ${record.doctorName}', style: TextStyle(color: Colors.grey[300])),
                  ],
                ),
              ),
            if (record.location != null && record.location!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey, size: 16),
                    const SizedBox(width: 8),
                    Text(record.location!, style: TextStyle(color: Colors.grey[300])),
                  ],
                ),
              ),
            if (record.notes != null && record.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Text(record.notes!, style: TextStyle(color: Colors.grey[300])),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(HealthRecordStatus status) {
    Color color;
    switch (status) {
      case HealthRecordStatus.COMPLETED:
        color = Colors.green;
        break;
      case HealthRecordStatus.SCHEDULED:
        color = Colors.amber;
        break;
      case HealthRecordStatus.CANCELLED:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.name,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
