import 'package:baby_mon/l10n/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:baby_mon/core/constants/app_colors.dart';
import '../../domain/entities/activity.dart';

class ActivityTypeSelector extends StatelessWidget {
  final ActivityType? selectedType;
  final void Function(ActivityType?) onTypeSelected;

  const ActivityTypeSelector({
    super.key,
    this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildChip(null, context.l10n.allFilter),
          _buildChip(ActivityType.feeding, context.l10n.feedingFilter),
          _buildChip(ActivityType.diaper, context.l10n.diapersFilter),
          _buildChip(ActivityType.sleep, context.l10n.sleepFilter),
          _buildChip(ActivityType.growth, context.l10n.growthFilter),
        ],
      ),
    );
  }

  Widget _buildChip(ActivityType? type, String label) {
    final isSelected = selectedType == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTypeSelected(type),
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        checkmarkColor: AppColors.primary,
      ),
    );
  }
}