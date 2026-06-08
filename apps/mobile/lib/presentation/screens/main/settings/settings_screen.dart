import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baby_mon/data/api_client.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/presentation/providers/auth_provider.dart';
import 'partners_screen.dart';
import 'subscription_screen.dart';

/// Global measurement units key used across feeding/health screens
const String measurementUnitsKey = 'measurement_units';

/// Settings screen with profile editing, subscription, export, deletion, and logout.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _subscription;
  String? _babyMonId;
  bool _isLoading = true;
  bool _isEditingName = false;
  bool _isMetric = true;

  Future<void> _loadUnitPref() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getString(measurementUnitsKey);
    if (mounted) setState(() => _isMetric = val != 'imperial');
  }

  Future<void> _saveUnitPref(bool metric) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(measurementUnitsKey, metric ? 'metric' : 'imperial');
    if (mounted) setState(() => _isMetric = metric);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) { _loadSettings(); _loadUnitPref(); });
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiClientProvider);
      final profileRes = await api.getProfile();
      final subRes = await api.getSubscription();
      final babyMonId = await api.getSelectedBabyMonId();
      if (mounted) {
        setState(() {
          _user = profileRes.data;
          _subscription = subRes.data;
          _babyMonId = babyMonId;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Shows an edit dialog to change the user's display name
  Future<void> _editName() async {
    final nameController = TextEditingController(text: _user?['name'] ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, nameController.text), child: const Text('Save')),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() => _isEditingName = true);
      try {
        // Use /users/me (generic patch adds /api prefix)
        await ref.read(apiClientProvider).patch('/users/me', data: {'name': result});
        final profileRes = await ref.read(apiClientProvider).getProfile();
        if (mounted) {
          setState(() {
            _user = profileRes.data;
            _isEditingName = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name updated!')));
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isEditingName = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  Future<void> _exportData() async {
    if (_babyMonId == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No BabyMon to export')));
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: Row(children: [CircularProgressIndicator(), SizedBox(width: 16), Text('Exporting your data...')]),
      ),
    );
    try {
      final response = await ref.read(apiClientProvider).exportBabyMon(_babyMonId!);
      if (mounted) Navigator.pop(context);
      if (mounted) await Share.share(response.data.toString(), subject: 'BabyMon Export');
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export error: $e')));
    }
  }

  Future<void> _deleteBabyMon() async {
    try {
      final api = ref.read(apiClientProvider);
      // Fetch all BabyMons so user can choose which to delete
      final allRes = await api.getBabyMons();
      final items = (allRes.data is List) ? allRes.data : ((allRes.data as Map)['items'] as List?) ?? [];
      final babyMons = items as List<dynamic>;
      if (babyMons.isEmpty) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No BabyMons to delete')));
        return;
      }
      // Show picker to choose which BabyMon
      final selected = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete BabyMon'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: babyMons.length,
              itemBuilder: (_, i) {
                final bm = babyMons[i] as Map<String, dynamic>;
                final name = bm['name'] as String? ?? 'BabyMon';
                return ListTile(
                  leading: const Icon(Icons.child_care),
                  title: Text(name),
                  onTap: () => Navigator.pop(ctx, bm),
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ],
        ),
      );
      if (selected == null) return;
      final name = selected['name'] ?? 'this BabyMon';
      final id = selected['id'] as String;
      // Confirmation with explicit warning
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('⚠️ Permanent Deletion'),
          content: Text('You are about to permanently delete "$name".\n\nThis will remove ALL data including milestones, feedings, photos, health records, and growth data.\n\nThis action CANNOT be undone.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete Permanently', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await api.deleteBabyMon(id);
      if (id == _babyMonId) {
        await api.setSelectedBabyMonId('');
        _babyMonId = null;
      }
      ref.read(appRefreshProvider.notifier).state++;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('BabyMon permanently deleted')));
        if (_babyMonId == null) GoRouter.of(context).go('/create-baby-mon');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete. Please try again.')));
      }
    }
  }

  void _showClearDataMenu() {
    if (_babyMonId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No BabyMon selected')));
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(padding: EdgeInsets.all(16), child: Text('Clear Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ListTile(
            leading: const Icon(Icons.warning_amber, color: Colors.orange),
            title: const Text('Clear All Allergies'),
            subtitle: const Text('Deletes all allergy profiles and events'),
            onTap: () { Navigator.pop(ctx); _clearAllAllergies(); },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.event_busy, color: Colors.orange),
            title: const Text('Clear All Events'),
            subtitle: const Text('Deletes allergy events but keeps profiles'),
            onTap: () { Navigator.pop(ctx); _clearAllEvents(); },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Delete BabyMon'),
            subtitle: const Text('Permanently remove all baby data'),
            onTap: () { Navigator.pop(ctx); _deleteBabyMon(); },
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  Future<void> _clearAllAllergies() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Allergies'),
        content: const Text('This will permanently delete all allergy profiles and their events for this BabyMon. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Clear', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final result = await ref.read(apiClientProvider).clearAllAllergies(_babyMonId!);
      final count = (result.data is Map) ? (result.data as Map)['deleted'] ?? 0 : 0;
      ref.read(appRefreshProvider.notifier).state++;
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$count allergies cleared')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _clearAllEvents() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Events'),
        content: const Text('This will delete all allergy event records but keep the allergy profiles. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Clear', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final result = await ref.read(apiClientProvider).clearAllAllergyEvents(_babyMonId!);
      final count = (result.data is Map) ? (result.data as Map)['deleted'] ?? 0 : 0;
      ref.read(appRefreshProvider.notifier).state++;
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$count events cleared')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Logout')),
        ],
      ),
    );
    if (confirmed == true) {
      final api = ref.read(apiClientProvider);
      await api.logout();
      if (mounted) GoRouter.of(context).go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).go('/home'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(radius: 32, child: Text((_user?['name'] ?? 'U').toString().substring(0, 1).toUpperCase())),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: _editName,
                                child: Row(children: [
                                  Text(_user?['name'] ?? 'User', style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(width: 4),
                                  Icon(Icons.edit, size: 14, color: Colors.grey.shade500),
                                ]),
                              ),
                              Text(_user?['email'] ?? '', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                        if (_isEditingName) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [const Icon(Icons.workspace_premium, size: 20), const SizedBox(width: 8), Text('Subscription', style: Theme.of(context).textTheme.titleMedium)]),
                        const SizedBox(height: 8),
                        Text('Plan: ${_subscription?['plan'] ?? 'Free'}'),
                        if (_subscription?['trialDaysRemaining'] != null) Text('Trial: ${_subscription!['trialDaysRemaining']} days remaining'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [const Icon(Icons.scale, size: 20), const SizedBox(width: 8), Text('Measurement Units', style: Theme.of(context).textTheme.titleMedium)]),
                        const SizedBox(height: 12),
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment(value: true, label: Text('Metric'), icon: Icon(Icons.straighten, size: 14)),
                            ButtonSegment(value: false, label: Text('Imperial'), icon: Icon(Icons.straighten, size: 14)),
                          ],
                          selected: {_isMetric},
                          onSelectionChanged: (v) => _saveUnitPref(v.first),
                        ),
                        const SizedBox(height: 4),
                        Text(_isMetric ? 'Weights in kg, lengths in cm, temp in °C, volumes in ml' : 'Weights in lbs, lengths in in, temp in °F, volumes in fl oz', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(leading: const Icon(Icons.compare_arrows), title: const Text('Subscription Plans'), subtitle: const Text('Compare plans & upgrade'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()))),
                const Divider(),
                ListTile(leading: const Icon(Icons.group_add, color: Colors.indigo), title: const Text('Manage Partners'), subtitle: const Text('Invite co-parents & guardians'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PartnersScreen()))),
                const Divider(),
                ListTile(leading: const Icon(Icons.cleaning_services, color: Colors.orange), title: const Text('Clear Data'), subtitle: const Text('Manage allergies, events, baby data & account'), trailing: const Icon(Icons.chevron_right), onTap: _showClearDataMenu),
                const Divider(),
                ListTile(leading: const Icon(Icons.download), title: const Text('Export Data'), trailing: const Icon(Icons.chevron_right), onTap: _exportData),
                const Divider(),
                ListTile(leading: const Icon(Icons.logout, color: Colors.orange), title: const Text('Logout', style: TextStyle(color: Colors.orange)), trailing: const Icon(Icons.chevron_right, color: Colors.orange), onTap: _logout),
              ],
            ),
    );
  }
}