import 'package:flutter/material.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository;

  UserProfile _profile = UserProfile.empty();
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  ProfileProvider(this._repository);

  UserProfile get profile => _profile;

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProfile() async {
    _isLoading = true;
    _isInitialized = false;
    notifyListeners();

    try {
      _profile = await _repository.getProfile();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> updateBabyInfo(Map<String, dynamic> babyInfo) async {
    await _repository.updateBabyInfo(babyInfo);
    await loadProfile();
  }
}
