import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/constants/constants.dart';
import 'package:baby_mon/core/widgets/theme_button.dart';

class NameStepWidget extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController middleController;
  final TextEditingController lastNameController;
  final VoidCallback onNext;
  const NameStepWidget({super.key, required this.nameController, required this.middleController, required this.lastNameController, required this.onNext});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceLg), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text("What's your baby's name?", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface)),
      const SizedBox(height: DesignTokens.spaceLg),
      TextField(controller: nameController, decoration: const InputDecoration(labelText: 'First Name *', prefixIcon: Icon(PhosphorIconsLight.baby), border: OutlineInputBorder()), textCapitalization: TextCapitalization.words),
      const SizedBox(height: DesignTokens.spaceMd),
      TextField(controller: middleController, decoration: const InputDecoration(labelText: 'Middle Name', prefixIcon: Icon(PhosphorIconsLight.heart), border: OutlineInputBorder()), textCapitalization: TextCapitalization.words),
      const SizedBox(height: DesignTokens.spaceMd),
      TextField(controller: lastNameController, decoration: const InputDecoration(labelText: 'Last Name', prefixIcon: Icon(PhosphorIconsLight.users), border: OutlineInputBorder()), textCapitalization: TextCapitalization.words),
      const SizedBox(height: DesignTokens.spaceXl),
      ThemeButton(text: 'Next', onPressed: nameController.text.trim().isNotEmpty ? onNext : null, fullWidth: true, trailingIcon: PhosphorIconsLight.arrowRight),
    ]));
  }
}

class StageStepWidget extends StatelessWidget {
  final String selectedStage;
  final DateTime? selectedDate;
  final ValueChanged<String> onStageChanged;
  final ValueChanged<DateTime?> onDateChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;
  const StageStepWidget({super.key, required this.selectedStage, this.selectedDate, required this.onStageChanged, required this.onDateChanged, required this.onNext, required this.onBack});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceLg), child: Column(mainAxisSize: MainAxisSize.min, children: [
    SegmentedButton<String>(segments: const [ButtonSegment(value: 'PLAN', label: Text('Plan')), ButtonSegment(value: 'INCUBATING', label: Text('Conceived')), ButtonSegment(value: 'BORN', label: Text('Born'))], selected: {selectedStage}, onSelectionChanged: (s) => onStageChanged(s.first)),
    const SizedBox(height: DesignTokens.spaceLg),
    OutlinedButton.icon(onPressed: () async { final p = await showDatePicker(context: context, initialDate: selectedDate ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 280))); if (p != null) onDateChanged(p); }, icon: const Icon(PhosphorIconsLight.calendar), label: Text(selectedDate != null ? selectedDate!.toIso8601String().split('T').first : 'Select Date')),
    const SizedBox(height: DesignTokens.spaceXl),
    Row(children: [ThemeButton(text: 'Back', onPressed: onBack, variant: ThemeButtonVariant.outlined), const SizedBox(width: DesignTokens.spaceMd), Expanded(child: ThemeButton(text: 'Next', onPressed: selectedDate != null ? onNext : null, trailingIcon: PhosphorIconsLight.arrowRight))]),
  ]));
}

class SpiritStepWidget extends StatelessWidget {
  final String selectedGender;
  final Set<String> selectedTraits;
  final ValueChanged<String> onGenderChanged;
  final ValueChanged<Set<String>> onTraitsChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;
  const SpiritStepWidget({super.key, required this.selectedGender, required this.selectedTraits, required this.onGenderChanged, required this.onTraitsChanged, required this.onNext, required this.onBack});
  static const defaultTraits = ['Curious', 'Peaceful', 'Playful', 'Gentle', 'Adventurous', 'Creative'];
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceLg), child: Column(mainAxisSize: MainAxisSize.min, children: [
    SegmentedButton<String>(segments: const [ButtonSegment(value: 'MONIOUS', label: Text('Boy')), ButtonSegment(value: 'MONIESE', label: Text('Girl')), ButtonSegment(value: 'MO', label: Text('Neutral'))], selected: {selectedGender}, onSelectionChanged: (s) => onGenderChanged(s.first)),
    const SizedBox(height: DesignTokens.spaceLg),
    Wrap(spacing: 8, runSpacing: 6, children: defaultTraits.map((t) { final sel = selectedTraits.contains(t); return FilterChip(label: Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)), selected: sel, onSelected: (v) { final u = Set<String>.from(selectedTraits); v ? u.add(t) : u.remove(t); onTraitsChanged(u); }, visualDensity: VisualDensity.compact); }).toList()),
    const SizedBox(height: DesignTokens.spaceXl),
    Row(children: [ThemeButton(text: 'Back', onPressed: onBack, variant: ThemeButtonVariant.outlined), const SizedBox(width: DesignTokens.spaceMd), Expanded(child: ThemeButton(text: 'Review', onPressed: onNext, trailingIcon: PhosphorIconsLight.checkCircle))]),
  ]));
}
