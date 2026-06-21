import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/core/core.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() =>
      _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  String _currentPlan = 'CORE';
  int? _trialDaysRemaining;
  bool _isLoading = true;
  bool _isUpgrading = false;

  // Plan definitions.
  // Prices are kept in a single list so a future remote-config
  // upgrade is a one-line change. Number formatting happens at
  // render-time so the values stay parseable.
  static const List<_PlanSpec> _plans = [
    _PlanSpec(
      name: 'CORE',
      price: '\$0',
      period: 'forever',
      tierName: 'CORE',
      isRecommended: false,
      features: [
        'Basic tracking (milestones, feeding, health)',
        'Export your data anytime',
        '1 BabyMon profile',
        '7-day history',
        'Push notifications',
        'Offline entry creation',
      ],
    ),
    _PlanSpec(
      name: 'AI_COMPANION',
      price: '\$4.99',
      period: 'month',
      tierName: 'AI_COMPANION',
      isRecommended: true,
      premiumHeader: 'Everything in CORE, plus:',
      features: [
        'AI-powered stage content & tips',
        'Unlimited history',
        'Multiple BabyMon profiles',
        'Priority support',
        'Badge animations & effects',
        'Evolution narratives',
        'Photo album (S3 storage)',
      ],
      footerNote: 'Cancel anytime \u00b7 30-day refund',
    ),
  ];

  // Feature comparison matrix.
  static const List<_ComparisonRow> _comparison = [
    _ComparisonRow('Milestones, feeding, health', true, true),
    _ComparisonRow('Push notifications', true, true),
    _ComparisonRow('Export your data', true, true),
    _ComparisonRow('7-day history', true, true),
    _ComparisonRow('AI-powered stage content', false, true),
    _ComparisonRow('Multiple BabyMon profiles', false, true),
    _ComparisonRow('Unlimited history', false, true),
    _ComparisonRow('Cloud photo album', false, true),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSubscription());
  }

  Future<void> _loadSubscription() async {
    setState(() => _isLoading = true);
    try {
      final response =
          await ref.read(apiClientProvider).getSubscription();
      final raw = response.data;
      final data = parseJsonMap(raw) ?? <String, dynamic>{};
      if (mounted) {
        setState(() {
          _currentPlan = parseString(data['plan']) ?? 'CORE';
          _trialDaysRemaining = parseInt(data['trialDaysRemaining']);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _upgradeToAiCompanion() async {
    if (_isUpgrading) return;
    setState(() => _isUpgrading = true);
    HapticFeedback.lightImpact();
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(apiClientProvider)
          .post('/subscriptions/upgrade', data: {'plan': 'PREMIUM'});
      await _loadSubscription();
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Upgraded to AI Companion!')),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Could not upgrade. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpgrading = false);
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
        title: 'Plans',
        onBack: () => GoRouter.of(context).pop(),
      ),
      body: PremiumBackground(
        child: _isLoading
            ? PremiumLoading.spinner()
            : ListView(
                padding: const EdgeInsets.fromLTRB(
                  DesignTokens.spaceLg,
                  DesignTokens.spaceLg,
                  DesignTokens.spaceLg,
                  DesignTokens.space3xl,
                ),
                children: [
                  // ── Hero ──
                  const _Hero(),
                  const SizedBox(height: DesignTokens.spaceXl),

                  // ── Current Plan Banner ──
                  _CurrentPlanBanner(
                    currentPlan: _currentPlan,
                    trialDaysRemaining: _trialDaysRemaining,
                  ),
                  const SizedBox(height: DesignTokens.spaceXl),

                  // ── Plan Cards (stacked) ──
                  ...List.generate(_plans.length, (i) {
                    final spec = _plans[i];
                    final isCurrent = spec.tierName == _currentPlan;
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: i == _plans.length - 1
                            ? DesignTokens.spaceXl
                            : DesignTokens.spaceLg,
                      ),
                      child: PlanCard(
                        name: spec.name,
                        price: spec.price,
                        period: spec.period,
                        features: spec.features,
                        premiumHeader: spec.premiumHeader,
                        isCurrent: isCurrent,
                        isRecommended: spec.isRecommended,
                        isBusy: _isUpgrading,
                        primaryActionLabel: isCurrent
                            ? null
                            : (spec.tierName == 'AI_COMPANION'
                                ? 'Upgrade to AI Companion'
                                : 'Choose CORE'),
                        onPrimaryAction: isCurrent
                            ? null
                            : (spec.tierName == 'AI_COMPANION'
                                ? _upgradeToAiCompanion
                                : null),
                        footerNote: spec.footerNote,
                      ),
                    );
                  }),

                  // ── Comparison Matrix ──
                  const _SectionTitle('Compare features'),
                  const SizedBox(height: DesignTokens.spaceSm),
                  _ComparisonHeader(),
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 0,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? context.glass.background
                          : context.colorScheme.surface,
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusLg,
                      ),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? context.colorScheme.outline
                            : context.colorScheme.outline,
                        width: 0.5,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (int i = 0; i < _comparison.length; i++)
                          FeatureComparisonRow(
                            feature: _comparison[i].feature,
                            freeIncluded: _comparison[i].freeIncluded,
                            premiumIncluded:
                                _comparison[i].premiumIncluded,
                            isLast: i == _comparison.length - 1,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spaceXl),

                  // ── Trust Band ──
                  const _TrustBand(),
                  const SizedBox(height: DesignTokens.space2xl),

                  // ── Footer ──
                  _SubscriptionFooter(
                    onRestore: () => _showComingSoon('Restore purchases'),
                    onTerms: () => _showComingSoon('Terms'),
                    onPrivacy: () => _showComingSoon('Privacy'),
                    onSupport: () => _showComingSoon('Support'),
                  ),
                ],
              ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Plan Spec (local)
// ═══════════════════════════════════════════════

class _PlanSpec {
  final String name;
  final String price;
  final String period;
  final String tierName;
  final bool isRecommended;
  final String? premiumHeader;
  final List<String> features;
  final String? footerNote;

  const _PlanSpec({
    required this.name,
    required this.price,
    required this.period,
    required this.tierName,
    required this.isRecommended,
    this.premiumHeader,
    required this.features,
    this.footerNote,
  });
}

class _ComparisonRow {
  final String feature;
  final bool freeIncluded;
  final bool premiumIncluded;

  const _ComparisonRow(
    this.feature,
    this.freeIncluded,
    this.premiumIncluded,
  );
}

// ═══════════════════════════════════════════════
//  Local sub-widgets (private)
// ═══════════════════════════════════════════════

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose your plan',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                height: 1.2,
              ),
        ),
        const SizedBox(height: DesignTokens.spaceSm),
        Text(
          'Start free. Upgrade anytime. Cancel in two taps.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: DesignTokens.fontMd,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _CurrentPlanBanner extends StatelessWidget {
  final String currentPlan;
  final int? trialDaysRemaining;

  const _CurrentPlanBanner({
    required this.currentPlan,
    required this.trialDaysRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final isAiCompanion = currentPlan == 'AI_COMPANION';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isAiCompanion ? context.colorScheme.primary : context.colorScheme.primary;
    final bg = accent.withValues(alpha: isDark ? 0.10 : 0.06);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceLg,
        vertical: DesignTokens.spaceMd,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(
          color: accent.withValues(alpha: 0.25),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
              border: Border.all(
                color: accent.withValues(alpha: 0.25),
                width: 0.5,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              isAiCompanion
                  ? PhosphorIconsLight.crown
                  : PhosphorIconsLight.gift,
              size: 22,
              color: accent,
            ),
          ),
          const SizedBox(width: DesignTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAiCompanion ? 'AI Companion' : 'CORE plan',
                  style: TextStyle(
                    fontSize: DesignTokens.fontLg,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isAiCompanion ? 'Renews monthly' : 'Free forever',
                  style: TextStyle(
                    fontSize: DesignTokens.fontSm2,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (trialDaysRemaining != null && trialDaysRemaining! > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: context.colorScheme.tertiary,
                borderRadius:
                    BorderRadius.circular(DesignTokens.radiusFull),
              ),
              child: Text(
                '${trialDaysRemaining}d left',
                style: TextStyle(
                  fontSize: DesignTokens.fontSm,
                  fontWeight: FontWeight.w800,
                  color: context.colorScheme.onPrimary,
                  letterSpacing: 0.2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.3,
      ),
    );
  }
}

class _ComparisonHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.spaceLg,
        DesignTokens.spaceMd,
        DesignTokens.spaceLg,
        DesignTokens.spaceXs,
      ),
      child: Row(
        children: [
          const Expanded(
            flex: 3,
            child: SizedBox.shrink(),
          ),
          Expanded(
            child: Text(
              'FREE',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: DesignTokens.font2xs,
                fontWeight: FontWeight.w700,
                color: context.colorScheme.primary,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'PREMIUM',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: DesignTokens.font2xs,
                fontWeight: FontWeight.w700,
                color: context.colorScheme.primary,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustBand extends StatelessWidget {
  const _TrustBand();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceLg,
        vertical: DesignTokens.spaceMd,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIconsLight.lock,
                size: 14,
                color: context.colorScheme.primaryContainer,
              ),
              const SizedBox(width: 6),
              Text(
                'Secured by Stripe',
                style: TextStyle(
                  fontSize: DesignTokens.fontSm,
                  fontWeight: FontWeight.w700,
                  color: context.colorScheme.primaryContainer,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '30-day money-back guarantee · Cancel anytime',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: DesignTokens.fontSm,
              color: context.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionFooter extends StatelessWidget {
  final VoidCallback onRestore;
  final VoidCallback onTerms;
  final VoidCallback onPrivacy;
  final VoidCallback onSupport;

  const _SubscriptionFooter({
    required this.onRestore,
    required this.onTerms,
    required this.onPrivacy,
    required this.onSupport,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Wrap(
            spacing: 4,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: [
              _FooterLink(label: 'Restore purchases', onTap: onRestore),
              const _FooterDot(),
              _FooterLink(label: 'Terms', onTap: onTerms),
              const _FooterDot(),
              _FooterLink(label: 'Privacy', onTap: onPrivacy),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceSm),
          TextButton.icon(
            onPressed: onSupport,
            icon: const Icon(PhosphorIconsLight.headset, size: 16),
            label: const Text('Need help? Talk to support'),
            style: TextButton.styleFrom(
              foregroundColor: context.colorScheme.primary,
              textStyle: const TextStyle(
                fontSize: DesignTokens.fontSm2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
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
        foregroundColor: context.colorScheme.onSurfaceVariant,
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
        style: TextStyle(color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7), fontSize: DesignTokens.fontSm),
      );
}
