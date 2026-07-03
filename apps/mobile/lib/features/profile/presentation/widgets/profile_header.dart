import 'package:baby_mon/l10n/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:baby_mon/core/constants/app_colors.dart';
import '../providers/profile_provider.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: profile.avatarUrl != null
                  ? ClipOval(
                      child: Image.network(
                        profile.avatarUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.person, size: 40, color: AppColors.primary),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name.isNotEmpty ? profile.name : 'Parent',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.email,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      context.l10n.levelLabel,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}