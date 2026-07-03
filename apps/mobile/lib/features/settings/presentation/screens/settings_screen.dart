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
  Future<void> _saveLocalePref(String locale) async {
    HapticFeedback.selectionClick();
    try {
      // Update provider first for immediate RTL layout change
      await ref.read(localeProvider.notifier).setLocale(locale);
      // Sync to backend
      await ref.read(apiClientProvider).patch('/users/me/locale', data: {'locale': locale});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(extractErrorMessage(e))),
        );
      }
    }
  }
  Future<void> _showLanguagePicker() async {
    final currentLocale = ref.read(localeProvider).languageCode;
    const flags = {
      'en': '🇬🇧', 'es': '🇪🇸', 'fr': '🇫🇷', 'pt': '🇵🇹',
      'de': '🇩🇪', 'ar': '🇸🇦', 'he': '🇮🇱', 'zh': '🇨🇳',
      'it': '🇮🇹',
    };
    final languages = [
      ('en', flags['en']!, context.l10n.languageEnglish),
      ('es', flags['es']!, context.l10n.languageSpanish),
      ('fr', flags['fr']!, context.l10n.languageFrench),
      ('pt', flags['pt']!, context.l10n.languagePortuguese),
      ('de', flags['de']!, context.l10n.languageGerman),
      ('ar', flags['ar']!, context.l10n.languageArabic),
      ('he', flags['he']!, context.l10n.languageHebrew),
      ('zh', flags['zh']!, context.l10n.languageChinese),
      ('it', flags['it']!, context.l10n.languageItalian),
    ];
    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(context.l10n.selectLanguage),
        children: languages.map((lang) {
          final code = lang.$1;
          final flag = lang.$2;
          final label = lang.$3;
          final isSelected = currentLocale == code;
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, code),
            child: Row(
              children: [
                Text(flag, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: DesignTokens.spaceMd),
                Text(label),
                if (isSelected) ...[
                  const Spacer(),
                  Icon(PhosphorIconsLight.check, color: ctx.colorScheme.primary),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
    if (selected != null && selected != currentLocale) {
      await _saveLocalePref(selected);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.localeUpdated)),
        );
      }
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
        title: Text(context.l10n.editName),
        content: SingleChildScrollView(
          child: TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: context.l10n.nameLabel),
            autofocus: true,
            textInputAction: TextInputAction.done,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, nameController.text),
            child: Text(context.l10n.saveButton),
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
          messenger.showSnackBar(SnackBar(content: Text(context.l10n.nameUpdated)));
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
        SnackBar(content: Text(context.l10n.noBabyMonToExport)),
      );
      return;
    }
    showDialog<void>(
      context: context,
      barrierDismissible: false,        builder: (ctx) => AlertDialog(
        content: Row(children: [
          const ButtonLoading(),
          const SizedBox(width: DesignTokens.spaceMd),
          Text(context.l10n.exportingData),
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
      _showComingSoon(context.l10n.createBabyMonFirst);
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
            SnackBar(content: Text(context.l10n.noBabyMonsToDelete)),
          );
        }
        return;
      }
      if (!mounted) return;
      final selected = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (ctx) => SimpleDialog(
          title: Text(context.l10n.deleteBabyMon),
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
      final id = parseString(selected['id']) ?? '';
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(context.l10n.permanentDeletion),
          content: Text(
            context.l10n.deleteBabyMonConfirm,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(context.l10n.cancelButton),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                context.l10n.deletePermanently,
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
          SnackBar(content: Text(context.l10n.babyMonDeleted)),
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
        SnackBar(content: Text(context.l10n.noBabyMonSelected)),
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
                context.l10n.clearData,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ListTile(
              leading: Icon(PhosphorIconsLight.warning, color: ctx.colorScheme.error),
              title: Text(context.l10n.clearAllAllergies),
              subtitle: Text(context.l10n.clearAllAllergiesDesc),
              onTap: () {
                Navigator.pop(ctx);
                _clearAllAllergies();
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(PhosphorIconsLight.xCircle, color: ctx.colorScheme.error),
              title: Text(context.l10n.clearAllEvents),
              subtitle: Text(context.l10n.clearAllEventsDesc),
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
        title: Text(context.l10n.clearAllAllergies),
        content: Text(
          context.l10n.clearAllAllergiesDesc,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.clearButton),
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
        messenger.showSnackBar(SnackBar(content: Text('$count ${context.l10n.allergiesCleared}')));
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(context.l10n.couldNotClear)),
        );
      }
    }
  }
  Future<void> _clearAllEvents() async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.clearAllEvents),
        content: Text(
          context.l10n.clearAllEventsDesc,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.clearButton),
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
        messenger.showSnackBar(SnackBar(content: Text('$count ${context.l10n.eventsCleared}')));
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(context.l10n.couldNotClear)),
        );
      }
    }
  }
  Future<void> _logout() async {
    final router = GoRouter.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.logOutTitle),
        content: Text(context.l10n.logOutConfirm),
        actions: [          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(context.l10n.cancelButton, style: TextStyle(color: context.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(context.l10n.logOutTitle, style: TextStyle(color: ctx.colorScheme.error)),
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
  String _localeName(BuildContext context) {
    final code = ref.watch(localeProvider).languageCode;
    const flags = {
      'en': '🇬🇧', 'es': '🇪🇸', 'fr': '🇫🇷', 'pt': '🇵🇹',
      'de': '🇩🇪', 'ar': '🇸🇦', 'he': '🇮🇱', 'zh': '🇨🇳',
      'it': '🇮🇹',
    };
    final flag = flags[code] ?? '';
    final name = switch (code) {
      'en' => context.l10n.languageEnglish,
      'es' => context.l10n.languageSpanish,
      'fr' => context.l10n.languageFrench,
      'pt' => context.l10n.languagePortuguese,
      'de' => context.l10n.languageGerman,
      'ar' => context.l10n.languageArabic,
      'he' => context.l10n.languageHebrew,
      'zh' => context.l10n.languageChinese,
      'it' => context.l10n.languageItalian,
      _ => code.toUpperCase(),
    };
    return '$flag $name';
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.featureComingSoon(feature))),
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
                  SettingsSectionHeader(title: context.l10n.preferences),
                  _SettingsCard(
                    children: [
                      SettingsRow(
                        icon: PhosphorIconsLight.crown,
                        iconColor: context.colorScheme.tertiary,
                        title: context.l10n.subscriptionAndPlan,
                        subtitle: context.l10n.comparePlans,
                        trailing: Text(
                          parseString(_subscription?['tier']) ?? context.l10n.freePlan,
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
                        title: context.l10n.notificationPreferences,
                        subtitle: context.l10n.notificationPreferencesDesc,
                        onTap: () => _showComingSoon(context.l10n.notificationPreferences),
                      ),
                      SettingsRow(
                        icon: PhosphorIconsLight.fingerprint,
                        iconColor: context.colorScheme.primary,
                        title: context.l10n.biometricLoginSetting,
                        subtitle: context.l10n.biometricLoginDesc,
                        trailing: Switch.adaptive(
                          value: _biometricsEnabled,
                          onChanged: _saveBiometricsPref,
                        ),
                      ),
                      SettingsRow(
                        icon: PhosphorIconsLight.globe,
                        iconColor: context.colorScheme.primary,
                        title: context.l10n.languageSetting,
                        subtitle: _localeName(context),
                        onTap: _showLanguagePicker,
                      ),
                      SettingsRow(
                    icon: PhosphorIconsLight.scales,
                    iconColor: context.colorScheme.primary,
                    title: context.l10n.measurementUnits,
                    trailing: SegmentedButton<bool>(
                        segments: [
                          ButtonSegment(value: true, label: Text(context.l10n.metric), enabled: true),
                          ButtonSegment(value: false, label: Text(context.l10n.imperial), enabled: true),
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
                    ),                  SettingsRow(
                    icon: PhosphorIconsLight.paintBrush,
                    iconColor: context.colorScheme.secondary,
                    title: context.l10n.visualStyle,
                        subtitle: context.l10n.visualStyleDesc,
                    trailing: Consumer(
                      builder: (context, ref, _) {
                        final style = ref.watch(appVisualStyleProvider);
                        return SegmentedButton<AppVisualStyle>(
                          segments: [
                            ButtonSegment(value: AppVisualStyle.glass, label: Text(context.l10n.visualStyleGlass)),
                            ButtonSegment(value: AppVisualStyle.clay, label: Text(context.l10n.visualStyleClay)),
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
                  ),                  SettingsRow(
                    icon: PhosphorIconsLight.sun,
                    iconColor: context.colorScheme.primary,
                    title: context.l10n.themeMode,
                        subtitle: context.l10n.themeModeDesc,
                    trailing: Consumer(
                      builder: (context, ref, _) {
                        final mode = ref.watch(appThemeModeProvider);
                        return SegmentedButton<AppThemeMode>(
                          segments: [
                            ButtonSegment(value: AppThemeMode.system, label: Text(context.l10n.themeSystem)),
                            ButtonSegment(value: AppThemeMode.light, label: Text(context.l10n.themeLight)),
                            ButtonSegment(value: AppThemeMode.dark, label: Text(context.l10n.themeDark)),
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
                  SettingsSectionHeader(title: context.l10n.babyMonData),
                  _SettingsCard(
                    children: [
                      SettingsRow(
                        icon: PhosphorIconsLight.baby,
                        iconColor: context.colorScheme.secondary,
                        title: context.l10n.activeBabyMon,
                        subtitle: _babyMon == null
                            ? context.l10n.noBabyMonSelected
                            : context.l10n.switchBabyMonHint,
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
                        title: context.l10n.managePartners,
                        subtitle: context.l10n.managePartnersDesc,
                        onTap: () => context.push('/partners'),
                        last: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.spaceLg),
                  // ── Backup & Privacy ──
                  SettingsSectionHeader(title: context.l10n.backupPrivacy),
                  _SettingsCard(
                    children: [
                      SettingsRow(
                        icon: PhosphorIconsLight.downloadSimple,
                        iconColor: context.colorScheme.primary,
                        title: context.l10n.exportData,
                        subtitle: context.l10n.exportDataDesc,
                        onTap: _exportData,
                      ),
                      SettingsRow(
                        icon: PhosphorIconsLight.cloudArrowUp,
                        iconColor: context.colorScheme.primary,
                        title: context.l10n.syncStatus,
                        subtitle: _babyMonId == null
                            ? context.l10n.noBabyMonSelected
                            : context.l10n.allChangesSaved,
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
                  SettingsSectionHeader(
                    title: context.l10n.dangerZone,
                  ),
                  _SettingsCard(
                    danger: true,
                    children: [
                      SettingsRow(
                        icon: PhosphorIconsLight.broom,
                        iconColor: context.colorScheme.error,
                        title: context.l10n.clearAllergiesEvents,
                        subtitle: context.l10n.clearAllergiesEventsDesc,
                        destructive: true,
                        onTap: _showClearDataMenu,
                      ),
                      SettingsRow(
                        icon: PhosphorIconsLight.trash,
                        iconColor: context.colorScheme.error,
                        title: context.l10n.deleteBabyMon,
                        subtitle: context.l10n.deleteBabyMonDesc,
                        onTap: _deleteBabyMon,
                        destructive: true,
                      ),
                      SettingsRow(
                        icon: PhosphorIconsLight.signOut,
                        iconColor: context.colorScheme.error,
                        title: context.l10n.logOutTitle,
                        subtitle: context.l10n.signOutDevice,
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