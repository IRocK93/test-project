import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/feed_log.dart';

class FeedLogCard extends StatelessWidget {
  final FeedLog feedLog;
  final VoidCallback onDelete;

  const FeedLogCard({super.key, required this.feedLog, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('HH:mm').format(feedLog.loggedAt);

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
          leading: Text(feedLog.typeEmoji, style: const TextStyle(fontSize: 32)),
          title: Text(feedLog.type.name.replaceAll('_', ' '), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$timeStr • ${feedLog.summary}', style: TextStyle(color: Colors.grey[400])),
              if (feedLog.notes != null && feedLog.notes!.isNotEmpty)
                Text(feedLog.notes!, style: TextStyle(color: Colors.grey[500], fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
          trailing: feedLog.method != null
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.teal.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
                  child: Text(feedLog.method!.name, style: const TextStyle(color: Colors.tealAccent, fontSize: 11)),
                )
              : null,
        ),
      ),
    );
  }
}