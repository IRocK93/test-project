import 'package:flutter/material.dart';
import '../../domain/models/baby_profile.dart';
import '../../../../core/constants/app_colors.dart';

/// Card displaying baby profile info with editable fields
///
/// Uses the BabyProfile domain model with a callback for updates.
/// The onFieldUpdated callback takes field name and value strings.
class BabyInfoCard extends StatelessWidget {
  final BabyProfile profile;
  final void Function(String field, String value)? onFieldUpdated;

  const BabyInfoCard({
    super.key,
    required this.profile,
    this.onFieldUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surfaceWhite,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.child_care, size: 32, color: AppColors.surfaceWhite),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(
                        '${profile.age} · ${profile.weight} kg',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildField(context, 'Gender', profile.gender, Icons.male),
            _buildField(context, 'Blood Type', profile.bloodType, Icons.bloodtype),
            _buildField(context, 'Zodiac', profile.zodiac, Icons.star),
          ],
        ),
      ),
    );
  }

  Widget _buildField(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              initialValue: value,
              onEditingComplete: () => onFieldUpdated?.call(label, value),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
