import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/core/core.dart';
import 'package:baby_mon/core/theme/theme_mode_provider.dart';
import 'package:baby_mon/core/widgets/legal_document_screen.dart';

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
            child: Text(
              'Clear',
              style: TextStyle(color: ctx.colorScheme.error),
            ),
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
            child: Text(
              'Clear',
              style: TextStyle(color: ctx.colorScheme.error),
            ),
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
        title: 'Settings',
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
                    planName: parseString(_subscription?['plan']) ?? 'Free',
                    trialDaysRemaining: parseInt(_subscription?['trialDaysRemaining']),
                    onTap: _isEditingName ? null : _editName,
                  ),

                  // ── Preferences ──
                  const SettingsSectionHeader(title: 'Preferences'),
                  _SettingsCard(
                    children: [
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
                            const TextStyle(
                              fontSize: DesignTokens.fontSm,
                              fontWeight: FontWeight.w600,
                            ),
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
                                  color: context.colorScheme.onSurfaceVariant,
                                ),
                              ),
                      ),
                      SettingsRow(
                        icon: PhosphorIconsLight.users,
                        iconColor: context.colorScheme.primary,
                        title: 'Manage Partners',
                        subtitle: 'Co-parents & guardians with access',
                        onTap: () => context.push('/partners'),
                      ),
                      SettingsRow(
                        icon: PhosphorIconsLight.crown,
                        iconColor: context.colorScheme.tertiary,
                        title: 'Subscription & Plan',
                        subtitle: 'Compare plans & upgrade',
                        trailing: Text(
                          parseString(_subscription?['plan']) ?? 'Free',
                          style: TextStyle(
                            fontSize: DesignTokens.fontMd,
                            fontWeight: FontWeight.w600,
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        onTap: () => context.push('/subscription'),
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
                        subtitle: 'Download milestones, feedings, health, photos',
                        onTap: _exportData,
                      ),
                      SettingsRow(
                        icon: PhosphorIconsLight.shieldCheck,
                        iconColor: context.colorScheme.primary,
                        title: 'Privacy & data sharing',
                        subtitle: 'Manage analytics and partner permissions',
                        onTap: () => _showComingSoon('Privacy settings'),
                      ),
                      SettingsRow(
                        icon: PhosphorIconsLight.devices,
                        iconColor: context.colorScheme.primary,
                        title: 'Sign out of all devices',
                        subtitle: 'Revoke all active sessions',
                        onTap: () => _showComingSoon('Sign out of all devices'),
                        last: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.spaceXl),

                  // ── Danger Zone ──
                  const SettingsSectionHeader(
                    title: 'Danger Zone',
                    danger: true,
                  ),
                  _SettingsCard(
                    danger: true,
                    children: [
                      if (_babyMonId != null) ...[
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
                        title: 'Delete this BabyMon',
                        subtitle: 'Permanently remove all baby data',
                        destructive: true,
                        onTap: _deleteBabyMon,
                      ),
                      ],
                      SettingsRow(
                        icon: PhosphorIconsLight.signOut,
                        iconColor: context.colorScheme.error,
                        title: 'Log out',
                        subtitle: 'Sign out of this device',
                        destructive: true,
                        onTap: _logout,
                        last: true,
                      ),
                    ],
                  ),

                  // ── Footer ──
                  const SizedBox(height: DesignTokens.space2xl),
                  const _SettingsFooter(),
                  const SizedBox(height: DesignTokens.space3xl),
                ],
              ),
      ),
    );
  }
}

