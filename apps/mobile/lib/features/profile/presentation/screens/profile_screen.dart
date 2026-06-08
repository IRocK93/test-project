import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/baby_profile.dart';
import '../widgets/baby_info_card.dart';
import '../widgets/achievements_section.dart';

/// Profile screen showing baby info + quick milestone buttons
///
/// Uses Riverpod ProviderScope so the BabyProfileProvider can be instantiated.
/// The scaffold contains a ProviderScope so the Riverpod provider can be created.
/// The consumer then accesses it.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _handleStageSelected(BabyProfile? stage) {
    // Navigate to stage details
    debugPrint('Stage selected: $stage');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = BabyProfile.demo();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BabyInfoCard(
            profile: profile,
            onFieldUpdated: (field, value) => debugPrint('$field = $value'),
          ),
          const SizedBox(height: 16),
          AchievementsSection(
            achievements: [
              AchievementItem(
                title: 'First Smile',
                icon: Icons.favorite,
                color: const Color(0xFFFF6B6B),
              ),
              AchievementItem(
                title: 'First Step',
                icon: Icons.directions_run,
                color: const Color(0xFF00B4D8),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _handleStageSelected(profile),
            child: const Text('Add Stage'),
          ),
          ElevatedButton(
            onPressed: () => _handleStageSelected(profile),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFA726),
            ),
            child: const Text('Export Data'),
          ),
        ],
      ),
    );
  }
}
