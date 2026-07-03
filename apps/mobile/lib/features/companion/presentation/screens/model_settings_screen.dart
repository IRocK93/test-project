import 'package:flutter/material.dart';
// ignore_for_file: unused_element
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import 'package:baby_mon/core/theme/design_tokens.dart';
import 'package:baby_mon/l10n/l10n_ext.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/features/companion/presentation/providers/llm_provider.dart';
import 'package:baby_mon/features/companion/presentation/providers/companion_provider.dart';
import 'package:baby_mon/features/companion/presentation/screens/medical_disclaimer_gate.dart';
import 'package:baby_mon/features/companion/presentation/screens/model_download_screen.dart';
import 'package:baby_mon/features/companion/presentation/screens/model_onboarding_screen.dart';
import 'package:baby_mon/features/companion/presentation/widgets/companion_theme.dart';
import 'package:baby_mon/features/companion/data/llm/model_manager.dart';
/// Settings screen for managing on-device AI models.
///
/// Shows installed models, allows switching active model, deleting models,
/// and downloading additional models.
class ModelSettingsScreen extends ConsumerStatefulWidget {
  final String babyMonId;
  const ModelSettingsScreen({super.key, required this.babyMonId});
  @override
  ConsumerState<ModelSettingsScreen> createState() => _ModelSettingsScreenState();
}
class _ModelSettingsScreenState extends ConsumerState<ModelSettingsScreen> {
  List<ModelRegistryEntry> _installed = [];
  String? _activeVersion;
  bool _isLoading = true;
  bool _isPremium = false;
  @override
  void initState() {
    super.initState();
    _load();
  }
  Future<void> _load() async {
    setState(() => _isLoading = true);
    // Capture strings before any async gaps
    final premiumPlanLabel = context.l10n.premiumPlan;
    try {
      final modelManager = await ref.read(modelManagerProvider.future);
      final installed = await modelManager.getInstalledVersions();
      final activeVersion = await modelManager.getActiveVersion();
      // Re-check subscription
      bool isPremium = false;
      try {
        final api = ref.read(apiClientProvider);
        final subRes = await api.getSubscription();
        final subData = subRes.data as Map<String, dynamic>?;
        isPremium = subData?['tier'] == premiumPlanLabel;
      } catch (_) {}
      if (mounted) {
        setState(() {
          _installed = installed;
          _activeVersion = activeVersion;
          _isPremium = isPremium;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  Future<void> _setActive(ModelRegistryEntry entry) async {
    final modelManager = await ref.read(modelManagerProvider.future);
    await modelManager.setActiveVersion(entry.version);
    final engine = ref.read(llamadartEngineProvider);
    if (engine.isLoaded) engine.unload();
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.switchToModelMessage(_modelDisplayName(entry.version)))),
      );
    }
  }
  Future<void> _deactivateModel() async {
    final modelManager = await ref.read(modelManagerProvider.future);
    await modelManager.setActiveVersion(null);
    final engine = ref.read(llamadartEngineProvider);
    if (engine.isLoaded) engine.unload();
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.switchedToBasic)),
      );
    }
  }
  Future<void> _deleteModel(ModelRegistryEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.deleteModel),
        content: Text(
          context.l10n.deleteModelConfirm,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.delete, style: TextStyle(color: ctx.colorScheme.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final modelManager = await ref.read(modelManagerProvider.future);
    // If this was the active model, unload it
    if (entry.version == _activeVersion) {
      final engine = ref.read(llamadartEngineProvider);
      if (engine.isLoaded) engine.unload();
    }
    await modelManager.removeVersion(entry.version);
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_modelDisplayName(entry.version)} deleted')),
      );
    }
  }
  void _downloadModel(String url, String version, int sizeBytes) {
    // Disclaimer gate — required before any model download
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MedicalDisclaimerGate(
          onAccept: () {
            Navigator.of(context).pop(); // close disclaimer
            _startDownload(url, version, sizeBytes);
          },
        ),
      ),
    );
  }
  void _startDownload(String url, String version, int sizeBytes) {
    final baseDir = ref.read(modelManagerProvider).asData?.value.baseDirectory ?? '';
    final fileName = url.split('/').last;
    final downloadPath = '$baseDir/$fileName';
    Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ModelDownloadScreen(
          url: url,
          destinationPath: downloadPath,
          version: version,
          sizeBytes: sizeBytes,
          onComplete: () => Navigator.of(context).pop(true),
        ),
      ),
    ).then((_) {
      // Refresh after route pops — gives registration time to complete
      Future.delayed(const Duration(milliseconds: 300), _load);
    });
  }
  String _modelDisplayName(String version) {
    if (version.startsWith('smollm2')) return context.l10n.quickStart;
    if (version.startsWith('smollm3')) return context.l10n.betterQuality;
    return version;
  }
  String _modelTechnicalName(String version) {
    if (version.startsWith('smollm2')) return 'SmolLM2 360M';
    if (version.startsWith('smollm3')) return 'SmolLM3 3B';
    return '';
  }
  int _modelSizeEstimate(String version) {
    if (version.startsWith('smollm2')) return 271000000;
    if (version.startsWith('smollm3')) return premiumModelSizeBytes;
    return 0;
  }
  static String _formatBytes(int bytes) {
    if (bytes >= 1000000000) return '${(bytes / 1000000000).toStringAsFixed(1)} GB';
    return '${(bytes / 1000000).toStringAsFixed(0)} MB';
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.aiModelSection),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(DesignTokens.spaceLg),
              children: [
                // ── Active model selection (radio buttons) ──
                _SectionHeader(title: context.l10n.activeModel),
                const SizedBox(height: DesignTokens.spaceSm),
                // Basic mode (no AI)
                _RadioTile(
                  title: context.l10n.basicMode,
                  subtitle: context.l10n.contentCardsOnly,
                  icon: PhosphorIconsLight.noteBlank,
                  isSelected: _activeVersion == null,
                  onTap: _activeVersion != null ? _deactivateModel : null,
                ),
                const SizedBox(height: DesignTokens.spaceXs),
                // Installed models
                ..._installed.map((entry) => _InstalledModelTile(
                  entry: entry,
                  isActive: entry.version == _activeVersion,
                  onSetActive: () => _setActive(entry),
                  onDelete: () => _deleteModel(entry),
                )),
                const SizedBox(height: DesignTokens.spaceXl),
                if (_installed.isEmpty) ...[
                  _EmptyState(),
                  const SizedBox(height: DesignTokens.spaceXl),
                ],
                // ── Available to download ──
                _SectionHeader(title: _installed.isEmpty ? context.l10n.downloadAiModel : context.l10n.availableToDownload),
                const SizedBox(height: DesignTokens.spaceSm),
                // Quick Start — always available
                _AvailableModelTile(
                  name: context.l10n.quickStart,
                  description: context.l10n.instantAnswersFast,
                  sizeBytes: 271000000,
                  isInstalled: _installed.any((e) => e.version.startsWith('smollm2')),
                  onDownload: () => _downloadModel(
                    'https://huggingface.co/bartowski/SmolLM2-360M-Instruct-GGUF/resolve/main/SmolLM2-360M-Instruct-Q4_K_M.gguf',
                    'smollm2-360m-v2',
                    271000000,
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceSm),
                // Better Quality — premium only
                _AvailableModelTile(
                  name: context.l10n.betterQuality,
                  description: context.l10n.deeperReasoningNuanced,
                  sizeBytes: premiumModelSizeBytes,
                  isPremium: true,
                  userIsPremium: _isPremium,
                  isInstalled: _installed.any((e) => e.version.startsWith('smollm3')),
                  onDownload: () => _downloadModel(
                    premiumModelUrl,
                    premiumModelVersion,
                    premiumModelSizeBytes,
                  ),
                ),
                const SizedBox(height: DesignTokens.space3xl),
                // ── Info footer ──
                Text(
                  '${context.l10n.modelsRunOnDeviceDesc} ${context.l10n.modelsStoredLocallyDesc}',
                  style: TextStyle(
                    fontSize: DesignTokens.fontSm,
                    color: context.textCaption,
                    height: 1.5,
                  ),
                ),
              ],
            ),
    );
  }
}
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: DesignTokens.fontXs,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: context.textCaption,
      ),
    );
  }
}
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceXl),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(color: context.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(PhosphorIconsLight.downloadSimple, size: 40, color: context.textCaption),
          const SizedBox(height: DesignTokens.spaceMd),
          Text(
            context.l10n.noAiModelInstalled,
            style: TextStyle(
              fontSize: DesignTokens.fontLg,
              fontWeight: FontWeight.w600,
              color: context.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceSm),
          Text(
            context.l10n.downloadModelBelow,
            style: TextStyle(fontSize: DesignTokens.fontSm, color: context.textSecondary),
          ),
        ],
      ),
    );
  }
}
class _InstalledModelTile extends StatelessWidget {
  final ModelRegistryEntry entry;
  final bool isActive;
  final VoidCallback onSetActive;
  final VoidCallback onDelete;
  const _InstalledModelTile({
    required this.entry,
    required this.isActive,
    required this.onSetActive,
    required this.onDelete,
  });
  String get _displayName {
    if (entry.version.startsWith('smollm2')) return 'Quick Start';
    if (entry.version.startsWith('smollm3')) return 'Better Quality';
    return entry.version;
  }
  String get _technicalName {
    if (entry.version.startsWith('smollm2')) return 'SmolLM2 360M';
    if (entry.version.startsWith('smollm3')) return 'SmolLM3 3B';
    return '';
  }
  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, yyyy').format(entry.installedAt);
    final sizeStr = _ModelSettingsScreenState._formatBytes(entry.sizeBytes);
    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(
          color: isActive
              ? context.colorScheme.primary.withValues(alpha: 0.4)
              : context.colorScheme.outline.withValues(alpha: 0.2),
          width: isActive ? 1.5 : 0.5,
        ),
      ),
      child: InkWell(
        onTap: isActive ? null : onSetActive,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spaceMd),
          child: Row(
            children: [
              // ignore: deprecated_member_use
              Radio<bool>(
                value: true,
                // ignore: deprecated_member_use
                groupValue: isActive,
                // ignore: deprecated_member_use
                onChanged: (_) => onSetActive(),
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: DesignTokens.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_displayName,
                      style: TextStyle(fontSize: DesignTokens.fontMd, fontWeight: FontWeight.w600, color: context.colorScheme.onSurface)),
                    Text('$sizeStr • $dateStr',
                      style: TextStyle(fontSize: DesignTokens.fontSm, color: context.textSecondary)),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(PhosphorIconsLight.trash, size: 18, color: context.colorScheme.error.withValues(alpha: 0.7)),
                onPressed: onDelete,
                tooltip: context.l10n.deleteModelTooltip,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _RadioTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;
  const _RadioTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(color: context.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spaceMd),
          child: Row(
            children: [
              // ignore: deprecated_member_use
              Radio<bool>(
                value: true,
                // ignore: deprecated_member_use
                groupValue: isSelected,
                // ignore: deprecated_member_use
                onChanged: (_) => onTap?.call(),
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: DesignTokens.spaceSm),
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: context.textCaption.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 16, color: context.textSecondary),
              ),
              const SizedBox(width: DesignTokens.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: DesignTokens.fontMd, fontWeight: FontWeight.w600, color: context.colorScheme.onSurface)),
                    Text(subtitle, style: TextStyle(fontSize: DesignTokens.fontSm, color: context.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _AvailableModelTile extends StatelessWidget {
  final String name;
  final String description;
  final int sizeBytes;
  final bool isPremium;
  final bool userIsPremium;
  final bool isInstalled;
  final VoidCallback onDownload;
  const _AvailableModelTile({
    required this.name,
    required this.description,
    required this.sizeBytes,
    this.isPremium = false,
    this.userIsPremium = false,
    required this.isInstalled,
    required this.onDownload,
  });
  @override
  Widget build(BuildContext context) {
    final locked = isPremium && !userIsPremium;
    final sizeStr = _ModelSettingsScreenState._formatBytes(sizeBytes);
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceLg),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(color: context.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: locked
                  ? context.textCaption.withValues(alpha: 0.1)
                  : context.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
            alignment: Alignment.center,
            child: Icon(
              locked ? PhosphorIconsLight.lock : PhosphorIconsLight.downloadSimple,
              size: 20,
              color: locked ? context.textCaption : context.colorScheme.primary,
            ),
          ),
          const SizedBox(width: DesignTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: DesignTokens.fontMd,
                        fontWeight: FontWeight.w600,
                        color: locked ? context.textCaption : context.colorScheme.onSurface,
                      ),
                    ),
                    if (isPremium) ...[
                      const SizedBox(width: DesignTokens.spaceSm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignTokens.spaceSm,
                          vertical: DesignTokens.space2xs,
                        ),
                        decoration: BoxDecoration(
                          color: context.colorScheme.tertiary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                        ),
                        child: Text(
                          context.l10n.premiumPlan,
                          style: TextStyle(
                            fontSize: DesignTokens.font2xs,
                            fontWeight: FontWeight.w700,
                            color: context.colorScheme.tertiary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '$description • $sizeStr',
                  style: TextStyle(fontSize: DesignTokens.fontSm, color: context.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: DesignTokens.spaceSm),
          if (isInstalled)
            Icon(PhosphorIconsLight.check, color: context.colorScheme.primary, size: 22)
          else if (locked)
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.l10n.requiresSubscription)),
                );
              },
              child: Text(context.l10n.upgradeButton),
            )
          else
            SizedBox(
              height: 34,
              child: ElevatedButton(
                onPressed: onDownload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colorScheme.primary,
                  foregroundColor: context.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMd)),
                  padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceMd),
                ),
                child: Text(context.l10n.startDownload, style: const TextStyle(fontSize: DesignTokens.fontSm, fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }
}
