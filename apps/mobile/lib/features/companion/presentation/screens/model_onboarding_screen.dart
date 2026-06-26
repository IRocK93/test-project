import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/theme/design_tokens.dart';
import 'package:baby_mon/core/widgets/premium_background.dart';
import 'package:baby_mon/features/companion/presentation/screens/model_download_screen.dart';
import 'package:baby_mon/features/companion/presentation/widgets/companion_theme.dart';

/// Premium model URL — SmolLM3 3B Q4_K_M from HuggingFace (ggml-org, ungated).
const premiumModelUrl =
    'https://huggingface.co/ggml-org/SmolLM3-3B-GGUF/resolve/main/SmolLM3-Q4_K_M.gguf?download=true';
const premiumModelVersion = 'smollm3-3b-v1';
const premiumModelName = 'SmolLM3 3B';
const premiumModelSizeBytes = 1915305312; // ~1.83 GB

/// Onboarding screen shown the first time a user activates the AI Companion.
///
/// Presents model download options. Free users see the default SmolLM2 360M
/// card only. Premium users also see the SmolLM3 3B upgrade card.
///
/// [manifestUrl], [manifestVersion], [manifestSha256], and [manifestSizeBytes]
/// come from the backend manifest and describe the default model (SmolLM2 360M).
class ModelOnboardingScreen extends StatelessWidget {
  final String manifestUrl;
  final String manifestVersion;
  final String? manifestSha256;
  final int? manifestSizeBytes;
  final String downloadBaseDir;
  final bool isPremium;
  final VoidCallback? onSkip;

  const ModelOnboardingScreen({
    super.key,
    required this.manifestUrl,
    required this.manifestVersion,
    this.manifestSha256,
    this.manifestSizeBytes,
    required this.downloadBaseDir,
    required this.isPremium,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final defaultFileName = Uri.parse(manifestUrl).pathSegments.last;
    final defaultPath = '$downloadBaseDir/$defaultFileName';
    final premiumFileName = Uri.parse(premiumModelUrl).pathSegments.last;
    final premiumPath = '$downloadBaseDir/$premiumFileName';

    return Scaffold(
      body: PremiumBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceLg),
            child: Column(
              children: [
                const Spacer(flex: 1),
                // ── Header ──
                Icon(
                  PhosphorIconsLight.brain,
                  size: 56,
                  color: context.colorScheme.primary,
                ),
                const SizedBox(height: DesignTokens.spaceLg),
                Text(
                  'Your On-Device\nAI Companion',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: DesignTokens.font2xl,
                    fontWeight: FontWeight.w700,
                    color: context.colorScheme.onSurface,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceMd),
                Text(
                  'A parenting coach that runs entirely on your phone.\nNothing leaves your device.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: DesignTokens.fontMd,
                    color: context.textSecondary,
                    height: 1.5,
                  ),
                ),
                const Spacer(flex: 1),

                // ── Default model card ──
                _ModelCard(
                  icon: PhosphorIconsLight.rocketLaunch,
                  title: 'Quick Start',
                  subtitle: 'Instant answers, fast download',
                  sizeLabel: _formatSize(manifestSizeBytes ?? 271000000),
                  timeLabel: '~2 min on Wi‑Fi',
                  badge: null,
                  onDownload: () => _startDownload(
                    context,
                    manifestUrl,
                    defaultPath,
                    manifestVersion,
                    manifestSha256,
                    manifestSizeBytes,
                  ),
                ),

                // ── Premium model card ──
                const SizedBox(height: DesignTokens.spaceMd),
                _ModelCard(
                    icon: PhosphorIconsLight.crown,
                    title: 'Better Quality',
                    subtitle: 'Deeper reasoning, nuanced advice',
                    sizeLabel: _formatSize(premiumModelSizeBytes),
                    timeLabel: '~10 min on Wi‑Fi',
                    badge: 'PREMIUM',
                    onDownload: () {
                      _showWifiGate(context, () => _startDownload(
                        context,
                        premiumModelUrl,
                        premiumPath,
                        premiumModelVersion,
                        null,
                        premiumModelSizeBytes,
                      ));
                    },
                  ),

                const SizedBox(height: DesignTokens.spaceXl),

                // ── Skip ──
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // close onboarding
                    onSkip?.call();
                  },
                  child: Text(
                    'Skip for now — use basic mode',
                    style: TextStyle(
                      color: context.textCaption,
                      fontSize: DesignTokens.fontMd,
                    ),
                  ),
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startDownload(
    BuildContext context,
    String url,
    String destinationPath,
    String version,
    String? sha256,
    int? sizeBytes,
  ) {
    debugPrint('[ONBOARDING] Starting download: $url -> $destinationPath');
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ModelDownloadScreen(
          url: url,
          destinationPath: destinationPath,
          version: version,
          sha256: sha256,
          sizeBytes: sizeBytes,
          onComplete: () {
            // Pop the download screen, then pop the onboarding screen
            Navigator.of(context)
              ..pop()
              ..pop();
          },
        ),
      ),
    );
  }

  void _showWifiGate(BuildContext context, VoidCallback onProceed) {
    // For now, proceed directly (Wi‑Fi gate is a nice-to-have).
    // In production, check connectivity_plus before prompting.
    onProceed();
  }

  static String _formatSize(int bytes) {
    if (bytes >= 1000000000) {
      return '${(bytes / 1000000000).toStringAsFixed(1)} GB';
    }
    return '${(bytes / 1000000).toStringAsFixed(0)} MB';
  }
}

/// A single model download card.
class _ModelCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String sizeLabel;
  final String timeLabel;
  final String? badge;
  final VoidCallback onDownload;

  const _ModelCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.sizeLabel,
    required this.timeLabel,
    this.badge,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DesignTokens.spaceLg),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(
          color: badge != null
              ? context.colorScheme.tertiary.withValues(alpha: 0.5)
              : context.colorScheme.outline.withValues(alpha: 0.3),
          width: badge != null ? 1.5 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 22, color: context.colorScheme.primary),
              ),
              const SizedBox(width: DesignTokens.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: DesignTokens.fontLg,
                            fontWeight: FontWeight.w700,
                            color: context.colorScheme.onSurface,
                          ),
                        ),
                        if (badge != null) ...[
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
                              badge!,
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
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: DesignTokens.fontSm,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          Row(
            children: [
              Icon(
                PhosphorIconsLight.downloadSimple,
                size: 14,
                color: context.textCaption,
              ),
              const SizedBox(width: 4),
              Text(
                sizeLabel,
                style: TextStyle(
                  fontSize: DesignTokens.fontSm,
                  fontWeight: FontWeight.w600,
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(width: DesignTokens.spaceMd),
              Icon(
                PhosphorIconsLight.clock,
                size: 14,
                color: context.textCaption,
              ),
              const SizedBox(width: 4),
              Text(
                timeLabel,
                style: TextStyle(
                  fontSize: DesignTokens.fontSm,
                  color: context.textSecondary,
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: onDownload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colorScheme.primary,
                    foregroundColor: context.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceLg),
                  ),
                  child: const Text(
                    'Download',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
