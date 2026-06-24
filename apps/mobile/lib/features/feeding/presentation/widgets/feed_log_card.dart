import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/feed_log.dart';

class FeedLogCard extends StatelessWidget {
  final FeedLog feedLog;
  final VoidCallback onDelete;

  const FeedLogCard({super.key, required this.feedLog, required this.onDelete});

  String _emojiForType(String type) {
    switch (type) {
      case 'BREASTMILK': return '🤱';
      case 'FORMULA': return '🍼';
      case 'SOLID': return '🥄';
      default: return '🍽️';
    }
  }

  String _labelForType(String type) {
    switch (type) {
      case 'BREASTMILK': return 'Breastmilk';
      case 'FORMULA': return 'Formula';
      case 'SOLID': return 'Solid';
      default: return type;
    }
  }

  String _summary(FeedLog log) {
    final parts = <String>[];
    if (log.amount != null) parts.add('${log.amount}${log.unit ?? ''}');
    return parts.isEmpty ? 'Logged' : parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = feedLog.happenedAt != null
        ? DateFormat('HH:mm').format(feedLog.happenedAt!)
        : '--:--';

    return Dismissible(
      key: Key(feedLog.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Feed Log?'),
            content: const Text('This cannot be undone.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
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
        child: ListTile(
          leading: Text(_emojiForType(feedLog.type), style: const TextStyle(fontSize: 32)),
          title: Text(_labelForType(feedLog.type), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$timeStr • ${_summary(feedLog)}', style: TextStyle(color: Colors.grey[400])),
              if (feedLog.notes != null && feedLog.notes!.isNotEmpty)
                Text(feedLog.notes!, style: TextStyle(color: Colors.grey[500], fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
          trailing: feedLog.unit != null
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.teal.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(8)),
                  child: Text(feedLog.unit!, style: const TextStyle(color: Colors.tealAccent, fontSize: 11)),
                )
              : null,
        ),
      ),
    );
  }
}
