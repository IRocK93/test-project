import 'dart:ui' as ui;
import 'package:flutter/material.dart';
// ignore_for_file: unused_element
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/core/core.dart';
import 'package:baby_mon/core/data/api_client.dart';
import 'package:baby_mon/core/widgets/responsive_wrapper.dart';
import 'package:baby_mon/features/dashboard/domain/entities/baby_mon.dart';
import 'package:baby_mon/features/health/domain/entities/growth_record.dart';
import 'package:baby_mon/features/health/domain/entities/allergy.dart';
import 'package:baby_mon/features/dashboard/presentation/widgets/dashboard_stats_row.dart';
import 'package:baby_mon/features/dashboard/presentation/widgets/dashboard_xp_card.dart';
import 'package:baby_mon/features/dashboard/presentation/widgets/dashboard_badge_section.dart';
import 'package:baby_mon/features/dashboard/presentation/widgets/dashboard_content_card.dart';
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
  BabyMon? _babyMon;
  String? _parentName;
  String? _parentContact;
  bool _customTraitDialogOpen = false;
  Map<String, dynamic>? _evolution;
  List _badges = [];
  List<Map<String, dynamic>> _badgeDefinitions = [];
  List<Allergy> _allergies = [];
  Map<String, dynamic>? _stageContent;
  GrowthRecord? _latestGrowth;
  GrowthRecord? _latestHeight;
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
      if (prev != next) _loadData(force: true);
    });
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safety net for hot reload: if we have no BabyMon ID but one is selected, reload
    if ((_babyMonId == null || _babyMonId!.isEmpty) && !_isLoading) {
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
      // ── Aggregated dashboard fetch (1 request instead of 8+) ──
      await _fetchDashboardAggregated(api, forceRefresh: force);
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
	    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }
  /// Fetches ALL dashboard data in a single API call (replaces 8+ individual requests).
  Future<void> _fetchDashboardAggregated(ApiClient api, {bool forceRefresh = false}) async {
    try {
      final res = await api.getDashboard(_babyMonId!);
      final data = parseJsonMap(res.data);
      if (data == null) throw Exception('Invalid dashboard data');

      // BabyMon
      final bm = parseJsonMap(data['babyMon']);
      if (bm != null) _babyMon = BabyMon.fromJson(bm);

	      // Evolution
	      final evo = parseJsonMap(data['evolution']);
	      if (evo != null) {
	        final evoBm = parseJsonMap(data['babyMon']) ?? <String, dynamic>{};
	        final counts = parseJsonMap(evoBm['_count']);
	        _evolution = <String, dynamic>{
	          ...evo,
	          ...evoBm,
	          // Remap _count fields to flat keys the stats row expects
	          if (counts != null) ...{
	            'milestoneCount': parseInt(counts['milestones']) ?? 0,
	            'feedLogCount': parseInt(counts['feedLogs']) ?? 0,
	            'healthRecordCount': parseInt(counts['healthRecords']) ?? 0,
	            'sleepLogCount': parseInt(counts['sleepLogs']) ?? 0,
	          },
	        };
	      }

      // Growth
      final growth = parseJsonMap(data['growth']);
      if (growth != null) {
        final w = parseJsonMap(growth['weight']);
        if (w != null) _latestGrowth = GrowthRecord.fromJson(w);
        final h = parseJsonMap(growth['height']);
        if (h != null) _latestHeight = GrowthRecord.fromJson(h);
      }

      // Allergies
      final allergiesRaw = data['allergies'];
      if (allergiesRaw is List) {
        _allergies = allergiesRaw.map((a) => Allergy.fromJson(parseJsonMap(a) ?? {})).toList();
      }

      // Badges
      final badgesRaw = data['badges'];
      if (badgesRaw is List) {
        _badges = badgesRaw;
      }

      // Badge definitions
      final defsRaw = data['badgeDefinitions'];
      if (defsRaw is Map) {
        _badgeDefinitions = (defsRaw as Map<String, dynamic>).entries.map((e) {
          final def = parseJsonMap(e.value)!;
          def['badgeType'] = e.key;
          return def;
        }).toList();
      }

      // Stage content from aggregation (may have different field names than widget expects)
      final stage = parseJsonMap(data['stageContent']);
      if (stage != null) _stageContent = stage;

      // Always refresh cosmetics from dedicated endpoints (correct field names + iconPath)
      _loadCosmeticData(api);
    } catch (e) {
      debugPrint('Dashboard aggregated fetch failed, falling back: $e');
      // Fall back to individual fetches
      await Future.wait([
        _fetchBabyMon(api),
        _fetchEvolution(api, forceRefresh: forceRefresh),
        _fetchGrowth(api),
        _fetchAllergies(api),
      ]);
      _loadCosmeticData(api);
    }
    // Always fetch profile separately (user-level data)
    await _fetchProfile(api);
  }

  /// Fires cosmetic data requests in the background after dashboard is rendered.
  @Deprecated('Use _fetchDashboardAggregated instead')
  Future<void> _loadCosmeticData(ApiClient api) async {
    // Parallelize badge definitions + badges (both independent)
    await Future.wait([
      _fetchBadgeDefinitions(api),
      _fetchBadges(api),
    ]);
    // Stage content depends on _evolution being set, so it runs after.
    // Uses the BabyMon-specific endpoint which personalises {name} placeholders.
    try {
      final stageRes = await api.getStageContentForBabyMon(_babyMonId!);
      final rawStage = stageRes.data;
      if (mounted) {
        setState(() {
          _stageContent = parseJsonMap(rawStage);
        });
      }
    } catch (e) { debugPrint('Failed to load stage content: $e'); }
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
    } catch (e) { debugPrint('Failed to load badge definitions: $e'); }
  }
  Future<void> _fetchBadges(ApiClient api) async {
    try {
      final badgesRes = await api.getBadges(_babyMonId!);
      _badges = (badgesRes.data is List)
          ? (badgesRes.data as List<dynamic>)
          : parseItems(badgesRes.data);
    } catch (e) { debugPrint('Dashboard data load failed: $e'); }
  }
  Future<void> _fetchBabyMon(ApiClient api) async {
    try {
      final babyMonRes = await api.getBabyMon(_babyMonId!);
      final rawBabyMon = babyMonRes.data;
      if (rawBabyMon is! Map) throw Exception('Invalid babyMon data');
      _babyMon = BabyMon.fromJson(parseJsonMap(rawBabyMon)!);
    } catch (e) { debugPrint('Dashboard data load failed: $e'); }
  }
  Future<void> _fetchEvolution(ApiClient api, {bool forceRefresh = false}) async {
    try {
      final evolutionRes = await api.getEvolution(_babyMonId!, forceRefresh: forceRefresh);
      final rawData = evolutionRes.data;
      if (rawData is! Map) throw Exception('Invalid evolution data');
      final evoData = parseJsonMap(rawData)!;
      final evoBabyMon = parseJsonMap(evoData['babyMon']) ?? <String, dynamic>{};
      _evolution = <String, dynamic>{...evoData, ...evoBabyMon};
    } catch (e) { debugPrint('Dashboard data load failed: $e'); }
  }
  Future<void> _fetchGrowth(ApiClient api) async {
    try {
      // Fetch last weight
      final weightRes = await api.getGrowthRecords(_babyMonId!, type: 'WEIGHT');
      final weightList = (weightRes.data is List)
          ? (weightRes.data as List<dynamic>)
          : parseItems(weightRes.data);
      if (weightList.isNotEmpty) {
        final last = weightList.last;
        _latestGrowth = GrowthRecord.fromJson(
          last is Map<String, dynamic> ? last : parseJsonMap(last) ?? {},
        );
      }
      // Fetch last height
      final heightRes = await api.getGrowthRecords(_babyMonId!, type: 'HEIGHT');
      final heightList = (heightRes.data is List)
          ? (heightRes.data as List<dynamic>)
          : parseItems(heightRes.data);
      if (heightList.isNotEmpty) {
        final last = heightList.last;
        _latestHeight = GrowthRecord.fromJson(
          last is Map<String, dynamic> ? last : parseJsonMap(last) ?? {},
        );
      }
    } catch (e) { debugPrint('Dashboard data load failed: $e'); }
  }
  Future<void> _fetchAllergies(ApiClient api) async {
    try {
      final aRes = await api.getAllergies(_babyMonId!);
      final raw = aRes.data;
      _allergies = parseItemsTyped(raw).map(Allergy.fromJson).toList();
    } catch (e) { debugPrint('Dashboard data load failed: $e'); }
  }
  Future<void> _fetchProfile(ApiClient api) async {
    try {
      final profile = await api.getProfile();
      final profileData = parseJsonMap(profile.data);
      _parentName = parseString(profileData?['name']);
      _parentContact = parseString(profileData?['phone']);
    } catch (e) { debugPrint('Dashboard data load failed: $e'); }
  }
  String _stageEmoji(String stage, String? gender) {
    switch (stage) {
      case 'BORN':
        return gender == 'MONIESE'
            ? '♀'
            : gender == 'MONIOUS'
                ? '♂'
                : '';
      case 'INCUBATING':
        return '';
      case 'PLAN':
        return '';
      default:
        return '';
    }
  }
  String get _babyMonAge {
    if (_babyMon?.stageStartType != 'BORN' || _babyMon?.referenceDate == null) return '';
    final diff = DateTime.now().difference(_babyMon!.referenceDate!);
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
    if (_babyMon?.stageStartType != 'INCUBATING' || _babyMon?.referenceDate == null) return '';
    final r =
        _babyMon!.referenceDate!.add(const Duration(days: 280)).difference(DateTime.now());
    return r.inDays <= 0 ? 'Due now!' : 'ETA: ${r.inDays} days';
  }
  String get _stageLabel {
    switch (_babyMon?.stageStartType) {
      case 'INCUBATING':
        return 'Incubating';
      case 'PLAN':
        return 'Plan';
      case 'BORN':
      default:
        // Try referenceDate first, fall back to birthDate
        final ref = _babyMon?.referenceDate ?? _babyMon?.birthDate;
        if (ref == null) return 'Born';
        final d = DateTime.now().difference(ref).inDays;
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
  int get _currentLevel => parseInt(_evolution?['currentLevel']) ?? 1;
  String _inferTier(String b) {
    if (b.contains('10') || b.contains('100') || b.contains('500')) {
      return 'GOLD';
    }
    if (b.contains('5') || b.contains('50')) return 'SILVER';
    return 'BRONZE';
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: ResponsiveWrapper(
        scrollable: false, // inner widgets handle their own scrolling
        child: PremiumBackground(
          child: _isLoading
              ? _buildLoadingState()
              : (_babyMonId == null || _babyMonId!.isEmpty)
                  ? _buildWelcomeScreen()
                  : RefreshIndicator(
                      onRefresh: () => _loadData(force: true),
                      child: _buildReorderableDashboard(context),
                    ),
        ),
      ),
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
      if (_latestGrowth != null || _latestHeight != null) _TileType.growth: _buildGrowthRow(),
      _TileType.badges: _buildBadgeSection(),
      if (_stageContent != null) _TileType.content: _buildStageContentCard(),
    };
    final visibleTiles = _tileOrder.where((t) => tiles.containsKey(t)).toList();
    final isWide = ResponsiveWrapper.isTablet(context) ||
        ResponsiveWrapper.isLandscape(context);
    final columns = ResponsiveWrapper.adaptiveColumnCount(context);
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
                        color: context.colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius:
                            BorderRadius.circular(DesignTokens.radiusFull),
                        border: Border.all(
                          color: context.colorScheme.primary.withValues(alpha: DesignTokens.opacitySubtle),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Refreshing',
                            style: TextStyle(
                              fontSize: DesignTokens.font2xs,
                              fontWeight: FontWeight.w600,
                              color: context.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        // ── Tiles ──
        Expanded(
          child: isWide
              ? _buildGridDashboard(context, tiles, visibleTiles, columns)
              : _buildListDashboard(context, tiles, visibleTiles),
        ),
      ],
    );
  }
  /// Tablet / landscape: adaptive grid layout (no reorder — drag is awkward on wide screens).
  Widget _buildGridDashboard(BuildContext context,
      Map<_TileType, Widget> tiles, List<_TileType> visible, int columns) {
    return GridView.builder(
      padding: const EdgeInsets.only(
        left: DesignTokens.bentoPadding,
        right: DesignTokens.bentoPadding,
        top: 7,
        bottom: 100,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: DesignTokens.bentoGap,
        crossAxisSpacing: DesignTokens.bentoGap,
        childAspectRatio: 0.85,
      ),
      itemCount: visible.length,
      itemBuilder: (context, index) => tiles[visible[index]]!,
    );
  }
  /// Phone portrait: reorderable vertical list.
  Widget _buildListDashboard(BuildContext context,
      Map<_TileType, Widget> tiles, List<_TileType> visible) {
    return ReorderableListView(
      padding: const EdgeInsets.only(
        left: DesignTokens.bentoPadding,
        right: DesignTokens.bentoPadding,
        top: 7,
        bottom: 100,
      ),
      // ignore: deprecated_member_use – onReorderItem not yet in stable
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (oldIndex >= visible.length || oldIndex < 0) return;
          final movedTile = visible[oldIndex];
          final oldFullIndex = _tileOrder.indexOf(movedTile);
          _tileOrder.removeAt(oldFullIndex);
          // Determine insertion point from the visible target position
          final int insertAt;
          if (newIndex >= visible.length) {
            insertAt = _tileOrder.length; // end of list
          } else {
            final targetTile = visible[newIndex];
            insertAt = _tileOrder.indexOf(targetTile);
          }
          _tileOrder.insert(insertAt, movedTile);
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
                            color: context.colorScheme.primary
                                .withValues(alpha: DesignTokens.opacitySubtle),
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
      children: visible
          .map((tile) => Padding(
                key: ValueKey(tile),
                padding: const EdgeInsets.only(bottom: DesignTokens.bentoGap),
                child: tiles[tile],
              ))
          .toList(),
    );
  }
  Widget _buildStageCard() {
    final accent = _genderAccent(_babyMon?.gender ?? 'MONIOUS');
    final genderBg = _babyMon?.gender == 'MONIESE'
        ? AppColors.genderMoniese
        : _babyMon?.gender == 'MONIOUS'
            ? AppColors.genderMonious
            : AppColors.genderNeutral;
    return Semantics(
      label: '${_babyMon?.name ?? 'Baby'}, level $_currentLevel',
      button: true,
      child: PremiumDoubleBezel(
        outerRadius: DesignTokens.radius2xl,
        gap: 5.0,
        outerColor: accent.withValues(alpha: 0.10),
        child: StageHero(
        name: _babyMon?.name ?? 'Baby',
        level: _currentLevel,
        accent: accent,
        ageText: _babyMonAge.isNotEmpty ? _babyMonAge : null,
        etaText: _etaText.isNotEmpty ? _etaText : null,
        detailsExpanded: _showDetails,
        onToggleDetails: () => setState(() => _showDetails = !_showDetails),
        onShare: _shareBabyMon,
        onEdit: _editBabyMon,
        backgroundColor: genderBg.withValues(alpha: 0.08),
        compact: true,
        child: _buildDetailsPanel(),
      ),
    ),
    );
  }
  Widget _buildDetailsPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Identity ──
        _detailRow('Age', _babyMonAge.isNotEmpty ? _babyMonAge : '—'),
        if (_babyMon?.birthDate != null)
          _detailRow('Birth Date', _formatDate(_babyMon!.birthDate!)),
        if (_babyMon?.conceptionDate != null)
          _detailRow('Conceived', _formatDate(_babyMon!.conceptionDate!)),
        if (_babyMon?.middleName != null && _babyMon!.middleName!.isNotEmpty)
          _detailRow('Middle Name', _babyMon!.middleName!),
        if (_babyMon?.lastName != null && _babyMon!.lastName!.isNotEmpty)
          _detailRow('Last Name', _babyMon!.lastName!),
        _detailRow(
          'Stage',
          _babyMon?.stageStartType == 'BORN'
              ? 'Born'
              : _babyMon?.stageStartType == 'INCUBATING'
                  ? 'Incubating'
                  : _babyMon?.stageStartType == 'PLAN'
                      ? 'Plan'
                      : '—',
        ),
        _detailRow(
          'Gender',
          _babyMon?.gender == 'MONIOUS'
              ? 'Monious (Male)'
              : _babyMon?.gender == 'MONIESE'
                  ? 'Moniese (Female)'
                  : 'Mo (Neutral)',
        ),
        if (_babyMon?.bloodGroup != null && _babyMon!.bloodGroup!.isNotEmpty)
          _detailRow('Blood Type', _babyMon!.bloodGroup!),
        if (_babyMon?.eyeColor != null && _babyMon!.eyeColor!.isNotEmpty)
          _detailRow('Eye Color', _babyMon!.eyeColor!),
        // ── Growth ──
        if (_latestGrowth != null) ...[
          _sectionHeader('Latest Growth'),
          _detailRow(_growthTypeLabel(_latestGrowth!.type),
              '${_latestGrowth!.value.toStringAsFixed(1)} ${_latestGrowth!.unit ?? ''}'),
          if (_latestGrowth!.measuredAt != null)
            _detailRow('Recorded', _formatDate(_latestGrowth!.measuredAt!)),
        ],
        // ── Progress ──
        _sectionHeader('Progress'),
        _detailRow('Level', '$_currentLevel — ${parseString(_evolution?['levelName']) ?? 'Level $_currentLevel'}'),
        _detailRow('XP', '${parseInt(_evolution?['currentXp']) ?? 0} / ${parseInt(_evolution?['xpForNextLevel']) ?? 50}'),
        // ── Family ──
        if (_parentName != null && _parentName!.isNotEmpty) ...[
          _sectionHeader('Family'),
          _detailRow('Parent', _parentName!),
        ],
        if (_babyMon?.biologicalMother != null && _babyMon!.biologicalMother!.isNotEmpty)
          _detailRow('Mother', _babyMon!.biologicalMother!),
        if (_babyMon?.biologicalFather != null && _babyMon!.biologicalFather!.isNotEmpty)
          _detailRow('Father', _babyMon!.biologicalFather!),
        // ── Health ──
        if (_allergies.isNotEmpty) ...[
          _sectionHeader('Allergies'),
          ..._allergies.map((a) => _detailRow(
                a.name ?? 'Unknown',
                '${a.severity ?? 'Unknown'} severity${a.triggers != null && (a.triggers as List).isNotEmpty ? ' — triggers: ${(a.triggers as List).join(', ')}' : ''}',
              )),
        ],
        // ── Traits ──
        if (_babyMon != null && _babyMon!.traits.isNotEmpty)
          _detailRow('Traits', _babyMon!.traits.join(', ')),
        if (_babyMon?.specialMove != null && _babyMon!.specialMove!.isNotEmpty)
          _detailRow('Special Move', _babyMon!.specialMove!),
      ],
    );
  }
  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 2),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: context.colorScheme.primary,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
  String _formatDate(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }
  String _growthTypeLabel(String type) {
    switch (type) {
      case 'WEIGHT': return 'Weight';
      case 'HEIGHT': return 'Height';
      case 'HEAD_CIRCUMFERENCE': return 'Head Circumference';
      default: return type;
    }
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
                    color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
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
    final allergyText = _allergies.isNotEmpty
        ? _allergies
            .map((a) => '• ${a.name ?? 'Unknown'} (${a.severity ?? 'Unknown'})')
            .join('\n')
        : 'None recorded';
    // Name in LASTNAME, First format (no middle name, last name UPPERCASE)
    final lastName = _babyMon?.lastName ?? '';
    final firstName = _babyMon?.name ?? '';
    final displayName = lastName.isNotEmpty
        ? '${lastName.toUpperCase()}, $firstName'
        : firstName.isNotEmpty
            ? firstName
            : 'Baby';
    final text = StringBuffer();
    text.writeln('BabyMon Card: $displayName');
    text.writeln('Age: ${_babyMonAge.isNotEmpty ? _babyMonAge : 'N/A'}');
    final genderLabel = _babyMon?.gender == 'MALE' || _babyMon?.gender == 'MONIOUS'
        ? 'Male'
        : _babyMon?.gender == 'FEMALE' || _babyMon?.gender == 'MONIESE'
            ? 'Female'
            : 'Neutral';
    text.writeln('Gender: $genderLabel');
    if (_babyMon?.bloodGroup != null && _babyMon!.bloodGroup!.isNotEmpty) {
      text.writeln('Blood Type: ${_babyMon!.bloodGroup}');
    }
    if (_babyMon?.eyeColor != null && _babyMon!.eyeColor!.isNotEmpty) {
      text.writeln('Eye Color: ${_babyMon!.eyeColor}');
    }
    if (_parentName != null && _parentName!.isNotEmpty) {
      text.writeln('Parent: $_parentName');
    }
    if (_parentContact != null && _parentContact!.isNotEmpty) {
      text.writeln('Parent Contact: $_parentContact');
    }
    text.writeln();
    text.writeln('Allergies:');
    text.writeln(allergyText);
    text.writeln();
    text.writeln('Shared via BabyMon');
    await Share.share(text.toString(), subject: '${displayName} Card');
  }
  Future<void> _editBabyMon() async {
    if (_babyMonId == null) return;
    final nameCtrl = TextEditingController(text: _babyMon?.name ?? '');
    final middleCtrl = TextEditingController(text: _babyMon?.middleName ?? '');
    final lastNameCtrl = TextEditingController(text: _babyMon?.lastName ?? '');
    final motherCtrl = TextEditingController(text: _babyMon?.biologicalMother ?? '');
    final fatherCtrl = TextEditingController(text: _babyMon?.biologicalFather ?? '');
    final parentCtrl = TextEditingController(text: _parentName ?? '');
    final contactCtrl = TextEditingController(text: _parentContact ?? '');
    final specialMoveCtrl = TextEditingController(text: _babyMon?.specialMove ?? '');
    final api = ref.read(apiClientProvider);
    Set<String> traits = {...?_babyMon?.traits};
    String? bloodGroup = _babyMon?.bloodGroup;
    String? gender = _babyMon?.gender;
    String? eyeColor = _babyMon?.eyeColor;
    if (!mounted) return;
    // Capture theme values before showing sheet — the parent context
    // can become invalid if the dashboard rebuilds while the sheet is open.
    final barrierColor = context.colorScheme.onSurface.withValues(alpha: DesignTokens.opacityDim);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassBg = context.glass.background;
    final glassSurface = context.glass.surface;
    final glassBorderLight = context.glass.borderLight;
    final dividerColor = context.dividerColor;
    final primaryColor = context.colorScheme.primary;
    final bool? result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: barrierColor,
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
                color: (isDark ? glassBg : glassSurface).withValues(alpha: 0.98),
                border: Border(
                  top: BorderSide(
                    color: glassBorderLight,
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
                      color: dividerColor,
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
                            color: primaryColor.withValues(alpha: 0.12),
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
                                  color: primaryColor,
                                  letterSpacing: 1.5,
                                  fontSize: DesignTokens.font2xs,
                                ),
                          ),
                        ),
                        const SizedBox(width: DesignTokens.spaceSm),
                        Expanded(
                          child: Text(
                            _babyMon?.name ?? 'BabyMon',
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
                          _editField(nameCtrl, 'First Name'),
                          const SizedBox(height: DesignTokens.spaceMd),
                          _editField(middleCtrl, 'Middle Name'),
                          const SizedBox(height: DesignTokens.spaceMd),
                          _editField(lastNameCtrl, 'Last Name'),
                          const SizedBox(height: DesignTokens.spaceMd),
                          _editTile(ctx, setD, 'Gender',
                              gender == 'MONIOUS'
                                  ? 'Monious'
                                  : gender == 'MONIESE'
                                      ? 'Moniese'
                                      : 'Mo', () async {
                            final sel =
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
                            if (sel != null) setD(() => gender = sel);
                          }),
                          const SizedBox(height: DesignTokens.spaceMd),
                          _editTile(ctx, setD, 'Blood Type',
                              bloodGroup == null || bloodGroup!.isEmpty
                                  ? 'Not set'
                                  : bloodGroup!,
                              () async {
                            final sel =
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
                            if (sel != null) setD(() => bloodGroup = sel);
                          }),
                          const SizedBox(height: DesignTokens.spaceMd),
                          _editTile(ctx, setD, 'Eye Color',
                              eyeColor == null || eyeColor!.isEmpty
                                  ? 'Not set'
                                  : eyeColor!,
                              () async {
                            final sel =
                                await WheelPickerBottomSheet.show<String>(
                              context: ctx,
                              title: 'Select Eye Color',
                              columns: [
                                WheelColumn<String>(
                                  label: 'Eye Color',
                                  options: const [
                                    WheelOption(value: '', label: 'Not set'),
                                    WheelOption(value: 'Brown', label: 'Brown'),
                                    WheelOption(value: 'Blue', label: 'Blue'),
                                    WheelOption(value: 'Green', label: 'Green'),
                                    WheelOption(value: 'Hazel', label: 'Hazel'),
                                    WheelOption(value: 'Gray', label: 'Gray'),
                                    WheelOption(value: 'Amber', label: 'Amber'),
                                  ],
                                  initialValue: eyeColor ?? '',
                                ),
                              ],
                            );
                            if (sel != null) setD(() => eyeColor = sel);
                          }),
                          const SizedBox(height: DesignTokens.spaceMd),
                          _editField(motherCtrl, 'Biological Mother'),
                          const SizedBox(height: DesignTokens.spaceMd),
                          _editField(fatherCtrl, 'Biological Father'),
                          const SizedBox(height: DesignTokens.spaceMd),
                          _editField(parentCtrl, 'Parent/Guardian Name'),
                          const SizedBox(height: DesignTokens.spaceMd),
                          _editField(contactCtrl, 'Parent Contact #',
                              keyboardType: TextInputType.phone),
                          const SizedBox(height: DesignTokens.spaceMd),
                          // ── Traits: multi-select chips ──
                          _buildTraitsEditor(ctx, setD, traits),
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
    final newName = parentCtrl.text.trim();
    final newPhone = contactCtrl.text.trim();
    final babyName = nameCtrl.text.trim();
    final babyMiddle = middleCtrl.text.trim();
    final babyLast = lastNameCtrl.text.trim();
    final babyMother = motherCtrl.text.trim();
    final babyFather = fatherCtrl.text.trim();
    final babySpecialMove = specialMoveCtrl.text.trim();
    final babyTraits = traits.toList();
    // Immediately dispose controllers to avoid lifecycle conflicts
    nameCtrl.dispose(); middleCtrl.dispose(); lastNameCtrl.dispose();
    motherCtrl.dispose(); fatherCtrl.dispose();
    parentCtrl.dispose(); contactCtrl.dispose(); specialMoveCtrl.dispose();
    // Save parent/guardian profile first (independent of BabyMon)
    final nameChanged = newName != (_parentName ?? '');
    final phoneChanged = newPhone != (_parentContact ?? '');
    if (nameChanged || phoneChanged) {
      try {
        final profileData = <String, dynamic>{};
        if (nameChanged) {
          profileData['name'] = newName.isEmpty ? null : newName;
        }
        if (phoneChanged) {
          profileData['phone'] = newPhone.isEmpty ? null : newPhone;
        }
        await api.patch('/users/me', data: profileData);
        if (mounted) {
          setState(() {
            _parentName = newName.isEmpty ? null : newName;
            _parentContact = newPhone.isEmpty ? null : newPhone;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile save failed: $e'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: context.colorScheme.error,
            ),
          );
        }
      }
    }
    // Then update BabyMon
    try {
      await api.updateBabyMon(_babyMonId!, {
        'name': babyName,
        'middleName': babyMiddle,
        'lastName': babyLast,
        'gender': gender,
        'bloodGroup': bloodGroup,
        'eyeColor': eyeColor,
        'biologicalMother': babyMother,
        'biologicalFather': babyFather,
        'traits': babyTraits,
        'specialMove': babySpecialMove,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('BabyMon save failed: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: context.colorScheme.error,
          ),
        );
      }
      return;
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
      outerColor: context.colorScheme.outline.withValues(alpha: 0.08),
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
      outerColor: ctx.colorScheme.outline.withValues(alpha: 0.08),
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
                    ?.copyWith(color: ctx.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(width: 4),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: ctx.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                ),
                child: Icon(PhosphorIconsLight.caretRight,
                    size: 14, color: ctx.colorScheme.primary.withValues(alpha: 0.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }
  static const List<String> _kDefaultTraits = [
    'Curious',
    'Peaceful',
    'Playful',
    'Gentle',
    'Adventurous',
    'Creative',
  ];
  Widget _buildTraitsEditor(
      BuildContext ctx, StateSetter setD, Set<String> traits) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Traits',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: ctx.colorScheme.onSurfaceVariant)),
        const SizedBox(height: DesignTokens.spaceSm),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            // Default traits as simple ChoiceChips
            for (final trait in _kDefaultTraits)
              ChoiceChip(
                key: ValueKey('default_$trait'),
                label: Text(trait, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                selected: traits.contains(trait),
                onSelected: (sel) {
                  setD(() => sel ? traits.add(trait) : traits.remove(trait));
                },
                visualDensity: VisualDensity.compact,
              ),
            // Custom traits with delete
            for (final trait in traits.where((t) => !_kDefaultTraits.contains(t)))
              Chip(
                key: ValueKey('custom_$trait'),
                label: Text(trait, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                deleteIcon: const Icon(Icons.close, size: 14),
                onDeleted: () => setD(() => traits.remove(trait)),
                visualDensity: VisualDensity.compact,
                backgroundColor: ctx.colorScheme.tertiaryContainer,
              ),
            // Add button
            ActionChip(
              key: const ValueKey('add_custom'),
              avatar: const Icon(Icons.add, size: 14),
              label: const Text('Add custom', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              visualDensity: VisualDensity.compact,
              onPressed: () async {
                if (_customTraitDialogOpen) return;
                _customTraitDialogOpen = true;
                final ctrl = TextEditingController();
                try {
                  final result = await showDialog<String>(
                    context: context,
                    builder: (dCtx) => AlertDialog(
                      title: const Text('Add Custom Trait'),
                      content: TextField(
                        controller: ctrl,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Brave, Silly, Stubborn',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dCtx),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(dCtx, ctrl.text.trim()),
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  );
                  if (result != null && result.isNotEmpty && mounted) {
                    // Add to set directly (no setD) — trait will appear on next rebuild
                    traits.add(result);
                    // Trigger rebuild safely via post-frame callback
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        try { setD(() {}); } catch (_) {}
                      }
                    });
                  }
                } catch (_) {
                  // ignore
                } finally {
                  _customTraitDialogOpen = false;
                  // Delay dispose to avoid racing with dialog's animation teardown
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    try { ctrl.dispose(); } catch (_) {}
                  });
                }
              },
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildXpCard() => DashboardXpCard(evolution: _evolution);
  Widget _buildQuickStatsRow() => DashboardStatsRow(evolution: _evolution);
  Widget _buildGrowthRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.bentoPadding),
      child: Row(children: [
        if (_latestGrowth != null)
          Expanded(child: _buildMiniGrowthCard(
            icon: PhosphorIconsLight.scales,
            label: 'Weight',
            value: '${_latestGrowth!.value} ${_latestGrowth!.unit ?? 'kg'}',
            date: _latestGrowth!.measuredAt != null
                ? DateFormat.yMMMd().format(_latestGrowth!.measuredAt!)
                : '',
          )),
        if (_latestGrowth != null && _latestHeight != null)
          const SizedBox(width: DesignTokens.spaceSm),
        if (_latestHeight != null)
          Expanded(child: _buildMiniGrowthCard(
            icon: PhosphorIconsLight.ruler,
            label: 'Height',
            value: '${_latestHeight!.value} ${_latestHeight!.unit ?? 'cm'}',
            date: _latestHeight!.measuredAt != null
                ? DateFormat.yMMMd().format(_latestHeight!.measuredAt!)
                : '',
          )),
      ]),
    );
  }
  Widget _buildMiniGrowthCard({
    required IconData icon,
    required String label,
    required String value,
    required String date,
  }) {
    return PremiumDoubleBezel(
      outerRadius: DesignTokens.radiusMd,
      gap: 3.0,
      outerColor: context.colorScheme.primary.withValues(alpha: 0.06),
      onTap: () => context.push('/growth-chart'),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Icon(icon, color: context.colorScheme.primary, size: 20),
              const Spacer(),
              Icon(PhosphorIconsLight.caretRight, color: context.colorScheme.primary.withValues(alpha: 0.5), size: 14),
            ]),
            const SizedBox(height: DesignTokens.spaceSm),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
            ),
            if (date.isNotEmpty)
              Text(
                date,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      fontSize: 10,
                    ),
              ),
          ],
        ),
      ),
    );
  }
  Widget _buildBadgeSection() => Semantics(
    label: 'Badges: ${_badges.length} earned',
    child: DashboardBadgeSection(
      badgeDefinitions: _badgeDefinitions,
      badges: _badges,
    ),
  );
  void _showLevelUpCelebration(int newLevel) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: context.colorScheme.onSurface.withValues(alpha: DesignTokens.opacityDim),
      builder: (ctx) => LevelUpCelebration(
        level: newLevel,
        onDismiss: () => Navigator.of(ctx).pop(),
      ),
    );
  }
  Widget _buildStageContentCard() {
    if (_stageContent == null) return const SizedBox.shrink();
    final prompt = parseString(_stageContent!['reflectionPrompt']);
    return Semantics(
      label: 'Stage content for ${_stageContent!['title'] ?? 'current stage'}',
      child: DashboardContentCard(
        stageContent: _stageContent!,
        onReflectionTap: () {
          GoRouter.of(context).push('/journal');
          if (prompt != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(prompt),
                duration: const Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
              ),
            );
          }
        },
        onOpenChat: _babyMonId != null
            ? () => GoRouter.of(context).push('/companion/$_babyMonId?openChat=true')
            : null,
        onViewMilestones: _babyMonId != null
            ? () => GoRouter.of(context).push('/companion/$_babyMonId?initialTab=2')
            : null,
      ),
    );
  }
}
