import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baby_mon/core/constants/constants.dart';
import 'package:baby_mon/l10n/l10n_ext.dart';

/// First-launch language picker shown before login/register.
///
/// Saves the selected locale to SharedPreferences under `'user_locale'`
/// and navigates to `/login` on confirmation.
class LanguageOnboardingScreen extends StatefulWidget {
  const LanguageOnboardingScreen({super.key});

  @override
  State<LanguageOnboardingScreen> createState() => _LanguageOnboardingScreenState();
}

class _LanguageOnboardingScreenState extends State<LanguageOnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _slide;

  static const _localeKey = 'user_locale';

  final List<_LanguageOption> _languages = const [
    _LanguageOption(code: 'en', flag: '🇬🇧', nativeName: 'English'),
    _LanguageOption(code: 'es', flag: '🇪🇸', nativeName: 'Español'),
    _LanguageOption(code: 'fr', flag: '🇫🇷', nativeName: 'Français'),
    _LanguageOption(code: 'de', flag: '🇩🇪', nativeName: 'Deutsch'),
    _LanguageOption(code: 'pt', flag: '🇵🇹', nativeName: 'Português'),
  ];

  String _selected = 'en';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<double>(begin: 24, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_localeKey);
    if (saved != null && mounted) {
      setState(() => _selected = saved);
    }
    if (mounted) _controller.forward();
  }

  Future<void> _saveAndContinue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, _selected);
    if (mounted) context.go('/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: AnimatedBuilder(
              animation: _slide,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, _slide.value),
                child: child,
              ),
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.spaceLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: DesignTokens.space3xl),
                    // Title
                    Text(
                      context.l10n.welcomeChooseLanguage,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: DesignTokens.spaceXs),
                    Text(
                      'BabyMon',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: DesignTokens.space3xl),
                    // Glass card with language list
                    ClipRRect(
                      borderRadius: BorderRadius.circular(DesignTokens.radius2xl),
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(
                          sigmaX: DesignTokens.glassBlurMd,
                          sigmaY: DesignTokens.glassBlurMd,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(DesignTokens.spaceLg),
                          decoration: BoxDecoration(
                            color: AppColors.glassWhite,
                            borderRadius: BorderRadius.circular(DesignTokens.radius2xl),
                            border: Border.all(
                              color: AppColors.glassBorder,
                              width: DesignTokens.glassBorderWidth,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: _languages.map((lang) {
                              final isSelected = _selected == lang.code;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
                                child: Semantics(
                                  label: '${lang.nativeName}, ${isSelected ? "selected" : "not selected"}',
                                  button: true,
                                  selected: isSelected,
                                  child: InkWell(
                                    onTap: () => setState(() => _selected = lang.code),
                                    borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      curve: Curves.easeInOut,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: DesignTokens.spaceMd,
                                        vertical: DesignTokens.spaceMd,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? cs.primaryContainer.withValues(alpha: 0.5)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                                        border: Border.all(
                                          color: isSelected
                                              ? cs.primary.withValues(alpha: 0.4)
                                              : Colors.transparent,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(lang.flag, style: const TextStyle(fontSize: 24)),
                                          const SizedBox(width: DesignTokens.spaceMd),
                                          Expanded(
                                            child: Text(
                                              lang.nativeName,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                                color: cs.onSurface,
                                              ),
                                            ),
                                          ),
                                          if (isSelected)
                                            Icon(
                                              Icons.check_circle,
                                              color: cs.primary,
                                              size: 22,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Continue button
                    ElevatedButton(
                      onPressed: _saveAndContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryDark,
                        padding: const EdgeInsets.symmetric(vertical: DesignTokens.spaceMd),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        context.l10n.continueButton,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spaceLg),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageOption {
  final String code;
  final String flag;
  final String nativeName;

  const _LanguageOption({
    required this.code,
    required this.flag,
    required this.nativeName,
  });
}
