import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/core/core.dart';
class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});
  @override
  ConsumerState<SubscriptionScreen> createState() =>
      _SubscriptionScreenState();
}
class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  String _currentPlan = 'FREE';
  int? _trialDaysRemaining;
  bool _isLoading = true;
  bool _isUpgrading = false;
  // Promo code
  final _promoController = TextEditingController();
  bool _promoLoading = false;
  String? _promoError;
  String? _promoSuccess;
  // Plan definitions.
  // Prices are kept in a single list so a future remote-config
  // upgrade is a one-line change. Number formatting happens at
  // render-time so the values stay parseable.
  static const List<_PlanSpec> _plans = [
    _PlanSpec(
      name: 'Free',
      price: '\$0',
      period: 'forever',
      tierName: 'FREE',
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
      name: 'Premium',
      price: '\$4.99',
      period: 'month',
      tierName: 'PREMIUM',
      isRecommended: true,
      premiumHeader: 'Everything in Free, plus:',
      features: [
        'AI-powered stage content & tips',
        'Unlimited history',
        'Multiple BabyMon profiles',
        'Priority support',
        'Badge animations & effects',
        'Evolution narratives',
        'Photo album (S3 storage)',
      ],
      footerNote: '\$4.99/month, auto-renews. Cancel at least 24 hours before renewal.',
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
          _currentPlan = parseString(data['tier']) ?? 'FREE';
          _trialDaysRemaining = parseInt(data['daysRemaining']);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  Widget _buildPromoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_promoSuccess != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DesignTokens.spaceMd),
              decoration: BoxDecoration(
                color: context.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              ),
              child: Row(
                children: [
                  Icon(PhosphorIconsLight.checkCircle, color: context.colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_promoSuccess!, style: TextStyle(color: context.colorScheme.primary, fontWeight: FontWeight.w600, fontSize: DesignTokens.fontSm))),
                ],
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promoController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Have a promo code?',
                      prefixIcon: const Icon(PhosphorIconsLight.tag, size: 20),
                      suffixIcon: _promoLoading
                          ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                          : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMd)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceMd, vertical: DesignTokens.spaceSm),
                      errorText: _promoError,
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: DesignTokens.fontSm),
                    onSubmitted: (_) => _applyPromoCode(),
                  ),
                ),
                const SizedBox(width: DesignTokens.spaceSm),
                SizedBox(
                  height: 40,
                  child: FilledButton(
                    onPressed: _promoLoading ? null : _applyPromoCode,
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceLg)),
                    child: const Text('Apply', style: TextStyle(fontSize: DesignTokens.fontSm)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _applyPromoCode() async {
    final code = _promoController.text.trim().toUpperCase();
    if (code.isEmpty) return;
    setState(() { _promoLoading = true; _promoError = null; _promoSuccess = null; });

    try {
      final api = ref.read(apiClientProvider);
      // Validate first
      final validate = await api.validatePromoCode(code);
      final data = validate.data as Map<String, dynamic>;
      final desc = data['description'] as String? ?? 'Apply this promo code?';

      if (!mounted) return;
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Promo Code'),
          content: Text(desc),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Apply')),
          ],
        ),
      );
      if (confirm != true) { setState(() => _promoLoading = false); return; }

      // Redeem
      final redeem = await api.redeemPromoCode(code);
      final result = redeem.data as Map<String, dynamic>;
      setState(() {
        _promoSuccess = 'Code applied! ${result['valueDays']} days of ${result['type'] == 'FULL_PREMIUM' ? 'Premium' : 'trial extension'} granted.';
        _promoController.clear();
        _promoLoading = false;
      });

      // Refresh subscription status
      _loadSubscription();
    } catch (e) {
      final msg = e is DioException ? (e.response?.data?['message'] ?? 'Invalid code') : 'Something went wrong';
      setState(() { _promoError = msg.toString(); _promoLoading = false; });
    }
  }

  Future<void> _upgradeToPremium() async {
    if (_isUpgrading) return;
    setState(() => _isUpgrading = true);
    HapticFeedback.lightImpact();
    final messenger = ScaffoldMessenger.of(context);
    try {
      // Fetch plans to get the Stripe price ID from the backend
      final plansResp = await ref.read(apiClientProvider).get('/subscriptions/plans');
      final plansData = plansResp.data is Map ? plansResp.data as Map<String, dynamic> : <String, dynamic>{};
      final plans = (plansData['plans'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final premium = plans.firstWhere(
        (p) => p['tier'] == 'PREMIUM',
        orElse: () => <String, dynamic>{},
      );
      final priceId = premium['stripePriceId'] as String?;
      if (priceId == null || priceId.isEmpty) {
        if (mounted) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Payment is not configured yet. Please try again later.')),
          );
        }
        return;
      }
      // Create Stripe checkout session
      final checkoutResp = await ref.read(apiClientProvider).post(
        '/subscriptions/create-checkout-session',
        data: {'priceId': priceId},
      );
      final checkoutData = checkoutResp.data is Map ? checkoutResp.data as Map<String, dynamic> : <String, dynamic>{};
      final url = checkoutData['url'] as String?;
      if (url != null && url.isNotEmpty) {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } else {
        if (mounted) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Could not start checkout. Please try again.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Could not upgrade. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpgrading = false);
    }
  }
  Future<void> _restorePurchases() async {
    // Restore purchases is handled by the store's account settings.
    // iOS: Settings > Apple ID > Subscriptions
    // Android: Play Store > Payments & subscriptions > Subscriptions
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('To restore a purchase, go to your app store account settings and tap Restore.'),
        duration: Duration(seconds: 4),
      ),
    );
  }
  void _openSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contact us at support@babymon.app'),
        duration: Duration(seconds: 3),
      ),
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
                  // ── Promo Code ──
                  _buildPromoSection(),
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
                            : (spec.tierName == 'PREMIUM'
                                ? 'Upgrade to Premium'
                                : 'Choose Free'),
                        onPrimaryAction: isCurrent
                            ? null
                            : (spec.tierName == 'PREMIUM'
                                ? _upgradeToPremium
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
                    onRestore: () => _restorePurchases(),
                    onTerms: () => context.push('/legal/tos'),
                    onPrivacy: () => context.push('/legal/privacy'),
                    onChildrensPrivacy: () => context.push('/legal/childrens-privacy'),
                    onSupport: () => _openSupport(),
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
    final isPremium = currentPlan == 'PREMIUM';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isPremium ? context.colorScheme.primary : context.colorScheme.primary;
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
              isPremium
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
                  isPremium ? 'Premium' : 'Free plan',
                  style: TextStyle(
                    fontSize: DesignTokens.fontLg,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isPremium ? 'Renews monthly' : 'Free forever',
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
            '30-day money-back guarantee · Cancel anytime through your app store settings. Auto-renews at \$4.99/month unless cancelled 24 hours before renewal.',
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
  final VoidCallback onChildrensPrivacy;
  final VoidCallback onSupport;
  const _SubscriptionFooter({
    required this.onRestore,
    required this.onTerms,
    required this.onPrivacy,
    required this.onChildrensPrivacy,
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
              const _FooterDot(),
              _FooterLink(label: 'Children', onTap: onChildrensPrivacy),
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
