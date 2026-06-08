import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:baby_mon/data/api_client.dart';
import 'package:baby_mon/core/providers.dart';

/// Subscription plans comparison screen with upgrade option.
///
/// Displays the user's current plan, trial status, and a side-by-side comparison
/// of Free vs Premium tiers with feature checkmarks. If on free tier, shows an
/// "Upgrade to Premium" button.
class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  Map<String, dynamic>? _subscription;
  String _currentPlan = 'FREE';
  int? _trialDaysRemaining;
  bool _isLoading = true;

  /// Plan definitions with features
  static const List<Map<String, dynamic>> _plans = [
    {
      'name': 'Free',
      'price': '\$0',
      'period': 'forever',
      'features': [
        'Basic tracking (milestones, feeding, health)',
        'Export your data anytime',
        '1 BabyMon profile',
        '7-day history',
        'Push notifications',
        'Offline entry creation',
      ],
    },
    {
      'name': 'Premium',
      'price': '\$4.99',
      'period': 'month',
      'features': [
        'All Free features',
        'AI-powered stage content & tips',
        'Unlimited history',
        'Multiple BabyMon profiles',
        'Priority support',
        'Badge animations & effects',
        'Evolution narratives',
        'Photo album (Cloudinary storage)',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSubscription());
  }

  Future<void> _loadSubscription() async {
    setState(() => _isLoading = true);
    try {
      final response = await ref.read(apiClientProvider).getSubscription();
      final data = response.data as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _subscription = data;
          _currentPlan = data['plan'] ?? 'FREE';
          _trialDaysRemaining = data['trialDaysRemaining'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _upgradeToPremium() async {
    try {
      await ref.read(apiClientProvider).post('/subscriptions/upgrade', data: {'plan': 'PREMIUM'});
      await _loadSubscription();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upgraded to Premium!')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upgrade error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Current Plan Banner
                Card(
                  color: _currentPlan == 'PREMIUM' ? Colors.amber.withOpacity(0.15) : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(_currentPlan == 'PREMIUM' ? Icons.workspace_premium : Icons.card_giftcard, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Current Plan: $_currentPlan', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                  if (_trialDaysRemaining != null && _trialDaysRemaining! > 0)
                                    Text('$_trialDaysRemaining trial days remaining', style: TextStyle(color: Colors.orange.shade700)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Plans Comparison
                Text('Compare Plans', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _plans.map((plan) => Expanded(
                    child: Card(
                      elevation: plan['name'] == 'Premium' ? 4 : 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: plan['name'] == 'Premium'
                            ? BorderSide(color: Colors.amber, width: 2)
                            : BorderSide.none,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(plan['name'], style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('${plan['price']}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                            Text('/${plan['period']}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            const SizedBox(height: 16),
                            ...((plan['features'] as List<String>).map((f) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.check_circle, size: 16, color: plan['name'] == 'Premium' ? Colors.amber : Colors.green),
                                  const SizedBox(width: 6),
                                  Expanded(child: Text(f, style: const TextStyle(fontSize: 12))),
                                ],
                              ),
                            ))),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  )).toList(),
                ),

                const SizedBox(height: 24),

                // Upgrade Button (only if on free tier)
                if (_currentPlan == 'FREE')
                  ElevatedButton.icon(
                    onPressed: _upgradeToPremium,
                    icon: const Icon(Icons.workspace_premium),
                    label: const Text('Upgrade to Premium'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),

                if (_currentPlan == 'PREMIUM')
                  const Card(
                    color: Colors.amber,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.workspace_premium),
                          SizedBox(width: 8),
                          Text('You are on the Premium plan!', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}