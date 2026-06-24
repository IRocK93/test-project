import 'package:flutter/material.dart';
/// Section showing milestone achievements as chips
///
/// Each AchievementItem has a color (non-nullable) and icon (non-nullable).
class AchievementsSection extends StatelessWidget {
  final List<AchievementItem> achievements;
  const AchievementsSection({super.key, required this.achievements});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Milestones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: achievements.map((a) => _buildChip(a)).toList(),
        ),
      ],
    );
  }
  Widget _buildChip(AchievementItem item) {
    return Chip(
      avatar: Icon(item.icon, size: 18, color: item.color),
      label: Text(item.title),
      backgroundColor: item.color.withValues(alpha: 0.15),
    );
  }
}
/// Milestone model with required color and icon.
class AchievementItem {
  final String title;
  final IconData icon;
  final Color color;
  const AchievementItem({required this.title, required this.icon, required this.color});
}
