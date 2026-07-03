import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/constants/constants.dart';
import 'package:baby_mon/l10n/l10n_ext.dart';
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
      Text(context.l10n.whatsYourBabyName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface)),
      const SizedBox(height: DesignTokens.spaceLg),
      TextField(controller: nameController, decoration: InputDecoration(labelText: context.l10n.firstNameRequired, prefixIcon: const Icon(PhosphorIconsLight.baby), border: const OutlineInputBorder()), textCapitalization: TextCapitalization.words),
      const SizedBox(height: DesignTokens.spaceMd),
      TextField(controller: middleController, decoration: InputDecoration(labelText: context.l10n.middleName, prefixIcon: const Icon(PhosphorIconsLight.heart), border: const OutlineInputBorder()), textCapitalization: TextCapitalization.words),
      const SizedBox(height: DesignTokens.spaceMd),
      TextField(controller: lastNameController, decoration: InputDecoration(labelText: context.l10n.lastName, prefixIcon: const Icon(PhosphorIconsLight.users), border: const OutlineInputBorder()), textCapitalization: TextCapitalization.words),
      const SizedBox(height: DesignTokens.spaceXl),
      ThemeButton(text: context.l10n.nextButton, onPressed: nameController.text.trim().isNotEmpty ? onNext : null, fullWidth: true, trailingIcon: PhosphorIconsLight.arrowRight),
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
    SegmentedButton<String>(segments: [ButtonSegment(value: 'PLAN', label: Text(context.l10n.planLabel)), ButtonSegment(value: 'INCUBATING', label: Text(context.l10n.conceivedLabel)), ButtonSegment(value: 'BORN', label: Text(context.l10n.bornLabel))], selected: {selectedStage}, onSelectionChanged: (s) => onStageChanged(s.first)),
    const SizedBox(height: DesignTokens.spaceLg),
    OutlinedButton.icon(onPressed: () async { final p = await showDatePicker(context: context, initialDate: selectedDate ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 280))); if (p != null) onDateChanged(p); }, icon: const Icon(PhosphorIconsLight.calendar),            label: Text(selectedDate != null ? selectedDate!.toIso8601String().split('T').first : context.l10n.selectDate)),
    const SizedBox(height: DesignTokens.spaceXl),
    Row(children: [ThemeButton(text: context.l10n.backButton, onPressed: onBack, variant: ThemeButtonVariant.outlined), const SizedBox(width: DesignTokens.spaceMd), Expanded(child: ThemeButton(text: context.l10n.nextButton, onPressed: selectedDate != null ? onNext : null, trailingIcon: PhosphorIconsLight.arrowRight))]),
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
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceLg), child: Column(mainAxisSize: MainAxisSize.min, children: [
    SegmentedButton<String>(segments: [ButtonSegment(value: 'MONIOUS', label: Text(context.l10n.boy)), ButtonSegment(value: 'MONIESE', label: Text(context.l10n.girl)), ButtonSegment(value: 'MO', label: Text(context.l10n.neutralGender))], selected: {selectedGender}, onSelectionChanged: (s) => onGenderChanged(s.first)),
    const SizedBox(height: DesignTokens.spaceLg),
    Wrap(spacing: 8, runSpacing: 6, children: kTraitKeys.map((t) { final sel = selectedTraits.contains(t); return FilterChip(label: Text(traitDisplay(t, context.l10n), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)), selected: sel, onSelected: (v) { final u = Set<String>.from(selectedTraits); v ? u.add(t) : u.remove(t); onTraitsChanged(u); }, visualDensity: VisualDensity.compact); }).toList()),
    const SizedBox(height: DesignTokens.spaceXl),
    Row(children: [ThemeButton(text: context.l10n.backButton, onPressed: onBack, variant: ThemeButtonVariant.outlined), const SizedBox(width: DesignTokens.spaceMd), Expanded(child: ThemeButton(text: context.l10n.reviewButton, onPressed: onNext, trailingIcon: PhosphorIconsLight.checkCircle))]),
  ]));
}
