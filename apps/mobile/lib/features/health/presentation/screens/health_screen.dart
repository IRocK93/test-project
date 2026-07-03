import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' as semantics;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/l10n/l10n_ext.dart';
import 'package:baby_mon/core/mixins/mixins.dart';
import 'package:baby_mon/features/settings/settings.dart';
import 'package:baby_mon/core/constants/constants.dart';
import 'package:baby_mon/core/utils/utils.dart';
import 'package:baby_mon/core/utils/error_handler.dart';
import 'package:baby_mon/features/health/domain/entities/health_record.dart';
import 'package:baby_mon/features/health/domain/entities/allergy.dart';
import 'package:baby_mon/features/health/domain/entities/health_value_keys.dart';
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
  /// Returns injury severity options as (apiKey, localizedLabel) pairs.
  List<MapEntry<String, String>> get _injurySeverityOptions => [
    MapEntry(InjurySeverityKey.mild, context.l10n.severityMild),
    MapEntry(InjurySeverityKey.moderate, context.l10n.severityModerate),
    MapEntry(InjurySeverityKey.severe, context.l10n.severitySevere),
    MapEntry(InjurySeverityKey.critical, context.l10n.severityCritical),
  ];
  /// Returns bowel color options as (apiKey, localizedLabel) pairs.
  List<MapEntry<String, String>> get _bowelColorOptions => [
    MapEntry(BowelColorKey.brown, context.l10n.colorBrown),
    MapEntry(BowelColorKey.green, context.l10n.colorGreen),
    MapEntry(BowelColorKey.yellow, context.l10n.colorYellow),
    MapEntry(BowelColorKey.red, context.l10n.colorRed),
    MapEntry(BowelColorKey.black, context.l10n.colorBlack),
    MapEntry(BowelColorKey.whiteClay, context.l10n.colorWhiteClay),
    MapEntry(BowelColorKey.orange, context.l10n.colorOrange),
  ];
  /// Returns allergy severity options as (apiKey, localizedLabel) pairs.
  List<MapEntry<String, String>> get _allergySeverityOptions => [
    MapEntry(AllergySeverityKey.mild, context.l10n.allergySeverityMild),
    MapEntry(AllergySeverityKey.moderate, context.l10n.allergySeverityModerate),
    MapEntry(AllergySeverityKey.severe, context.l10n.allergySeveritySevere),
    MapEntry(AllergySeverityKey.lifeThreatening, context.l10n.allergySeverityLifeThreatening),
  ];
  IconData _categoryIcon(String cat) =>
      HealthCategory.fromApiKey(cat)?.icon ?? PhosphorIconsLight.note;
  String _categoryLabel(String cat) {
    final hc = HealthCategory.fromApiKey(cat);
    if (hc != null) return _healthCategoryLabel(hc);
    return (cat.isEmpty ? '' : cat[0].toUpperCase() + cat.substring(1).toLowerCase());
  }
  String _healthCategoryLabel(HealthCategory c) {
    switch (c) {
      case HealthCategory.weight: return context.l10n.weightCategoryLabel;
      case HealthCategory.height: return context.l10n.heightCategoryLabel;
      case HealthCategory.headCircumference: return context.l10n.headCircCategoryLabel;
      case HealthCategory.temperature: return context.l10n.bodyTempCategoryLabel;
      case HealthCategory.hospital: return context.l10n.hospitalCategoryLabel;
      case HealthCategory.clinic: return context.l10n.clinicCategoryLabel;
      case HealthCategory.injury: return context.l10n.injuryCategoryLabel;
      case HealthCategory.bowelMovement: return context.l10n.bowelCategoryLabel;
      case HealthCategory.vaccination: return context.l10n.vaccinationCategoryLabel;
      case HealthCategory.allergy: return context.l10n.allergyCategoryLabel;
      case HealthCategory.other: return context.l10n.otherCategoryLabel;
      case HealthCategory.allergyEvent: return context.l10n.allergyCategoryLabel;
    }
  }

  // ── Display-time localization of API keys stored in the backend ──
  String? _localizeDisplayValue(String category, dynamic value) {
    if (value == null) return null;
    final v = value.toString();
    final localizer = HealthValueLocalizer(context.l10n);
    final cat = HealthCategory.fromApiKey(category);
    switch (cat) {
      case HealthCategory.injury:
        return InjurySeverityKey.all.contains(v) ? localizer.localizeInjurySeverity(v) : v;
      case HealthCategory.bowelMovement:
        return BowelColorKey.all.contains(v) ? localizer.localizeBowelColor(v) : v;
      case HealthCategory.vaccination:
        return VaccineKey.all.contains(v) ? localizer.localizeVaccine(v) : v;
      default:
        return v;
    }
  }

  String? _localizeDisplayUnit(String category, String? unit) {
    if (unit == null) return null;
    if (category == HealthCategory.bowelMovement.apiKey && StoolTypeKey.all.contains(unit)) {
      return HealthValueLocalizer(context.l10n).localizeStoolType(unit);
    }
    return unit;
  }
  Future<bool> _deleteRecord(String id, int index) async {
    // Capture messenger and strings upfront so we can safely use them after async gaps.
    final messenger = ScaffoldMessenger.of(context);
    final entryDeletedText = context.l10n.entryDeleted;
    final confirmed = await ConfirmDeleteDialog.show(
      context,
      title: context.l10n.deleteRecordLabel,
      message: context.l10n.deleteRecordMessage,
    );
    if (confirmed != true) return false;
    try {
      await ref.read(apiClientProvider).deleteHealthRecord(id);
      setState(() => _records.removeAt(index));
      loadData(force: true);
      messenger.showSnackBar(SnackBar(content: Text(entryDeletedText)));
      return true;
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(extractErrorMessage(e))));
      return false;
    }
  }
  Future<bool> _deleteAllergyEvent(String eventId) async {
    // Capture messenger and strings upfront so we can safely use them after async gaps.
    final messenger = ScaffoldMessenger.of(context);
    final entryDeletedText = context.l10n.entryDeleted;
    final healthEventDeletedText = context.l10n.healthEventDeleted;
    final directionality = Directionality.of(context);
    final confirmed = await ConfirmDeleteDialog.show(
      context,
      title: context.l10n.deleteEventLabel,
      message: context.l10n.deleteEventMessage,
    );
    if (confirmed != true) return false;
    try {
      await ref.read(apiClientProvider).deleteAllergyEvent(babyMonId!, eventId);
      loadData(force: true);
      messenger.showSnackBar(SnackBar(content: Text(entryDeletedText)));
      // ignore: deprecated_member_use
      semantics.SemanticsService.announce(healthEventDeletedText, directionality);
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
                        padding: const EdgeInsetsDirectional.only(
                          top: 7,
                          start: DesignTokens.spaceMd,
                          end: DesignTokens.spaceMd,
                        ),
                        child: Row(children: [
                          Expanded(
                            child: _NavTile(
                              icon: PhosphorIconsLight.chartLine,
                              label: context.l10n.growth,
                              color: context.colorScheme.primary,
                              onTap: () => context.push('/growth-chart'),
                            ),
                          ),
                          const SizedBox(width: DesignTokens.spaceSm),
                          Expanded(
                            child: _NavTile(
                              icon: PhosphorIconsLight.moon,
                              label: context.l10n.sleep,
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
                      alignment: AlignmentDirectional.centerStart,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: DesignTokens.spaceXs),
                        child: FilterChip(
                          label: Text(context.l10n.allMilestones),
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
                        title: context.l10n.noHealthRecordsTitle,
                        subtitle: context.l10n.noHealthRecordsSubtitle,
                        actionLabel: context.l10n.addRecordAction,
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
            padding: const EdgeInsetsDirectional.only(end: DesignTokens.spaceSm),
            child: FilterChip(
              label: Text(_healthCategoryLabel(category)),
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
    final title = isAllergyEvent && entry.title != null
        ? (AllergyNameKey.all.contains(entry.title!) ? HealthValueLocalizer(context.l10n).localizeAllergyName(entry.title!) : entry.title!)
        : _categoryLabel(entry.category);
    // Localize API keys stored in the backend; fall back to raw value for legacy data.
    final localizedValue = _localizeDisplayValue(entry.category, entry.value);
    final localizedUnit = _localizeDisplayUnit(entry.category, entry.unit);
    final dateStr = entry.happenedAt != null ? DateFormat.yMMMd().format(entry.happenedAt!) : '';
    final semLabel = '$title${localizedValue != null ? ', $localizedValue ${localizedUnit ?? ''}' : ''}${dateStr.isNotEmpty ? ', $dateStr' : ''}${isAllergyEvent ? ' (allergy event)' : ''}';
    return Semantics(
      label: semLabel,
      button: true,
      child: Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
      child: HealthRecordRow(
        title: title,
        value: localizedValue,
        unit: localizedUnit,
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
          padding: EdgeInsetsDirectional.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, start: DesignTokens.spaceLg, end: DesignTokens.spaceLg, top: DesignTokens.spaceLg),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(context.l10n.addMeasurement, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: DesignTokens.spaceMd),
            SegmentedButton<HealthCategory>(
              segments: _measurementCategories.map((c) =>
                ButtonSegment(value: c, label: Text(_healthCategoryLabel(c), maxLines: 2, textAlign: TextAlign.center, style: const TextStyle(fontSize: DesignTokens.fontXs))),
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
            TextField(controller: titleCtrl, decoration: InputDecoration(labelText: context.l10n.titleOptional, hintText: context.l10n.noteOptionalHint)),
            const SizedBox(height: DesignTokens.spaceMd),
            TextField(controller: notesCtrl, decoration: InputDecoration(labelText: context.l10n.notesOptionalLabel), maxLines: 2),
            const SizedBox(height: DesignTokens.spaceMd),
            ListTile(leading: Icon(PhosphorIconsLight.calendar, color: context.colorScheme.primary), title: Text(DateFormat.yMMMd().format(selectedDate), style: TextStyle(color: ctx.textPrimary)),
              onTap: () async { final p = await showDatePicker(context: ctx, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime.now()); if (p != null) setD(() => selectedDate = p); }),
            const SizedBox(height: DesignTokens.spaceLg),
            ThemeButton(
              text: context.l10n.save,
              onPressed: () async {
                if (computedVal <= 0) {
                  setD(() => validationError = context.l10n.pleaseEnterValidValue);
                  return;
                }
                setD(() { validationError = null; saving = true; });
                try {
                  final api = ref.read(apiClientProvider);
                  if (babyMonId == null) return;
                  final result = await api.createHealthRecord(babyMonId!, {
                    'category': selectedCategory.apiKey,
                    'title': titleCtrl.text.isNotEmpty ? titleCtrl.text : _healthCategoryLabel(selectedCategory),
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
              semanticLabel: context.l10n.saveHealthMeasurement,
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
      ThemeButton.icon(icon: PhosphorIconsLight.caretUp, onPressed: () { if (value + step <= max) onChanged(value + step); }, semanticLabel: context.l10n.increaseValue, variant: ThemeButtonVariant.text),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceMd, vertical: DesignTokens.spaceSm),
        decoration: BoxDecoration(border: Border.all(color: context.colorScheme.outline), borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('$value', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(width: 4),
          Text(unit, style: TextStyle(fontSize: DesignTokens.fontMd, fontWeight: FontWeight.w600, color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7))),
        ]),
      ),
      ThemeButton.icon(icon: PhosphorIconsLight.caretDown, onPressed: () { if (value - step >= 0) onChanged(value - step); }, semanticLabel: context.l10n.decreaseValue, variant: ThemeButtonVariant.text),
    ]);
  }
  void _showEventDialog() {
    showModalBottomSheet<void>(
      context: context, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => Padding(
          padding: const EdgeInsets.all(DesignTokens.spaceLg),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(context.l10n.addEvent, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: DesignTokens.spaceLg),
            ..._eventCategories.map((category) => ListTile(
              leading: Icon(category.icon, color: context.colorScheme.primary),
              title: Text(_healthCategoryLabel(category)),
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
        title: Text(context.l10n.addMedicalContact),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(labelText: context.l10n.nameLabel, hintText: context.l10n.drSmithHint),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: roleCtrl,
              decoration: InputDecoration(labelText: context.l10n.rolePhoneLabel, hintText: context.l10n.pediatricianHint),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(context.l10n.cancel)),
          TextButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final medicalTeamAddedText = context.l10n.medicalTeamAdded;
              final failedToAddText = context.l10n.failedToAdd;
              if (name.isEmpty) return;
              try {
                await ref.read(apiClientProvider).createMedicalTeamMember(
                  babyMonId!,
                  {'name': name, 'role': roleCtrl.text.trim()},
                );
                messenger.showSnackBar(SnackBar(content: Text(medicalTeamAddedText)));
              } catch (_) {
                messenger.showSnackBar(SnackBar(content: Text(failedToAddText)));
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(context.l10n.addLabel),
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
    bool allergyIsOther = false;
    final allergyOtherCtrl = TextEditingController();
    String? allergySeverity;
    showModalBottomSheet<void>(
      context: context, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => Padding(
          padding: EdgeInsetsDirectional.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, start: DesignTokens.spaceLg, end: DesignTokens.spaceLg, top: DesignTokens.spaceLg),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(isNew ? context.l10n.addAllergyTitle : context.l10n.recordAllergyEventTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: DesignTokens.spaceLg),
            if (isNew) ...[
              _AllergyPicker(
                value: nameCtrl.text,
                onChanged: (v) {
                  setD(() { nameCtrl.text = v; allergyIsOther = v == AllergyNameKey.other; });
                },
                showOtherField: allergyIsOther,
                otherCtrl: allergyOtherCtrl,
              ),
              const SizedBox(height: DesignTokens.spaceMd),
              TextField(controller: triggersCtrl, decoration: InputDecoration(labelText: context.l10n.triggers, hintText: context.l10n.triggersHint)),
              const SizedBox(height: DesignTokens.spaceMd),
              ListTile(
                title: Text('${context.l10n.allergySeverity}: ${allergySeverity != null ? HealthValueLocalizer(context.l10n).localizeAllergySeverity(allergySeverity!) : context.l10n.tapToSelect}'),
                trailing: const Icon(PhosphorIconsLight.caretDown),
                contentPadding: EdgeInsets.zero,
                onTap: () async {
                  final v = await WheelPickerBottomSheet.show<String>(context: ctx, title: context.l10n.allergySeverity, columns: [WheelColumn<String>(label: '', options: _allergySeverityOptions.map((e) => WheelOption(value: e.key, label: e.value)).toList())]);
                  if (v != null) setD(() => allergySeverity = v);
                },
              ),
              const SizedBox(height: DesignTokens.spaceMd),
              TextField(controller: treatmentCtrl, decoration: InputDecoration(labelText: context.l10n.treatment, hintText: context.l10n.treatmentHint)),
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
            TextField(controller: notesCtrl, decoration: InputDecoration(labelText: context.l10n.notesOptionalLabel), maxLines: 2),
            const SizedBox(height: 20),
            if (validationError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
                child: Text(validationError!, style: TextStyle(color: context.colorScheme.error, fontSize: DesignTokens.fontSm)),
              ),
            ThemeButton(
              text: context.l10n.save,
              onPressed: () async {
                final allergyName = nameCtrl.text == AllergyNameKey.other ? allergyOtherCtrl.text.trim() : nameCtrl.text;
                final pleaseEnterNameText = context.l10n.pleaseEnterName;
                final allergyAddedText = context.l10n.allergyAdded;
                final allergyEventRecordedText = context.l10n.allergyEventRecorded;
                final failedToSaveText = context.l10n.failedToSave;
                if (isNew && allergyName.isEmpty) {
                  setD(() => validationError = pleaseEnterNameText);
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
                      'severity': allergySeverity ?? severityCtrl.text,
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
                  loadData(force: true);
                  messenger.showSnackBar(SnackBar(content: Text(isNew ? allergyAddedText : allergyEventRecordedText)));
                  if (ctx.mounted) Navigator.pop(ctx);
                } on DioException catch (e) {
                  setD(() => saving = false);
                  final msg = parseString(parseJsonMap(e.response?.data)?['message']);
                  if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg ?? failedToSaveText)));
                } catch (e) {
                  setD(() => saving = false);
                  if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(failedToSaveText)));
                }
              },
              isLoading: saving,
              fullWidth: true,
              semanticLabel: context.l10n.saveAllergy,
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
    String? injurySeverity;
    String? bowelColor;
    bool vaccineIsOther = false;
    final vaccineOtherCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now();
    bool saving = false;
    final staffCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    final isHospitalOrClinic = category == HealthCategory.hospital || category == HealthCategory.clinic;
    final isInjuryOrBowelOrVax = category == HealthCategory.injury || category == HealthCategory.bowelMovement || category == HealthCategory.vaccination;
    final showTitle = !isInjuryOrBowelOrVax;
    String formLabel1() {
      if (isHospitalOrClinic) return context.l10n.reasonLabel;
      if (category == HealthCategory.injury) return context.l10n.allergySeverity;
      if (category == HealthCategory.bowelMovement) return context.l10n.colorLabel;
      if (category == HealthCategory.vaccination) return context.l10n.vaccineNameLabel;
      return '';
    }
    final showStaff = isHospitalOrClinic;
    final showExtra1 = category == HealthCategory.hospital || category == HealthCategory.clinic || category == HealthCategory.injury || category == HealthCategory.bowelMovement || category == HealthCategory.vaccination;
    final showExtra2 = category == HealthCategory.hospital || category == HealthCategory.clinic || category == HealthCategory.injury || category == HealthCategory.vaccination;
    final showTime = category == HealthCategory.bowelMovement;
    final showVenue = category == HealthCategory.vaccination;
    final venueCtrl = TextEditingController();
    String? stoolTypeKey;
    String? validationError;
    final l10n = context.l10n;
    final localizer = HealthValueLocalizer(l10n);
    final stoolTypeOptions = [
      MapEntry(StoolTypeKey.watery, l10n.stoolTypeWatery),
      MapEntry(StoolTypeKey.loose, l10n.stoolTypeLoose),
      MapEntry(StoolTypeKey.mushy, l10n.stoolTypeMushy),
      MapEntry(StoolTypeKey.softFormed, l10n.stoolTypeSoftFormed),
      MapEntry(StoolTypeKey.normal, l10n.stoolTypeNormal),
      MapEntry(StoolTypeKey.firm, l10n.stoolTypeFirm),
      MapEntry(StoolTypeKey.hardPellets, l10n.stoolTypeHardPellets),
      MapEntry(StoolTypeKey.constipated, l10n.stoolTypeConstipated),
    ];
    showModalBottomSheet<void>(
      context: context, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => Padding(
          padding: EdgeInsetsDirectional.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, start: DesignTokens.spaceLg, end: DesignTokens.spaceLg, top: DesignTokens.spaceLg),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('${context.l10n.addLabel} ${_healthCategoryLabel(category)}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: DesignTokens.spaceLg),
            if (showTitle) ...[
              TextField(controller: titleCtrl, decoration: InputDecoration(labelText: context.l10n.nameTitle, hintText: 'e.g. ${category == HealthCategory.hospital ? context.l10n.erVisitHint : context.l10n.annualCheckup}')),
              const SizedBox(height: DesignTokens.spaceMd),
            ],
            if (showStaff) ...[
              TextField(controller: staffCtrl, decoration: InputDecoration(labelText: context.l10n.attendingStaff)),
              const SizedBox(height: DesignTokens.spaceMd),
            ],
            if (showTime) ...[
              TextField(controller: timeCtrl, decoration: InputDecoration(labelText: context.l10n.time), readOnly: true,
                onTap: () async {
                  final t = await showTimePicker(context: ctx, initialTime: TimeOfDay.now());
                  if (t != null) setD(() => timeCtrl.text = t.format(ctx));
                }),
              const SizedBox(height: DesignTokens.spaceMd),
            ],
            if (showExtra1) ...[
              if (category == HealthCategory.injury) ...[
                ListTile(
                  title: Text('${context.l10n.allergySeverity}: ${injurySeverity != null ? localizer.localizeInjurySeverity(injurySeverity!) : context.l10n.tapToSelect}'),
                  trailing: const Icon(PhosphorIconsLight.caretDown),
                  onTap: () async {
                    final v = await WheelPickerBottomSheet.show<String>(context: ctx, title: context.l10n.allergySeverity, columns: [WheelColumn<String>(label: '', options: _injurySeverityOptions.map((e) => WheelOption(value: e.key, label: e.value)).toList())]);
                    if (v != null) setD(() => injurySeverity = v);
                  },
                ),
              ] else if (category == HealthCategory.bowelMovement) ...[
                ListTile(
                  title: Text('${context.l10n.colorLabel}: ${bowelColor != null ? localizer.localizeBowelColor(bowelColor!) : context.l10n.tapToSelect}'),
                  trailing: const Icon(PhosphorIconsLight.caretDown),
                  onTap: () async {
                    final v = await WheelPickerBottomSheet.show<String>(context: ctx, title: context.l10n.colorLabel, columns: [WheelColumn<String>(label: '', options: _bowelColorOptions.map((e) => WheelOption(value: e.key, label: e.value)).toList())]);
                    if (v != null) setD(() => bowelColor = v);
                  },
                ),
              ] else if (category == HealthCategory.vaccination) ...[
                _VaccinePicker(
                  value: extraCtrl1.text,
                  onChanged: (v) {
                    setD(() { extraCtrl1.text = v; vaccineIsOther = v == VaccineKey.other; });
                  },
                  showOtherField: vaccineIsOther,
                  otherCtrl: vaccineOtherCtrl,
                ),
              ] else ...[
                TextField(controller: extraCtrl1, decoration: InputDecoration(labelText: formLabel1())),
              ],
              const SizedBox(height: DesignTokens.spaceMd),
            ],
            if (showExtra2) ...[
              TextField(controller: (() { final c = TextEditingController(); return c; })(), decoration: InputDecoration(labelText: category == HealthCategory.injury ? context.l10n.description : category == HealthCategory.vaccination ? context.l10n.locationOnBody : context.l10n.outcomeLabel)),
              const SizedBox(height: DesignTokens.spaceMd),
            ],
            if (category == HealthCategory.bowelMovement) ...[
              const SizedBox(height: 4),
              Text(context.l10n.consistencyLabel, style: TextStyle(fontSize: DesignTokens.fontSm, fontWeight: FontWeight.w500, color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7))),
              const SizedBox(height: 6),
              Wrap(spacing: 6, runSpacing: 6, children: stoolTypeOptions.map((e) => ChoiceChip(
                label: Text(e.value, style: const TextStyle(fontSize: DesignTokens.fontSm)),
                selected: stoolTypeKey == e.key,
                onSelected: (sel) => setD(() => stoolTypeKey = sel ? e.key : null),
                selectedColor: context.colorScheme.primaryContainer,
              )).toList()),
              const SizedBox(height: DesignTokens.spaceMd),
            ],
            if (showVenue) ...[
              TextField(controller: venueCtrl, decoration: InputDecoration(labelText: context.l10n.venue)),
              const SizedBox(height: DesignTokens.spaceMd),
            ],
            TextField(controller: notesCtrl, decoration: InputDecoration(labelText: context.l10n.notesOptionalLabel), maxLines: 2),
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
              text: context.l10n.save,
              onPressed: () async {                  if (titleCtrl.text.isEmpty && category == HealthCategory.other) {
                  setD(() => validationError = context.l10n.pleaseEnterDescription);
                  return;
                }
                setD(() { validationError = null; saving = true; });
                try {
                  final api = ref.read(apiClientProvider);
                  if (babyMonId == null) return;
                  final data = <String, dynamic>{
                    'category': apiKey,
                    'title': titleCtrl.text.isNotEmpty ? titleCtrl.text : _healthCategoryLabel(category),
                    'notes': notesCtrl.text.isNotEmpty ? notesCtrl.text : null,
                    'happenedAt': selectedDate.toIso8601String(),
                  };
                  // Store primary enum key in [value] so it can be localized at display time.
                  if (category == HealthCategory.injury && injurySeverity != null) {
                    data['value'] = injurySeverity;
                  }
                  if (category == HealthCategory.bowelMovement && bowelColor != null) {
                    data['value'] = bowelColor;
                  }
                  if (category == HealthCategory.vaccination && extraCtrl1.text.isNotEmpty) {
                    final vaxKey = extraCtrl1.text == VaccineKey.other ? vaccineOtherCtrl.text.trim() : extraCtrl1.text;
                    if (vaxKey.isNotEmpty) data['value'] = vaxKey;
                  }
                  // Store stool type (API key) in [unit] for bowel movements — it will be localized at display.
                  if (category == HealthCategory.bowelMovement && stoolTypeKey != null) {
                    data['unit'] = stoolTypeKey;
                  }
                  final extras = <String>[];
                  if (extraCtrl1.text.isNotEmpty && category != HealthCategory.injury && category != HealthCategory.bowelMovement && category != HealthCategory.vaccination) extras.add('${formLabel1()}: ${extraCtrl1.text}');
                  if (showVenue && venueCtrl.text.isNotEmpty) extras.add('${context.l10n.venuePrefix} ${venueCtrl.text}');
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
              semanticLabel: context.l10n.saveHealthEvent,
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

  String _localizeVaccine(String key, dynamic l10n) {
    final localizer = HealthValueLocalizer(l10n);
    return localizer.localizeVaccine(key);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final displayValue = widget.value.isEmpty ? '' : _localizeVaccine(widget.value, l10n);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(widget.value.isEmpty ? l10n.vaccineTapToSelect : '${l10n.vaccinePrefix} $displayValue', maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(PhosphorIconsLight.caretDown),
        onTap: () => _showPicker(context),
      ),
      if (widget.showOtherField)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: TextField(controller: widget.otherCtrl, decoration: InputDecoration(labelText: l10n.vaccineName, hintText: l10n.enterCustomVaccine)),
        ),
    ]);
  }
  void _showPicker(BuildContext context) {
    final l10n = context.l10n;
    final vaccines = [
      MapEntry(VaccineKey.other, l10n.vaccineOther),
      MapEntry(VaccineKey.hepB, l10n.vaccineHepB),
      MapEntry(VaccineKey.rotavirus, l10n.vaccineRotavirus),
      MapEntry(VaccineKey.dtap, l10n.vaccineDTaP),
      MapEntry(VaccineKey.hib, l10n.vaccineHib),
      MapEntry(VaccineKey.pcv13, l10n.vaccinePCV13),
      MapEntry(VaccineKey.ipv, l10n.vaccineIPV),
      MapEntry(VaccineKey.flu, l10n.vaccineFlu),
      MapEntry(VaccineKey.mmr, l10n.vaccineMMR),
      MapEntry(VaccineKey.varicella, l10n.vaccineVaricella),
      MapEntry(VaccineKey.hepA, l10n.vaccineHepA),
      MapEntry(VaccineKey.menACWY, l10n.vaccineMenACWY),
      MapEntry(VaccineKey.covid, l10n.vaccineCOVID),
      MapEntry(VaccineKey.hpv, l10n.vaccineHPV),
      MapEntry(VaccineKey.tdap, l10n.vaccineTdap),
      MapEntry(VaccineKey.rsv, l10n.vaccineRSV),
    ];
    const otherValue = VaccineKey.other;
    _searchCtrl.clear();
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) {
          final query = _searchCtrl.text.toLowerCase();
          final filtered = vaccines.where((v) => v.value.toLowerCase().contains(query)).toList();
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  decoration: InputDecoration(hintText: l10n.searchVaccines, prefixIcon: const Icon(PhosphorIconsLight.magnifyingGlass), border: const OutlineInputBorder()),
                  onChanged: (_) => setD(() {}),
                ),
              ),
              Flexible(child: ListView(
                shrinkWrap: true,
                children: filtered.map((v) => ListTile(
                  title: Text(v.value, style: TextStyle(fontWeight: v.key == widget.value ? FontWeight.w700 : FontWeight.w400, color: v.key == otherValue ? Theme.of(context).colorScheme.primary : null)),
                  onTap: () {
                    widget.onChanged(v.key);
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

  String _localizeAllergyName(String key, dynamic l10n) {
    final localizer = HealthValueLocalizer(l10n);
    return localizer.localizeAllergyName(key);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final displayValue = widget.value.isEmpty ? '' : _localizeAllergyName(widget.value, l10n);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(widget.value.isEmpty ? l10n.allergyTapToSelect : '${l10n.allergyPrefix} $displayValue', maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(PhosphorIconsLight.caretDown),
        onTap: () => _showPicker(context),
      ),
      if (widget.showOtherField)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: TextField(controller: widget.otherCtrl, decoration: InputDecoration(labelText: l10n.allergyNameField, hintText: l10n.enterCustomAllergy)),
        ),
    ]);
  }
  void _showPicker(BuildContext context) {
    final l10n = context.l10n;
    final allergies = [
      MapEntry(AllergyNameKey.other, l10n.allergyOtherOption),
      MapEntry(AllergyNameKey.peanuts, l10n.allergyPeanutsOption),
      MapEntry(AllergyNameKey.treeNuts, l10n.allergyTreeNutsOption),
      MapEntry(AllergyNameKey.milkDairy, l10n.allergyMilkDairyOption),
      MapEntry(AllergyNameKey.eggs, l10n.allergyEggsOption),
      MapEntry(AllergyNameKey.soy, l10n.allergySoyOption),
      MapEntry(AllergyNameKey.wheat, l10n.allergyWheatOption),
      MapEntry(AllergyNameKey.fish, l10n.allergyFishOption),
      MapEntry(AllergyNameKey.shellfish, l10n.allergyShellfishOption),
      MapEntry(AllergyNameKey.sesame, l10n.allergySesameOption),
      MapEntry(AllergyNameKey.pollen, l10n.allergyPollenOption),
      MapEntry(AllergyNameKey.dustMites, l10n.allergyDustMitesOption),
      MapEntry(AllergyNameKey.mold, l10n.allergyMoldOption),
      MapEntry(AllergyNameKey.petDander, l10n.allergyPetDanderOption),
      MapEntry(AllergyNameKey.insectStings, l10n.allergyInsectStingsOption),
      MapEntry(AllergyNameKey.latex, l10n.allergyLatexOption),
      MapEntry(AllergyNameKey.penicillin, l10n.allergyPenicillinOption),
      MapEntry(AllergyNameKey.nsaids, l10n.allergyNSAIDsOption),
      MapEntry(AllergyNameKey.sulfaDrugs, l10n.allergySulfaDrugsOption),
    ];
    final explanations = {
      AllergyNameKey.peanuts: l10n.allergyExplanationPeanuts,
      AllergyNameKey.treeNuts: l10n.allergyExplanationTreeNuts,
      AllergyNameKey.milkDairy: l10n.allergyExplanationMilkDairy,
      AllergyNameKey.eggs: l10n.allergyExplanationEggs,
      AllergyNameKey.soy: l10n.allergyExplanationSoy,
      AllergyNameKey.wheat: l10n.allergyExplanationWheat,
      AllergyNameKey.fish: l10n.allergyExplanationFish,
      AllergyNameKey.shellfish: l10n.allergyExplanationShellfish,
      AllergyNameKey.sesame: l10n.allergyExplanationSesame,
      AllergyNameKey.pollen: l10n.allergyExplanationPollen,
      AllergyNameKey.dustMites: l10n.allergyExplanationDustMites,
      AllergyNameKey.mold: l10n.allergyExplanationMold,
      AllergyNameKey.petDander: l10n.allergyExplanationPetDander,
      AllergyNameKey.insectStings: l10n.allergyExplanationInsectStings,
      AllergyNameKey.latex: l10n.allergyExplanationLatex,
      AllergyNameKey.penicillin: l10n.allergyExplanationPenicillin,
      AllergyNameKey.nsaids: l10n.allergyExplanationNSAIDs,
      AllergyNameKey.sulfaDrugs: l10n.allergyExplanationSulfaDrugs,
    };
    const otherValue = AllergyNameKey.other;
    _searchCtrl.clear();
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) {
          final query = _searchCtrl.text.toLowerCase();
          final filtered = allergies.where((a) => a.value.toLowerCase().contains(query)).toList();
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  decoration: InputDecoration(hintText: l10n.searchAllergies, prefixIcon: const Icon(PhosphorIconsLight.magnifyingGlass), border: const OutlineInputBorder()),
                  onChanged: (_) => setD(() {}),
                ),
              ),
              Flexible(child: ListView(
                shrinkWrap: true,
                children: filtered.map((a) => ListTile(
                  title: Text(a.value, style: TextStyle(fontWeight: a.key == widget.value ? FontWeight.w700 : FontWeight.w400, color: a.key == otherValue ? Theme.of(context).colorScheme.primary : null)),
                  subtitle: explanations[a.key] != null ? Text(explanations[a.key]!, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)) : null,
                  onTap: () {
                    widget.onChanged(a.key);
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
