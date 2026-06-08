import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:baby_mon/data/api_client.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/core/constants/api_constants.dart';
import '../settings/settings_screen.dart';
import 'growth_chart_screen.dart';
import '../sleep/sleep_screen.dart';

class HealthScreen extends ConsumerStatefulWidget {
  const HealthScreen({super.key});

  @override
  ConsumerState<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends ConsumerState<HealthScreen> {
  String? _babyMonId;
  List _records = [];
  String _selectedCategory = 'ALL';
  bool _isLoading = true;
  bool _fabOpen = false;
  bool _isMetric = true;

  List<Map<String, dynamic>> _allergies = [];  // raw allergy profiles for cure/reactivate
  List<Map<String, dynamic>> _allergyEvents = [];  // flattened event list for display

  final List<String> _categories = ['ALL', 'WEIGHT', 'HEIGHT', 'HEAD_CIRCUMFERENCE', 'TEMPERATURE',
    'HOSPITAL', 'CLINIC', 'INJURY', 'BOWEL_MOVEMENT', 'VACCINATION', 'ALLERGY', 'OTHER'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
    ref.listenManual(appRefreshProvider, (prev, next) {
      if (prev != next) _loadData();
    });
  }

  Future<void> _loadUnitPref() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getString(measurementUnitsKey);
    if (mounted) setState(() => _isMetric = val != 'imperial');
  }

  Future<void> _loadData() async {
    _loadUnitPref();
    final api = ref.read(apiClientProvider);
    final id = await api.getSelectedBabyMonId();
    if (id == null || id.isEmpty) {
      if (id != null && id.isEmpty) await api.setSelectedBabyMonId(null);
      setState(() => _isLoading = false);
      return;
    }
    _babyMonId = id;
    await _fetchHealthRecords();
  }

