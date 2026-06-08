import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> getProfile();
  Future<void> updateProfile(UserProfile profile);
  Future<void> updateBabyInfo(Map<String, dynamic> babyInfo);
}