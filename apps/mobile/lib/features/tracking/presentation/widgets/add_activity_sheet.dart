import 'package:baby_mon/l10n/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:baby_mon/core/constants/app_colors.dart';
import 'package:baby_mon/core/widgets/custom_button.dart';
import '../../domain/entities/activity.dart';
import '../providers/activity_provider.dart';

class AddActivitySheet extends StatefulWidget {
  final ActivityType type;

  const AddActivitySheet({
    super.key,
    required this.type,
  });

  @override
  State<AddActivitySheet> createState() => _AddActivitySheetState();
}

class _AddActivitySheetState extends State<AddActivitySheet> {
  // Controllers and state for each activity type
  final TextEditingController _methodController = TextEditingController();
  final TextEditingController _diaperTypeController = TextEditingController();
  final TextEditingController _sleepDurationController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  String _selectedMethod = 'Breast';
  String _selectedDiaperType = 'Wet';
  int _sleepDuration = 30;
  double _weight = 3.5;
  double _height = 50.0;

  @override
  void dispose() {
    _methodController.dispose();
    _diaperTypeController.dispose();
    _sleepDurationController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        start: 24,
        end: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${context.l10n.addActivity} ${_getTypeName(context)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildFormFields(),
            const SizedBox(height: 24),
            Consumer<ActivityProvider>(
              builder: (context, provider, _) => CustomButton(
                text: context.l10n.saveActivity,
                isLoading: provider.isLoading,
                onPressed: _saveActivity,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _getTypeName(BuildContext context) {
    switch (widget.type) {
      case ActivityType.feeding:
        return context.l10n.feedingFilter;
      case ActivityType.diaper:
        return context.l10n.diapersFilter;
      case ActivityType.sleep:
        return context.l10n.sleepFilter;
      case ActivityType.growth:
        return context.l10n.growthFilter;
    }
  }

  Widget _buildFormFields() {
    switch (widget.type) {
      case ActivityType.feeding:
        return Column(
          children: [
            Text(context.l10n.feedingMethodLabel),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [context.l10n.breastLabel, context.l10n.bottleLabel, context.l10n.solidLabel, context.l10n.pumpedLabel].map((method) {
                return ChoiceChip(
                  label: Text(method),
                  selected: _selectedMethod == method,
                  onSelected: (selected) => setState(() => _selectedMethod = method),
                );
              }).toList(),
            ),
          ],
        );
      case ActivityType.diaper:
        return Column(
          children: [
            Text(context.l10n.diaperTypeLabel),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [context.l10n.wetLabel, context.l10n.dirtyLabel, context.l10n.bothLabel].map((type) {
                return ChoiceChip(
                  label: Text(type),
                  selected: _selectedDiaperType == type,
                  onSelected: (selected) => setState(() => _selectedDiaperType = type),
                );
              }).toList(),
            ),
          ],
        );
      case ActivityType.sleep:
        return Column(
          children: [
            Text(context.l10n.durationMinutesFormat(_sleepDuration)),
            Slider(
              value: _sleepDuration.toDouble(),
              min: 5,
              max: 240,
              divisions: 47,
              label: '${_sleepDuration.round()} min',
              onChanged: (value) =>
                  setState(() => _sleepDuration = value.round()),
            ),
          ],
        );
      case ActivityType.growth:
        return Column(
          children: [
            Text(context.l10n.weightKgFormat(_weight.toStringAsFixed(1))),
            Slider(
              value: _weight,
              min: 1,
              max: 20,
              divisions: 38,
              label: '${_weight.toStringAsFixed(1)} kg',
              onChanged: (value) => setState(() => _weight = value),
            ),
            const SizedBox(height: 16),
            Text(context.l10n.heightCmFormat(_height.toStringAsFixed(0))),
            Slider(
              value: _height,
              min: 30,
              max: 120,
              divisions: 90,
              label: '${_height.round()} cm',
              onChanged: (value) => setState(() => _height = value),
            ),
          ],
        );
    }
  }

  Future<void> _saveActivity() async {
    Map<String, dynamic> data;
    
    switch (widget.type) {
      case ActivityType.feeding:
        data = {'method': _selectedMethod};
      case ActivityType.diaper:
        data = {'type': _selectedDiaperType};
      case ActivityType.sleep:
        data = {'durationMinutes': _sleepDuration};
      case ActivityType.growth:
        data = {'weight': _weight, 'height': _height};
    }

    final provider = context.read<ActivityProvider>();
    final success = await provider.addActivity(widget.type, data);
    
    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.activitySavedXP),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}