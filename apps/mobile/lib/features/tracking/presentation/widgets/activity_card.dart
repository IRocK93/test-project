import 'package:flutter/material.dart';
import 'package:baby_mon/core/constants/app_colors.dart';
import 'package:baby_mon/core/utils/date_utils.dart';
import '../../domain/entities/activity.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback? onDelete;

  const ActivityCard({
    Key? key,
    required this.activity,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(activity.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: _buildIcon(),
          title: Text(_getTitle(), style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(_getSubtitle()),
              const SizedBox(height: 4),
              Text(
                AppDateUtils.formatDateTime(activity.timestamp),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '+${activity.xpEarned} XP',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData icon;
    Color color;

    switch (activity.type) {
      case ActivityType.feeding:
        icon = Icons.restaurant;
        color = Colors.orange;
      case ActivityType.diaper:
        icon = Icons.baby_changing_station;
        color = Colors.blue;
      case ActivityType.sleep:
        icon = Icons.bedtime;
        color = Colors.purple;
      case ActivityType.growth:
        icon = Icons.trending_up;
        color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  String _getTitle() {
    switch (activity.type) {
      case ActivityType.feeding:
        return 'Feeding';
      case ActivityType.diaper:
        return 'Diaper Change';
      case ActivityType.sleep:
        return 'Sleep';
      case ActivityType.growth:
        return 'Growth Measurement';
    }
  }

  String _getSubtitle() {
    switch (activity.type) {
      case ActivityType.feeding:
        return activity.data['method'] ?? 'Bottle';
      case ActivityType.diaper:
        return activity.data['type'] ?? 'Wet';
      case ActivityType.sleep:
        return '${activity.data['durationMinutes'] ?? 0} minutes';
      case ActivityType.growth:
        return 'Weight: ${activity.data['weight'] ?? 0} kg';
    }
  }
}