  Future<void> _fetchHealthRecords() async {
    if (_babyMonId == null) return;
    setState(() => _isLoading = true);
    try {
      final response = await ref.read(apiClientProvider).get(
        '${ApiConstants.babyMons}/$_babyMonId/health-records',
      );
      List<Map<String, dynamic>> allergies = [];
      final flat = <Map<String, dynamic>>[];
      try {
        final aRes = await ref.read(apiClientProvider).getAllergies(_babyMonId!);
        final raw = aRes.data;
        final rawList = (raw is List) ? raw : (raw is Map ? ((raw['items'] as List?) ?? []) : []);
        for (final a in rawList) {
          final events = (a['events'] as List?) ?? [];
          for (final evt in events) {
            flat.add({
              ...Map<String, dynamic>.from(evt),
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
        allergies = rawList.cast<Map<String, dynamic>>();
      } catch (_) {}
      if (mounted) setState(() {
        _records = (response.data is List) ? response.data : ((response.data as Map)['items'] as List?) ?? [];
        _allergies = allergies;
        _allergyEvents = flat;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List _filteredRecords() {
    if (_selectedCategory == 'ALLERGY') return _allergyEvents;
    if (_selectedCategory == 'ALL') {
      final merged = [..._records, ..._allergyEvents];
      return merged;
    }
    return _records.where((r) => r['category'] == _selectedCategory).toList();
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

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'WEIGHT': return Icons.monitor_weight;
      case 'HEIGHT': return Icons.height;
      case 'HEAD_CIRCUMFERENCE': return Icons.face;
      case 'TEMPERATURE': return Icons.thermostat;
      case 'HOSPITAL': return Icons.local_hospital;
      case 'CLINIC': return Icons.medication;
      case 'INJURY': return Icons.healing;
      case 'BOWEL_MOVEMENT': return Icons.water_drop;
      case 'VACCINATION': return Icons.vaccines;
      case 'ALLERGY': return Icons.warning_amber;
      default: return Icons.note;
    }
  }

  String _unitFor(String cat) {
    if (_isMetric) {
      switch (cat) {
        case 'WEIGHT': return 'kg';
        case 'HEIGHT': return 'cm';
        case 'HEAD_CIRCUMFERENCE': return 'cm';
        case 'TEMPERATURE': return '°C';
        default: return '';
      }
    } else {
      switch (cat) {
        case 'WEIGHT': return 'lbs';
        case 'HEIGHT': return 'in';
        case 'HEAD_CIRCUMFERENCE': return 'in';
        case 'TEMPERATURE': return '°F';
        default: return '';
      }
    }
  }

  Future<bool> _deleteRecord(String id, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Delete this health record?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return false;
    try {
      await ref.read(apiClientProvider).deleteHealthRecord(id);
      setState(() => _records.removeAt(index));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted')));
      return true;
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      return false;
    }
  }

  Future<bool> _deleteAllergyEvent(String eventId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Delete this allergy event? (The allergy itself will remain)'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return false;
    try {
      await ref.read(apiClientProvider).deleteAllergyEvent(_babyMonId!, eventId);
      ref.read(appRefreshProvider.notifier).state++;
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event deleted')));
      return true;
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      return false;
    }
  }

  String _formatValue(Map record) {
    final value = record['value'];
    final unit = record['unit'] ?? '';
    if (value == null) return '';
    return ' ($value $unit)';
  }

  String _recordSubtitle(Map record) {
    final cat = record['category'] ?? '';
    if (cat == 'ALLERGY_EVENT' || cat == 'ALLERGY') {
      final severity = record['severity'] as String?;
      final date = record['happenedAt'] != null ? '${DateFormat.yMMMd().add_jm().format(DateTime.parse(record['happenedAt']))}' : '';
      final parts = <String>[];
      if (date.isNotEmpty) parts.add(date);
      if (severity != null && severity.isNotEmpty) parts.add(severity);
      return parts.join(' · ');
    }
    final date = record['happenedAt'] != null ? DateFormat.yMMMd().format(DateTime.parse(record['happenedAt'])) : '';
    final val = _formatValue(record);
    final notes = record['notes'] as String?;
    final parts = <String>[];
    if (val.isNotEmpty) parts.add(val);
    if (notes != null && notes.isNotEmpty) parts.add(notes);
    return '${_categoryLabel(cat)}$val — $date';
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRecords();
    return Scaffold(
      appBar: AppBar(title: const Text('Health')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              // Growth Chart nav
              Card(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2), child: Icon(Icons.show_chart, color: Theme.of(context).colorScheme.primary)),
                  title: const Text('Growth Chart'), subtitle: const Text('Weight, height, head circumference'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GrowthChartScreen())),
                ),
              ),
              // Sleep nav
              Card(
                margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.indigo.withOpacity(0.2), child: const Icon(Icons.bedtime, color: Colors.indigo)),
                  title: const Text('Sleep Tracking'), subtitle: const Text('Nap & night sleep logs'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SleepScreen())),
                ),
              ),
              // Filter chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: _categories.map((cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat == 'ALL' ? 'All' : _categoryLabel(cat)),
                      selected: _selectedCategory == cat,
                      onSelected: (_) => setState(() => _selectedCategory = cat),
                    ),
                  )).toList()),
                ),
              ),
              // List
              Expanded(
                child: filtered.isEmpty
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.medical_services, size: 64, color: Colors.grey),
                        const SizedBox(height: 16), const Text('No health records yet', style: TextStyle(color: Colors.grey)),
                      ]))
                    : RefreshIndicator(
                        onRefresh: _fetchHealthRecords,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final record = filtered[index];
                            final cat = record['category'] ?? '';
                            final isAllergyEvent = cat == 'ALLERGY_EVENT';
                            return Dismissible(
                              key: Key(record['id'] ?? index.toString()),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (_) => isAllergyEvent ? _deleteAllergyEvent(record['id'] as String) : _deleteRecord(record['id'], _records.indexOf(record)),
                              background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), color: Colors.red, child: const Icon(Icons.delete, color: Colors.white)),
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: CircleAvatar(backgroundColor: isAllergyEvent ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2), child: Icon(isAllergyEvent ? Icons.warning_amber : _categoryIcon(cat), color: isAllergyEvent ? Colors.orange : Colors.green)),
                                  title: Text(record['title'] ?? _categoryLabel(cat)),
                                  subtitle: Text(_recordSubtitle(record), maxLines: 2, overflow: TextOverflow.ellipsis),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ]),
      floatingActionButton: _buildExpandableFAB(),
    );
  }

  // ╔══════════════════════════════════╗
  // ║  EXPANDABLE FAB (fan-out menu) ║
  // ╚══════════════════════════════════╝
  Widget _buildExpandableFAB() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_fabOpen) ...[
          FloatingActionButton.small(heroTag: 'add_measurement', backgroundColor: Colors.teal,
            onPressed: () { setState(() => _fabOpen = false); _showMeasurementDialog(); },
            child: const Icon(Icons.straighten)),
          const SizedBox(height: 8),
          FloatingActionButton.small(heroTag: 'add_event', backgroundColor: Colors.orange,
            onPressed: () { setState(() => _fabOpen = false); _showEventDialog(); },
            child: const Icon(Icons.local_hospital)),
          const SizedBox(height: 8),
          FloatingActionButton.small(heroTag: 'set_team', backgroundColor: Colors.indigo,
            onPressed: () { setState(() => _fabOpen = false); _showTeamHint(); },
            child: const Icon(Icons.group)),
          const SizedBox(height: 8),
        ],
        FloatingActionButton(heroTag: 'health_fab', onPressed: () => setState(() => _fabOpen = !_fabOpen), child: Icon(_fabOpen ? Icons.close : Icons.add)),
      ],
    );
  }

  void _showTeamHint() {
    final nameCtrl = TextEditingController();
    final specialtyCtrl = TextEditingController();
    final facilityCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    bool saving = false;

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Add Medical Team Member', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Provider Name', hintText: 'e.g. Dr. Smith')),
            const SizedBox(height: 12),
            TextField(controller: specialtyCtrl, decoration: const InputDecoration(labelText: 'Specialty', hintText: 'e.g. Pediatrician')),
            const SizedBox(height: 12),
            TextField(controller: facilityCtrl, decoration: const InputDecoration(labelText: 'Facility / Hospital', hintText: 'e.g. Children\'s Hospital')),
            const SizedBox(height: 12),
            TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes (optional)', hintText: 'Contact info, office hours, etc.'), maxLines: 3),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saving ? null : () async {
                if (nameCtrl.text.isEmpty) return;
                setD(() => saving = true);
                try {
                  final api = ref.read(apiClientProvider);
                  if (_babyMonId == null) return;
                  await api.createMedicalTeamMember(_babyMonId!, {
                    'name': nameCtrl.text,
                    'specialty': specialtyCtrl.text,
                    'facility': facilityCtrl.text,
                    'notes': notesCtrl.text.isNotEmpty ? notesCtrl.text : null,
                  });
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Medical team member added!')));
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  setD(() => saving = false);
                  if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'),
            ),
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }

  // ═══ MEASUREMENT DIALOG (Weight / Height / Head Circumference / Temp) ═══
  // Uses numeric dials: Weight (kg + g), Height (cm + mm), Head (cm + mm), Temp (°C / °F)
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
        case 'TEMPERATURE': return _isMetric ? '°C' : '°F';
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

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Add Measurement', style: Theme.of(context).textTheme.titleLarge),
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
            // Numeric dials: major (e.g. kg) on left, minor (e.g. g) on right
            Text('${majorUnit(selectedType)} · ${minorUnit(selectedType)}', textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Row(children: [
              // Major dial (e.g. kg/cm)
              Expanded(child: _buildDial(
                value: major,
                max: selectedType == 'TEMPERATURE' ? 50 : 200,
                unit: majorUnit(selectedType),
                onChanged: (v) => setD(() => major = v),
              )),
              const SizedBox(width: 16),
              // Minor dial (e.g. g/mm)
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
            ListTile(leading: const Icon(Icons.calendar_today), title: Text(DateFormat.yMMMd().format(selectedDate)),
              onTap: () async { final p = await showDatePicker(context: ctx, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime.now()); if (p != null) setD(() => selectedDate = p); }),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: saving ? null : () async {
                setD(() => saving = true);
                try {
                  final api = ref.read(apiClientProvider);
                  if (_babyMonId == null) return;
                  await api.createHealthRecord(_babyMonId!, {
                    'category': selectedType,
                    'title': titleCtrl.text.isNotEmpty ? titleCtrl.text : _categoryLabel(selectedType),
                    'notes': notesCtrl.text.isNotEmpty ? notesCtrl.text : null,
                    'happenedAt': selectedDate.toIso8601String(),
                    'value': computedValue(selectedType),
                    'unit': _unitFor(selectedType),
                  });
                  await _fetchHealthRecords();
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  setD(() => saving = false);
                  if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'),
            ),
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }

  Widget _buildDial({required int value, required int max, required String unit, int step = 1, required ValueChanged<int> onChanged}) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      IconButton(icon: const Icon(Icons.keyboard_arrow_up, size: 32), onPressed: () { if (value + step <= max) onChanged(value + step); }),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('$value', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(width: 4),
          Text(unit, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
        ]),
      ),
      IconButton(icon: const Icon(Icons.keyboard_arrow_down, size: 32), onPressed: () { if (value - step >= 0) onChanged(value - step); }),
    ]);
  }

  // ═══ EVENT DIALOG (Hospital / Clinic / Injury / Bowel Movement / Vaccination / Other) ═══
  void _showEventDialog() {
    // First step: pick event type
    String? selectedType;
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Add Event', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _eventOption(ctx, setD, Icons.local_hospital, 'Hospital', 'HOSPITAL'),
            _eventOption(ctx, setD, Icons.medication, 'Clinic', 'CLINIC'),
            _eventOption(ctx, setD, Icons.healing, 'Injury', 'INJURY'),
            _eventOption(ctx, setD, Icons.water_drop, 'Bowel Movement', 'BOWEL_MOVEMENT'),
            _eventOption(ctx, setD, Icons.vaccines, 'Vaccination', 'VACCINATION'),
            _eventOption(ctx, setD, Icons.warning_amber, 'Allergy', 'ALLERGY'),
            _eventOption(ctx, setD, Icons.note, 'Other', 'OTHER'),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }

  Widget _eventOption(BuildContext ctx, dynamic setD, IconData icon, String label, String type) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.pop(ctx);
        _showEventForm(type);
      },
    );
  }

  void _showAllergyForm({String? prefillName, String? prefillTriggers, String? prefillSeverity, String? prefillTreatment}) {
    final nameCtrl = TextEditingController(text: prefillName);
    final triggersCtrl = TextEditingController(text: prefillTriggers);
    final severityCtrl = TextEditingController(text: prefillSeverity);
    final treatmentCtrl = TextEditingController(text: prefillTreatment);
    final notesCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    final isNew = prefillName == null;
    bool saving = false;

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(isNew ? 'Add Allergy' : 'Record Allergy Event', style: Theme.of(context).textTheme.titleLarge),
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
            // Date/time picker
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(DateFormat.yMMMd().format(selectedDate)),
              subtitle: Text(selectedTime.format(ctx)),
              onTap: () async {
                final p = await showDatePicker(context: ctx, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime.now());
                if (p != null) {
                  final t = await showTimePicker(context: ctx, initialTime: selectedTime);
                  if (t != null) setD(() { selectedDate = p; selectedTime = t; });
                }
              },
            ),
            const SizedBox(height: 8),
            TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes (optional)'), maxLines: 2),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saving ? null : () async {
                if (isNew && nameCtrl.text.isEmpty) return;
                setD(() => saving = true);
                try {
                  final api = ref.read(apiClientProvider);
                  if (_babyMonId == null) return;
                  final happenedAt = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute).toIso8601String();
                  if (isNew) {
                    await api.createAllergy(_babyMonId!, {
                      'name': nameCtrl.text,
                      'triggers': triggersCtrl.text,
                      'severity': severityCtrl.text,
                      'treatment': treatmentCtrl.text,
                      'happenedAt': happenedAt,
                      'notes': notesCtrl.text.isNotEmpty ? notesCtrl.text : null,
                    });
                  } else {
                    // Find allergy ID by name and add event
                    final existing = _allergies.firstWhere((a) => a['name'] == prefillName);
                    await api.addAllergyEvent(_babyMonId!, existing['id'] as String, {
                      'happenedAt': happenedAt,
                      'notes': notesCtrl.text.isNotEmpty ? notesCtrl.text : null,
                    });
                  }
                  ref.read(appRefreshProvider.notifier).state++;
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isNew ? 'Allergy added!' : 'Allergy event recorded!')));
                  if (ctx.mounted) Navigator.pop(ctx);
                } on DioException catch (e) {
                  setD(() => saving = false);
                  final msg = (e.response?.data is Map) ? (e.response!.data as Map)['message'] as String? : null;
                  if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg ?? 'Failed to save. Please try again.')));
                } catch (e) {
                  setD(() => saving = false);
                  if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Failed to save. Please try again.')));
                }
              },
              child: saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'),
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

    final _isHospitalOrClinic = category == 'HOSPITAL' || category == 'CLINIC';
    final _isInjuryOrBowelOrVax = ['INJURY', 'BOWEL_MOVEMENT', 'VACCINATION'].contains(category);
    final _showTitle = !_isInjuryOrBowelOrVax;

    String _formLabel1() {
      if (_isHospitalOrClinic) return 'Reason';
      if (category == 'INJURY') return 'Severity';
      if (category == 'BOWEL_MOVEMENT') return 'Color';
      if (category == 'VACCINATION') return 'Vaccine Name';
      return '';
    }

    final _showStaff = _isHospitalOrClinic;
    final _showExtra1 = ['HOSPITAL', 'CLINIC', 'INJURY', 'BOWEL_MOVEMENT', 'VACCINATION'].contains(category);
    final _showExtra2 = ['HOSPITAL', 'CLINIC', 'INJURY', 'VACCINATION'].contains(category);
    final _showTime = category == 'BOWEL_MOVEMENT';
    final _showVenue = category == 'VACCINATION';
    final venueCtrl = TextEditingController();

    // Bowel movement consistency chip selection
    String? _stoolType;
    final _stoolTypes = ['Watery (Diarrhea)', 'Loose', 'Mushy', 'Soft & Formed', 'Normal', 'Firm', 'Hard Pellets', 'Constipated'];

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Add ${_categoryLabel(category)}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (_showTitle) ...[
              TextField(controller: titleCtrl, decoration: InputDecoration(labelText: 'Name / Title', hintText: 'e.g. ${category == 'HOSPITAL' ? 'ER Visit' : 'Annual Checkup'}')),
              const SizedBox(height: 12),
            ],
            if (_showStaff) ...[
              TextField(controller: staffCtrl, decoration: const InputDecoration(labelText: 'Attending Staff')),
              const SizedBox(height: 12),
            ],
            if (_showTime) ...[
              TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: 'Time'), readOnly: true,
                onTap: () async {
                  final t = await showTimePicker(context: ctx, initialTime: TimeOfDay.now());
                  if (t != null) setD(() => timeCtrl.text = t.format(ctx));
                }),
              const SizedBox(height: 12),
            ],
            if (_showExtra1) ...[
              TextField(controller: extraCtrl1, decoration: InputDecoration(labelText: _formLabel1())),
              const SizedBox(height: 12),
            ],
            if (_showExtra2) ...[
              TextField(controller: (() { final c = TextEditingController(); return c; })(), decoration: InputDecoration(labelText: category == 'INJURY' ? 'Description' : category == 'VACCINATION' ? 'Location on body' : 'Outcome')),
              const SizedBox(height: 12),
            ],
            if (category == 'BOWEL_MOVEMENT') ...[
              const SizedBox(height: 4),
              Text('Consistency (choose one)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade600)),
              const SizedBox(height: 6),
              Wrap(spacing: 6, runSpacing: 6, children: _stoolTypes.map((t) => ChoiceChip(
                label: Text(t, style: TextStyle(fontSize: 12)),
                selected: _stoolType == t,
                onSelected: (sel) => setD(() => _stoolType = sel ? t : null),
                selectedColor: Colors.brown.shade100,
              )).toList()),
              const SizedBox(height: 12),
            ],
            if (_showVenue) ...[
              TextField(controller: venueCtrl, decoration: const InputDecoration(labelText: 'Venue')),
              const SizedBox(height: 12),
            ],
            TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes (optional)'), maxLines: 2),
            const SizedBox(height: 12),
            ListTile(leading: const Icon(Icons.calendar_today), title: Text(DateFormat.yMMMd().format(selectedDate)),
              onTap: () async { final p = await showDatePicker(context: ctx, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime.now()); if (p != null) setD(() => selectedDate = p); }),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: saving ? null : () async {
                if (titleCtrl.text.isEmpty && category == 'OTHER') return;
                setD(() => saving = true);
                try {
                  final api = ref.read(apiClientProvider);
                  if (_babyMonId == null) return;
                  final data = <String, dynamic>{
                    'category': category,
                    'title': titleCtrl.text.isNotEmpty ? titleCtrl.text : _categoryLabel(category),
                    'notes': notesCtrl.text.isNotEmpty ? notesCtrl.text : null,
                    'happenedAt': selectedDate.toIso8601String(),
                  };
                  final extras = <String>[];
                  if (extraCtrl1.text.isNotEmpty) extras.add('${_formLabel1()}: ${extraCtrl1.text}');
                  if (category == 'BOWEL_MOVEMENT' && _stoolType != null) extras.add('Consistency: $_stoolType');
                  if (_showVenue && venueCtrl.text.isNotEmpty) extras.add('Venue: ${venueCtrl.text}');
                  if (extras.isNotEmpty) {
                    data['notes'] = '${extras.join(' | ')}${notesCtrl.text.isNotEmpty ? '\n${notesCtrl.text}' : ''}';
                  }
                  await api.createHealthRecord(_babyMonId!, data);
                  await _fetchHealthRecords();
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  setD(() => saving = false);
                  if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'),
            ),
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }
}