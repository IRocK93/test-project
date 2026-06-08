import 'package:flutter/material.dart';
import 'package:baby_mon/core/constants/app_colors.dart';
import '../../domain/entities/activity.dart';

class ActivityTypeSelector extends StatelessWidget {
  final ActivityType? selectedType;
  final void Function(ActivityType?) onTypeSelected;

  const ActivityTypeSelector({
    Key? key,
    this.selectedType,
    required this.onTypeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildChip(null, 'All'),
          _buildChip(ActivityType.feeding, 'Feeding'),
          _buildChip(ActivityType.diaper, 'Diapers'),
          _buildChip(ActivityType.sleep, 'Sleep'),
          _buildChip(ActivityType.growth, 'Growth'),
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
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
      ),
    );
  }
}