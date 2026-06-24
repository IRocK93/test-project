import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/core/core.dart';
import 'package:baby_mon/core/theme/theme_mode_provider.dart';
import 'package:baby_mon/core/utils/error_handler.dart';
import 'package:baby_mon/l10n/l10n_ext.dart';
const String measurementUnitsKey = 'measurement_units';
const String _biometricsEnabledKey = 'biometrics_enabled';
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}
class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _subscription;
  String? _babyMonId;
  Map<String, dynamic>? _babyMon;
  bool _isLoading = true;
  bool _isEditingName = false;
  bool _isMetric = true;
  bool _biometricsEnabled = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
      _loadUnitPref();
      _loadBiometricsPref();
      _loadActiveBabyMon();
    });
  }
  Future<void> _loadActiveBabyMon() async {
    try {
      final api = ref.read(apiClientProvider);
      final id = await api.getSelectedBabyMonId();
      if (id == null || id.isEmpty) return;
      if (mounted) setState(() => _babyMonId = id);  // Set immediately so Danger Zone shows
      final res = await api.getBabyMon(id);
      if (mounted) {
        final raw = res.data;
        setState(() => _babyMon = parseJsonMap(raw));
      }
    } catch (e) { debugPrint('Failed to load babyMon for settings: $e'); }
  }
  Future<void> _loadUnitPref() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final val = prefs.getString(measurementUnitsKey);
    if (mounted) setState(() => _isMetric = val != 'imperial');
  }
  Future<void> _saveUnitPref(bool metric) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(measurementUnitsKey, metric ? 'metric' : 'imperial');
    if (mounted) setState(() => _isMetric = metric);
  }
  Future<void> _loadBiometricsPref() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final enabled = prefs.getBool(_biometricsEnabledKey) ?? false;
    if (mounted) setState(() => _biometricsEnabled = enabled);
  }
  Future<void> _saveBiometricsPref(bool enabled) async {
    HapticFeedback.selectionClick();
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.setBool(_biometricsEnabledKey, enabled);
      if (mounted) setState(() => _biometricsEnabled = enabled);
    } catch (e) {
      // Roll back the optimistic UI update on failure.
      if (mounted) setState(() => _biometricsEnabled = !enabled);
    }
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
          _user = parseJsonMap(profileRes.data);
          _subscription = parseJsonMap(subRes.data);
          _babyMonId = babyMonId;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  Future<void> _editName() async {
    final messenger = ScaffoldMessenger.of(context);
    final nameController = TextEditingController(text: parseString(_user?['name']) ?? '');
    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Name'),
        content: SingleChildScrollView(
          child: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
            autofocus: true,
            textInputAction: TextInputAction.done,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, nameController.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() => _isEditingName = true);
      try {
        await ref.read(apiClientProvider).patch('/users/me', data: {'name': result});
        final profileRes = await ref.read(apiClientProvider).getProfile();
        if (mounted) {
          setState(() {
            _user = parseJsonMap(profileRes.data);
            _isEditingName = false;
          });
          messenger.showSnackBar(const SnackBar(content: Text('Name updated!')));
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isEditingName = false);
      messenger.showSnackBar(
        SnackBar(content: Text(extractErrorMessage(e))),
      );
        }
      }
    }
  }
  Future<void> _exportData() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (_babyMonId == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No BabyMon to export')),
      );
      return;
    }
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: Row(children: [
          ButtonLoading(),
          SizedBox(width: DesignTokens.spaceMd),
          Text('Exporting your data...'),
        ]),
      ),
    );
    try {
      final response = await ref.read(apiClientProvider).exportBabyMon(_babyMonId!);
      navigator.pop();
      if (mounted) {
        await Share.share(response.data.toString(), subject: 'BabyMon Export');
      }
    } catch (e) {
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text(extractErrorMessage(e))),
      );
    }
  }
  Future<void> _deleteBabyMon() async {
    if (_babyMonId == null) {
      _showComingSoon('Create a BabyMon first');
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      final api = ref.read(apiClientProvider);
      final allRes = await api.getBabyMons();
      final items = parseItems(allRes.data);
      final babyMons = items;
      if (babyMons.isEmpty) {
        if (mounted) {
          messenger.showSnackBar(
            const SnackBar(content: Text('No BabyMons to delete')),
          );
        }
        return;
      }
      if (!mounted) return;
      final selected = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (ctx) => SimpleDialog(
          title: const Text('Delete BabyMon'),
          children: [
            for (final bm in babyMons)
              SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, bm as Map<String, dynamic>),
                child: Row(children: [
                  const Icon(PhosphorIconsLight.baby),
                  const SizedBox(width: DesignTokens.spaceSm),
                  Text(parseString(bm['name']) ?? 'BabyMon'),
                ]),
              ),
          ],
        ),
      );
      if (selected == null) return;
      final name = selected['name'] ?? 'this BabyMon';
      final id = parseString(selected['id']) ?? '';
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Permanent Deletion'),
          content: Text(
            'You are about to permanently delete "$name".\n\n'
            'This will remove ALL data including milestones, feedings, photos, '
            'health records, and growth data.\n\nThis action CANNOT be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                'Delete Permanently',
                style: TextStyle(color: ctx.colorScheme.error),
              ),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await api.deleteBabyMon(id);
      if (id == _babyMonId) {
        await api.setSelectedBabyMonId('');
        _babyMonId = null;
        _babyMon = null;
      }
      ref.read(appRefreshProvider.notifier).state++;
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('BabyMon permanently deleted')),
        );
        if (_babyMonId == null) router.go('/create-baby-mon');
      }
    } catch (e) {
      if (mounted) {
      messenger.showSnackBar(
        SnackBar(content: Text(extractErrorMessage(e))),
      );
      }
    }
  }
  void _showClearDataMenu() {
    if (_babyMonId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No BabyMon selected')),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(DesignTokens.spaceMd),
              child: Text(
                'Clear Data',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ListTile(
              leading: Icon(PhosphorIconsLight.warning, color: ctx.colorScheme.error),
              title: const Text('Clear all allergies'),
              subtitle: const Text('Removes all allergy profiles and events'),
              onTap: () {
                Navigator.pop(ctx);
                _clearAllAllergies();
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(PhosphorIconsLight.xCircle, color: ctx.colorScheme.error),
              title: const Text('Clear all allergy events'),
              subtitle: const Text('Removes events but keeps allergy profiles'),
              onTap: () {
                Navigator.pop(ctx);
                _clearAllEvents();
              },
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _clearAllAllergies() async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all allergies'),
        content: const Text(
          'This will permanently delete all allergy profiles and their '
          'events for this BabyMon. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final result = await ref.read(apiClientProvider).clearAllAllergies(_babyMonId!);
      final count = parseJsonMap(result.data)?['deleted'] ?? 0;
      ref.read(appRefreshProvider.notifier).state++;
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('$count allergies cleared')));
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Could not clear. Please try again.')),
        );
      }
    }
  }
  Future<void> _clearAllEvents() async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all events'),
        content: const Text(
          'This will delete all allergy event records but keep the allergy '
          'profiles. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final result = await ref.read(apiClientProvider).clearAllAllergyEvents(_babyMonId!);
      final count = parseJsonMap(result.data)?['deleted'] ?? 0;
      ref.read(appRefreshProvider.notifier).state++;
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('$count events cleared')));
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Could not clear. Please try again.')),
        );
      }
    }
  }
  Future<void> _logout() async {
    final router = GoRouter.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel', style: TextStyle(color: context.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Log out', style: TextStyle(color: ctx.colorScheme.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final api = ref.read(apiClientProvider);
      await api.logout();
      if (mounted) router.go('/login');
    }
  }
  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature — coming soon')),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ScreenHeader(
        title: context.l10n.settings,
        onBack: () => popOrGoHome(context),
      ),
      body: PremiumBackground(
        child: _isLoading
            ? PremiumLoading.spinner()
            : ListView(
                padding: EdgeInsets.zero,
                children: [
                  // ── Identity Card ──
                  IdentityCard(
                    name: parseString(_user?['name']) ?? 'User',
                    email: parseString(_user?['email']) ?? '',
                    planName: parseString(_subscription?['tier']) ?? 'Free',
                    trialDaysRemaining: parseInt(_subscription?['trialDaysRemaining']),
                    onTap: _isEditingName ? null : _editName,
                  ),
                  // ── Preferences ──
                  const SettingsSectionHeader(title: 'Preferences'),
                  _SettingsCard(
                    children: [
                      SettingsRow(
                        icon: PhosphorIconsLight.crown,
                        iconColor: context.colorScheme.tertiary,
                        title: 'Subscription & Plan',
                        subtitle: 'Compare plans & upgrade',
                        trailing: Text(
                          parseString(_subscription?['tier']) ?? 'Free',
                          style: TextStyle(
                            fontSize: DesignTokens.fontMd,
                            fontWeight: FontWeight.w600,
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        onTap: () => context.push('/subscription'),
                      ),
                      SettingsRow(
                        icon: PhosphorIconsLight.bell,
                        iconColor: context.colorScheme.primary,
                        title: 'Notification preferences',
                        subtitle: 'Push, milestone reminders, partner activity',
                        onTap: () => _showComingSoon('Notification preferences'),
                      ),
                      SettingsRow(
                        icon: PhosphorIconsLight.fingerprint,
                        iconColor: context.colorScheme.primary,
                        title: 'Biometric login',
                        subtitle: 'Use fingerprint or face to sign in',
                        trailing: Switch.adaptive(
                          value: _biometricsEnabled,
                          onChanged: _saveBiometricsPref,
                        ),
                      ),
                  SettingsRow(
                    icon: PhosphorIconsLight.scales,
                    iconColor: context.colorScheme.primary,
                    title: 'Measurement units',
                    trailing: SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(value: true, label: Text('Metric')),
                          ButtonSegment(value: false, label: Text('Imperial')),
                        ],
                        selected: {_isMetric},
                        onSelectionChanged: (v) => _saveUnitPref(v.first),
                        showSelectedIcon: false,
                        style: ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: WidgetStateProperty.all(
                            const TextStyle(fontSize: DesignTokens.fontSm, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  SettingsRow(
                    icon: PhosphorIconsLight.paintBrush,
                    iconColor: context.colorScheme.secondary,
                    title: 'Visual style',
                    subtitle: 'Glass or Clay theme',
                    trailing: Consumer(
                      builder: (context, ref, _) {
                        final style = ref.watch(appVisualStyleProvider);
                        return SegmentedButton<AppVisualStyle>(
                          segments: const [
                            ButtonSegment(value: AppVisualStyle.glass, label: Text('Glass')),
                            ButtonSegment(value: AppVisualStyle.clay, label: Text('Clay')),
                          ],
                          selected: {style},
                          onSelectionChanged: (v) {
                            ref.read(appVisualStyleProvider.notifier).setStyle(v.first);
                          },
                          showSelectedIcon: false,
                          style: ButtonStyle(
                            visualDensity: VisualDensity.compact,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            textStyle: WidgetStateProperty.all(
                              const TextStyle(fontSize: DesignTokens.fontSm, fontWeight: FontWeight.w600),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SettingsRow(
                    icon: PhosphorIconsLight.sun,
                    iconColor: context.colorScheme.primary,
                    title: 'Theme mode',
                    subtitle: 'Light, dark, or follow system',
                    trailing: Consumer(
                      builder: (context, ref, _) {
                        final mode = ref.watch(appThemeModeProvider);
                        return SegmentedButton<AppThemeMode>(
                          segments: const [
                            ButtonSegment(value: AppThemeMode.system, label: Text('System')),
                            ButtonSegment(value: AppThemeMode.light, label: Text('Light')),
                            ButtonSegment(value: AppThemeMode.dark, label: Text('Dark')),
                          ],
                          selected: {mode},
                          onSelectionChanged: (v) {
                            ref.read(appThemeModeProvider.notifier).setMode(v.first);
                          },
                          showSelectedIcon: false,
                          style: ButtonStyle(
                            visualDensity: VisualDensity.compact,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            textStyle: WidgetStateProperty.all(
                              const TextStyle(fontSize: DesignTokens.font2xs, fontWeight: FontWeight.w600),
                            ),
                          ),
                        );
                      },
                    ),
                    last: true,
                  ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.spaceLg),
                  // ── BabyMon Data ──
                  const SettingsSectionHeader(title: 'BabyMon Data'),
                  _SettingsCard(
                    children: [
                      SettingsRow(
                        icon: PhosphorIconsLight.baby,
                        iconColor: context.colorScheme.secondary,
                        title: 'Active BabyMon',
                        subtitle: _babyMon == null
                            ? 'No BabyMon selected'
                            : 'Use the avatar in the top bar to switch',
                        trailing: _babyMon == null
                            ? null
                            : Text(
                                parseString(_babyMon!['name']) ?? 'Baby',
                                style: TextStyle(
                                  fontSize: DesignTokens.fontMd,
                                  fontWeight: FontWeight.w600,
                                  color: context.colorScheme.onSurface,
                                ),
                              ),
                      ),
                      SettingsRow(
                        icon: PhosphorIconsLight.users,
                        iconColor: context.colorScheme.primary,
                        title: 'Manage Partners',
                        subtitle: 'Co-parents & guardians with access',
                        onTap: () => context.push('/partners'),
                        last: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.spaceLg),
                  // ── Backup & Privacy ──
                  const SettingsSectionHeader(title: 'Backup & Privacy'),
                  _SettingsCard(
                    children: [
                      SettingsRow(
                        icon: PhosphorIconsLight.downloadSimple,
                        iconColor: context.colorScheme.primary,
                        title: 'Export data',
                        subtitle: 'Download all records as JSON',
                        onTap: _exportData,
                      ),
                      SettingsRow(
                        icon: PhosphorIconsLight.cloudArrowUp,
                        iconColor: context.colorScheme.primary,
                        title: 'Sync status',
                        subtitle: _babyMonId == null
                            ? 'No BabyMon selected'
                            : 'All changes saved',
                        trailing: Icon(
                          PhosphorIconsLight.checkCircle,
                          color: context.colorScheme.primary,
                          size: 20,
                        ),
                        last: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.spaceLg),
                  // ── Danger Zone ──
                  const SettingsSectionHeader(
                    title: 'Danger Zone',
                  ),
                  _SettingsCard(
                    danger: true,
                    children: [
                      SettingsRow(
                        icon: PhosphorIconsLight.broom,
                        iconColor: context.colorScheme.error,
                        title: 'Clear allergies & events',
                        subtitle: 'Remove allergy records for this BabyMon',
                        destructive: true,
                        onTap: _showClearDataMenu,
                      ),
                      SettingsRow(
                        icon: PhosphorIconsLight.trash,
                        iconColor: context.colorScheme.error,
                        title: 'Delete BabyMon',
                        subtitle: 'Permanently remove all data',
                        onTap: _deleteBabyMon,
                        destructive: true,
                      ),
                      SettingsRow(
                        icon: PhosphorIconsLight.signOut,
                        iconColor: context.colorScheme.error,
                        title: 'Log out',
                        subtitle: 'Sign out of this device',
                        onTap: _logout,
                        destructive: true,
                        last: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.spaceLg),
                ],
              ),
      ),
    );
  }
}
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final bool danger;
  const _SettingsCard({required this.children, this.danger = false});
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = danger
        ? colorScheme.errorContainer.withValues(alpha: 0.25)
        : isDark
            ? colorScheme.surface.withValues(alpha: 0.6)
            : colorScheme.surface.withValues(alpha: 0.8);
    final border = BorderSide(
      color: danger
          ? colorScheme.error.withValues(alpha: 0.3)
          : colorScheme.outline.withValues(alpha: 0.15),
      width: 0.5,
    );
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceLg),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(color: border.color, width: border.width),
      ),
      child: Column(
        children: [
          const SizedBox(height: DesignTokens.space2xs),
          ...children,
        ],
      ),
    );
  }
}