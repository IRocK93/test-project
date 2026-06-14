import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'package:baby_mon/features/auth/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ErrorWidget.builder = (details) {
    debugPrint('FATAL: ${details.exception}\n${details.stack}');
    return const Material(
      color: Color(0xFF0E0E12),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64, color: Color(0xFFE53935)),
              SizedBox(height: 24),
              Text(
                'Something went wrong',
                style: TextStyle(
                  color: Color(0xFFF0F0F5),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Please restart the app.',
                style: TextStyle(color: Color(0xFF808090), fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  };

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  runZonedGuarded(
    () {
      runApp(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) => prefs),
          ],
          child: const BabyMonApp(),
        ),
      );
    },
    (Object error, StackTrace stack) {
      debugPrint('Unhandled async error: $error\n$stack');
    },
  );
}