import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/theme/design_tokens.dart';
import 'package:baby_mon/features/companion/domain/models/model_download_state.dart';
import 'package:baby_mon/features/companion/presentation/providers/llm_provider.dart';
import 'package:baby_mon/features/companion/presentation/widgets/companion_theme.dart';

class ModelDownloadScreen extends ConsumerStatefulWidget {
  final String url;
  final String destinationPath;
  final String version;
  final String? sha256;
  final int? sizeBytes;
  final VoidCallback onComplete;

  const ModelDownloadScreen({super.key, required this.url, required this.destinationPath, required this.version, this.sha256, this.sizeBytes, required this.onComplete});

  @override
  ConsumerState<ModelDownloadScreen> createState() => _ModelDownloadScreenState();
}

class _ModelDownloadScreenState extends ConsumerState<ModelDownloadScreen> {
  bool _didFireComplete = false;

  @override
  Widget build(BuildContext context) {
    final downloadState = ref.watch(modelDownloadStateProvider);
    final notifier = ref.read(modelDownloadStateProvider.notifier);

    // Fire onComplete exactly once when download completes
    if (downloadState is ModelDownloadComplete && !_didFireComplete) {
      _didFireComplete = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onComplete());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Download AI Model'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.space2xl),
          child: _buildState(context, downloadState, notifier),
        ),
      ),
    );
  }

  Widget _buildState(BuildContext context, ModelDownloadState state, ModelDownloadNotifier notifier) {
    switch (state) {
      case ModelDownloadNotStarted():
        return _buildNotStarted(context, notifier);
      case ModelDownloadInProgress(:final progress, :final downloadedBytes, :final totalBytes):
        return _buildProgress(progress, downloadedBytes, totalBytes, notifier);
      case ModelDownloadVerifying():
        return _buildVerifying();
      case ModelDownloadComplete():
        return _buildComplete();
      case ModelDownloadError(:final message):
        return _buildError(context, message, notifier);
    }
  }

  Widget _buildNotStarted(BuildContext context, ModelDownloadNotifier notifier) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(DesignTokens.space2xl),
          decoration: BoxDecoration(color: context.colorScheme.primary.withValues(alpha: 0.08), shape: BoxShape.circle),
          child: Icon(PhosphorIconsLight.download, size: 56, color: context.colorScheme.primary),
        ),
        const SizedBox(height: DesignTokens.space3xl),
        const Text('Download AI Model', style: TextStyle(fontSize: DesignTokens.fontXl2, fontWeight: FontWeight.w700)),
        const SizedBox(height: DesignTokens.spaceMd),
        Text('The AI Companion needs to download a language model (~${_formatSize(widget.sizeBytes ?? 1288490188)}) to provide personalized guidance on your device.', textAlign: TextAlign.center, style: TextStyle(fontSize: DesignTokens.fontMd2, color: context.textSecondary, height: 1.5)),
        const SizedBox(height: DesignTokens.spaceSm),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(PhosphorIconsLight.shieldCheck, size: 16, color: context.colorScheme.primary), const SizedBox(width: 6), Text('Runs entirely on your device', style: TextStyle(fontSize: DesignTokens.fontSm2, color: context.colorScheme.primary, fontWeight: FontWeight.w600))]),
        const SizedBox(height: DesignTokens.space3xl),
        SizedBox(width: double.infinity, height: 52, child: ElevatedButton(onPressed: () => notifier.startDownload(url: widget.url, destinationPath: widget.destinationPath, expectedSha256: widget.sha256, version: widget.version), style: ElevatedButton.styleFrom(backgroundColor: context.colorScheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMd))), child: const Text('Start Download', style: TextStyle(fontSize: DesignTokens.fontLg, fontWeight: FontWeight.w600, color: Colors.white)))),
        const SizedBox(height: DesignTokens.spaceMd),
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Skip for now', style: TextStyle(color: context.textCaption))),
      ],
    );
  }

  Widget _buildProgress(double progress, int downloaded, int total, ModelDownloadNotifier notifier) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(width: 100, height: 100, child: Stack(fit: StackFit.expand, children: [CircularProgressIndicator(value: progress, strokeWidth: 6, backgroundColor: context.textSecondary.withValues(alpha: 0.12), valueColor: AlwaysStoppedAnimation(context.colorScheme.primary)), Center(child: Text('${(progress * 100).round()}%', style: const TextStyle(fontSize: DesignTokens.fontXl2, fontWeight: FontWeight.w700)))])),
      const SizedBox(height: DesignTokens.space2xl), const Text('Downloading AI model...', style: TextStyle(fontSize: DesignTokens.fontLg, fontWeight: FontWeight.w600)),
      const SizedBox(height: DesignTokens.spaceSm), Text('${_formatSize(downloaded)} of ${_formatSize(total)}', style: TextStyle(fontSize: DesignTokens.fontMd, color: context.textSecondary)),
      const SizedBox(height: DesignTokens.space2xl),
      TextButton.icon(onPressed: () { notifier.cancelDownload(); Navigator.pop(context); }, icon: const Icon(PhosphorIconsLight.x, size: 18), label: const Text('Cancel')),
    ]);
  }

  Widget _buildVerifying() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      const CircularProgressIndicator(), const SizedBox(height: DesignTokens.space2xl),
      const Text('Verifying download...', style: TextStyle(fontSize: DesignTokens.fontLg, fontWeight: FontWeight.w600)),
      const SizedBox(height: DesignTokens.spaceSm), Text('Checking file integrity', style: TextStyle(fontSize: DesignTokens.fontMd, color: context.textSecondary)),
    ]);
  }

  Widget _buildComplete() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(padding: const EdgeInsets.all(DesignTokens.spaceXl), decoration: BoxDecoration(color: context.colorScheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(PhosphorIconsLight.checkCircle, size: 56, color: context.colorScheme.primary)),
      const SizedBox(height: DesignTokens.space2xl), const Text('Download Complete!', style: TextStyle(fontSize: DesignTokens.fontXl2, fontWeight: FontWeight.w700)),
      const SizedBox(height: DesignTokens.spaceSm), Text('Your AI Companion is ready.', style: TextStyle(fontSize: DesignTokens.fontMd2, color: context.textSecondary)),
    ]);
  }

  Widget _buildError(BuildContext context, String message, ModelDownloadNotifier notifier) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(padding: const EdgeInsets.all(DesignTokens.spaceXl), decoration: BoxDecoration(color: context.colorScheme.error.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(PhosphorIconsLight.warning, size: 48, color: context.colorScheme.error)),
      const SizedBox(height: DesignTokens.space2xl), const Text('Download Failed', style: TextStyle(fontSize: DesignTokens.fontLg2, fontWeight: FontWeight.w700)),
      const SizedBox(height: DesignTokens.spaceSm), Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: DesignTokens.fontMd, color: context.textSecondary)),
      const SizedBox(height: DesignTokens.space2xl),
      ElevatedButton(onPressed: () => notifier.startDownload(url: widget.url, destinationPath: widget.destinationPath, expectedSha256: widget.sha256, version: widget.version), style: ElevatedButton.styleFrom(backgroundColor: context.colorScheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMd))), child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white))),
      TextButton(onPressed: () => Navigator.pop(context), child: Text('Close', style: TextStyle(color: context.textCaption))),
    ]);
  }

  String _formatSize(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
