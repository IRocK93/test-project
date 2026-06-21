import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baby_mon/core/theme/design_tokens.dart';
import 'package:baby_mon/features/companion/presentation/widgets/companion_theme.dart';

class MonthlyAIReminder {
  static const _lastShownKey = 'ai_reminder_last_shown';
  static const _defaultIntervalDays = 30;

  /// Configurable interval. Override for testing or A/B experiments.
  static int reminderIntervalDays = _defaultIntervalDays;

  /// Returns true if the reminder should be shown (30+ days since last shown)
  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    final lastShown = prefs.getInt(_lastShownKey);
    if (lastShown == null) return true; // Never shown

    final lastDate = DateTime.fromMillisecondsSinceEpoch(lastShown);
    final daysSince = DateTime.now().difference(lastDate).inDays;
    return daysSince >= reminderIntervalDays;
  }

  /// Mark the reminder as shown today
  static Future<void> markShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastShownKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Show the reminder dialog. Returns true if user acknowledged it.
  static Future<bool> show(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        barrierColor: Colors.black54,
        transitionDuration: DesignTokens.durationNormal,
        reverseTransitionDuration: DesignTokens.durationFast,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: _ReminderContent(),
          );
        },
      ),
    );

    if (result == true) {
      await markShown();
    }
    return result ?? false;
  }
}

class _ReminderContent extends StatefulWidget {
  @override
  State<_ReminderContent> createState() => _ReminderContentState();
}

class _ReminderContentState extends State<_ReminderContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _dismiss() {
    Navigator.of(context).pop(true);
  }

  void _close() {
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space2xl),
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) => Transform.scale(
                scale: _pulseAnimation.value,
                child: child,
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: context.cardSurface,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: DesignTokens.opacitySubtle),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header gradient
                    Container(
                      padding: const EdgeInsets.fromLTRB(DesignTokens.space2xl, DesignTokens.space3xl, DesignTokens.space2xl, DesignTokens.spaceXl),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            context.colorScheme.primary,
                            context.colorScheme.primary.withValues(alpha: 0.75),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(DesignTokens.radiusLg),
                          topRight: Radius.circular(DesignTokens.radiusLg),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(DesignTokens.spaceLg),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              PhosphorIconsLight.heart,
                              size: 36,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'A Gentle Reminder',
                            style: TextStyle(
                              fontSize: DesignTokens.fontXl2,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Because your little one matters most',
                            style: TextStyle(
                              fontSize: DesignTokens.fontMd,
                              color: Colors.white.withValues(alpha: 0.85),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Body content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                      DesignTokens.space2xl,
                      DesignTokens.space2xl,
                      DesignTokens.space2xl,
                      DesignTokens.spaceSm,
                    ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Main message
                          Text(
                            'We love that you trust BabyMon to support your parenting journey. '
                            'It means the world to us that you turn to our AI Companion for guidance.',
                            style: TextStyle(
                              fontSize: DesignTokens.fontMd2,
                              height: 1.6,
                              color: context.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // The important part
                          Container(
                            padding: const EdgeInsets.all(DesignTokens.spaceLg),
                            decoration: BoxDecoration(
                              color: context.colorScheme.primary.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                              border: Border.all(
                                color: context.colorScheme.primary.withValues(alpha: 0.12),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: DesignTokens.space2xs),
                                  child: Icon(
                                    PhosphorIconsLight.info,
                                    size: 20,
                                    color: context.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Our AI Companion runs on your device and provides helpful information — '
                                    'but it is not a doctor. Its advice may not always be right, complete, '
                                    'or right for your child specifically.',
                                    style: TextStyle(
                                      fontSize: DesignTokens.fontMd,
                                      height: 1.55,
                                      fontWeight: FontWeight.w500,
                                      color: context.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // What to do instead
                          _adviceRow(
                            icon: PhosphorIconsLight.stethoscope,
                            text: 'Always check with your pediatrician or healthcare provider about any concerns',
                          ),
                          const SizedBox(height: 12),
                          _adviceRow(
                            icon: PhosphorIconsLight.phoneCall,
                            text: 'Call your doctor right away if something feels wrong — trust your instincts',
                          ),
                          const SizedBox(height: 12),
                          _adviceRow(
                            icon: PhosphorIconsLight.bookOpen,
                            text: 'Use our parenting advice as a starting point, not the final word',
                          ),
                          const SizedBox(height: 12),
                          _adviceRow(
                            icon: PhosphorIconsLight.shieldCheck,
                            text: 'In an emergency, call 911 immediately — not the AI Companion',
                          ),

                          const SizedBox(height: 24),

                          // Heartfelt closing
                          Center(
                            child: Text(
                              'You\'re doing an amazing job.\n'
                              'We just want to make sure you have the full picture.',
                              style: TextStyle(
                                fontSize: DesignTokens.fontSm2,
                                height: 1.6,
                                color: context.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Buttons
                    Padding(
                      padding: const EdgeInsets.fromLTRB(DesignTokens.space2xl, DesignTokens.spaceLg, DesignTokens.space2xl, DesignTokens.space2xl),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _dismiss,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                                ),
                              ),
                              child: const Text(
                                'I Understand — Thank You',
                                style: TextStyle(
                                  fontSize: DesignTokens.fontLg,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: DesignTokens.spaceSm),
                          TextButton(
                            onPressed: _close,
                            child: Text(
                              'Remind me later',
                              style: TextStyle(
                                fontSize: DesignTokens.fontMd,
                                color: context.textCaption,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _adviceRow({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: DesignTokens.spaceXs),
          child: Icon(icon, size: 18, color: context.colorScheme.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: DesignTokens.fontMd, height: 1.5),
          ),
        ),
      ],
    );
  }
}
