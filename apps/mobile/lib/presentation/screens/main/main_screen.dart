import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/presentation/providers/auth_provider.dart';
import 'package:baby_mon/data/api_client.dart';
import 'dashboard/dashboard_screen.dart';
import 'milestones/milestones_screen.dart';
import 'feeding/feeding_screen.dart';
import 'health/health_screen.dart';
import 'album/album_screen.dart';
import 'journal/journal_screen.dart';
import 'settings/partners_screen.dart';

/// Main navigation shell with a shared AppBar BabyMon selector
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // BabyMon selector state shared across all screens
  String? _activeBabyMonId;
  String _activeBabyMonName = '';
  String _activeBabyMonGender = 'MONIOUS';
  List<Map<String, dynamic>> _allBabyMons = [];
  bool _selectorLoading = true;
  bool _switchInProgress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSelectorData());
    ref.listenManual(appRefreshProvider, (prev, next) {
      if (prev != next) _loadSelectorData();
    });
  }

  Future<void> _loadSelectorData() async {
    try {
      final api = ref.read(apiClientProvider);
      final allRes = await api.getBabyMons();
      final items = (allRes.data is List) ? allRes.data : ((allRes.data as Map)['items'] as List?) ?? [];
      _allBabyMons = items.cast<Map<String, dynamic>>();
      final activeId = await api.getSelectedBabyMonId();
      if (activeId != null) {
        _activeBabyMonId = activeId;
        // Find name/gender from list
        final current = _allBabyMons.cast<Map<String, dynamic>?>().firstWhere(
          (b) => b?['id'] == activeId,
          orElse: () => null,
        );
        if (current != null) {
          _activeBabyMonName = current['name'] as String? ?? '';
          _activeBabyMonGender = current['gender'] as String? ?? 'MONIOUS';
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
    final capturedId = newId;
    try {
      await ref.read(apiClientProvider).setSelectedBabyMonId(capturedId);
      ref.read(appRefreshProvider.notifier).state++;
      await _loadSelectorData();
      if (_activeBabyMonId != capturedId) {
        await _loadSelectorData();
      }
    } finally {
      _switchInProgress = false;
    }
  }

  // ── Gender helpers ──
  String _genderEmoji(String? g) => g == 'MONIESE' ? '👶‍♀️' : g == 'MONIOUS' ? '👶‍♂️' : '👶';

  Color _genderColor(String? g) {
    switch (g) {
      case 'MONIESE': return Colors.pink.shade100;
      case 'MONIOUS': return Colors.lightBlue.shade100;
      default: return Colors.purple.shade100;
    }
  }

  Color _genderAccent(String? g) {
    switch (g) {
      case 'MONIESE': return Colors.pink.shade300;
      case 'MONIOUS': return Colors.lightBlue.shade300;
      default: return Colors.purple.shade300;
    }
  }

  Widget _buildAppBarSelector() {
    if (_selectorLoading) {
      return const Padding(padding: EdgeInsets.all(4), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)));
    }
    if (_allBabyMons.length <= 1) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: _genderColor(_activeBabyMonGender),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _genderAccent(_activeBabyMonGender).withOpacity(0.5)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(_genderEmoji(_activeBabyMonGender), style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(_activeBabyMonName.isNotEmpty ? _activeBabyMonName : 'BabyMon', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: _genderColor(_activeBabyMonGender),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _genderAccent(_activeBabyMonGender).withOpacity(0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _activeBabyMonId,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
          icon: Icon(Icons.arrow_drop_down, color: _genderAccent(_activeBabyMonGender)),
          dropdownColor: Colors.white,
          underline: const SizedBox.shrink(),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          items: _allBabyMons
            .where((bm) => bm['deletedAt'] == null)
            .map((bm) => DropdownMenuItem(
              value: bm['id'] as String,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(_genderEmoji(bm['gender'] as String?), style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(bm['name'] as String? ?? 'BabyMon'),
              ]),
            )).toList(),
          onChanged: (v) { if (v != null) _switchBabyMon(v); },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: SizedBox(
          width: MediaQuery.of(context).size.width * 0.55,
          child: _buildAppBarSelector(),
        ),
        centerTitle: false,
        titleSpacing: 4,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.green),
            tooltip: 'Create BabyMon',
            onPressed: () => GoRouter.of(context).go('/create-baby-mon'),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(children: [Icon(Icons.notifications, color: Colors.white, size: 28), SizedBox(width: 12), Text('Notifications', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))]),
                  SizedBox(height: 4),
                  Text('Stay updated on your BabyMon', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 48),
            const Center(child: Column(children: [
              Icon(Icons.notifications_none, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Coming Soon', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey)),
              SizedBox(height: 8),
              Padding(padding: EdgeInsets.symmetric(horizontal: 32), child: Text('Notification features are under development.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))),
            ])),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(radius: 30, backgroundColor: Colors.white, child: Text('B', style: TextStyle(fontSize: 24, color: Color(0xFF9C7CF4)))),
                  SizedBox(height: 12),
                  Text('BabyMon', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Your Parenting Companion', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            _drawerItem(Icons.home_filled, 'Dashboard', 0),
            _drawerItem(Icons.star, 'Milestones', 1),
            _drawerItem(Icons.restaurant, 'Feeding', 2),
            _drawerItem(Icons.favorite, 'Health', 3),
            _drawerItem(Icons.explore, 'Discover', 4),
            _drawerItem(Icons.photo_library, 'Album', 5),
            _drawerItem(Icons.auto_stories, 'Journal', 6),
            const Divider(),
            ListTile(leading: const Icon(Icons.settings), title: const Text('Settings'), onTap: () { Navigator.pop(context); GoRouter.of(context).go('/settings'); }),
            ListTile(leading: const Icon(Icons.group_add, color: Colors.indigo), title: const Text('Manage Partners'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const PartnersScreen())); }),
            const Divider(),
            ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text('Logout', style: TextStyle(color: Colors.red)), onTap: () async {
              final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Logout'), content: const Text('Are you sure?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Logout', style: TextStyle(color: Colors.red)))]));
              if (confirmed == true) { await ref.read(authProvider.notifier).logout(); if (mounted) context.go('/login'); }
            }),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          DashboardScreen(),
          MilestonesScreen(),
          FeedingScreen(),
          HealthScreen(),
          _DiscoverPlaceholder(),
          AlbumScreen(),
          JournalScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Milestones'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Feeding'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Health'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.photo_library), label: 'Album'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_stories), label: 'Journal'),
        ],
      ),
      floatingActionButton: _currentIndex == 0 || _currentIndex == 6
          ? FloatingActionButton(onPressed: () => _onFabPressed(), child: Icon(_currentIndex == 0 ? Icons.flash_on : Icons.edit))
          : null,
    );
  }

  Widget _drawerItem(IconData icon, String label, int index) => ListTile(
    leading: Icon(icon), title: Text(label), selected: _currentIndex == index,
    onTap: () { setState(() => _currentIndex = index); Navigator.pop(context); },
  );

  void _onFabPressed() {
    if (_currentIndex == 0) _showQuickActions();
    else if (_currentIndex == 6) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New journal entry coming soon')));
  }

  void _showQuickActions() => showModalBottomSheet(context: context, builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Padding(padding: EdgeInsets.all(16), child: Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
    ListTile(leading: const Icon(Icons.restaurant, color: Colors.orange), title: const Text('Log Feeding'), onTap: () { Navigator.pop(ctx); setState(() => _currentIndex = 2); }),
    ListTile(leading: const Icon(Icons.star, color: Colors.amber), title: const Text('Add Milestone'), onTap: () { Navigator.pop(ctx); setState(() => _currentIndex = 1); }),
    ListTile(leading: const Icon(Icons.medical_services, color: Colors.green), title: const Text('Add Health Record'), onTap: () { Navigator.pop(ctx); setState(() => _currentIndex = 3); }),
    const SizedBox(height: 16),
  ])));
}

/// Discover screen placeholder — Sleep screen still exists at apps/mobile/.../sleep/sleep_screen.dart
/// but is no longer shown in the bottom nav. Sleep tracking remains accessible via the Health screen.
class _DiscoverPlaceholder extends StatelessWidget {
  const _DiscoverPlaceholder();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Discover')),
    body: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.explore, size: 80, color: Colors.grey),
      SizedBox(height: 24),
      Text('Coming Soon', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
      SizedBox(height: 12),
      Padding(padding: EdgeInsets.symmetric(horizontal: 48), child: Text('Discover new features, tips, and community content.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))),
    ])),
  );
}