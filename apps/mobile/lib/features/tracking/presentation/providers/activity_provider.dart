import 'package:flutter/material.dart';
import '../../domain/entities/activity.dart';
import '../../domain/repositories/activity_repository.dart';

class ActivityProvider extends ChangeNotifier {
  final ActivityRepository _repository;

  List<Activity> _activities = [];
  bool _isLoading = false;
  String? _error;
  ActivityType? _filterType;

  ActivityProvider(this._repository);

  List<Activity> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ActivityType? get filterType => _filterType;

  Future<void> loadActivities({ActivityType? type}) async {
    _isLoading = true;
    _filterType = type;
    notifyListeners();

    try {
      _activities = await _repository.getActivities(type: type);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addActivity(ActivityType type, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      final activity = Activity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: type,
        timestamp: DateTime.now(),
        data: data,
        xpEarned: _calculateXp(type),
      );

      await _repository.addActivity(activity);
      await loadActivities(type: _filterType);
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  int _calculateXp(ActivityType type) {
    switch (type) {
      case ActivityType.feeding:
        return 10;
      case ActivityType.diaper:
        return 5;
      case ActivityType.sleep:
        return 15;
      case ActivityType.growth:
        return 20;
    }
  }

  Future<void> deleteActivity(String id) async {
    await _repository.deleteActivity(id);
    await loadActivities(type: _filterType);
  }
}