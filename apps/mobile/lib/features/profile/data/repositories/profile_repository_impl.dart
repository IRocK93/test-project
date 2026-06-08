import 'dart:convert';
import 'package:baby_mon/features/profile/domain/entities/user_profile.dart';
import 'package:baby_mon/features/profile/domain/repositories/profile_repository.dart';
import 'package:baby_mon/core/services/local_storage_service.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  static const String _profileKey = 'user_profile';
  static const String _babyInfoKey = 'baby_info';

  @override
  Future<UserProfile> getProfile() async {
    final jsonString = LocalStorageService.getString(_profileKey);
    if (jsonString == null || jsonString.isEmpty) {
      return UserProfile.empty();
    }
    
    try {
      final jsonMap = jsonDecode(jsonString);
      return UserProfile.fromJsonMap(jsonMap);
    } catch (e) {
      return UserProfile.empty();
    }
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    await LocalStorageService.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  @override
  Future<void> updateBabyInfo(Map<String, dynamic> babyInfo) async {
    await LocalStorageService.setString(_babyInfoKey, jsonEncode(babyInfo));
    
    // Also update the profile's babyInfo
    final profile = await getProfile();
    final updatedProfile = profile.copyWith(babyInfo: babyInfo);
    await updateProfile(updatedProfile);
  }
}