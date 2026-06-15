import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/core/core.dart';
import 'package:baby_mon/core/data/api_client.dart';
import 'package:baby_mon/features/dashboard/presentation/widgets/level_up_celebration.dart';

enum _TileType { stage, stats, xp, growth, badges, content }

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with WidgetsBindingObserver {
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
  Map<String, dynamic>? _stageContent;
  Map<String, dynamic>? _latestGrowth;
  List<Map<String, dynamic>> _allergies = [];
  bool _isLoading = true;
  bool _showDetails = false;
  bool _isRefreshing = false;
  DateTime? _lastDataRefresh;
  DateTime? _lastBackgroundResume;
  int? _previousLevel;

  // Cache cooldown: skip refetch if data was fetched within this window
  static const _refreshCooldown = Duration(seconds: 10);
  // Background timeout: force refresh if app was in background longer than this
  static const _backgroundTimeout = Duration(minutes: 5);

  // Reorderable tile order — user-configurable via long-press drag, persisted to SharedPreferences
  static const List<_TileType> _defaultTileOrder = [
    _TileType.stage,   // Hero: BabyMon identity + stage
    _TileType.stats,   // Quick stats row (milestones, feedings, health, photos)
    _TileType.xp,      // Progress: XP bar + level
    _TileType.growth,  // Growth chart (if data exists)
    _TileType.badges,  // Achievement clusters
    _TileType.content, // Stage-specific editorial content
  ];

  List<_TileType> _tileOrder = [..._defaultTileOrder];

  Future<void> _loadTileOrder() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final saved = prefs.getString('dashboard_tile_order');
    if (saved != null && saved.isNotEmpty) {
      final parsed = saved.split(',').map((n) {
        return _TileType.values.firstWhere(
          (t) => t.name == n,
          orElse: () => _defaultTileOrder.first,
        );
      }).toList();
      if (parsed.length == _TileType.values.length) {
        _tileOrder = parsed;
      } else if (parsed.isNotEmpty) {
        final deduped = parsed.toSet().toList();
        if (deduped.length == _TileType.values.length) {
          _tileOrder = deduped;
        }
      }
    }
  }

  Future<void> _saveTileOrder() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(
      'dashboard_tile_order',
      _tileOrder.map((t) => t.name).join(','),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
    ref.listenManual(appRefreshProvider, (prev, next) {
      if (prev != next) _loadData(force: true);
    });
    ref.listenManual(tabRefreshProvider(0), (prev, next) {
      if (prev != next) _loadData(); // respects cooldown via non-force
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safety net for hot reload: if we have no BabyMon ID but one is selected, reload
    if (_babyMonId == null && !_isLoading) {
      final api = ref.read(apiClientProvider);
      api.getSelectedBabyMonId().then((id) {
        if (id != null && id.isNotEmpty && mounted) {
          _loadData();
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _lastBackgroundResume = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      final wasInBackground = _lastBackgroundResume != null;
      final goneLong = wasInBackground &&
          DateTime.now().difference(_lastBackgroundResume!) > _backgroundTimeout;
      _loadData(force: goneLong);
    }
  }

  Future<void> _loadData({bool force = false}) async {
    // ── Cache check: skip refetch if data is fresh enough (unless forced) ──
    if (!force && _lastDataRefresh != null && _babyMonId != null) {
      final elapsed = DateTime.now().difference(_lastDataRefresh!);
      if (elapsed < _refreshCooldown) {
        return;
      }
    }

    // ── Show subtle progress indicator for background refreshes ──
    if (!_isLoading && mounted) {
      setState(() => _isRefreshing = true);
    }

    final api = ref.read(apiClientProvider);
    try {
      final id = await api.getSelectedBabyMonId();
      if (id == null) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }
      _babyMonId = id;

      // ── Restore saved tile order ──
      await _loadTileOrder();

      // ── Parallelize all independent fetches (BabyMon, Evolution, Growth, Allergies, Profile) ──
      await Future.wait([
        _fetchBabyMon(api),
        _fetchEvolution(api),
        _fetchGrowth(api),
        _fetchAllergies(api),
        _fetchProfile(api),
      ]);

      // ── Detect level-up ──
      if (mounted && _evolution != null) {
        final newLevel = _currentLevel;
        // Only fire celebration on upward movement, not on first load
        // or when evolution data is stale/failed (newLevel would be 1).
        if (_previousLevel != null && newLevel > _previousLevel!) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showLevelUpCelebration(newLevel);
          });
        }
        _previousLevel = newLevel;
      }

      // ── Render dashboard now with essential data ──
      _lastDataRefresh = DateTime.now();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }

      // ── Fire-and-forget cosmetic data (badges + stage content) ──
      _loadCosmeticData(api);

    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  /// Fires cosmetic data requests in the background after dashboard is rendered.
  Future<void> _loadCosmeticData(ApiClient api) async {
    // Parallelize badge definitions + badges (both independent)
    await Future.wait([
      _fetchBadgeDefinitions(api),
      _fetchBadges(api),
    ]);
    // Stage content depends on _evolution being set, so it runs after
    try {
      final stageKey = parseString(_evolution?['currentStage']) ?? 'BORN';
      final stageRes = await api.getStageContent(stageKey);
      final rawStage = stageRes.data;
      if (mounted) {
        setState(() {
          _stageContent = parseJsonMap(rawStage);
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchBadgeDefinitions(ApiClient api) async {
    try {
      final defRes = await api.getBadgeDefinitions();
      final data = defRes.data;
      if (data is List) {
        _badgeDefinitions = data.whereType<Map<String, dynamic>>().toList();
      } else if (data is Map) {
        _badgeDefinitions = (data.entries)
            .map((e) {
              final def = parseJsonMap(e.value)!;
              def['badgeType'] = e.key;
              if (!def.containsKey('tier')) {
                def['tier'] = _inferTier(parseString(e.key) ?? '');
              }
              return def;
            })
            .toList();
      } else {
        _badgeDefinitions = [];
      }
    } catch (_) {}
  }

  Future<void> _fetchBadges(ApiClient api) async {
    try {
      final badgesRes = await api.getBadges(_babyMonId!);
      _badges = (badgesRes.data is List)
          ? (badgesRes.data as List<dynamic>)
          : parseItems(badgesRes.data);
    } catch (_) {}
  }

  Future<void> _fetchBabyMon(ApiClient api) async {
    try {
      final babyMonRes = await api.getBabyMon(_babyMonId!);
      final rawBabyMon = babyMonRes.data;
      if (rawBabyMon is! Map) throw Exception('Invalid babyMon data');
      final babyMon = parseJsonMap(rawBabyMon)!;
      _babyMonName = parseString(babyMon['name']) ?? 'Baby';
      _babyMonGender = parseString(babyMon['gender']) ?? 'MONIOUS';
      _traits = parseList(babyMon['traits']).whereType<String>().toList();
      _specialMove = parseString(babyMon['specialMove']);
      _stageStartType = parseString(babyMon['stageStartType']);
      _bloodGroup = parseString(babyMon['bloodGroup']);
      _biologicalMother = parseString(babyMon['biologicalMother']);
      _biologicalFather = parseString(babyMon['biologicalFather']);
      final refDateRaw = _stageStartType == 'CONCEIVED'
          ? babyMon['conceptionDate'] ?? babyMon['lmpDate']
          : _stageStartType == 'IDEA'
              ? babyMon['ideaDate']
              : babyMon['birthDate'];
      _referenceDate = refDateRaw is String
          ? DateTime.tryParse(refDateRaw)
          : safeCast<DateTime>(refDateRaw);
    } catch (_) {}
  }

  Future<void> _fetchEvolution(ApiClient api) async {
    try {
      final evolutionRes = await api.getEvolution(_babyMonId!);
      final rawData = evolutionRes.data;
      if (rawData is! Map) throw Exception('Invalid evolution data');
      final evoData = parseJsonMap(rawData)!;
      final evoBabyMon = parseJsonMap(evoData['babyMon']) ?? <String, dynamic>{};
      _evolution = <String, dynamic>{...evoData, ...evoBabyMon};
    } catch (_) {}
  }

  Future<void> _fetchGrowth(ApiClient api) async {
    try {
      final growthRes = await api.getGrowthRecords(_babyMonId!, type: 'WEIGHT');
      final growthList = (growthRes.data is List)
          ? (growthRes.data as List<dynamic>)
          : parseItems(growthRes.data);
      if (growthList.isNotEmpty) {
        _latestGrowth = parseJsonMap(growthList.last);
      }
    } catch (_) {}
  }

  Future<void> _fetchAllergies(ApiClient api) async {
    try {
      final aRes = await api.getAllergies(_babyMonId!);
      final raw = aRes.data;
      _allergies = parseItemsTyped(raw);
    } catch (_) {}
  }

  Future<void> _fetchProfile(ApiClient api) async {
    try {
      final profile = await api.getProfile();
      final profileData = parseJsonMap(profile.data);
      _parentName = parseString(profileData?['name']);
      _parentContact = parseString(profileData?['phone']);
    } catch (_) {}
  }

  String _stageEmoji(String stage, String? gender) {
    switch (stage) {
      case 'BORN':
        return gender == 'MONIESE'
            ? '👶\u200d♀️'
            : gender == 'MONIOUS'
                ? '👶\u200d♂️'
                : '👶';
      case 'CONCEIVED':
        return '🤰';
      case 'IDEA':
        return '💡';
      default:
        return '🌟';
    }
  }

  String get _babyMonAge {
    if (_stageStartType != 'BORN' || _referenceDate == null) return '';
    final diff = DateTime.now().difference(_referenceDate!);
    final y = diff.inDays ~/ 365,
        m = (diff.inDays % 365) ~/ 30,
        d = diff.inDays % 30,
        w = diff.inDays ~/ 7;
    final p = <String>[];
    if (y > 0) p.add('$y yr');
    if (m > 0) p.add('$m mo');
    if (d > 0 || p.isEmpty) p.add('$d d');
    return '${p.join(' ')} ($w wk)';
  }

  String get _etaText {
    if (_stageStartType != 'CONCEIVED' || _referenceDate == null) return '';
    final r =
        _referenceDate!.add(const Duration(days: 280)).difference(DateTime.now());
    return r.inDays <= 0 ? 'Due now!' : 'ETA: ${r.inDays} days';
  }

  String get _stageLabel {
    switch (_stageStartType) {
      case 'CONCEIVED':
        return 'Fetus';
      case 'IDEA':
        return 'Planning';
      case 'BORN':
      default:
        if (_referenceDate == null) return 'Born';
        final d = DateTime.now().difference(_referenceDate!).inDays;
        if (d <= 28) return 'Neonate';
        if (d <= 365) return 'Infant';
        if (d <= 1095) return 'Toddler';
        if (d <= 1825) return 'Preschooler';
        return 'Child';
    }
  }

  Color _genderAccent(String? g) => g == 'MONIESE'
      ? AppColors.genderMonieseAccent
      : g == 'MONIOUS'
          ? AppColors.genderMoniousAccent
          : AppColors.genderNeutralAccent;

  /// XP progress as 0.0–1.0 for the progress bar.
  /// Uses the backend's pre-computed xpProgress when available.
  double get _xpProgress {
    if (_evolution == null) return 0.0;
    // Pre-computed percentage from backend (0-100)
    final progress = _evolution!['xpProgress'];
    if (progress != null) return (progress as num).toDouble() / 100.0;
    // Fallback: compute locally
    final xp = (parseDouble(_evolution!['currentXp']) ?? 0.0);
    final needed = parseDouble(_evolution!['xpForNextLevel']) ?? 50;
    return needed > 0 ? (xp / needed).clamp(0.0, 1.0) : 0.0;
  }

  int get _xpCurrent => parseInt(_evolution?['currentXp']) ?? 0;
  int get _xpForNextLevel {
    // Backend now sends this explicitly
    final numVal = parseDouble(_evolution?['xpForNextLevel']);
    if (numVal != null && numVal > 0) return numVal.round();
    // Legacy fallback for level 1 (50 XP)
    return 50;
  }

  int get _currentLevel => parseInt(_evolution?['currentLevel']) ?? 1;
  String get _levelName => parseString(_evolution?['levelName']) ?? 'Level $_currentLevel';
  String get _nextLevelName => parseString(_evolution?['nextLevelName']) ?? 'Level ${_currentLevel + 1}';

  List<Map<String, dynamic>> get _badgesByCategory {
    if (_badgeDefinitions.isEmpty) return [];
    final u = _badges.map((b) => parseString(b['badgeType']) ?? '').toSet();
    return _badgeDefinitions
        .map((def) => {
              ...def,
              'unlocked': u.contains(parseString(def['badgeType']) ?? ''),
              'category': parseString(def['category']) ?? 'Other',
            })
        .toList();
  }

  Map<String, List<Map<String, dynamic>>> get _groupedBadges {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final b in _badgesByCategory) {
      map.putIfAbsent(parseString(b['category']) ?? '', () => []).add(b);
    }
    return map;
  }

  int _unlockedInCategory(String c) =>
      _groupedBadges[c]?.where((b) => b['unlocked'] == true).length ?? 0;
  int _totalInCategory(String c) => _groupedBadges[c]?.length ?? 0;
  int get _totalUnlocked => _badges.length;
  int get _totalBadges => _badgeDefinitions.length;

  String _inferTier(String b) {
    if (b.contains('10') || b.contains('100') || b.contains('500')) {
      return 'GOLD';
    }
    if (b.contains('5') || b.contains('50')) return 'SILVER';
    return 'BRONZE';
  }

  Color _tierColor(String t) {
    switch (t) {
      case 'DIAMOND':
        return const Color(0xFFB366FF);
      case 'GOLD':
        return const Color(0xFFD4A017);
      case 'SILVER':
        return const Color(0xFF8E8E93);
      default:
        return const Color(0xFFCD7F32);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: PremiumBackground(
        child: _isLoading
            ? _buildLoadingState()
            : _babyMonId == null
                ? _buildWelcomeScreen()
                : RefreshIndicator(
                    onRefresh: () => _loadData(force: true),
                    child: _buildReorderableDashboard(context),
                  ),
      ),
      floatingActionButton: _babyMonId != null
          ? InfoFab(
              tooltip: 'Quick actions',
              icon: PhosphorIconsLight.lightning,
              children: [
                InfoFabAction(
                  tooltip: 'Log Feeding',
                  infoDescription: 'Feeding',
                  backgroundColor: AppColors.warning,
                  onTap: () {},
                  child: const Icon(PhosphorIconsLight.bowlFood, color: AppColors.textOnPrimary),
                ),
                InfoFabAction(
                  tooltip: 'Add Milestone',
                  infoDescription: 'Milestone',
                  backgroundColor: AppColors.accent,
                  onTap: () {},
                  child: const Icon(PhosphorIconsLight.trophy, color: AppColors.textOnPrimary),
                ),
                InfoFabAction(
                  tooltip: 'Health Record',
                  infoDescription: 'Health',
                  backgroundColor: AppColors.success,
                  onTap: () {},
                  child: const Icon(PhosphorIconsLight.heart, color: AppColors.textOnPrimary),
                ),
                InfoFabAction(
                  tooltip: 'Create BabyMon',
                  infoDescription: 'New Baby',
                  backgroundColor: AppColors.secondary,
                  onTap: () => GoRouter.of(context).push('/create-baby-mon'),
                  child: const Icon(PhosphorIconsLight.baby, color: AppColors.textOnPrimary),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildLoadingState() {
    return PremiumLoading.spinner(message: 'Loading your dashboard...');
  }

  Widget _buildWelcomeScreen() {
    return PremiumEmptyState(
      icon: PhosphorIconsLight.baby,
      title: 'Welcome to BabyMon!',
      subtitle:
          'Create your first BabyMon to start tracking milestones, feedings, and more.',
      actionLabel: 'Create BabyMon',
      onAction: () => GoRouter.of(context).push('/create-baby-mon'),
    );
  }

  Widget _buildReorderableDashboard(BuildContext context) {
    final tiles = <_TileType, Widget>{
      _TileType.stage: _buildStageCard(),
      _TileType.stats: _buildQuickStatsRow(),
      _TileType.xp: _buildXpCard(),
      if (_latestGrowth != null) _TileType.growth: _buildGrowthCard(),
      _TileType.badges: _buildBadgeSection(),
      if (_stageContent != null) _TileType.content: _buildStageContentCard(),
    };

    return Column(
      children: [
        // ── Subtle refresh pill for background refetches ──
        AnimatedSize(
          duration: DesignTokens.durationNormal,
          curve: DesignTokens.curvePremium,
          child: _isRefreshing
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(
                    DesignTokens.bentoPadding,
                    DesignTokens.bentoPadding,
                    DesignTokens.bentoPadding,
                    DesignTokens.spaceSm,
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius:
                            BorderRadius.circular(DesignTokens.radiusFull),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          width: 0.5,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Refreshing',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        // ── Reorderable tiles ──
        Expanded(
          child: ReorderableListView(
            padding: const EdgeInsets.only(
              left: DesignTokens.bentoPadding,
              right: DesignTokens.bentoPadding,
              bottom: 100,
            ),
            // ignore: deprecated_member_use – onReorderItem not yet in stable
            onReorder: (int oldIndex, int newIndex) {
              if (newIndex > oldIndex) newIndex--;
              setState(() {
                final tile = _tileOrder.removeAt(oldIndex);
                _tileOrder.insert(newIndex, tile);
              });
              _saveTileOrder();
            },
            proxyDecorator: (child, index, animation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + 0.02 * animation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: animation.value > 0
                            ? [
                                BoxShadow(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.15),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                ),
                              ]
                            : null,
                      ),
                      child: child,
                    ),
                  );
                },
                child: child,
              );
            },
            children: _tileOrder
                .where((t) => tiles.containsKey(t))
                .map((tile) => Padding(
                      key: ValueKey(tile),
                      padding: const EdgeInsets.only(
                          bottom: DesignTokens.bentoGap),
                      child: tiles[tile],
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStageCard() {
    final accent = _genderAccent(_babyMonGender);

    // StageHero is the flat replacement for the old 4-deep
    // PremiumDoubleBezel stack. The details panel renders inside
    // the same card surface (controlled by _showDetails) — one
    // hero card with an expandable body, not two stacked cards.
    return StageHero(
      name: _babyMonName ?? 'Baby',
      stageLabel: _stageLabel,
      emoji: _stageEmoji(_stageStartType ?? 'BORN', _babyMonGender),
      level: _currentLevel,
      accent: accent,
      ageText: _babyMonAge.isNotEmpty ? _babyMonAge : null,
      etaText: _etaText.isNotEmpty ? _etaText : null,
      detailsExpanded: _showDetails,
      onToggleDetails: () => setState(() => _showDetails = !_showDetails),
      onShare: _shareBabyMon,
      onEdit: _editBabyMon,
      child: _buildDetailsPanel(),
    );
  }

  Widget _buildDetailsPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _detailRow(
          'Stage',
          _stageStartType == 'BORN'
              ? 'Born'
              : _stageStartType == 'CONCEIVED'
                  ? 'Expecting'
                  : 'Planning',
        ),
        if (_bloodGroup != null && _bloodGroup!.isNotEmpty)
          _detailRow('Blood Type', _bloodGroup!),
        if (_parentName != null && _parentName!.isNotEmpty)
          _detailRow('Parent', _parentName!),
        if (_biologicalMother != null && _biologicalMother!.isNotEmpty)
          _detailRow('Mother', _biologicalMother!),
        if (_biologicalFather != null && _biologicalFather!.isNotEmpty)
          _detailRow('Father', _biologicalFather!),
        if (_allergies.isNotEmpty)
          _detailRow(
            'Allergies',
            _allergies
                .map((a) =>
                    '${a['name']} (${a['severity'] ?? 'Unknown'})')
                .join(', '),
          ),
        if (_traits != null && _traits!.isNotEmpty)
          _detailRow('Traits', _traits!.join(', ')),
        if (_specialMove != null && _specialMove!.isNotEmpty)
          _detailRow('Special Move', _specialMove!),
        _detailRow(
          'Gender',
          _babyMonGender == 'MONIOUS'
              ? 'Monious (Male)'
              : _babyMonGender == 'MONIESE'
                  ? 'Moniese (Female)'
                  : 'Mo (Neutral)',
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textCaption,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareBabyMon() async {
    final allergyList = _allergies.isNotEmpty
        ? _allergies
            .map((a) =>
                '• ${a['name']} (${a['severity'] ?? 'Unknown'}): ${a['treatment'] ?? 'N/A'}')
            .toList()
        : ['None recorded'];
    final text =
        '🦁 BabyMon Card: ${_babyMonName ?? 'Baby'}\n\nStage: $_stageLabel\nAge: ${_babyMonAge.isNotEmpty ? _babyMonAge : 'N/A'}\nGender: ${_babyMonGender == 'MONIOUS' ? 'Male (Monious)' : _babyMonGender == 'MONIESE' ? 'Female (Moniese)' : 'Neutral (Mo)'}${_bloodGroup != null && _bloodGroup!.isNotEmpty ? '\nBlood Type: $_bloodGroup' : ''}${_parentContact != null && _parentContact!.isNotEmpty ? '\nContact: $_parentContact' : ''}${_biologicalMother != null ? '\nMother: $_biologicalMother' : ''}${_biologicalFather != null ? '\nFather: $_biologicalFather' : ''}\n\nAllergies:\n${allergyList.join('\n')}\n\nTraits: ${(_traits ?? []).join(', ')}${_specialMove != null ? '\nSpecial Move: $_specialMove' : ''}\n\nShared via BabyMon';
    await SharePlus.instance.share(ShareParams(text: text, subject: '${_babyMonName ?? 'BabyMon'} Card'));
  }

  Future<void> _editBabyMon() async {
    if (_babyMonId == null) return;
    final api = ref.read(apiClientProvider);
    final nameCtrl = TextEditingController(text: _babyMonName ?? '');
    final motherCtrl = TextEditingController(text: _biologicalMother ?? '');
    final fatherCtrl = TextEditingController(text: _biologicalFather ?? '');
    final parentCtrl = TextEditingController(text: _parentName ?? '');
    final contactCtrl = TextEditingController(text: _parentContact ?? '');
    final traitsCtrl =
        TextEditingController(text: (_traits ?? []).join(', '));
    final specialMoveCtrl = TextEditingController(text: _specialMove ?? '');
    String? bloodGroup = _bloodGroup;
    String? gender = _babyMonGender;
    if (!mounted) return;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.textPrimary.withValues(alpha: 0.3),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(DesignTokens.radius3xl)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => ClipRRect(
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(DesignTokens.radius3xl)),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(
              sigmaX: DesignTokens.glassBlurMd,
              sigmaY: DesignTokens.glassBlurMd,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.glassDark
                        : AppColors.glassWhite)
                    .withValues(alpha: 0.98),
                border: const Border(
                  top: BorderSide(
                    color: AppColors.glassBorderLight,
                    width: DesignTokens.glassBorderWidth,
                  ),
                ),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom +
                    DesignTokens.spaceLg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Drag handle ──
                  Container(
                    width: 36,
                    height: 4,
                    margin:
                        const EdgeInsets.only(top: 12, bottom: DesignTokens.spaceMd),
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // ── Eyebrow tag header ──
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spaceLg),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(
                                DesignTokens.radiusFull),
                          ),
                          child: Text(
                            'EDIT PROFILE',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                  letterSpacing: 1.5,
                                  fontSize: 11,
                                ),
                          ),
                        ),
                        const SizedBox(width: DesignTokens.spaceSm),
                        Expanded(
                          child: Text(
                            _babyMonName ?? 'BabyMon',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spaceMd),
                  // ── Scrollable content ──
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: DesignTokens.spaceLg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _editField(nameCtrl, 'Name'),
                          const SizedBox(height: DesignTokens.spaceMd),
                          _editTile(ctx, setD, 'Gender',
                              gender == 'MONIOUS'
                                  ? 'Monious'
                                  : gender == 'MONIESE'
                                      ? 'Moniese'
                                      : 'Mo', () async {
                            final result =
                                await WheelPickerBottomSheet.show<String>(
                              context: ctx,
                              title: 'Select Gender',
                              columns: [
                                WheelColumn<String>(
                                  label: 'Gender',
                                  options: const [
                                    WheelOption(
                                        value: 'MONIOUS', label: 'Monious'),
                                    WheelOption(
                                        value: 'MONIESE', label: 'Moniese'),
                                    WheelOption(value: 'MO', label: 'Mo'),
                                  ],
                                  initialValue: gender,
                                ),
                              ],
                            );
                            if (result != null) setD(() => gender = result);
                          }),
                          const SizedBox(height: DesignTokens.spaceMd),
                          _editTile(ctx, setD, 'Blood Type',
                              bloodGroup == null || bloodGroup!.isEmpty
                                  ? 'Not set'
                                  : bloodGroup!,
                              () async {
                            final result =
                                await WheelPickerBottomSheet.show<String>(
                              context: ctx,
                              title: 'Select Blood Type',
                              columns: [
                                WheelColumn<String>(
                                  label: 'Blood Type',
                                  options: const [
                                    WheelOption(value: '', label: 'Not set'),
                                    WheelOption(value: 'A+', label: 'A+'),
                                    WheelOption(value: 'A-', label: 'A-'),
                                    WheelOption(value: 'B+', label: 'B+'),
                                    WheelOption(value: 'B-', label: 'B-'),
                                    WheelOption(
                                        value: 'AB+', label: 'AB+'),
                                    WheelOption(
                                        value: 'AB-', label: 'AB-'),
                                    WheelOption(value: 'O+', label: 'O+'),
                                    WheelOption(value: 'O-', label: 'O-'),
                                  ],
                                  initialValue: bloodGroup ?? '',
                                ),
                              ],
                            );
                            if (result != null) setD(() => bloodGroup = result);
                          }),
                          const SizedBox(height: DesignTokens.spaceMd),
                          _editField(contactCtrl, 'Parent Contact #',
                              keyboardType: TextInputType.phone),
                          const SizedBox(height: DesignTokens.spaceMd),
                          _editField(parentCtrl, 'Parent/Guardian Name'),
                          const SizedBox(height: DesignTokens.spaceMd),
                          _editField(motherCtrl, 'Biological Mother'),
                          const SizedBox(height: DesignTokens.spaceMd),
                          _editField(fatherCtrl, 'Biological Father'),
                          const SizedBox(height: DesignTokens.spaceMd),
                          _editField(traitsCtrl, 'Traits (comma separated)'),
                          const SizedBox(height: DesignTokens.spaceMd),
                          _editField(specialMoveCtrl, 'Special Move'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spaceMd),
                  // ── Save button with button-in-button ──
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spaceLg),
                    child: ThemeButton(
                      text: 'Save Changes',
                      onPressed: () => Navigator.pop(ctx, true),
                      fullWidth: true,
                      icon: PhosphorIconsLight.check,
                      borderRadius: DesignTokens.radiusFull,
                      height: 56,
                      semanticLabel: 'Save profile changes',
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spaceSm),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (result != true) return;
    await api.updateBabyMon(_babyMonId!, {
      'name': nameCtrl.text.trim(),
      'gender': gender,
      'bloodGroup': bloodGroup,
      'biologicalMother': motherCtrl.text.trim(),
      'biologicalFather': fatherCtrl.text.trim(),
      'traits': traitsCtrl.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      'specialMove': specialMoveCtrl.text.trim(),
    });

    final profileData = <String, dynamic>{};
    if (parentCtrl.text.trim().isNotEmpty &&
        parentCtrl.text.trim() != _parentName) {
      profileData['name'] = parentCtrl.text.trim();
    }
    if (contactCtrl.text.trim() != (_parentContact ?? '')) {
      profileData['phone'] = contactCtrl.text.trim();
    }
    if (profileData.isNotEmpty) {
      try {
        await api.patch('/users/me', data: profileData);
        _parentName = parentCtrl.text.trim();
        _parentContact = contactCtrl.text.trim();
      } catch (_) {}
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Updated!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
        ),
      );
      _loadData(force: true);
    }
  }

  Widget _editField(TextEditingController ctrl, String label,
      {TextInputType? keyboardType}) {
    return PremiumDoubleBezel(
      outerRadius: DesignTokens.radiusMd + 2,
      gap: 2.0,
      outerColor: AppColors.border.withValues(alpha: 0.08),
      innerPadding: EdgeInsets.zero,
      showInnerHighlight: false,
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        keyboardType: keyboardType,
      ),
    );
  }

  Widget _editTile(BuildContext ctx, StateSetter setD, String label,
      String value, VoidCallback onTap) {
    return PremiumDoubleBezel(
      outerRadius: DesignTokens.radiusMd + 2,
      gap: 2.0,
      outerColor: AppColors.border.withValues(alpha: 0.08),
      innerPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      showInnerHighlight: false,
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(width: 4),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                ),
                child: Icon(PhosphorIconsLight.caretRight,
                    size: 14, color: AppColors.primary.withValues(alpha: 0.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildXpCard() {
    return PremiumDoubleBezel(
      outerRadius: DesignTokens.radius2xl,
      gap: 5.0,
      outerColor: AppColors.warning.withValues(alpha: 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusSm),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.15),
                        width: 0.5,
                      ),
                    ),
                    child: const Icon(
                      PhosphorIconsLight.sparkle,
                      size: 16,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Experience',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                  ),
                ],
              ),
              // ── XP counter badge with button-in-button ──
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$_xpCurrent',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            fontSize: 13,
                          ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '/ $_xpForNextLevel XP',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.textCaption,
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceLg),
          PremiumProgressBar(
            value: _xpProgress,
            height: 10,
            progressColor: AppColors.secondary,
            showGlow: true,
            isGlass: true,
          ),
          const SizedBox(height: DesignTokens.spaceSm),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$_levelName (Lv $_currentLevel)',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                ),
              ),
              Text(
                'Next: $_nextLevelName',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textCaption,
                      fontSize: 10,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsRow() {
    // Equal-weight 4-up grid using a shared BackdropFilter for performance.
    // Instead of each PremiumStatCard applying its own blur (4 passes),
    // the entire row is wrapped in a single ClipRRect + BackdropFilter
    // and each card renders with isGlass=false (no per-card blur).
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: DesignTokens.glassBlurLight,
          sigmaY: DesignTokens.glassBlurLight,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.glassDark : AppColors.glassLight,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            border: Border.all(
              color: isDark
                  ? AppColors.glassDarkBorderLight
                  : AppColors.glassBorderLight,
              width: 0.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: DesignTokens.spaceXs,
            horizontal: DesignTokens.spaceXs,
          ),
          child: Row(
            children: [
              Expanded(
                child: PremiumStatCard(
                  label: 'Milestones',
                  value: '${_evolution?['milestoneCount'] ?? 0}',
                  icon: PhosphorIconsLight.trophy,
                  iconColor: AppColors.bentoGold,
                  isGlass: false,
                ),
              ),
              const SizedBox(width: DesignTokens.spaceXs),
              Expanded(
                child: PremiumStatCard(
                  label: 'Feedings',
                  value: '${_evolution?['feedLogCount'] ?? 0}',
                  icon: PhosphorIconsLight.bowlFood,
                  iconColor: AppColors.bentoCoral,
                  isGlass: false,
                ),
              ),
              const SizedBox(width: DesignTokens.spaceXs),
              Expanded(
                child: PremiumStatCard(
                  label: 'Health',
                  value: '${_evolution?['healthRecordCount'] ?? 0}',
                  icon: PhosphorIconsLight.heart,
                  iconColor: AppColors.bentoPurple,
                  isGlass: false,
                ),
              ),
              const SizedBox(width: DesignTokens.spaceXs),
              Expanded(
                child: PremiumStatCard(
                  label: 'Sleep',
                  value: '${_evolution?['sleepLogCount'] ?? 0}',
                  icon: PhosphorIconsLight.moon,
                  iconColor: AppColors.bentoBlue,
                  isGlass: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildGrowthCard() {
    final latest = _latestGrowth!;
    final measuredAt = latest['measuredAt'] != null
        ? DateFormat.yMMMd()
            .format(DateTime.parse(parseString(latest['measuredAt'])!))
        : '';
    return PremiumDoubleBezel(
      outerRadius: DesignTokens.radius2xl,
      gap: 5.0,
      outerColor: AppColors.accent.withValues(alpha: 0.06),
      onTap: () => context.push('/growth-chart'),
      child: Row(
        children: [
          // ── Premium icon tray with double-bezel ──
          PremiumDoubleBezel(
            outerRadius: DesignTokens.radiusMd + 4,
            gap: 3.0,
            outerColor: AppColors.accent.withValues(alpha: 0.08),
            innerPadding: EdgeInsets.zero,
            showInnerHighlight: false,
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
            child: const Icon(
              PhosphorIconsLight.scales,
              color: AppColors.accent,
              size: 22,
            ),
            ),
          ),
          const SizedBox(width: DesignTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Latest Weight',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.3,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${latest['value']} ${latest['unit'] ?? 'kg'}',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                ),
                if (measuredAt.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      measuredAt,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(
                            color: AppColors.textCaption,
                            fontSize: 11,
                          ),
                    ),
                  ),
              ],
            ),
          ),
          // ── Button-in-Button chevron ──
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
            ),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
              ),
            child: const Icon(
              PhosphorIconsLight.caretRight,
              color: AppColors.accent,
              size: 16,
            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeSection() {
    if (_badgeDefinitions.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceLg,
          vertical: DesignTokens.spaceMd,
        ),
        decoration: BoxDecoration(
          color: (Theme.of(context).brightness == Brightness.dark
                  ? AppColors.glassDark
                  : AppColors.surface)
              .withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            const Icon(PhosphorIconsLight.trophy,
                color: AppColors.warning, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Badges ($_totalUnlocked unlocked)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Stable category order: known categories first, then anything new.
    const catOrder = [
      'milestones', 'feeding', 'sleep', 'health',
      'growth', 'parenting', 'progression', 'traits',
    ];
    final sorted = <String, List<Map<String, dynamic>>>{};
    for (final c in catOrder) {
      if (_groupedBadges.containsKey(c)) sorted[c] = _groupedBadges[c]!;
    }
    for (final c in _groupedBadges.keys) {
      if (!sorted.containsKey(c)) sorted[c] = _groupedBadges[c]!;
    }

    return PremiumCard(
      isGlass: true,
      padding: EdgeInsets.zero,
      child: Material(
        type: MaterialType.transparency,
        child: ExpansionTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          tilePadding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spaceLg, vertical: DesignTokens.spaceSm),
          childrenPadding: const EdgeInsets.fromLTRB(
              DesignTokens.spaceSm, 0, DesignTokens.spaceSm, DesignTokens.spaceSm),
          initiallyExpanded: false,
          title: Row(
            children: [
              const Icon(PhosphorIconsLight.trophy, size: 18, color: AppColors.warning),
              const SizedBox(width: DesignTokens.spaceSm),
              const Expanded(
                child: Text(
                  'Achievements',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            Text(
              '$_totalUnlocked / $_totalBadges',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.warning,
              ),
            ),
          ],
        ),
        children: [
          for (final entry in sorted.entries)
            _badgeCategoryTile(entry.key, entry.value),
        ],
        ),
      ),
    );
  }

  /// A collapsible category tile — wraps each achievement category in an
  /// [ExpansionTile] that's collapsed by default. Individual badges appear
  /// inside via [_badgeGrid] when the category is expanded.
  Widget _badgeCategoryTile(String cat, List<Map<String, dynamic>> badges) {
    final unlocked = _unlockedInCategory(cat);
    final total = _totalInCategory(cat);
    return Material(
      type: MaterialType.transparency,
      child: ExpansionTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        tilePadding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceSm, vertical: 0),
        childrenPadding: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
        initiallyExpanded: false,
        title: Row(
          children: [
            Icon(_categoryIcon(cat), size: 16, color: AppColors.textSecondary),
            const SizedBox(width: DesignTokens.spaceSm),
            Expanded(
              child: Text(
                '${cat[0].toUpperCase()}${cat.substring(1)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            Text(
              '$unlocked/$total',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textCaption,
              ),
            ),
          ],
        ),
        children: [
          _badgeGrid(badges),
        ],
      ),
    );
  }

  Widget _badgeGrid(List<Map<String, dynamic>> badges) {
    // Unlocked first — the earned badges anchor the top of each row.
    final sorted = [...badges]..sort((a, b) {
        final au = a['unlocked'] == true ? 0 : 1;
        final bu = b['unlocked'] == true ? 0 : 1;
        return au.compareTo(bu);
      });
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceLg),
      child: Wrap(
        spacing: DesignTokens.spaceSm,
        runSpacing: DesignTokens.spaceSm,
        children: sorted.map(_badgeChip).toList(),
      ),
    );
  }

  // _buildCategoryTile was removed when _buildBadgeSection was flattened
  // into a 4×N grid. The new _badgeGrid + _badgeCategoryHeader helpers
  // replace it.

  IconData _categoryIcon(String c) {
    switch (c) {
      case 'milestones':
        return PhosphorIconsLight.trophy;
      case 'feeding':
        return PhosphorIconsLight.bowlFood;
      case 'sleep':
        return PhosphorIconsLight.moon;
      case 'health':
        return PhosphorIconsLight.heart;
      case 'growth':
        return PhosphorIconsLight.scales;
      case 'parenting':
        return PhosphorIconsLight.users;
      case 'progression':
        return PhosphorIconsLight.lightning;
      default:
        return PhosphorIconsLight.trophy;
    }
  }

  Widget _badgeChip(Map<String, dynamic> b) {
    final u = b['unlocked'] == true;
    final n = parseString(b['name']) ?? '';
    final t = parseString(b['tier']) ?? 'BRONZE';
    return Semantics(
      label: n,
      button: true,
      child: GestureDetector(
      onTap: () => _showBadgeDetail(b),
      child: Tooltip(
        message: u ? '$n\n${b['description'] ?? ''}' : '$n (Locked)',
        child: AnimatedContainer(
          duration: DesignTokens.durationFast,
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,              color: u
                  ? _tierColor(t).withValues(alpha: 0.15)
                  : (Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurface : AppColors.surfaceLight),
            border: Border.all(
              color: u ? _tierColor(t) : AppColors.border,
              width: u ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            n.isNotEmpty ? n[0].toUpperCase() : '?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: u ? _tierColor(t) : AppColors.textCaption,
            ),
          ),
        ),
      ),
      ),
    );
  }

  void _showBadgeDetail(Map<String, dynamic> b) {
    final u = b['unlocked'] == true;
    final t = parseString(b['tier']) ?? 'BRONZE';
    final xp = parseInt(b['xpValue']) ?? 10;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        ),
        titlePadding: const EdgeInsets.fromLTRB(
            DesignTokens.spaceMd, DesignTokens.spaceMd,
            DesignTokens.spaceMd, 0),
        title: Row(
          children: [
            Icon(
              u ? PhosphorIconsLight.trophy : PhosphorIconsLight.lock,
              color: u ? _tierColor(t) : AppColors.textCaption,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(                child: Text(
                parseString(b['name']) ?? '',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _tierChip(t),
                const SizedBox(width: 8),
                Text(
                  '$xp XP',
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              parseString(b['description']) ?? '',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            if (!u) ...[
              const SizedBox(height: 16),
              Text(
                'Keep tracking to unlock!',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                      color: AppColors.textCaption,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _tierChip(String t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _tierColor(t).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
      ),
      child: Text(
        t[0] + t.substring(1).toLowerCase(),
        style: TextStyle(                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _tierColor(t),
        ),
      ),
    );
  }

  void _showLevelUpCelebration(int newLevel) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: AppColors.textPrimary.withValues(alpha: 0.3),
      builder: (ctx) => LevelUpCelebration(
        level: newLevel,
        onDismiss: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  Widget _buildStageContentCard() {
    if (_stageContent == null) return const SizedBox.shrink();
    return PremiumCard(
      isGlass: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(PhosphorIconsLight.sparkle,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                parseString(_stageContent!['title']) ?? 'Stage Insights',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          if (_stageContent!['summary'] != null) ...[
            const SizedBox(height: DesignTokens.spaceSm),
            Text(
              parseString(_stageContent!['summary']) ?? '',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
          if (_stageContent!['tips'] != null) ...[
            const SizedBox(height: DesignTokens.spaceSm),
            ...parseList(_stageContent!['tips']).map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                      Expanded(
                        child: Text(
                          tip.toString(),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }


}