/// A simple bordered card that groups [SettingsRow] children. Provides
/// the standard border, radius, and background. When [danger] is true,
/// a 2px red top border is rendered and the card background uses
/// [context.colorScheme.errorContainer] (faded).
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final bool danger;

  const _SettingsCard({required this.children, this.danger = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = danger
        ? Colors.transparent
        : (isDark ? context.glass.background : context.colorScheme.surface);
    final borderColor = danger
        ? context.colorScheme.error.withValues(alpha: 0.4)
        : (isDark ? context.colorScheme.outline : context.colorScheme.outline);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceLg,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: danger
            ? Border.all(color: context.colorScheme.error.withValues(alpha: 0.4), width: 1)
            : Border.all(color: borderColor, width: 0.5),
        boxShadow: danger ? null : DesignTokens.shadowSm(Colors.transparent),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

}

/// Extract a human-readable message from an error object.
String extractErrorMessage(Object e) {
  if (e is Exception) {
    final msg = e.toString();
    if (msg.startsWith('Exception: ')) return msg.substring(11);
    return msg;
  }
  return e.toString();
}

/// Centered footer with version number and legal links.
class _SettingsFooter extends StatelessWidget {
  const _SettingsFooter();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            'BabyMon v1.0.0',
            style: TextStyle(
              fontSize: DesignTokens.fontSm,
              fontWeight: FontWeight.w500,
              color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: DesignTokens.spaceSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _FooterLink(label: 'Terms', onTap: () => _openLegal(context, 'Terms & Conditions', _termsContent)),
              const _FooterDot(),
              _FooterLink(label: 'Privacy', onTap: () => _openLegal(context, 'Privacy Policy', _privacyContent)),
              const _FooterDot(),
              _FooterLink(label: 'Support', onTap: () => _openLegal(context, 'Support', _supportContent)),
            ],
          ),
        ],
      ),
    );
  }
}

void _openLegal(BuildContext context, String title, String content) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => LegalDocumentScreen(title: title, content: content),
    ),
  );
}

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _FooterLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: Theme.of(context).brightness == Brightness.dark ? context.colorScheme.onSurfaceVariant : context.colorScheme.onSurfaceVariant,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: DesignTokens.fontSm, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _FooterDot extends StatelessWidget {
  const _FooterDot();
  @override
  Widget build(BuildContext context) => Text(
        '·',
        style: TextStyle(
          color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          fontSize: DesignTokens.fontSm,
        ),
      );
}

const _termsContent = '''
## Terms & Conditions

By using BabyMon, you agree to these terms.

### Medical Disclaimer
BabyMon is NOT a medical device. All content is informational only. Always consult a qualified healthcare provider for medical concerns. In an emergency, call 911 immediately.

### Age Requirement
You must be 18+ and the parent or legal guardian of any child whose data you enter.

### Subscriptions
AI COMPANION is a paid subscription. Free trials auto-renew unless cancelled 24 hours before renewal. Cancel anytime through your app store settings.

### AI Companion
The AI Companion uses an on-device language model. AI-generated advice may be inaccurate. You are responsible for verifying all AI information with a healthcare professional.

### Privacy
Your data is stored securely. The AI Companion runs entirely on your device — no child health data is sent to external AI services.

### Liability
BabyMon is provided "as is" without warranties. We are not liable for damages arising from your use of the app or reliance on its content.
''';

const _privacyContent = '''
## Privacy Policy

### What We Collect
Account information (email, name), child profiles (name, birth date, gender, traits), health and tracking data you enter (feeding, sleep, growth, milestones, allergies), photos you upload, device tokens for notifications.

### How We Use It
To provide app features, to personalize your AI Companion (on-device only), and to improve the app with de-identified aggregated data.

### AI & Privacy
The AI Companion runs ENTIRELY on your device. No child health data is ever sent to external AI APIs.

### Third Parties
Stripe (payments), Firebase (notifications), AWS (photo storage), Neon (database).

### Your Rights
Export your data, delete your account, or request data deletion anytime in Settings.

### Children's Privacy
We are committed to protecting children's privacy and building a secure, trustworthy environment for families.
''';

const _supportContent = '''
## Support

### Contact
Email: support@babymon.app

### Common Questions

**How do I cancel?**
Go to your device app store → Subscriptions → BabyMon → Cancel.

**Is my data private?**
Yes. Your child's health data is stored securely. The AI Companion runs on-device. No data is sold or shared.

**How accurate is the AI Companion?**
The AI Companion provides informational guidance only. It is NOT a substitute for professional medical advice. Always verify with your healthcare provider.

**Can I export my data?**
Yes. Settings → Export Data.

**How do I delete my account?**
Settings → Account → Delete Account.

**What if I find incorrect advice?**
Report to support@babymon.app. We continuously improve our content.

### Emergency
BabyMon is NOT for medical emergencies. If your child needs immediate medical attention, call 911 (US) or your local emergency number.
''';
