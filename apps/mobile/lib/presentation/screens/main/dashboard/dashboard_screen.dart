import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:baby_mon/data/api_client.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/presentation/screens/main/health/growth_chart_screen.dart';

enum _TileType { stage, stats, xp, growth, badges, content }

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with WidgetsBindingObserver {
  String? _babyMonId;
  String? _babyMonName;
  String? _babyMonGender;
  List<String>? _traits;
  String? _specialMove;
  String? _stageStartType;
  DateTime? _referenceDate;
  String? _bloodGroup;
  String? _biologicalMother;
  String? _biologicalFather;
  String? _parentName;
  String? _parentContact;
  Map<String, dynamic>? _evolution;
  List _badges = [];
  List<Map<String, dynamic>> _badgeDefinitions = [];
  String? _expandedCategory;
  Map<String, dynamic>? _stageContent;
  Map<String, dynamic>? _latestGrowth;
  List<Map<String, dynamic>> _allergies = [];
  bool _isLoading = true;
  bool _showDetails = false;
  bool _loadInProgress = false;

  static const _tileOrderKey = 'dashboard_tile_order';
  List<_TileType> _tileOrder = List<_TileType>.from(_TileType.values);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) { _loadTileOrder(); _loadData(); });
    ref.listenManual(appRefreshProvider, (prev, next) { if (prev != next) _loadData(); });
  }

  @override
  void dispose() { WidgetsBinding.instance.removeObserver(this); super.dispose(); }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) { if (state == AppLifecycleState.resumed) _loadData(); }

  Future<void> _loadTileOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_tileOrderKey);
      if (saved != null && saved.length == _TileType.values.length) {
        final order = saved.map((s) => _TileType.values.firstWhere((t) => t.name == s, orElse: () => _TileType.stage)).toList();
        if (mounted) setState(() => _tileOrder = order);
      }
    } catch (_) {}
  }

  Future<void> _saveTileOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_tileOrderKey, List<String>.from(_tileOrder.map((t) => t.name)));
    } catch (_) {}
  }

  Future<void> _loadData() async {
    if (_loadInProgress) {
      setState(() => _isLoading = false);
      return;
    }
    _loadInProgress = true;
    _expandedCategory = null; // reset accordion on data refresh
    final api = ref.read(apiClientProvider);
    try {
      final id = await api.getSelectedBabyMonId();
      if (id == null) { if (mounted) setState(() => _isLoading = false); return; }
      try {
        final defRes = await api.getBadgeDefinitions();
        final data = defRes.data;
        if (data is List) { _badgeDefinitions = data.cast<Map<String, dynamic>>(); }
        else if (data is Map) { _badgeDefinitions = (data.entries).map((e) { final def = Map<String, dynamic>.from(e.value as Map); def['badgeType'] = e.key; if (!def.containsKey('tier')) def['tier'] = _inferTier(e.key as String); return def; }).toList(); }
        else { _badgeDefinitions = []; }
      } catch (_) {}
      final babyMonRes = await api.getBabyMon(id);
      final babyMon = babyMonRes.data as Map<String, dynamic>;
      _babyMonName = babyMon['name'] as String? ?? 'Baby';
      _babyMonGender = babyMon['gender'] as String? ?? 'MONIOUS';
      _traits = (babyMon['traits'] as List?)?.cast<String>() ?? [];
      _specialMove = babyMon['specialMove'] as String?;
      _stageStartType = babyMon['stageStartType'] as String?;
      _bloodGroup = babyMon['bloodGroup'] as String?;
      _biologicalMother = babyMon['biologicalMother'] as String?;
      _biologicalFather = babyMon['biologicalFather'] as String?;
      try { final profile = await api.getProfile(); _parentName = (profile.data as Map)['name'] as String?; _parentContact = (profile.data as Map)['phone'] as String?; } catch (_) {}
      final refDateRaw = _stageStartType == 'CONCEIVED' ? babyMon['conceptionDate'] ?? babyMon['lmpDate'] : _stageStartType == 'IDEA' ? babyMon['ideaDate'] : babyMon['birthDate'];
      _referenceDate = refDateRaw is String ? DateTime.tryParse(refDateRaw) : (refDateRaw as DateTime?);
      _babyMonId = id;
      await _fetchDashboardData();
    } catch (_) {
      await api.setSelectedBabyMonId('');
      if (mounted) { setState(() { _babyMonId = null; _isLoading = false; }); }
    } finally { _loadInProgress = false; }
  }

  Future<void> _fetchDashboardData() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final api = ref.read(apiClientProvider);
      final evolutionRes = await api.getEvolution(_babyMonId!);
      final badgesRes = await api.getBadges(_babyMonId!);
      final evoData = evolutionRes.data as Map<String, dynamic>;
      final evoBabyMon = (evoData['babyMon'] as Map<String, dynamic>?) ?? {};
      final evolution = <String, dynamic>{...evoData, ...evoBabyMon};
      final stageKey = evolution['currentStage'] ?? 'BORN';
      Map<String, dynamic>? stageContent;
      try { final stageRes = await api.getStageContent(stageKey); stageContent = stageRes.data as Map<String, dynamic>?; } catch (_) {}
      Map<String, dynamic>? latestGrowth;
      try { final growthRes = await api.getGrowthRecords(_babyMonId!, type: 'WEIGHT'); final growthList = (growthRes.data is List) ? growthRes.data : ((growthRes.data as Map)['items'] as List?) ?? []; if (growthList.isNotEmpty) latestGrowth = Map<String, dynamic>.from(growthList.last as Map); } catch (_) {}
      List<Map<String, dynamic>> allergies = [];
      try { final aRes = await api.getAllergies(_babyMonId!); final raw = aRes.data; allergies = (raw is List) ? raw.cast<Map<String, dynamic>>() : (raw is Map ? ((raw['items'] as List?)?.cast<Map<String, dynamic>>() ?? []) : []); } catch (_) {}
      if (mounted) setState(() { _evolution = evolution; _badges = (badgesRes.data is List) ? badgesRes.data : ((badgesRes.data as Map)['items'] as List?) ?? []; _stageContent = stageContent; _latestGrowth = latestGrowth; _allergies = allergies; _isLoading = false; });
    } catch (e) { if (mounted) setState(() => _isLoading = false); }
  }

  String _stageEmoji(String stage, String? gender) {
    switch (stage) { case 'BORN': return gender == 'MONIESE' ? '👶‍♀️' : gender == 'MONIOUS' ? '👶‍♂️' : '👶'; case 'CONCEIVED': return '🤰'; case 'IDEA': return '💡'; default: return '🌟'; }
  }

  String get _babyMonAge {
    if (_stageStartType != 'BORN' || _referenceDate == null) return '';
    final diff = DateTime.now().difference(_referenceDate!);
    final y = diff.inDays ~/ 365, m = (diff.inDays % 365) ~/ 30, d = diff.inDays % 30, w = diff.inDays ~/ 7;
    final p = <String>[]; if (y > 0) p.add('$y yr'); if (m > 0) p.add('$m mo'); if (d > 0 || p.isEmpty) p.add('$d d');
    return '${p.join(' ')} ($w wk)';
  }

  String get _etaText {
    if (_stageStartType != 'CONCEIVED' || _referenceDate == null) return '';
    final r = _referenceDate!.add(const Duration(days: 280)).difference(DateTime.now());
    return r.inDays <= 0 ? 'Due now!' : 'ETA: ${r.inDays} days';
  }

  String get _stageLabel {
    switch (_stageStartType) { case 'CONCEIVED': return 'Fetus'; case 'IDEA': return 'Planning'; case 'BORN': default: if (_referenceDate == null) return 'Born'; final d = DateTime.now().difference(_referenceDate!).inDays; if (d <= 28) return 'Neonate'; if (d <= 365) return 'Infant'; if (d <= 1095) return 'Toddler'; if (d <= 1825) return 'Preschooler'; return 'Child'; }
  }

  Color _genderColor(String? g) => g == 'MONIESE' ? Colors.pink.shade50 : g == 'MONIOUS' ? Colors.lightBlue.shade50 : Colors.purple.shade50;
  Color _genderAccent(String? g) => g == 'MONIESE' ? Colors.pink.shade200 : g == 'MONIOUS' ? Colors.lightBlue.shade200 : Colors.purple.shade200;
  double get _xpProgress => _evolution != null ? ((_evolution!['currentXp'] ?? 0) as num).toDouble() / 100.0 : 0;

  List<Map<String, dynamic>> get _badgesByCategory {
    if (_badgeDefinitions.isEmpty) return [];
    final u = _badges.map((b) => b['badgeType'] as String? ?? '').toSet();
    return _badgeDefinitions.map((def) => {...def, 'unlocked': u.contains(def['badgeType'] as String? ?? ''), 'category': def['category'] as String? ?? 'Other'}).toList();
  }

  Map<String, List<Map<String, dynamic>>> get _groupedBadges {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final b in _badgesByCategory) { map.putIfAbsent(b['category'] as String, () => []).add(b); }
    return map;
  }

  int _unlockedInCategory(String c) => _groupedBadges[c]?.where((b) => b['unlocked'] == true).length ?? 0;
  int _totalInCategory(String c) => _groupedBadges[c]?.length ?? 0;
  String _inferTier(String b) { if (b.contains('10') || b.contains('100') || b.contains('500')) return 'GOLD'; if (b.contains('5') || b.contains('50')) return 'SILVER'; return 'BRONZE'; }
  Color _tierColor(String t) { switch (t) { case 'DIAMOND': return Colors.purpleAccent; case 'GOLD': return Colors.amber.shade700; case 'SILVER': return Colors.indigo; default: return Colors.brown.shade400; } }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : _babyMonId == null ? _buildWelcomeScreen(context) : RefreshIndicator(onRefresh: _fetchDashboardData, child: _buildReorderableDashboard(context)),
      floatingActionButton: Column(mainAxisSize: MainAxisSize.min, children: [FloatingActionButton(heroTag: 'dashboard_fab', onPressed: () => _showQuickActions(), child: const Icon(Icons.flash_on))]),
    );
  }

  Widget _buildWelcomeScreen(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.child_care, size: 80, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 24),
    Text('Welcome to BabyMon!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
    const SizedBox(height: 8), const Text('Create your first BabyMon to start tracking milestones, feedings, and more.', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center), const SizedBox(height: 32),
    ElevatedButton.icon(onPressed: () => GoRouter.of(context).go('/create-baby-mon'), icon: const Icon(Icons.add_circle_outline), label: const Text('Create BabyMon'), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16))),
  ])));

  Widget _buildReorderableDashboard(BuildContext context) {
    final tiles = <_TileType, Widget>{
      _TileType.stage: _buildStageCard(context), _TileType.stats: _buildQuickStatsRow(), _TileType.xp: _buildXpCard(context),
      if (_latestGrowth != null) _TileType.growth: _buildGrowthCard(context),
      _TileType.badges: _buildBadgeSection(context),
      if (_stageContent != null) _TileType.content: _buildStageContentCard(context),
    };
    return ReorderableListView(
      padding: const EdgeInsets.all(12), proxyDecorator: (c, i, a) => Material(elevation: 4, borderRadius: BorderRadius.circular(12), child: c),
      onReorder: (o, n) { setState(() { if (n > o) n--; final item = _tileOrder.removeAt(o); _tileOrder.insert(n, item); }); _saveTileOrder(); },
      buildDefaultDragHandles: false,
      children: _tileOrder.where((t) => tiles.containsKey(t)).toList().asMap().entries.map((e) => ReorderableDragStartListener(key: ValueKey(e.value.name), index: e.key, child: Padding(padding: const EdgeInsets.only(bottom: 8), child: tiles[e.value]!))).toList(),
    );
  }

  Widget _buildStageCard(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _showDetails = !_showDetails),
      child: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [_genderAccent(_babyMonGender).withOpacity(0.5), _genderColor(_babyMonGender)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(children: [
          Row(children: [
            Text(_stageEmoji(_stageStartType ?? 'BORN', _babyMonGender), style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_babyMonName ?? 'Baby', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: Colors.black87, shadows: [Shadow(color: Colors.white.withOpacity(0.6), blurRadius: 4)])),
              const SizedBox(height: 1),
              Text(_stageLabel, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary, shadows: [Shadow(color: Colors.white.withOpacity(0.6), blurRadius: 3)])),
              if (_babyMonAge.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 1), child: Text(_babyMonAge, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54, shadows: [Shadow(color: Colors.white70, blurRadius: 2)]))),
              if (_etaText.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 1), child: Text(_etaText, style: TextStyle(fontSize: 11, color: Colors.orange.shade800, fontWeight: FontWeight.w800, shadows: [Shadow(color: Colors.white.withOpacity(0.5), blurRadius: 3)]))),
            ])),
            Column(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(16)), child: Text('Lv ${_evolution?['currentLevel'] ?? 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12))),
              const SizedBox(height: 4),
              Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: Icon(Icons.share, size: 16, color: Colors.grey.shade700), onPressed: _shareBabyMon, tooltip: 'Share', constraints: const BoxConstraints(minWidth: 24, minHeight: 24), padding: EdgeInsets.zero),
                IconButton(icon: Icon(Icons.edit, size: 16, color: Colors.grey.shade700), onPressed: _editBabyMon, tooltip: 'Edit', constraints: const BoxConstraints(minWidth: 24, minHeight: 24), padding: EdgeInsets.zero),
              ]),
            ]),
          ]),
          Padding(padding: const EdgeInsets.only(top: 4), child: Text(_showDetails ? '▲' : '▼', style: const TextStyle(fontSize: 10, color: Colors.black38))),
          if (_showDetails) ...[const Divider(height: 12),
            _detailRow('Stage', _stageStartType == 'BORN' ? 'Born' : _stageStartType == 'CONCEIVED' ? 'Expecting' : 'Planning'),
            if (_bloodGroup != null && _bloodGroup!.isNotEmpty) _detailRow('Blood Type', _bloodGroup!),
            if (_parentName != null && _parentName!.isNotEmpty) _detailRow('Parent', _parentName!),
            if (_biologicalMother != null && _biologicalMother!.isNotEmpty) _detailRow('Mother', _biologicalMother!),
            if (_biologicalFather != null && _biologicalFather!.isNotEmpty) _detailRow('Father', _biologicalFather!),
            if (_allergies.isNotEmpty) _detailRow('Allergies', _allergies.map((a) => '${a['name']} (${a['severity'] ?? 'Unknown'})').join(', ')),
            if (_traits != null && _traits!.isNotEmpty) _detailRow('Traits', _traits!.join(', ')),
            if (_specialMove != null && _specialMove!.isNotEmpty) _detailRow('Special Move', _specialMove!),
            _detailRow('Gender', _babyMonGender == 'MONIOUS' ? 'Monious (Male)' : _babyMonGender == 'MONIESE' ? 'Moniese (Female)' : 'Mo (Neutral)'),
          ],
        ]),
      ),
    );
  }

  Future<void> _shareBabyMon() async {
    final allergyList = _allergies.isNotEmpty ? _allergies.map((a) => '• ${a['name']} (${a['severity'] ?? 'Unknown'}): ${a['treatment'] ?? 'N/A'}').toList() : ['None recorded'];
    final text = '🦁 BabyMon Card: ${_babyMonName ?? 'Baby'}\n\nStage: $_stageLabel\nAge: ${_babyMonAge.isNotEmpty ? _babyMonAge : 'N/A'}\nGender: ${_babyMonGender == 'MONIOUS' ? 'Male (Monious)' : _babyMonGender == 'MONIESE' ? 'Female (Moniese)' : 'Neutral (Mo)'}${_bloodGroup != null && _bloodGroup!.isNotEmpty ? '\nBlood Type: $_bloodGroup' : ''}${_parentContact != null && _parentContact!.isNotEmpty ? '\nContact: $_parentContact' : ''}${_biologicalMother != null ? '\nMother: $_biologicalMother' : ''}${_biologicalFather != null ? '\nFather: $_biologicalFather' : ''}\n\nAllergies:\n${allergyList.join('\n')}\n\nTraits: ${(_traits ?? []).join(', ')}${_specialMove != null ? '\nSpecial Move: $_specialMove' : ''}\n\nShared via BabyMon';
    await Share.share(text, subject: '${_babyMonName ?? 'BabyMon'} Card');
  }

  Future<void> _editBabyMon() async {
    if (_babyMonId == null) return;
    final api = ref.read(apiClientProvider);
    final nameCtrl = TextEditingController(text: _babyMonName ?? '');
    final motherCtrl = TextEditingController(text: _biologicalMother ?? '');
    final fatherCtrl = TextEditingController(text: _biologicalFather ?? '');
    final parentCtrl = TextEditingController(text: _parentName ?? '');
    final contactCtrl = TextEditingController(text: _parentContact ?? '');
    final traitsCtrl = TextEditingController(text: (_traits ?? []).join(', '));
    final specialMoveCtrl = TextEditingController(text: _specialMove ?? '');
    String? bloodGroup = _bloodGroup;
    String? gender = _babyMonGender;
    if (!mounted) return;
    final result = await showDialog<bool>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setD) => AlertDialog(
      title: const Text('Edit BabyMon'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')), const SizedBox(height: 12),
        DropdownButtonFormField<String>(value: gender, items: const [DropdownMenuItem(value: 'MONIOUS', child: Text('Monious (Male)')), DropdownMenuItem(value: 'MONIESE', child: Text('Moniese (Female)')), DropdownMenuItem(value: 'MO', child: Text('Mo (Neutral)')),], onChanged: (v) => setD(() => gender = v), decoration: const InputDecoration(labelText: 'Gender')),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: bloodGroup,
          items: const [
            DropdownMenuItem(value: null, child: Text('Not set')),
            DropdownMenuItem(value: 'A+', child: Text('A+')),
            DropdownMenuItem(value: 'A-', child: Text('A-')),
            DropdownMenuItem(value: 'B+', child: Text('B+')),
            DropdownMenuItem(value: 'B-', child: Text('B-')),
            DropdownMenuItem(value: 'AB+', child: Text('AB+')),
            DropdownMenuItem(value: 'AB-', child: Text('AB-')),
            DropdownMenuItem(value: 'O+', child: Text('O+')),
            DropdownMenuItem(value: 'O-', child: Text('O-')),
          ],
          onChanged: (v) => setD(() => bloodGroup = v),
          decoration: const InputDecoration(labelText: 'Blood Type'),
        ),
        const SizedBox(height: 12), TextField(controller: contactCtrl, decoration: const InputDecoration(labelText: 'Parent Contact #'), keyboardType: TextInputType.phone),
        const SizedBox(height: 12), TextField(controller: parentCtrl, decoration: const InputDecoration(labelText: 'Parent/Guardian Name')),
        const SizedBox(height: 12), TextField(controller: motherCtrl, decoration: const InputDecoration(labelText: 'Biological Mother')),
        const SizedBox(height: 12), TextField(controller: fatherCtrl, decoration: const InputDecoration(labelText: 'Biological Father')),
        const SizedBox(height: 12), TextField(controller: traitsCtrl, decoration: const InputDecoration(labelText: 'Traits (comma separated)')),
        const SizedBox(height: 12), TextField(controller: specialMoveCtrl, decoration: const InputDecoration(labelText: 'Special Move')),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save'))],
    )));
    if (result != true) return;
    await api.updateBabyMon(_babyMonId!, {'name': nameCtrl.text.trim(), 'gender': gender, 'bloodGroup': bloodGroup, 'biologicalMother': motherCtrl.text.trim(), 'biologicalFather': fatherCtrl.text.trim(), 'traits': traitsCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(), 'specialMove': specialMoveCtrl.text.trim()});
    // Also update user profile if parent name or contact changed
    final profileData = <String, dynamic>{};
    if (parentCtrl.text.trim().isNotEmpty && parentCtrl.text.trim() != _parentName) {
      profileData['name'] = parentCtrl.text.trim();
    }
    if (contactCtrl.text.trim() != (_parentContact ?? '')) {
      profileData['phone'] = contactCtrl.text.trim();
    }
    if (profileData.isNotEmpty) {
      try { await api.patch('/users/me', data: profileData); _parentName = parentCtrl.text.trim(); _parentContact = contactCtrl.text.trim(); } catch (_) {}
    }
    if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated!'))); _loadData(); }
  }

  Widget _buildXpCard(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [Icon(Icons.bolt, size: 16, color: Colors.amber.shade700), const SizedBox(width: 4), Text('XP', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700))]), Text('${_evolution?['currentXp'] ?? 0} / 100', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade600))]),
    const SizedBox(height: 6), ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(value: _xpProgress, minHeight: 6, backgroundColor: Colors.grey.shade200)),
  ]));

  Widget _buildQuickStatsRow() => Row(children: [
    _statCard('🏅', 'Milestones', '${_evolution?['milestoneCount'] ?? 0}'), _statCard('🍼', 'Feedings', '${_evolution?['feedLogCount'] ?? 0}'),
    _statCard('💉', 'Health', '${_evolution?['healthRecordCount'] ?? 0}'), _statCard('💤', 'Sleep', '${_evolution?['sleepLogCount'] ?? 0}'),
  ].asMap().entries.map((e) => Expanded(child: Padding(padding: EdgeInsets.only(right: e.key < 3 ? 6 : 0), child: e.value))).toList());

  Widget _statCard(String emoji, String label, String count) => Container(padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)), child: Column(children: [
    Text(emoji, style: const TextStyle(fontSize: 18)), const SizedBox(height: 2), Text(count, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)), Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
  ]));

  Widget _buildGrowthCard(BuildContext context) => InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GrowthChartScreen())), borderRadius: BorderRadius.circular(10), child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)), child: Row(children: [
    CircleAvatar(radius: 18, backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1), child: Icon(Icons.monitor_weight, size: 18, color: Theme.of(context).colorScheme.primary)),
    const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Latest Weight', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)), Text('${_latestGrowth!['value']} ${_latestGrowth!['unit'] ?? 'kg'}', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
      Text(DateFormat.yMMMd().format(DateTime.parse(_latestGrowth!['measuredAt'])), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey.shade500)),
    ])), Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade400),
  ])));

  Widget _buildBadgeSection(BuildContext context) {
    if (_badgeDefinitions.isEmpty) return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)), child: Row(children: [Icon(Icons.emoji_events, size: 18, color: Colors.amber.shade600), const SizedBox(width: 8), Expanded(child: Text('Badges (${_badges.length} unlocked)', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)))]));
    final totalUnlocked = _badges.length;
    // Sort categories: milestones, feeding, sleep, health, growth, parenting, progression, traits
    final catOrder = ['milestones', 'feeding', 'sleep', 'health', 'growth', 'parenting', 'progression', 'traits'];
    final sorted = <String, List<Map<String, dynamic>>>{};
    for (final c in catOrder) { if (_groupedBadges.containsKey(c)) sorted[c] = _groupedBadges[c]!; }
    for (final c in _groupedBadges.keys) { if (!sorted.containsKey(c)) sorted[c] = _groupedBadges[c]!; }
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
      child: ExpansionTile(
        dense: true, visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        initiallyExpanded: false,
        onExpansionChanged: (expanded) {
          if (!expanded) setState(() => _expandedCategory = null);
        },
        leading: Icon(Icons.emoji_events, color: Colors.amber.shade600, size: 18),
        title: Row(children: [
          Expanded(child: Text('Badges', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800))),
          Text('$totalUnlocked/${_badgeDefinitions.length}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: totalUnlocked > 0 ? Colors.amber.shade700 : Colors.grey.shade500)),
        ]),
        children: sorted.entries.map((e) => _buildCategoryTile(context, e.key, e.value, _unlockedInCategory(e.key), _totalInCategory(e.key))).toList(),
      ),
    );
  }

  String _categoryEmoji(String c) { switch (c) { case 'milestones': return '🏅'; case 'feeding': return '🍼'; case 'sleep': return '💤'; case 'health': return '💉'; case 'growth': return '📏'; case 'parenting': return '👨‍👩‍👧'; case 'progression': return '⚡'; default: return '🏆'; } }

  Widget _buildCategoryTile(BuildContext ctx, String cat, List<Map<String, dynamic>> badges, int unlocked, int total) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
      child: ExpansionTile(
        dense: true, visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        initiallyExpanded: false,
        onExpansionChanged: (expanded) => setState(() => _expandedCategory = expanded ? cat : null),
        leading: Text(_categoryEmoji(cat), style: const TextStyle(fontSize: 16)),
        title: Text('${cat[0].toUpperCase()}${cat.substring(1)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        trailing: Text('$unlocked/$total', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: unlocked > 0 ? Colors.amber.shade700 : Colors.grey.shade500)),
        children: [Padding(padding: const EdgeInsets.fromLTRB(12, 0, 12, 10), child: Wrap(spacing: 6, runSpacing: 6, children: [...badges.where((b) => b['unlocked'] == true).map((b) => _badgeChip(b)), ..._buildLockedBatch(badges)]))],
      ),
    );
  }

  List<Widget> _buildLockedBatch(List<Map<String, dynamic>> badges) { final l = badges.where((b) => b['unlocked'] != true).toList(); if (l.isEmpty) return []; return l.map((b) => _badgeChip(b)).toList(); }

  Widget _badgeChip(Map<String, dynamic> b) {
    final u = b['unlocked'] == true; final n = b['name'] as String? ?? ''; final t = b['tier'] as String? ?? 'BRONZE';
    return GestureDetector(onTap: () => _showBadgeDetail(b), child: Tooltip(message: u ? '$n\n${b['description'] ?? ''}' : '$n (Locked)', child: Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, color: u ? _tierColor(t).withOpacity(0.1) : Colors.grey.shade100, border: Border.all(color: u ? _tierColor(t) : Colors.grey.shade300, width: u ? 2 : 1)), alignment: Alignment.center, child: Text(n.isNotEmpty ? n[0].toUpperCase() : '?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: u ? _tierColor(t) : Colors.grey.shade400)))));
  }

  void _showBadgeDetail(Map<String, dynamic> b) {
    final u = b['unlocked'] == true; final t = b['tier'] as String? ?? 'BRONZE'; final xp = b['xpValue'] as int? ?? 10;
    showDialog(context: context, builder: (ctx) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), title: Row(children: [Icon(u ? Icons.emoji_events : Icons.lock_outline, color: u ? _tierColor(t) : Colors.grey, size: 28), const SizedBox(width: 12), Expanded(child: Text(b['name'] ?? '', style: const TextStyle(fontSize: 18)))]), content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [_tierChip(t), const SizedBox(width: 8), Text('$xp XP', style: TextStyle(color: Colors.amber.shade800, fontWeight: FontWeight.bold))]), const SizedBox(height: 12), Text(b['description'] ?? '', style: const TextStyle(fontSize: 14)), if (!u) ...[const SizedBox(height: 16), Text('Keep tracking to unlock!', style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontStyle: FontStyle.italic))]]), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))]));
  }

  Widget _tierChip(String t) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: _tierColor(t).withOpacity(0.15), borderRadius: BorderRadius.circular(8)), child: Text(t[0] + t.substring(1).toLowerCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _tierColor(t))));

  Widget _buildStageContentCard(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3), borderRadius: BorderRadius.circular(10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [const Icon(Icons.auto_awesome, size: 18), const SizedBox(width: 6), Text(_stageContent!['title'] ?? 'Stage Content', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700))]),
    if (_stageContent!['summary'] != null) ...[const SizedBox(height: 6), Text(_stageContent!['summary']!, style: const TextStyle(fontSize: 13))],
    if (_stageContent!['tips'] != null) ...[const SizedBox(height: 8), ...(_stageContent!['tips'] as List).map((tip) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('• ', style: TextStyle(fontWeight: FontWeight.w800)), Expanded(child: Text(tip.toString(), style: const TextStyle(fontSize: 13)))])))],
  ]));

  Widget _detailRow(String label, String value) => Padding(padding: const EdgeInsets.only(bottom: 2), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 70, child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey.shade700))), Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)))]));

  void _showQuickActions() => showModalBottomSheet(context: context, builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Padding(padding: EdgeInsets.all(16), child: Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
    ListTile(leading: const Icon(Icons.restaurant, color: Colors.orange), title: const Text('Log Feeding'), onTap: () => Navigator.pop(ctx)),
    ListTile(leading: const Icon(Icons.star, color: Colors.amber), title: const Text('Add Milestone'), onTap: () => Navigator.pop(ctx)),
    ListTile(leading: const Icon(Icons.medical_services, color: Colors.green), title: const Text('Add Health Record'), onTap: () => Navigator.pop(ctx)),
    const SizedBox(height: 16),
  ])));
}