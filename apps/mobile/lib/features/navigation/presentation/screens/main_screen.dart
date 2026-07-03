import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/features/auth/auth.dart';
import 'package:baby_mon/features/dashboard/dashboard.dart';
import 'package:baby_mon/features/milestones/milestones.dart';
import 'package:baby_mon/features/feeding/feeding.dart';
import 'package:baby_mon/features/health/health.dart';
import 'package:baby_mon/features/companion/presentation/screens/companion_tab.dart';
import 'package:baby_mon/core/core.dart';
import 'package:baby_mon/l10n/l10n_ext.dart';
/// Main navigation shell — redesigned with 5-tab bottom nav, floating AppBar,
/// premium drawer, and cross-fade tab transitions.
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});
  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}
class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _visitedTabs = <int>{0}; // dashboard starts visited
  // ═══ BabyMon selector ═══
  String? _activeBabyMonId;
  String _activeBabyMonName = '';
  String _activeBabyMonGender = 'MONIOUS';
  List<Map<String, dynamic>> _allBabyMons = [];
  bool _selectorLoading = true;
  bool _switchInProgress = false;
  // ═══ Scroll-aware tab label ═══
  final Set<int> _scrolledTabs = {};
  // Navigation configuration
  static const _tabCount = 6;
  List<_NavTab> _buildTabs(BuildContext context) => [
    _NavTab(PhosphorIconsLight.gauge, PhosphorIconsLight.gauge, context.l10n.dashboard),
    _NavTab(PhosphorIconsLight.trophy, PhosphorIconsLight.trophy, context.l10n.milestones),
    _NavTab(PhosphorIconsLight.bowlFood, PhosphorIconsLight.bowlFood, context.l10n.feeding),
    _NavTab(PhosphorIconsLight.heart, PhosphorIconsLight.heart, context.l10n.health),
    _NavTab(PhosphorIconsLight.magicWand, PhosphorIconsLight.magicWand, context.l10n.companion),
    _NavTab(PhosphorIconsLight.dotsSixVertical, PhosphorIconsLight.dotsSixVertical, context.l10n.more),
  ];
  /// Returns the real screen for visited tabs, [SizedBox.shrink] for others.
  /// IndexedStack builds all children eagerly — deferring unvisited tabs
  /// prevents their API calls from racing on first render.
  List<Widget> _buildScreenList() {
    Widget screen(int i, Widget child) =>
        _visitedTabs.contains(i) ? child : const SizedBox.shrink();
    return [
      screen(0, const DashboardScreen()),
      screen(1, _scrollAware(1, const MilestonesScreen())),
      screen(2, _scrollAware(2, const FeedingScreen())),
      screen(3, _scrollAware(3, const HealthScreen())),
      screen(4, CompanionTab(babyMonId: _activeBabyMonId ?? '')),
      const SizedBox.shrink(), // More tab placeholder
    ];
  }
  /// Wraps a tab screen in [ScrollAware] to track scroll offset for the pill.
  Widget _scrollAware(int tabIndex, Widget screen) {
    return ScrollAware(
      threshold: 10,
      onScrolledChanged: (isScrolled) {
        final wasScrolled = _scrolledTabs.contains(tabIndex);
        if (wasScrolled != isScrolled) {
          setState(() {
            if (isScrolled) {
              _scrolledTabs.add(tabIndex);
            } else {
              _scrolledTabs.remove(tabIndex);
            }
          });
        }
      },
      child: screen,
    );
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSelectorData());
    ref.listenManual(appRefreshProvider, (prev, next) {
      if (prev != next) _loadSelectorData();
    });
  }
  // ═══ BabyMon selector ═══
  Future<void> _loadSelectorData() async {
    try {
      final api = ref.read(apiClientProvider);
      final allRes = await api.getBabyMons();
      _allBabyMons = parseItemsTyped(allRes.data);
      final activeId = await api.getSelectedBabyMonId();
      if (activeId != null) {
        _activeBabyMonId = activeId;
        final current = _allBabyMons.whereType<Map<String, dynamic>?>().firstWhere(
          (b) => b?['id'] == activeId,
          orElse: () => null,
        );
        if (current != null) {
          _activeBabyMonName = parseString(current['name']) ?? '';
          _activeBabyMonGender = parseString(current['gender']) ?? 'MONIOUS';
        }
      } else if (_allBabyMons.isNotEmpty) {
        // Auto-select the first BabyMon if none is stored (e.g. after reinstall)
        final first = _allBabyMons.cast<Map<String, dynamic>?>().firstWhere(
          (b) => b != null && b['id'] != null,
          orElse: () => null,
        );
        if (first != null) {
          final id = parseString(first['id'])!;
          _activeBabyMonId = id;
          _activeBabyMonName = parseString(first['name']) ?? '';
          _activeBabyMonGender = parseString(first['gender']) ?? 'MONIOUS';
          await api.setSelectedBabyMonId(id);
          ref.read(appRefreshProvider.notifier).state++;
        }
      }
      if (mounted) setState(() => _selectorLoading = false);
    } catch (_) {
      if (mounted) setState(() => _selectorLoading = false);
    }
  }
  Future<void> _switchBabyMon(String newId) async {
    if (_switchInProgress || newId == _activeBabyMonId) return;
    _switchInProgress = true;
    try {
      await ref.read(apiClientProvider).setSelectedBabyMonId(newId);
      ref.read(appRefreshProvider.notifier).state++;
      await _loadSelectorData();
    } finally {
      _switchInProgress = false;
    }
  }
  // ═══ Gender helpers ═══
  String _genderEmoji(String? g) =>
      g == 'MONIESE' ? '♀' : g == 'MONIOUS' ? '♂' : '';
  Color _genderBg(String? g) {
    switch (g) {
      case 'MONIESE': return AppColors.genderMoniese;
      case 'MONIOUS': return AppColors.genderMonious;
      default: return AppColors.genderNeutral;
    }
  }
  Color _genderAccent(String? g) {
    switch (g) {
      case 'MONIESE': return AppColors.genderMonieseAccent;
      case 'MONIOUS': return AppColors.genderMoniousAccent;
      default: return AppColors.genderNeutralAccent;
    }
  }
  // ═══ AppBar — Floating island BabyMon selector ═══
  Widget _buildAppBarSelector() {
    if (_selectorLoading) {
      return const ButtonLoading(size: 24);
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = _genderBg(_activeBabyMonGender);
    final accent = _genderAccent(_activeBabyMonGender);
    if (_allBabyMons.length <= 1) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
          border: Border.all(color: accent.withValues(alpha: DesignTokens.opacityDim)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_genderEmoji(_activeBabyMonGender),
                style: const TextStyle(fontSize: DesignTokens.fontLg)),
            const SizedBox(width: 8),
            Text(
              _activeBabyMonName.isNotEmpty
                  ? _activeBabyMonName
                  : context.l10n.appTitle,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        border: Border.all(color: accent.withValues(alpha: DesignTokens.opacityDim)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _activeBabyMonId,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          icon: Icon(Icons.keyboard_arrow_down, color: accent, size: 20),            dropdownColor: isDark ? context.colorScheme.surface : context.colorScheme.surface,
          underline: const SizedBox.shrink(),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          items: _allBabyMons
              .where((bm) => bm['deletedAt'] == null)
              .map((bm) => DropdownMenuItem(
                    value: parseString(bm['id']) ?? '',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_genderEmoji(parseString(bm['gender'])),
                            style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 8),
                        Text(
                          parseString(bm['name']) ?? context.l10n.appTitle,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) _switchBabyMon(v);
          },
        ),
      ),
    );
  }
  // ═══ More Menu Sheet ═══
  void _showMoreMenu() {
    final moreItems = [
      _MoreItem(PhosphorIconsLight.images, context.l10n.album, AppColors.bentoPurple, () {
        Navigator.pop(context);
        context.push('/album');
      }),
      _MoreItem(PhosphorIconsLight.bookOpen, context.l10n.journal, AppColors.bentoGold, () {
        Navigator.pop(context);
        context.push('/journal');
      }),
      _MoreItem(PhosphorIconsLight.compass, context.l10n.discover, AppColors.bentoTeal, () {
        Navigator.pop(context);
        context.push('/discover');
      }),
    ];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DesignTokens.radiusXl),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            DesignTokens.spaceLg,
            DesignTokens.spaceLg,
            DesignTokens.spaceLg,
            DesignTokens.spaceLg,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 32,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: DesignTokens.spaceLg),
                  decoration: BoxDecoration(
                    color: context.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  context.l10n.moreFeatures,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: DesignTokens.spaceMd),
                // Shared BackdropFilter for the grid — one blur pass instead of per-tile.
                GlassSurface(
                  borderRadius: DesignTokens.radiusMd,
                  blurSigma: DesignTokens.glassBlurLight,
                  child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: DesignTokens.bentoGap,
                        mainAxisSpacing: DesignTokens.bentoGap,
                        childAspectRatio: 1.4,
                      ),
                      itemCount: moreItems.length,
                      itemBuilder: (ctx, i) => _buildMoreGridItem(ctx, moreItems[i]),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildMoreGridItem(BuildContext ctx, _MoreItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ScalePress(
      onTap: item.onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          color: isDark ? context.glass.background : context.glass.surface,
          border: Border.all(
            color: item.color.withValues(alpha: isDark ? 0.2 : 0.15),
            width: DesignTokens.glassBorderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: item.color.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(
                  DesignTokens.radiusMd,
                ),
                border: Border.all(
                  color: item.color.withValues(alpha: 0.25),
                  width: 0.5,
                ),
              ),
              child: Icon(
                item.icon,
                color: item.color,
                size: 24,
              ),
            ),
            const SizedBox(height: DesignTokens.spaceSm),
            Text(
              item.label,
              style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
  // ═══ Helpers ═══
  void _triggerTabRefresh(int index) {
    ref.read(tabRefreshProvider(index).notifier).state++;
  }
  // ═══ Drawer ═══
  Widget _buildDrawer() {
    final navItems = [
      _DrawerSection(context.l10n.main, [
        _DrawerItem(PhosphorIconsLight.house, context.l10n.dashboard, 0),
        _DrawerItem(PhosphorIconsLight.trophy, context.l10n.milestones, 1),
        _DrawerItem(PhosphorIconsLight.bowlFood, context.l10n.feeding, 2),
        _DrawerItem(PhosphorIconsLight.heart, context.l10n.health, 3),
        _DrawerItem(PhosphorIconsLight.magicWand, context.l10n.companion, 4),
      ]),
      _DrawerSection(context.l10n.more, [
        _DrawerItem(PhosphorIconsLight.images, context.l10n.album, null, () =>
            _drawerNavigate(() => GoRouter.of(context).push('/album'))),
        _DrawerItem(PhosphorIconsLight.bookOpen, context.l10n.journal, null, () =>
            _drawerNavigate(() => GoRouter.of(context).push('/journal'))),
        _DrawerItem(PhosphorIconsLight.moon, context.l10n.sleep, null, () =>
            _drawerNavigate(() => GoRouter.of(context).push('/sleep'))),
        _DrawerItem(PhosphorIconsLight.compass, context.l10n.discover, null, () =>
            _drawerNavigate(() => GoRouter.of(context).push('/discover'))),
      ]),
    ];
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.70, // Material Design max drawer width
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile header
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: DesignTokens.spaceLg,
              right: DesignTokens.spaceLg,
              bottom: DesignTokens.space2xl,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.colorScheme.primary,
                  context.colorScheme.primaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: context.colorScheme.surface,
              child: Icon(
                Icons.child_care,
                size: 28,
                color: context.colorScheme.primary,
              ),
                ),
                const SizedBox(height: DesignTokens.spaceMd),
                Text(
                  context.l10n.appTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: context.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceXs),
                Text(
                  context.l10n.yourParentingCompanion,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                    color: context.colorScheme.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          // Nav items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                vertical: DesignTokens.spaceSm,
              ),
              children: [
                for (final section in navItems) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      DesignTokens.spaceLg,
                      DesignTokens.spaceMd,
                      DesignTokens.spaceLg,
                      DesignTokens.spaceXs,
                    ),
                    child: Text(
                      section.title,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.08,
                      ),
                    ),
                  ),
                  for (final item in section.items)
                    _buildDrawerItem(item),
                ],
                const Divider(
                  height: DesignTokens.space3xl,
                  indent: DesignTokens.spaceLg,
                  endIndent: DesignTokens.spaceLg,
                ),
                // Secondary actions
                _buildDrawerTile(
                  PhosphorIconsLight.gear,
                  context.l10n.settings,
                  Theme.of(context).brightness == Brightness.dark ? context.colorScheme.onPrimary : context.colorScheme.onSurface,
                  () => _drawerNavigate(
                    () => GoRouter.of(context).push('/settings'),
                  ),
                ),
                _buildDrawerTile(
                  PhosphorIconsLight.users,
                  context.l10n.managePartners,
                  context.colorScheme.primary,
                  () => _drawerNavigate(
                    () => GoRouter.of(context).push('/partners'),
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceLg),
                // Logout
                _buildDrawerTile(
                  PhosphorIconsLight.signOut,
                  context.l10n.logoutTitle,
                  context.colorScheme.error,
                  () => _logout(),
                ),
                const SizedBox(height: DesignTokens.space3xl),
              ],
            ),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.all(DesignTokens.spaceLg),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: context.dividerColor.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  PhosphorIconsLight.heart,
                  size: 12,
                  color: context.colorScheme.secondary,
                ),
                const SizedBox(width: DesignTokens.spaceXs),
                Text(
                  context.l10n.babyMonVersion,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildDrawerItem(_DrawerItem item) {
    final index = item.index;
    if (index != null && index < _tabCount) {
      return _buildDrawerTile(
        item.icon,
        item.label,
        _currentIndex == index
            ? context.colorScheme.primary
            : context.colorScheme.onSurfaceVariant,
        () {
          setState(() {
            _currentIndex = index;
            _visitedTabs.add(index);
          });
          _triggerTabRefresh(index);
          Navigator.pop(context);
        },
        _currentIndex == index,
      );
    }
    return _buildDrawerTile(
      item.icon,
      item.label,
      context.colorScheme.onSurfaceVariant,
      item.onTap,
    );
  }
  Widget _buildDrawerTile(
    IconData icon,
    String label,
    Color color, [
    VoidCallback? onTap,
    bool selected = false,
  ]) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceSm,
        vertical: 1,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
        color: selected
            ? context.colorScheme.primaryContainer
            : Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(icon, size: 20, color: color),
        title: Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        dense: true,
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
        ),
        onTap: onTap,
      ),
    );
  }
  void _drawerNavigate(VoidCallback action) {
    Navigator.pop(context);
    action();
  }
  // ═══ Logout ═══
  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.logoutTitle),
        content: Text(context.l10n.logoutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              context.l10n.logoutTitle,
              style: Theme.of(ctx).textTheme.labelLarge?.copyWith(color: context.colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) context.go('/login');
    }
  }
  // ═══ Build ═══
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? context.glass.background : context.glass.surface;
    final navBorder = isDark
        ? context.glass.border.withValues(alpha: 0.6)
        : context.glass.border.withValues(alpha: 0.6);
    return Scaffold(
      key: _scaffoldKey,
      // ── Floating pill AppBar with enhanced frosted glass + premium shadow ──
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Padding(
          padding: const EdgeInsets.only(
            top: DesignTokens.spaceSm,
            left: DesignTokens.spaceSm,
            right: DesignTokens.spaceSm,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
              boxShadow: [
                BoxShadow(
                  color: isDark ? context.glass.shadow : context.glass.shadow,
                  blurRadius: DesignTokens.glassShadowBlur,
                  offset: const Offset(0, DesignTokens.glassShadowOffset),
                ),
              ],
            ),
            child: GlassSurface(
              borderRadius: DesignTokens.radiusXl,
              blurSigma: DesignTokens.glassBlurLight,
              child: AppBar(
                  backgroundColor: navBg,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  scrolledUnderElevation: 2,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(DesignTokens.radiusXl),
                    side: BorderSide(
                      color: navBorder,
                      width: DesignTokens.glassBorderWidth,
                    ),
                  ),
                  leading: MorphingHamburger(
                    isOpen: _scaffoldKey.currentState?.isDrawerOpen ?? false,
                    onTap: () =>
                        _scaffoldKey.currentState?.openDrawer(),
                    size: 28,
                    strokeWidth: 2.5,
                  ),
                  title: Row(
                    children: [
                      Flexible(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.4,
                          ),
                          child: _buildAppBarSelector(),
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: DesignTokens.durationFast,
                        transitionBuilder: (child, anim) => ScaleTransition(
                          scale: Tween<double>(
                            begin: 1.08,
                            end: 1.0,
                          ).animate(CurvedAnimation(
                            parent: anim,
                            curve: Curves.easeOutBack,
                          )),
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(-0.2, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: anim,
                              curve: Curves.easeOutCubic,
                            )),
                            child: FadeTransition(
                              opacity: anim,
                              child: child,
                            ),
                          ),
                        ),
                        child: _currentIndex > 0 &&
                                _currentIndex < _tabCount - 1 &&
                                _scrolledTabs.contains(_currentIndex)
                            ? Padding(
                                key: const ValueKey('tabLabel'),
                                padding: const EdgeInsets.only(left: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(
                                      DesignTokens.radiusFull,
                                    ),
                                  ),
                                  child: Text(
                                    _buildTabs(context)[_currentIndex].label,
                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  centerTitle: false,
                  titleSpacing: 0,
                  actions: [
                    ThemeButton.icon(icon: PhosphorIconsLight.bell, onPressed: () { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.notificationsComingSoon), duration: const Duration(seconds: 2))); }, tooltip: context.l10n.notifications, variant: ThemeButtonVariant.text),
                    ThemeButton.icon(icon: PhosphorIconsLight.plusCircle, onPressed: () => GoRouter.of(context).push('/create-baby-mon'), tooltip: context.l10n.createBabyMon, variant: ThemeButtonVariant.text, foregroundColor: context.colorScheme.secondary),
                    const SizedBox(width: DesignTokens.spaceXs),
                  ],
                ),
              ),
          ),
        ),
      ),
      // ── Drawer ──
      drawer: _buildDrawer(),
      // ── Body — IndexedStack preserves state across tab switches ──
      body: IndexedStack(
        index: _currentIndex < _tabCount - 1 ? _currentIndex : 0,
        children: _buildScreenList(),
      ),
      // ── Bottom Nav — Floating Glass Pill ──
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: DesignTokens.spaceLg,
          right: DesignTokens.spaceLg,
          bottom: DesignTokens.spaceLg + MediaQuery.of(context).padding.bottom,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(
              sigmaX: DesignTokens.glassBlurLight,
              sigmaY: DesignTokens.glassBlurLight,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: navBg.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                border: Border.all(
                  color: navBorder,
                  width: DesignTokens.glassBorderWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? context.glass.shadow : context.glass.shadow).withValues(alpha: 0.15),
                    blurRadius: DesignTokens.glassShadowBlur,
                    offset: const Offset(0, DesignTokens.glassShadowOffset),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spaceSm,
                vertical: DesignTokens.spaceXs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_tabCount - 1, (index) {
                  final isSelected = _currentIndex == index;
                  final tab = _buildTabs(context)[index];
                  return _FloatingNavItem(
                    icon: tab.outlinedIcon,
                    activeIcon: tab.filledIcon,
                    label: tab.label,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _currentIndex = index;
                        _visitedTabs.add(index);
                      });
                      _triggerTabRefresh(index);
                    },
                  );
                })..add(
                    _FloatingNavItem(
                      icon: PhosphorIconsLight.dotsSixVertical,
                      activeIcon: PhosphorIconsLight.dotsSixVertical,
                      label: context.l10n.more,
                      isSelected: _currentIndex == _tabCount - 1,
                      onTap: _showMoreMenu,
                    ),
                  ),
              ),
          ),
        ),
      ),
    ),
      // ── FAB ──
      floatingActionButton: _currentIndex == 0
          ? InfoFab(
                tooltip: context.l10n.quickActions,
                icon: PhosphorIconsLight.lightning,
                children: [
                  InfoFabAction(
                    tooltip: context.l10n.journal,
                    infoDescription: context.l10n.journal,
                    backgroundColor: AppColors.bentoGold,
                    onTap: () => context.push('/journal'),
                    child: const Icon(PhosphorIconsLight.bookOpen, color: Colors.white),
                  ),
                  InfoFabAction(
                    tooltip: context.l10n.album,
                    infoDescription: context.l10n.album,
                    backgroundColor: AppColors.bentoPurple,
                    onTap: () => context.push('/album'),
                    child: const Icon(PhosphorIconsLight.images, color: Colors.white),
                  ),
                ],
              )
          : _currentIndex == 3
              ? InfoFab(
                  tooltip: context.l10n.addHealthActionsTooltip,
                  icon: PhosphorIconsLight.plus,
                  children: [
                    InfoFabAction(
                      tooltip: context.l10n.addMeasurement,
                      infoDescription: context.l10n.measurement,
                      backgroundColor: context.colorScheme.primary,
                      onTap: () {
                        ref.read(pendingAddActionProvider.notifier).state =
                            AddAction.healthMeasurement;
                      },
                      child: Icon(PhosphorIconsLight.ruler,
                          color: context.colorScheme.onPrimary),
                    ),
                    InfoFabAction(
                      tooltip: context.l10n.addEvent,
                      infoDescription: context.l10n.event,
                      backgroundColor: context.colorScheme.tertiary,
                      onTap: () {
                        ref.read(pendingAddActionProvider.notifier).state =
                            AddAction.healthEvent;
                      },
                      child: Icon(PhosphorIconsLight.building,
                          color: context.colorScheme.onPrimary),
                    ),
                    InfoFabAction(
                      tooltip: context.l10n.addMedicalContact,
                      infoDescription: context.l10n.medTeamShortLabel,
                      backgroundColor: context.colorScheme.secondary,
                      onTap: () {
                        ref.read(pendingAddActionProvider.notifier).state =
                            AddAction.healthMedicalTeam;
                      },
                      child: Icon(PhosphorIconsLight.firstAid,
                          color: context.colorScheme.onPrimary),
                    ),
                  ],
                )
              : null,
    );
  }
}
// ═══════════════════════════════════════
//  Floating Nav Item
// ═══════════════════════════════════════
class _FloatingNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _FloatingNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = context.colorScheme.primary;
    final inactiveColor = isDark
        ? context.colorScheme.onSurface.withValues(alpha: 0.55)
        : context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7);
    return Semantics(
      label: '$label tab',
      button: true,
      selected: isSelected,
      child: Material(
        color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
        child: AnimatedContainer(
          duration: DesignTokens.durationFast,
          curve: DesignTokens.curvePremium,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? DesignTokens.spaceMd : DesignTokens.spaceSm,
            vertical: DesignTokens.spaceXs,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: DesignTokens.durationFast,
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                    CurvedAnimation(parent: anim, curve: DesignTokens.curvePremium),
                  ),
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  key: ValueKey(isSelected),
                  size: 22,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: DesignTokens.spaceXs),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: activeColor,
                    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      ),
    );
  }
}
// ═══════════════════════════════════════
//  Supporting classes
// ═══════════════════════════════════════
class _NavTab {
  final IconData outlinedIcon;
  final IconData filledIcon;
  final String label;
  const _NavTab(this.outlinedIcon, this.filledIcon, this.label);
}
class _DrawerSection {
  final String title;
  final List<_DrawerItem> items;
  const _DrawerSection(this.title, this.items);
}
class _DrawerItem {
  final IconData icon;
  final String label;
  final int? index;
  final VoidCallback? onTap;
  const _DrawerItem(this.icon, this.label, this.index, [this.onTap]);
}
class _MoreItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MoreItem(this.icon, this.label, this.color, this.onTap);
}
