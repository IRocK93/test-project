import 'package:flutter/material.dart';
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

  List _records = [];
  String _selectedCategory = 'ALL';
  bool _isMetric = true;

  List<Map<String, dynamic>> _allergies = [];
  List<Map<String, dynamic>> _allergyEvents = [];

  // ── Filter chips grouped semantically (was 12 chips on a single
  // horizontal scroll — now 2 rows by type). ──
  static const List<String> _measurementCategories = [
    'ALL', 'WEIGHT', 'HEIGHT', 'HEAD_CIRCUMFERENCE', 'TEMPERATURE',
  ];
  static const List<String> _eventCategories = [
    'HOSPITAL', 'CLINIC', 'INJURY', 'BOWEL_MOVEMENT',
    'VACCINATION', 'ALLERGY', 'OTHER',
  ];

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
    // Cross-tab signal from the Dashboard's InfoFab: open the
    // "Add Measurement" dialog when the action fires, then clear
    // the signal so it doesn't re-open on rebuild.
    ref.listenManual(pendingAddActionProvider, (prev, next) {
      if (next == AddAction.healthMeasurement) {
        ref.read(pendingAddActionProvider.notifier).state = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _showMeasurementDialog();
        });
      }
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
    final response = await ref.read(apiClientProvider).get(
      '${ApiConstants.babyMons}/$babyMonId/health-records',
    );
    List<Map<String, dynamic>> allergies = [];
    final flat = <Map<String, dynamic>>[];
    try {
      final aRes = await ref.read(apiClientProvider).getAllergies(babyMonId!);
      final raw = aRes.data;
      final rawList = parseItemsTyped(raw);
      for (final a in rawList) {
        final events = parseList(a['events']);
        for (final evt in events) {
          flat.add({
            ...(parseJsonMap(evt) ?? <String, dynamic>{}),
            'allergyName': a['name'],
            'allergyId': a['id'],
            'allergyStatus': a['status'] ?? 'ACTIVE',
            'severity': a['severity'],
            'triggers': a['triggers'],
            'treatment': a['treatment'],
            'category': 'ALLERGY_EVENT',
            'title': a['name'] ?? 'Allergy',
          });
        }
      }
      allergies = rawList;
    } catch (e) {
      debugPrint('Failed to load allergies: $e');
    }
    _records = parseItems(response.data);
    _allergies = allergies;
    _allergyEvents = flat;
  }

  List<Map<String, dynamic>> _filteredRecords() {
    if (_selectedCategory == 'ALLERGY') return _allergyEvents;
    if (_selectedCategory == 'ALL') {
      return <Map<String, dynamic>>[
        ..._records.whereType<Map<String, dynamic>>(),
        ..._allergyEvents,
      ];
    }
    return _records
        .where((r) => r['category'] == _selectedCategory)
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'WEIGHT': return PhosphorIconsLight.scales;
      case 'HEIGHT': return PhosphorIconsLight.ruler;
      case 'HEAD_CIRCUMFERENCE': return PhosphorIconsLight.userCircle;
      case 'TEMPERATURE': return PhosphorIconsLight.thermometer;
      case 'HOSPITAL': return PhosphorIconsLight.building;
      case 'CLINIC': return PhosphorIconsLight.stethoscope;
      case 'INJURY': return PhosphorIconsLight.bandaids;
      case 'BOWEL_MOVEMENT': return PhosphorIconsLight.toilet;
      case 'VACCINATION': return PhosphorIconsLight.syringe;
      case 'ALLERGY': return PhosphorIconsLight.warningCircle;
      default: return PhosphorIconsLight.note;
    }
  }

  String _categoryLabel(String cat) {
    switch (cat) {
      case 'WEIGHT': return 'Weight';
      case 'HEIGHT': return 'Height';
      case 'HEAD_CIRCUMFERENCE': return 'Head Circumference';
      case 'TEMPERATURE': return 'Body Temp';
      case 'HOSPITAL': return 'Hospital';
      case 'CLINIC': return 'Clinic';
      case 'INJURY': return 'Injury';
      case 'BOWEL_MOVEMENT': return 'Bowel Movement';
      case 'VACCINATION': return 'Vaccination';
      case 'ALLERGY': return 'Allergy';
      case 'OTHER': return 'Other';
      default: return cat[0].toUpperCase() + cat.substring(1).toLowerCase();
    }
  }

  String _unitFor(String cat) {
    if (_isMetric) {
      switch (cat) {
        case 'WEIGHT': return 'kg';
        case 'HEIGHT': return 'cm';
        case 'HEAD_CIRCUMFERENCE': return 'cm';
        case 'TEMPERATURE': return '\u00b0C';
        default: return '';
      }
    } else {
      switch (cat) {
        case 'WEIGHT': return 'lbs';
        case 'HEIGHT': return 'in';
        case 'HEAD_CIRCUMFERENCE': return 'in';
        case 'TEMPERATURE': return '\u00b0F';
        default: return '';
      }
    }
  }

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
                child: PremiumCard(
                isGlass: true,
                margin: const EdgeInsets.fromLTRB(DesignTokens.spaceMd, DesignTokens.spaceSm, DesignTokens.spaceMd, DesignTokens.spaceXs),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: 0.15), child: const Icon(PhosphorIconsLight.chartLine, color: AppColors.primary)),
                  title: Text('Growth Chart', style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w600)), subtitle: const Text('Weight, height, head circumference', style: TextStyle(color: AppColors.textSecondary, height: 1.4)),
                  trailing: const Icon(PhosphorIconsLight.caretRight, color: AppColors.textCaption),
                  onTap: () => context.push('/growth-chart'),
                ),
              ),
              ),
              StaggeredFadeSlide(
                index: 1,
                child: PremiumCard(
                isGlass: true,
                margin: const EdgeInsets.fromLTRB(DesignTokens.spaceMd, DesignTokens.spaceXs, DesignTokens.spaceMd, DesignTokens.spaceXs),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: 0.15), child: const Icon(PhosphorIconsLight.moon, color: AppColors.primary)),
                  title: Text('Sleep Tracking', style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w600)), subtitle: const Text('Nap & night sleep logs', style: TextStyle(color: AppColors.textSecondary, height: 1.4)),
                  trailing: const Icon(PhosphorIconsLight.caretRight, color: AppColors.textCaption),
                  onTap: () => context.push('/sleep'),
                ),
              ),
              ),
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
                    _categoryChipRow(_measurementCategories
                        .where((c) => c != 'ALL')
                        .toList()),
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
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final record = filtered[index];
                            return _buildHealthRecordRow(record, index);
                          },
                        ),
                      ),
              ),              ]),
            ),
      floatingActionButton: _buildExpandableFAB(),
    );
  }

  Widget _buildExpandableFAB() {
    return InfoFab(
        tooltip: 'Add a measurement, allergy, or clinic visit',
        children: [
          InfoFabAction(
            tooltip: 'Add Measurement',
            infoDescription: 'Measurement',
            backgroundColor: AppColors.teal,
            onTap: () { _showMeasurementDialog(); },
            child: const Icon(PhosphorIconsLight.ruler, color: AppColors.textOnPrimary),
          ),
          InfoFabAction(
            tooltip: 'Add Event',
            infoDescription: 'Event',
            backgroundColor: AppColors.warning,
            onTap: () { _showEventDialog(); },
            child: const Icon(PhosphorIconsLight.building, color: AppColors.textOnPrimary),
          ),
        ],
      );
  }

  /// Renders a single horizontal scroll of category filter chips.
  Widget _categoryChipRow(List<String> categories) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_categoryLabel(cat)),
              selected: _selectedCategory == cat,
              onSelected: (_) => setState(() => _selectedCategory = cat),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Builds a [HealthRecordRow] for a single health record, with a
  /// Dismissible wrapper that confirms delete via the existing dialogs.
  Widget _buildHealthRecordRow(Map<String, dynamic> record, int index) {
    final cat = parseString(record['category']) ?? '';
    final isAllergyEvent = cat == 'ALLERGY_EVENT';
    final iconColor = isAllergyEvent ? AppColors.warning : AppColors.success;
    final iconData = isAllergyEvent ? PhosphorIconsLight.warning : _categoryIcon(cat);
    final title = record['title']?.toString() ?? _categoryLabel(cat);
    final value = record['value']?.toString();
    final unit = record['unit']?.toString();
    final happenedAt = record['happenedAt'] != null
        ? DateTime.tryParse(record['happenedAt'].toString())
        : null;
    final notes = record['notes']?.toString();

    final id = record['id']?.toString() ?? index.toString();
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
      child: HealthRecordRow(
        title: title,
        value: value,
        unit: unit,
        date: happenedAt,
        notes: notes,
        icon: iconData,
        iconColor: iconColor,
        isDismissible: true,
        onConfirmDelete: () => isAllergyEvent
            ? _deleteAllergyEvent(id)
            : _deleteRecord(id, _records.indexOf(record)),
      ),
    );
  }

  void _showMeasurementDialog() {
    String selectedType = 'WEIGHT';
    int major = 0;
    int minor = 0;
    final titleCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now();
    bool saving = false;

    String majorUnit(String t) {
      switch (t) {
        case 'WEIGHT': return _isMetric ? 'kg' : 'lbs';
        case 'HEIGHT': case 'HEAD_CIRCUMFERENCE': return _isMetric ? 'cm' : 'in';
        case 'TEMPERATURE': return _isMetric ? '\u00b0C' : '\u00b0F';
        default: return '';
      }
    }

    String minorUnit(String t) {
      switch (t) {
        case 'WEIGHT': return 'g';
        case 'HEIGHT': case 'HEAD_CIRCUMFERENCE': return 'mm';
        case 'TEMPERATURE': return '.0';
        default: return '';
      }
    }

    double computedValue(String t) {
      switch (t) {
        case 'WEIGHT': return major + (minor / 1000.0);
        case 'HEIGHT': case 'HEAD_CIRCUMFERENCE': return major + (minor / 10.0);
        case 'TEMPERATURE': return major + (minor / 10.0);
        default: return major + (minor / 10.0);
      }
    }

    showModalBottomSheet<void>(
      context: context, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Add Measurement', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'WEIGHT', label: Text('Weight')),
                ButtonSegment(value: 'HEIGHT', label: Text('Height')),
                ButtonSegment(value: 'HEAD_CIRCUMFERENCE', label: Text('Head')),
                ButtonSegment(value: 'TEMPERATURE', label: Text('Temp')),
              ],
              selected: {selectedType},
              onSelectionChanged: (s) => setD(() => selectedType = s.first),
              showSelectedIcon: false,
            ),
            const SizedBox(height: 16),
            Text('${majorUnit(selectedType)} \u00b7 ${minorUnit(selectedType)}', textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textCaption)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _buildDial(
                value: major,
                max: selectedType == 'TEMPERATURE' ? 50 : 200,
                unit: majorUnit(selectedType),
                onChanged: (v) => setD(() => major = v),
              )),
              const SizedBox(width: 16),
              Expanded(child: _buildDial(
                value: minor,
                max: selectedType == 'WEIGHT' ? 999 : 9,
                unit: minorUnit(selectedType),
                step: selectedType == 'WEIGHT' ? 5 : 1,
                onChanged: (v) => setD(() => minor = v),
              )),
            ]),
            const SizedBox(height: 4),
            Text(computedValue(selectedType).toStringAsFixed(selectedType == 'WEIGHT' ? 3 : 1),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 12),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title (optional)', hintText: 'e.g. Morning weigh-in')),
            const SizedBox(height: 12),
            TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes (optional)'), maxLines: 2),
            const SizedBox(height: 12),
            ListTile(leading: const Icon(PhosphorIconsLight.calendar, color: AppColors.primary), title: Text(DateFormat.yMMMd().format(selectedDate), style: TextStyle(color: ctx.textPrimary)),
              onTap: () async { final p = await showDatePicker(context: ctx, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime.now()); if (p != null) setD(() => selectedDate = p); }),
            const SizedBox(height: 16),
            ThemeButton(
              text: 'Save',
              onPressed: () async {
                setD(() => saving = true);
                try {
                  final api = ref.read(apiClientProvider);
                  if (babyMonId == null) return;
                  final result = await api.createHealthRecord(babyMonId!, {
                    'category': selectedType,
                    'title': titleCtrl.text.isNotEmpty ? titleCtrl.text : _categoryLabel(selectedType),
                    'notes': notesCtrl.text.isNotEmpty ? notesCtrl.text : null,
                    'happenedAt': selectedDate.toIso8601String(),
                    'value': computedValue(selectedType),
                    'unit': _unitFor(selectedType),
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
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }

  Widget _buildDial({required int value, required int max, required String unit, int step = 1, required ValueChanged<int> onChanged}) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      ThemeButton.icon(icon: PhosphorIconsLight.caretUp, onPressed: () { if (value + step <= max) onChanged(value + step); }, semanticLabel: 'Increase value', variant: ThemeButtonVariant.text),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('$value', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(width: 4),
          Text(unit, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textCaption)),
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
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Add Event', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _eventOption(ctx, setD, PhosphorIconsLight.building, 'Hospital', 'HOSPITAL'),
            _eventOption(ctx, setD, PhosphorIconsLight.stethoscope, 'Clinic', 'CLINIC'),
            _eventOption(ctx, setD, PhosphorIconsLight.bandaids, 'Injury', 'INJURY'),
            _eventOption(ctx, setD, PhosphorIconsLight.toilet, 'Bowel Movement', 'BOWEL_MOVEMENT'),
            _eventOption(ctx, setD, PhosphorIconsLight.syringe, 'Vaccination', 'VACCINATION'),
            _eventOption(ctx, setD, PhosphorIconsLight.warningCircle, 'Allergy', 'ALLERGY'),
            _eventOption(ctx, setD, PhosphorIconsLight.note, 'Other', 'OTHER'),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }

  Widget _eventOption(BuildContext ctx, dynamic setD, IconData icon, String label, String type) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      trailing: const Icon(PhosphorIconsLight.caretRight),
      onTap: () {
        Navigator.pop(ctx);
        _showEventForm(type);
      },
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

    showModalBottomSheet<void>(
      context: context, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(isNew ? 'Add Allergy' : 'Record Allergy Event', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            if (isNew) ...[
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Allergy Name', hintText: 'e.g. Peanuts')),
              const SizedBox(height: 12),
              TextField(controller: triggersCtrl, decoration: const InputDecoration(labelText: 'Triggers', hintText: 'e.g. Ingestion, Skin contact, Airborne')),
              const SizedBox(height: 12),
              TextField(controller: severityCtrl, decoration: const InputDecoration(labelText: 'Severity', hintText: 'e.g. Mild rash, Severe (anaphylaxis)')),
              const SizedBox(height: 12),
              TextField(controller: treatmentCtrl, decoration: const InputDecoration(labelText: 'Treatment', hintText: 'e.g. EpiPen, Antihistamine, Avoidance')),
              const SizedBox(height: 12),
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
            const SizedBox(height: 8),
            TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes (optional)'), maxLines: 2),
            const SizedBox(height: 20),
            ThemeButton(
              text: 'Save',
              onPressed: () async {
                if (isNew && nameCtrl.text.isEmpty) return;
                setD(() => saving = true);
                try {
                  final api = ref.read(apiClientProvider);
                  if (babyMonId == null) return;
                  final happenedAt = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute).toIso8601String();
                  if (isNew) {
                    await api.createAllergy(babyMonId!, {
                      'name': nameCtrl.text,
                      'triggers': triggersCtrl.text,
                      'severity': severityCtrl.text,
                      'treatment': treatmentCtrl.text,
                      'happenedAt': happenedAt,
                      'notes': notesCtrl.text.isNotEmpty ? notesCtrl.text : null,
                    });
                  } else {
                    final existing = _allergies.firstWhere((a) => a['name'] == prefillName);
                    await api.addAllergyEvent(babyMonId!, parseString(existing['id']) ?? '', {
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
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }

  void _showEventForm(String category) {
    if (category == 'ALLERGY') { _showAllergyForm(); return; }
    final titleCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final extraCtrl1 = TextEditingController();
    DateTime selectedDate = DateTime.now();
    bool saving = false;

    final staffCtrl = TextEditingController();
    final timeCtrl = TextEditingController();

    final isHospitalOrClinic = category == 'HOSPITAL' || category == 'CLINIC';
    final isInjuryOrBowelOrVax = ['INJURY', 'BOWEL_MOVEMENT', 'VACCINATION'].contains(category);
    final showTitle = !isInjuryOrBowelOrVax;

    String formLabel1() {
      if (isHospitalOrClinic) return 'Reason';
      if (category == 'INJURY') return 'Severity';
      if (category == 'BOWEL_MOVEMENT') return 'Color';
      if (category == 'VACCINATION') return 'Vaccine Name';
      return '';
    }

    final showStaff = isHospitalOrClinic;
    final showExtra1 = ['HOSPITAL', 'CLINIC', 'INJURY', 'BOWEL_MOVEMENT', 'VACCINATION'].contains(category);
    final showExtra2 = ['HOSPITAL', 'CLINIC', 'INJURY', 'VACCINATION'].contains(category);
    final showTime = category == 'BOWEL_MOVEMENT';
    final showVenue = category == 'VACCINATION';
    final venueCtrl = TextEditingController();

    String? stoolType;
    final stoolTypes = ['Watery (Diarrhea)', 'Loose', 'Mushy', 'Soft & Formed', 'Normal', 'Firm', 'Hard Pellets', 'Constipated'];

    showModalBottomSheet<void>(
      context: context, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Add ${_categoryLabel(category)}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            if (showTitle) ...[
              TextField(controller: titleCtrl, decoration: InputDecoration(labelText: 'Name / Title', hintText: 'e.g. ${category == 'HOSPITAL' ? 'ER Visit' : 'Annual Checkup'}')),
              const SizedBox(height: 12),
            ],
            if (showStaff) ...[
              TextField(controller: staffCtrl, decoration: const InputDecoration(labelText: 'Attending Staff')),
              const SizedBox(height: 12),
            ],
            if (showTime) ...[
              TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: 'Time'), readOnly: true,
                onTap: () async {
                  final t = await showTimePicker(context: ctx, initialTime: TimeOfDay.now());
                  if (t != null) setD(() => timeCtrl.text = t.format(ctx));
                }),
              const SizedBox(height: 12),
            ],
            if (showExtra1) ...[
              TextField(controller: extraCtrl1, decoration: InputDecoration(labelText: formLabel1())),
              const SizedBox(height: 12),
            ],
            if (showExtra2) ...[
              TextField(controller: (() { final c = TextEditingController(); return c; })(), decoration: InputDecoration(labelText: category == 'INJURY' ? 'Description' : category == 'VACCINATION' ? 'Location on body' : 'Outcome')),
              const SizedBox(height: 12),
            ],
            if (category == 'BOWEL_MOVEMENT') ...[
              const SizedBox(height: 4),
              const Text('Consistency (choose one)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textCaption)),
              const SizedBox(height: 6),
              Wrap(spacing: 6, runSpacing: 6, children: stoolTypes.map((t) => ChoiceChip(
                label: Text(t, style: const TextStyle(fontSize: 12)),
                selected: stoolType == t,
                onSelected: (sel) => setD(() => stoolType = sel ? t : null),
                selectedColor: AppColors.warmLight,
              )).toList()),
              const SizedBox(height: 12),
            ],
            if (showVenue) ...[
              TextField(controller: venueCtrl, decoration: const InputDecoration(labelText: 'Venue')),
              const SizedBox(height: 12),
            ],
            TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes (optional)'), maxLines: 2),
            const SizedBox(height: 12),
            ListTile(leading: const Icon(PhosphorIconsLight.calendar, color: AppColors.primary), title: Text(DateFormat.yMMMd().format(selectedDate), style: TextStyle(color: ctx.textPrimary)),
              onTap: () async { final p = await showDatePicker(context: ctx, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime.now()); if (p != null) setD(() => selectedDate = p); }),
            const SizedBox(height: 16),
            ThemeButton(
              text: 'Save',
              onPressed: () async {
                if (titleCtrl.text.isEmpty && category == 'OTHER') return;
                setD(() => saving = true);
                try {
                  final api = ref.read(apiClientProvider);
                  if (babyMonId == null) return;
                  final data = <String, dynamic>{
                    'category': category,
                    'title': titleCtrl.text.isNotEmpty ? titleCtrl.text : _categoryLabel(category),
                    'notes': notesCtrl.text.isNotEmpty ? notesCtrl.text : null,
                    'happenedAt': selectedDate.toIso8601String(),
                  };
                  final extras = <String>[];
                  if (extraCtrl1.text.isNotEmpty) extras.add('${formLabel1()}: ${extraCtrl1.text}');
                  if (category == 'BOWEL_MOVEMENT' && stoolType != null) extras.add('Consistency: $stoolType');
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
