import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' as semantics;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/core/mixins/mixins.dart';
import 'package:baby_mon/features/settings/settings.dart';
import 'package:baby_mon/core/constants/constants.dart';
import 'package:baby_mon/core/utils/utils.dart';
import 'package:baby_mon/core/utils/error_handler.dart';
import 'package:baby_mon/features/health/domain/entities/health_record.dart';
import 'package:baby_mon/features/health/domain/entities/allergy.dart';
import 'package:baby_mon/core/widgets/widgets.dart';
import 'package:baby_mon/features/dashboard/presentation/widgets/level_up_celebration.dart';
class HealthScreen extends ConsumerStatefulWidget {
  const HealthScreen({super.key});
  @override
  ConsumerState<HealthScreen> createState() => _HealthScreenState();
}
class _HealthScreenState extends ConsumerState<HealthScreen>
    with DataScreenMixin<HealthScreen> {
  @override
  Duration? get refreshCooldown => const Duration(seconds: 10);
  List<HealthRecord> _records = [];
  String _selectedCategory = 'ALL';
  bool _isMetric = true;
  List<Allergy> _allergies = [];
  List<HealthDisplayEntry> _cachedAllergyEntries = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => loadData());
    ref.listenManual(appRefreshProvider, (prev, next) {
      if (prev != next) loadData();
    });
    ref.listenManual(tabRefreshProvider(3), (prev, next) {
      if (prev != next) loadData();
    });
    // Cross-tab signal from the main InfoFab: open the
    // appropriate dialog when the action fires, then clear
    // the signal so it doesn't re-open on rebuild.
    ref.listenManual(pendingAddActionProvider, (prev, next) {
      if (next == null) return;
      ref.read(pendingAddActionProvider.notifier).state = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        switch (next) {
          case AddAction.healthMeasurement:
            _showMeasurementDialog();
          case AddAction.healthEvent:
            _showEventDialog();
          case AddAction.healthMedicalTeam:
            _showMedicalTeamDialog();
          default:
            break;
        }
      });
    });
  }
  Future<void> _loadUnitPref() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final val = prefs.getString(measurementUnitsKey);
    if (mounted) setState(() => _isMetric = val != 'imperial');
  }
  @override
  Future<void> fetchData() async {
    await _loadUnitPref();
    final response = await ref.read(apiClientProvider).getHealthRecords(babyMonId!);
    try {
      final aRes = await ref.read(apiClientProvider).getAllergies(babyMonId!);
      final raw = aRes.data;
      _allergies = parseItemsTyped(raw).map(Allergy.fromJson).toList();
    } catch (e) {
      debugPrint('Failed to load allergies: $e');
    }
    _records = parseItems(response.data).whereType<Map<String, dynamic>>().map(HealthRecord.fromJson).toList();
    _cachedAllergyEntries = _allergies.expand((a) => a.flattenedEvents.map((m) => (
      id: (m['id'] ?? '').toString(),
      category: (m['category'] ?? '').toString(),
      title: m['title']?.toString(),
      value: m['value'],
      unit: m['unit']?.toString(),
      happenedAt: m['happenedAt'] != null ? DateTime.tryParse(m['happenedAt'].toString()) : null,
      notes: m['notes']?.toString(),
      isAllergyEvent: true,
    ))).toList();
  }
  List<HealthDisplayEntry> _filteredRecords() {
    if (_selectedCategory == 'ALLERGY') return _cachedAllergyEntries;
    if (_selectedCategory == 'ALL') {
      return <HealthDisplayEntry>[
        ..._records.map((r) => r.toDisplayEntry()),
        ..._cachedAllergyEntries,
      ];
    }
    return _records
        .where((r) => r.category == _selectedCategory)
        .map((r) => r.toDisplayEntry())
        .toList();
  }
  // ── Filter chips grouped semantically (was 12 chips on a single
  // horizontal scroll — now 2 rows by type). ──
  static const List<HealthCategory> _measurementCategories = [
    HealthCategory.weight, HealthCategory.height,
    HealthCategory.headCircumference, HealthCategory.temperature,
  ];
  static const List<HealthCategory> _eventCategories = [
    HealthCategory.hospital, HealthCategory.clinic, HealthCategory.injury,
    HealthCategory.bowelMovement, HealthCategory.vaccination,
    HealthCategory.allergy, HealthCategory.other,
  ];
  static const List<String> _injurySeverities = ['Mild', 'Moderate', 'Severe', 'Critical'];
  static const List<String> _bowelColors = ['Brown', 'Green', 'Yellow', 'Red', 'Black', 'White / Clay', 'Orange'];
  static const List<String> _vaccines = [
    'Other', 'Hepatitis B (HepB)', 'Rotavirus (RV)', 'DTaP', 'Hib', 'Pneumococcal (PCV13)', 'Polio (IPV)',
    'Influenza (Flu)', 'MMR', 'Varicella (Chickenpox)', 'Hepatitis A (HepA)', 'Meningococcal (MenACWY)',
    'COVID-19', 'HPV', 'Tdap', 'RSV',
  ];
  static const List<String> _allergySeverities = ['Mild', 'Moderate', 'Severe', 'Life-Threatening'];
  static const List<String> _allergyOptions = [
    'Other', 'Peanuts', 'Tree Nuts', 'Milk (Dairy)', 'Eggs', 'Soy', 'Wheat', 'Fish', 'Shellfish',
    'Sesame', 'Pollen (Hay Fever)', 'Dust Mites', 'Mold', 'Pet Dander', 'Insect Stings',
    'Latex', 'Penicillin', 'NSAIDs', 'Sulfa Drugs',
  ];
  IconData _categoryIcon(String cat) =>
      HealthCategory.fromApiKey(cat)?.icon ?? PhosphorIconsLight.note;
  String _categoryLabel(String cat) =>
      HealthCategory.fromApiKey(cat)?.label ??
      (cat.isEmpty ? '' : cat[0].toUpperCase() + cat.substring(1).toLowerCase());
  Future<bool> _deleteRecord(String id, int index) async {
    // Capture messenger upfront so we can safely use it after async gaps.
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await ConfirmDeleteDialog.show(
      context,
      title: 'Delete Record',
      message: 'Delete this health record?',
    );
    if (confirmed != true) return false;
    try {
      await ref.read(apiClientProvider).deleteHealthRecord(id);
      setState(() => _records.removeAt(index));
      ref.read(appRefreshProvider.notifier).state++;
      messenger.showSnackBar(const SnackBar(content: Text('Deleted')));
      return true;
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(extractErrorMessage(e))));
      return false;
    }
  }
  Future<bool> _deleteAllergyEvent(String eventId) async {
    // Capture messenger upfront so we can safely use it after async gaps.
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await ConfirmDeleteDialog.show(
      context,
      title: 'Delete Event',
      message: 'Delete this allergy event? (The allergy itself will remain)',
    );
    if (confirmed != true) return false;
    try {
      await ref.read(apiClientProvider).deleteAllergyEvent(babyMonId!, eventId);
      ref.read(appRefreshProvider.notifier).state++;
      messenger.showSnackBar(const SnackBar(content: Text('Event deleted')));
      semantics.SemanticsService.announce('Health event deleted', ui.TextDirection.ltr);
      return true;
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(extractErrorMessage(e))));
      return false;
    }
  }
  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRecords();
    return Scaffold(
      body: PremiumBackground(
        child: isLoading
            ? buildLoading()
            : !hasBabyMon
                ? buildNoBabyMon()
                : Column(children: [
                    StaggeredFadeSlide(
                      index: 0,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 7,
                          left: DesignTokens.spaceMd,
                          right: DesignTokens.spaceMd,
                        ),
                        child: Row(children: [
                          Expanded(
                            child: _NavTile(
                              icon: PhosphorIconsLight.chartLine,
                              label: 'Growth',
                              color: context.colorScheme.primary,
                              onTap: () => context.push('/growth-chart'),
                            ),
                          ),
                          const SizedBox(width: DesignTokens.spaceSm),
                          Expanded(
                            child: _NavTile(
                              icon: PhosphorIconsLight.moon,
                              label: 'Sleep',
                              color: const Color(0xFF5C6BC0),
                              onTap: () => context.push('/sleep'),
                            ),
                          ),
                        ]),
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spaceSm),
              // ── "All records" pill above the two chip rows ──
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spaceMd,
                    vertical: DesignTokens.spaceSm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: DesignTokens.spaceXs),
                        child: FilterChip(
                          label: const Text('All records'),
                          selected: _selectedCategory == 'ALL',
                          onSelected: (_) => setState(() => _selectedCategory = 'ALL'),
                        ),
                      ),
                    ),
                    _categoryChipRow(_measurementCategories),
                    const SizedBox(height: DesignTokens.spaceXs),
                    _categoryChipRow(_eventCategories),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? PremiumEmptyState(
                        icon: PhosphorIconsLight.stethoscope,
                        title: 'No health records yet',
                        subtitle: 'Tap the + button to add a measurement, allergy, or clinic visit.',
                        actionLabel: 'Add record',
                        onAction: _showEventDialog,
                      )
                    : RefreshIndicator(
                        onRefresh: onRefresh,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(DesignTokens.spaceLg),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final record = filtered[index];
                            return _buildHealthRecordRow(record, index);
                          },
                        ),
                      ),
              ),              ]),
            ),
    );
  }
  /// Renders a single horizontal scroll of category filter chips.
  Widget _categoryChipRow(List<HealthCategory> categories) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          return Padding(
            padding: const EdgeInsets.only(right: DesignTokens.spaceSm),
            child: FilterChip(
              label: Text(category.label),
              selected: _selectedCategory == category.apiKey,
              onSelected: (_) => setState(() => _selectedCategory = category.apiKey),
            ),
          );
        }).toList(),
      ),
    );
  }
  /// Builds a [HealthRecordRow] for a single health record, with a
  /// Dismissible wrapper that confirms delete via the existing dialogs.
  Widget _buildHealthRecordRow(HealthDisplayEntry entry, int index) {
    final isAllergyEvent = entry.isAllergyEvent;
    final iconColor = isAllergyEvent ? context.colorScheme.tertiary : context.colorScheme.primary;
    final iconData = isAllergyEvent ? PhosphorIconsLight.warning : _categoryIcon(entry.category);
    final title = entry.title ?? _categoryLabel(entry.category);
    final value = entry.value?.toString();
    final dateStr = entry.happenedAt != null ? DateFormat.yMMMd().format(entry.happenedAt!) : '';
    final semLabel = '$title${value != null ? ', $value ${entry.unit ?? ''}' : ''}${dateStr.isNotEmpty ? ', $dateStr' : ''}${isAllergyEvent ? ' (allergy event)' : ''}';
    return Semantics(
      label: semLabel,
      button: true,
      child: Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
      child: HealthRecordRow(
        title: title,
        value: value,
        unit: entry.unit,
        date: entry.happenedAt,
        notes: entry.notes,
        icon: iconData,
        iconColor: iconColor,
        isDismissible: true,
        onConfirmDelete: () => isAllergyEvent
            ? _deleteAllergyEvent(entry.id)
            : _deleteRecord(entry.id, _records.indexWhere((r) => r.id == entry.id)),
      ),
    ),
    );
  }
  void _showMeasurementDialog() {
    HealthCategory selectedCategory = HealthCategory.weight;
    int major = 0;
    int minor = 0;
    final titleCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now();
    bool saving = false;
    String? validationError;
    showModalBottomSheet<void>(
      context: context, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) {
          final majorU = selectedCategory.unitFor(_isMetric);
          final minorU = selectedCategory.minorUnit;
          final computedVal = selectedCategory.computeValue(major, minor);
          return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: DesignTokens.spaceLg, right: DesignTokens.spaceLg, top: DesignTokens.spaceLg),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Add Measurement', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: DesignTokens.spaceMd),
            SegmentedButton<HealthCategory>(
              segments: _measurementCategories.map((c) =>
                ButtonSegment(value: c, label: Text(c.label, maxLines: 2, textAlign: TextAlign.center, style: const TextStyle(fontSize: DesignTokens.fontXs))),
              ).toList(),
              selected: {selectedCategory},
              onSelectionChanged: (s) => setD(() { selectedCategory = s.first; major = 0; minor = 0; }),
              showSelectedIcon: false,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: WidgetStateProperty.all(
                  const TextStyle(fontSize: DesignTokens.fontSm, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.spaceLg),
            Text('$majorU \u00b7 $minorU', textAlign: TextAlign.center,
              style: TextStyle(fontSize: DesignTokens.fontSm2, fontWeight: FontWeight.w600, color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7))),
            const SizedBox(height: DesignTokens.spaceSm),
            Row(children: [
              Expanded(child: _buildDial(
                value: major,
                max: selectedCategory.dialMax,
                unit: majorU,
                onChanged: (v) => setD(() => major = v),
              )),
              const SizedBox(width: DesignTokens.spaceLg),
              Expanded(child: _buildDial(
                value: minor,
                max: selectedCategory.dialMinorMax,
                unit: minorU,
                step: selectedCategory.dialMinorStep,
                onChanged: (v) => setD(() => minor = v),
              )),
            ]),
            const SizedBox(height: 4),
            Text(computedVal.toStringAsFixed(selectedCategory.decimalPlaces),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: DesignTokens.fontXl, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: DesignTokens.spaceMd),
            if (validationError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
                child: Text(validationError!, style: TextStyle(color: context.colorScheme.error, fontSize: DesignTokens.fontSm)),
              ),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title (optional)', hintText: 'e.g. Morning weigh-in')),
            const SizedBox(height: DesignTokens.spaceMd),
            TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes (optional)'), maxLines: 2),
            const SizedBox(height: DesignTokens.spaceMd),
            ListTile(leading: Icon(PhosphorIconsLight.calendar, color: context.colorScheme.primary), title: Text(DateFormat.yMMMd().format(selectedDate), style: TextStyle(color: ctx.textPrimary)),
              onTap: () async { final p = await showDatePicker(context: ctx, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime.now()); if (p != null) setD(() => selectedDate = p); }),
            const SizedBox(height: DesignTokens.spaceLg),
            ThemeButton(
              text: 'Save',
              onPressed: () async {
                if (computedVal <= 0) {
                  setD(() => validationError = 'Please enter a valid measurement value');
                  return;
                }
                setD(() { validationError = null; saving = true; });
                try {
                  final api = ref.read(apiClientProvider);
                  if (babyMonId == null) return;
                  final result = await api.createHealthRecord(babyMonId!, {
                    'category': selectedCategory.apiKey,
                    'title': titleCtrl.text.isNotEmpty ? titleCtrl.text : selectedCategory.label,
                    'notes': notesCtrl.text.isNotEmpty ? notesCtrl.text : null,
                    'happenedAt': selectedDate.toIso8601String(),
                    'value': computedVal,
                    'unit': selectedCategory.unitFor(_isMetric),
                  });
                  final data = result.data;
                  if (data is Map && data['leveledUp'] == true) {
                    if (ctx.mounted) LevelUpCelebration.show(ctx, parseInt(data['newStage']) ?? 0);
                  }
                  await loadData(force: true);
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  setD(() => saving = false);
                  if (ctx.mounted) showError(ctx, e);
                }
              },
              isLoading: saving,
              fullWidth: true,
              semanticLabel: 'Save health measurement',
            ),
            const SizedBox(height: DesignTokens.spaceLg),
          ]),
        );
        },
      ),
    );
  }
  Widget _buildDial({required int value, required int max, required String unit, int step = 1, required ValueChanged<int> onChanged}) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      ThemeButton.icon(icon: PhosphorIconsLight.caretUp, onPressed: () { if (value + step <= max) onChanged(value + step); }, semanticLabel: 'Increase value', variant: ThemeButtonVariant.text),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceMd, vertical: DesignTokens.spaceSm),
        decoration: BoxDecoration(border: Border.all(color: context.colorScheme.outline), borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('$value', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(width: 4),
          Text(unit, style: TextStyle(fontSize: DesignTokens.fontMd, fontWeight: FontWeight.w600, color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7))),
        ]),
      ),
      ThemeButton.icon(icon: PhosphorIconsLight.caretDown, onPressed: () { if (value - step >= 0) onChanged(value - step); }, semanticLabel: 'Decrease value', variant: ThemeButtonVariant.text),
    ]);
  }
  void _showEventDialog() {
    showModalBottomSheet<void>(
      context: context, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => Padding(
          padding: const EdgeInsets.all(DesignTokens.spaceLg),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Add Event', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: DesignTokens.spaceLg),
            ..._eventCategories.map((category) => ListTile(
              leading: Icon(category.icon, color: context.colorScheme.primary),
              title: Text(category.label),
              trailing: const Icon(PhosphorIconsLight.caretRight),
              onTap: () {
                Navigator.pop(ctx);
                _showEventForm(category);
              },
            )),
            const SizedBox(height: DesignTokens.spaceSm),
          ]),
        ),
      ),
    );
  }
  void _showMedicalTeamDialog() {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Medical Team'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name', hintText: 'Dr. Smith'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: roleCtrl,
              decoration: const InputDecoration(labelText: 'Role / Phone', hintText: 'Pediatrician'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              try {
                await ref.read(apiClientProvider).createMedicalTeamMember(
                  babyMonId!,
                  {'name': name, 'role': roleCtrl.text.trim()},
                );
                messenger.showSnackBar(const SnackBar(content: Text('Medical team member added')));
              } catch (_) {
                messenger.showSnackBar(const SnackBar(content: Text('Failed to add')));
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
  void _showAllergyForm({String? prefillName, String? prefillTriggers, String? prefillSeverity, String? prefillTreatment}) {
    // Capture messenger upfront so we can safely use it after async gaps.
    final messenger = ScaffoldMessenger.of(context);
    final nameCtrl = TextEditingController(text: prefillName);
    final triggersCtrl = TextEditingController(text: prefillTriggers);
    final severityCtrl = TextEditingController(text: prefillSeverity);
    final treatmentCtrl = TextEditingController(text: prefillTreatment);
    final notesCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    final isNew = prefillName == null;
    bool saving = false;
    String? validationError;
    bool _allergyIsOther = false;
    final _allergyOtherCtrl = TextEditingController();
    String? _allergySeverity;
    showModalBottomSheet<void>(
      context: context, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: DesignTokens.spaceLg, right: DesignTokens.spaceLg, top: DesignTokens.spaceLg),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(isNew ? 'Add Allergy' : 'Record Allergy Event', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: DesignTokens.spaceLg),
            if (isNew) ...[
              _AllergyPicker(
                value: nameCtrl.text,
                onChanged: (v) {
                  setD(() { nameCtrl.text = v; _allergyIsOther = v == 'Other'; });
                },
                showOtherField: _allergyIsOther,
                otherCtrl: _allergyOtherCtrl,
              ),
              const SizedBox(height: DesignTokens.spaceMd),
              TextField(controller: triggersCtrl, decoration: const InputDecoration(labelText: 'Triggers', hintText: 'e.g. Ingestion, Skin contact, Airborne')),
              const SizedBox(height: DesignTokens.spaceMd),
              ListTile(
                title: Text('Severity: ${_allergySeverity ?? 'Tap to select'}'),
                trailing: const Icon(PhosphorIconsLight.caretDown),
                contentPadding: EdgeInsets.zero,
                onTap: () async {
                  final v = await WheelPickerBottomSheet.show<String>(context: ctx, title: 'Severity', columns: [WheelColumn<String>(label: '', options: _allergySeverities.map((s) => WheelOption(value: s, label: s)).toList())]);
                  if (v != null) setD(() => _allergySeverity = v);
                },
              ),
              const SizedBox(height: DesignTokens.spaceMd),
              TextField(controller: treatmentCtrl, decoration: const InputDecoration(labelText: 'Treatment', hintText: 'e.g. EpiPen, Antihistamine, Avoidance')),
              const SizedBox(height: DesignTokens.spaceMd),
            ],
            ListTile(
              leading: const Icon(PhosphorIconsLight.calendar),
              title: Text(DateFormat.yMMMd().format(selectedDate)),
              subtitle: Text(selectedTime.format(ctx)),
              onTap: () async {
                final p = await showDatePicker(context: ctx, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime.now());
                if (p != null && ctx.mounted) {
                  final t = await showTimePicker(context: ctx, initialTime: selectedTime);
                  if (t != null) setD(() { selectedDate = p; selectedTime = t; });
                }
              },
            ),
            const SizedBox(height: DesignTokens.spaceSm),
            TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes (optional)'), maxLines: 2),
            const SizedBox(height: 20),
            if (validationError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
                child: Text(validationError!, style: TextStyle(color: context.colorScheme.error, fontSize: DesignTokens.fontSm)),
              ),
            ThemeButton(
              text: 'Save',
              onPressed: () async {
                final allergyName = nameCtrl.text == 'Other' ? _allergyOtherCtrl.text.trim() : nameCtrl.text;
                if (isNew && allergyName.isEmpty) {
                  setD(() => validationError = 'Please enter an allergy name');
                  return;
                }
                setD(() { validationError = null; saving = true; });
                try {
                  final api = ref.read(apiClientProvider);
                  if (babyMonId == null) return;
                  final happenedAt = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute).toIso8601String();
                  if (isNew) {
                    await api.createAllergy(babyMonId!, {
                      'name': allergyName,
                      'triggers': triggersCtrl.text,
                      'severity': _allergySeverity ?? severityCtrl.text,
                      'treatment': treatmentCtrl.text,
                      'happenedAt': happenedAt,
                      'notes': notesCtrl.text.isNotEmpty ? notesCtrl.text : null,
                    });
                  } else {
                    final existing = _allergies.firstWhere((a) => a.name == prefillName);
                    await api.addAllergyEvent(babyMonId!, existing.id, {
                      'happenedAt': happenedAt,
                      'notes': notesCtrl.text.isNotEmpty ? notesCtrl.text : null,
                    });
                  }
                  ref.read(appRefreshProvider.notifier).state++;
                  messenger.showSnackBar(SnackBar(content: Text(isNew ? 'Allergy added!' : 'Allergy event recorded!')));
                  if (ctx.mounted) Navigator.pop(ctx);
                } on DioException catch (e) {
                  setD(() => saving = false);
                  final msg = parseString(parseJsonMap(e.response?.data)?['message']);
                  if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg ?? 'Failed to save. Please try again.')));
                } catch (e) {
                  setD(() => saving = false);
                  if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Failed to save. Please try again.')));
                }
              },
              isLoading: saving,
              fullWidth: true,
              semanticLabel: 'Save allergy',
            ),
            const SizedBox(height: DesignTokens.spaceLg),
          ]),
        ),
      ),
    );
  }
  void _showEventForm(HealthCategory category) {
    if (category == HealthCategory.allergy) { _showAllergyForm(); return; }
    final apiKey = category.apiKey;
    final titleCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final extraCtrl1 = TextEditingController();
    String? _injurySeverity;
    String? _bowelColor;
    bool _vaccineIsOther = false;
    final _vaccineOtherCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now();
    bool saving = false;
    final staffCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    final isHospitalOrClinic = category == HealthCategory.hospital || category == HealthCategory.clinic;
    final isInjuryOrBowelOrVax = category == HealthCategory.injury || category == HealthCategory.bowelMovement || category == HealthCategory.vaccination;
    final showTitle = !isInjuryOrBowelOrVax;
    String formLabel1() {
      if (isHospitalOrClinic) return 'Reason';
      if (category == HealthCategory.injury) return 'Severity';
      if (category == HealthCategory.bowelMovement) return 'Color';
      if (category == HealthCategory.vaccination) return 'Vaccine Name';
      return '';
    }
    final showStaff = isHospitalOrClinic;
    final showExtra1 = category == HealthCategory.hospital || category == HealthCategory.clinic || category == HealthCategory.injury || category == HealthCategory.bowelMovement || category == HealthCategory.vaccination;
    final showExtra2 = category == HealthCategory.hospital || category == HealthCategory.clinic || category == HealthCategory.injury || category == HealthCategory.vaccination;
    final showTime = category == HealthCategory.bowelMovement;
    final showVenue = category == HealthCategory.vaccination;
    final venueCtrl = TextEditingController();
    String? stoolType;
    String? validationError;
    final stoolTypes = ['Watery (Diarrhea)', 'Loose', 'Mushy', 'Soft & Formed', 'Normal', 'Firm', 'Hard Pellets', 'Constipated'];
    showModalBottomSheet<void>(
      context: context, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: DesignTokens.spaceLg, right: DesignTokens.spaceLg, top: DesignTokens.spaceLg),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Add ${category.label}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: DesignTokens.spaceLg),
            if (showTitle) ...[
              TextField(controller: titleCtrl, decoration: InputDecoration(labelText: 'Name / Title', hintText: 'e.g. ${category == HealthCategory.hospital ? 'ER Visit' : 'Annual Checkup'}')),
              const SizedBox(height: DesignTokens.spaceMd),
            ],
            if (showStaff) ...[
              TextField(controller: staffCtrl, decoration: const InputDecoration(labelText: 'Attending Staff')),
              const SizedBox(height: DesignTokens.spaceMd),
            ],
            if (showTime) ...[
              TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: 'Time'), readOnly: true,
                onTap: () async {
                  final t = await showTimePicker(context: ctx, initialTime: TimeOfDay.now());
                  if (t != null) setD(() => timeCtrl.text = t.format(ctx));
                }),
              const SizedBox(height: DesignTokens.spaceMd),
            ],
            if (showExtra1) ...[
              if (category == HealthCategory.injury) ...[
                ListTile(
                  title: Text('Severity: ${_injurySeverity ?? 'Tap to select'}'),
                  trailing: const Icon(PhosphorIconsLight.caretDown),
                  onTap: () async {
                    final v = await WheelPickerBottomSheet.show<String>(context: ctx, title: 'Severity', columns: [WheelColumn<String>(label: '', options: _injurySeverities.map((s) => WheelOption(value: s, label: s)).toList())]);
                    if (v != null) setD(() => _injurySeverity = v);
                  },
                ),
              ] else if (category == HealthCategory.bowelMovement) ...[
                ListTile(
                  title: Text('Color: ${_bowelColor ?? 'Tap to select'}'),
                  trailing: const Icon(PhosphorIconsLight.caretDown),
                  onTap: () async {
                    final v = await WheelPickerBottomSheet.show<String>(context: ctx, title: 'Color', columns: [WheelColumn<String>(label: '', options: _bowelColors.map((s) => WheelOption(value: s, label: s)).toList())]);
                    if (v != null) setD(() => _bowelColor = v);
                  },
                ),
              ] else if (category == HealthCategory.vaccination) ...[
                _VaccinePicker(
                  value: extraCtrl1.text,
                  onChanged: (v) {
                    setD(() { extraCtrl1.text = v; _vaccineIsOther = v == 'Other'; });
                  },
                  showOtherField: _vaccineIsOther,
                  otherCtrl: _vaccineOtherCtrl,
                ),
              ] else ...[
                TextField(controller: extraCtrl1, decoration: InputDecoration(labelText: formLabel1())),
              ],
              const SizedBox(height: DesignTokens.spaceMd),
            ],
            if (showExtra2) ...[
              TextField(controller: (() { final c = TextEditingController(); return c; })(), decoration: InputDecoration(labelText: category == HealthCategory.injury ? 'Description' : category == HealthCategory.vaccination ? 'Location on body' : 'Outcome')),
              const SizedBox(height: DesignTokens.spaceMd),
            ],
            if (category == HealthCategory.bowelMovement) ...[
              const SizedBox(height: 4),
              Text('Consistency (choose one)', style: TextStyle(fontSize: DesignTokens.fontSm, fontWeight: FontWeight.w500, color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7))),
              const SizedBox(height: 6),
              Wrap(spacing: 6, runSpacing: 6, children: stoolTypes.map((t) => ChoiceChip(
                label: Text(t, style: const TextStyle(fontSize: DesignTokens.fontSm)),
                selected: stoolType == t,
                onSelected: (sel) => setD(() => stoolType = sel ? t : null),
                selectedColor: context.colorScheme.primaryContainer,
              )).toList()),
              const SizedBox(height: DesignTokens.spaceMd),
            ],
            if (showVenue) ...[
              TextField(controller: venueCtrl, decoration: const InputDecoration(labelText: 'Venue')),
              const SizedBox(height: DesignTokens.spaceMd),
            ],
            TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes (optional)'), maxLines: 2),
            const SizedBox(height: DesignTokens.spaceMd),
            ListTile(leading: Icon(PhosphorIconsLight.calendar, color: context.colorScheme.primary), title: Text(DateFormat.yMMMd().format(selectedDate), style: TextStyle(color: ctx.textPrimary)),
              onTap: () async { final p = await showDatePicker(context: ctx, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime.now()); if (p != null) setD(() => selectedDate = p); }),
            const SizedBox(height: DesignTokens.spaceLg),
            if (validationError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
                child: Text(validationError!, style: TextStyle(color: context.colorScheme.error, fontSize: DesignTokens.fontSm)),
              ),
            ThemeButton(
              text: 'Save',
              onPressed: () async {                  if (titleCtrl.text.isEmpty && category == HealthCategory.other) {
                  setD(() => validationError = 'Please enter a description');
                  return;
                }
                setD(() { validationError = null; saving = true; });
                try {
                  final api = ref.read(apiClientProvider);
                  if (babyMonId == null) return;
                  final data = <String, dynamic>{
                    'category': apiKey,
                    'title': titleCtrl.text.isNotEmpty ? titleCtrl.text : category.label,
                    'notes': notesCtrl.text.isNotEmpty ? notesCtrl.text : null,
                    'happenedAt': selectedDate.toIso8601String(),
                  };
                  final extras = <String>[];
                  if (category == HealthCategory.injury && _injurySeverity != null) extras.add('Severity: $_injurySeverity');
                  if (category == HealthCategory.bowelMovement && _bowelColor != null) extras.add('Color: $_bowelColor');
                  if (category == HealthCategory.vaccination && extraCtrl1.text.isNotEmpty) {
                    final vaxName = extraCtrl1.text == 'Other' ? _vaccineOtherCtrl.text.trim() : extraCtrl1.text;
                    if (vaxName.isNotEmpty) extras.add('Vaccine: $vaxName');
                  }
                  if (extraCtrl1.text.isNotEmpty && category != HealthCategory.injury && category != HealthCategory.bowelMovement && category != HealthCategory.vaccination) extras.add('${formLabel1()}: ${extraCtrl1.text}');
                  if (category == HealthCategory.bowelMovement && stoolType != null) extras.add('Consistency: $stoolType');
                  if (showVenue && venueCtrl.text.isNotEmpty) extras.add('Venue: ${venueCtrl.text}');
                  if (extras.isNotEmpty) {
                    data['notes'] = '${extras.join(' | ')}${notesCtrl.text.isNotEmpty ? '\n${notesCtrl.text}' : ''}';
                  }
                  final hResult = await api.createHealthRecord(babyMonId!, data);
                  final hData = hResult.data;
                  if (hData is Map && hData['leveledUp'] == true) {
                    if (ctx.mounted) LevelUpCelebration.show(ctx, parseInt(hData['newStage']) ?? 0);
                  }
                  await loadData(force: true);
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  setD(() => saving = false);
                  if (ctx.mounted) showError(ctx, e);
                }
              },
              isLoading: saving,
              fullWidth: true,
              semanticLabel: 'Save health event',
            ),
            const SizedBox(height: DesignTokens.spaceMd),
          ]),
        ),
      ),
    );
  }
}
class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _NavTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: DesignTokens.spaceMd),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.08 : 0.06),
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: DesignTokens.spaceXs),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
/// Searchable vaccine picker with "Other" option.
class _VaccinePicker extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final bool showOtherField;
  final TextEditingController otherCtrl;
  const _VaccinePicker({required this.value, required this.onChanged, required this.showOtherField, required this.otherCtrl});
  @override State<_VaccinePicker> createState() => _VaccinePickerState();
}
class _VaccinePickerState extends State<_VaccinePicker> {
  final _searchCtrl = TextEditingController();
  @override void dispose() { _searchCtrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(widget.value.isEmpty ? 'Vaccine: Tap to select' : 'Vaccine: ${widget.value}', maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(PhosphorIconsLight.caretDown),
        onTap: () => _showPicker(context),
      ),
      if (widget.showOtherField)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: TextField(controller: widget.otherCtrl, decoration: const InputDecoration(labelText: 'Vaccine name', hintText: 'Enter custom vaccine')),
        ),
    ]);
  }
  void _showPicker(BuildContext context) {
    final vaccines = _HealthScreenState._vaccines;
    _searchCtrl.clear();
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) {
          final query = _searchCtrl.text.toLowerCase();
          final filtered = vaccines.where((v) => v.toLowerCase().contains(query)).toList();
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'Search vaccines...', prefixIcon: Icon(PhosphorIconsLight.magnifyingGlass), border: OutlineInputBorder()),
                  onChanged: (_) => setD(() {}),
                ),
              ),
              Flexible(child: ListView(
                shrinkWrap: true,
                children: filtered.map((v) => ListTile(
                  title: Text(v, style: TextStyle(fontWeight: v == widget.value ? FontWeight.w700 : FontWeight.w400, color: v == 'Other' ? Theme.of(context).colorScheme.primary : null)),
                  onTap: () {
                    widget.onChanged(v);
                    Navigator.pop(ctx);
                  },
                )).toList(),
              )),
            ]),
          );
        },
      ),
    );
  }
}
/// Searchable allergy picker with "Other" option and brief explanations.
class _AllergyPicker extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final bool showOtherField;
  final TextEditingController otherCtrl;
  const _AllergyPicker({required this.value, required this.onChanged, required this.showOtherField, required this.otherCtrl});
  @override State<_AllergyPicker> createState() => _AllergyPickerState();
}
class _AllergyPickerState extends State<_AllergyPicker> {
  final _searchCtrl = TextEditingController();
  @override void dispose() { _searchCtrl.dispose(); super.dispose(); }
  static const _allergyExplanations = {
    'Peanuts': 'Legume allergy, often severe, can cause anaphylaxis',
    'Tree Nuts': 'Almonds, walnuts, cashews — often lifelong',
    'Milk (Dairy)': 'Cow milk protein allergy, common in infants',
    'Eggs': 'Often outgrown by school age',
    'Soy': 'Soybean allergy, common in formula-fed babies',
    'Wheat': 'Protein allergy, distinct from celiac disease',
    'Fish': 'Often lifelong, salmon and cod most common',
    'Shellfish': 'Shrimp, crab, lobster — usually permanent',
    'Sesame': 'Seed allergy, found in tahini, hummus, oils',
    'Pollen (Hay Fever)': 'Seasonal allergic rhinitis, sneezing, itchy eyes',
    'Dust Mites': 'Year-round indoor allergen in bedding and carpets',
    'Mold': 'Damp areas, outdoor or indoor — triggers asthma',
    'Pet Dander': 'Cats and dogs, skin flakes cause reactions',
    'Insect Stings': 'Bees, wasps, hornets — can cause severe reactions',
    'Latex': 'Rubber allergy, common in medical settings',
    'Penicillin': 'Common antibiotic allergy, can cause hives or rash',
    'NSAIDs': 'Ibuprofen, aspirin type anti-inflammatory drugs',
    'Sulfa Drugs': 'Sulfonamide antibiotics, distinct from sulfites',
  };
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(widget.value.isEmpty ? 'Allergy: Tap to select' : 'Allergy: ${widget.value}', maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(PhosphorIconsLight.caretDown),
        onTap: () => _showPicker(context),
      ),
      if (widget.showOtherField)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: TextField(controller: widget.otherCtrl, decoration: const InputDecoration(labelText: 'Allergy name', hintText: 'Enter custom allergy')),
        ),
    ]);
  }
  void _showPicker(BuildContext context) {
    final allergies = _HealthScreenState._allergyOptions;
    _searchCtrl.clear();
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) {
          final query = _searchCtrl.text.toLowerCase();
          final filtered = allergies.where((a) => a.toLowerCase().contains(query)).toList();
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'Search allergies...', prefixIcon: Icon(PhosphorIconsLight.magnifyingGlass), border: OutlineInputBorder()),
                  onChanged: (_) => setD(() {}),
                ),
              ),
              Flexible(child: ListView(
                shrinkWrap: true,
                children: filtered.map((a) => ListTile(
                  title: Text(a, style: TextStyle(fontWeight: a == widget.value ? FontWeight.w700 : FontWeight.w400, color: a == 'Other' ? Theme.of(context).colorScheme.primary : null)),
                  subtitle: _allergyExplanations[a] != null ? Text(_allergyExplanations[a]!, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)) : null,
                  onTap: () {
                    widget.onChanged(a);
                    Navigator.pop(ctx);
                  },
                )).toList(),
              )),
            ]),
          );
        },
      ),
    );
  }
}
