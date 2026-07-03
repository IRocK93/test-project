import 'package:baby_mon/l10n/l10n_ext.dart';
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

  String _labelForType(BuildContext context, String type) {
    switch (type) {
      case 'BREASTMILK': return context.l10n.breastmilkLabel;
      case 'FORMULA': return context.l10n.formula;
      case 'SOLID': return context.l10n.solidFood;
      default: return type;
    }
  }

  String _summary(FeedLog log, BuildContext ctx) {
    final parts = <String>[];
    if (log.amount != null) parts.add('${log.amount}${log.unit ?? ''}');
    return parts.isEmpty ? ctx.l10n.logged : parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = feedLog.happenedAt != null
        ? DateFormat('HH:mm').format(feedLog.happenedAt!)
        : context.l10n.noTimeFallback;

    return Dismissible(
      key: Key(feedLog.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(context.l10n.deleteFeedLogTitle),
            content: Text(context.l10n.deleteConfirmText),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.l10n.cancel)),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(context.l10n.delete, style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: const Color(0xFF1E1E1E),
        child: ListTile(
          leading: Text(_emojiForType(feedLog.type), style: const TextStyle(fontSize: 32)),
          title: Text(_labelForType(context, feedLog.type), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$timeStr • ${_summary(feedLog, context)}', style: TextStyle(color: Colors.grey[400])),
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
