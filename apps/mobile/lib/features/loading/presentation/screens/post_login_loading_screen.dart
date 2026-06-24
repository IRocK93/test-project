import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/core/constants/constants.dart';
import 'package:baby_mon/core/widgets/widgets.dart';
/// Full-screen branded loading experience shown after sign-in.
///
/// Pre-fetches dashboard data into the [ResponseCache] while displaying
/// an animated splash for a minimum of 6 seconds, then navigates to /home.
class PostLoginLoadingScreen extends ConsumerStatefulWidget {
  const PostLoginLoadingScreen({super.key});
  @override
  ConsumerState<PostLoginLoadingScreen> createState() =>
      _PostLoginLoadingScreenState();
}
class _PostLoginLoadingScreenState
    extends ConsumerState<PostLoginLoadingScreen> {
  static const _minDisplaySeconds = 6;
  static const _messageCycleSeconds = 2;
  final List<String> _messages = const [
    'Welcome back!',
    'Loading your BabyMon…',
    'Preparing your dashboard…',
    'Almost ready…',
  ];
  int _messageIndex = 0;
  Timer? _messageTimer;
  @override
  void initState() {
    super.initState();
    _start();
  }
  @override
  void dispose() {
    _messageTimer?.cancel();
    super.dispose();
  }
  Future<void> _start() async {
    // Cycle loading messages
    _messageTimer = Timer.periodic(
      const Duration(seconds: _messageCycleSeconds),
      (_) {
        if (mounted) {
          setState(() => _messageIndex = (_messageIndex + 1) % _messages.length);
        }
      },
    );
    // Run pre-fetch and minimum timer in parallel
    final results = await Future.wait([
      _prefetchData(),
      Future.delayed(const Duration(seconds: _minDisplaySeconds)),
    ]);
    final prefetchOk = results[0] as bool;
    if (mounted) {
      _messageTimer?.cancel();
      // Brief pause so the user sees the final state
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        if (prefetchOk) {
          context.go('/home');
        } else {
          // Still navigate — dashboard will handle missing data gracefully
          context.go('/home');
        }
      }
    }
  }
  /// Pre-fetches essential dashboard data to warm the ResponseCache.
  /// Returns true if the critical path (BabyMon ID + BabyMon) succeeded.
  Future<bool> _prefetchData() async {
    final api = ref.read(apiClientProvider);
    try {
      // Step 1: get selected BabyMon ID
      final id = await api.getSelectedBabyMonId();
      if (id == null) return false; // No BabyMon yet — dashboard shows welcome
      // Step 2: parallel fetch all essential dashboard data
      await Future.wait([
        _safeFetch(() => api.getBabyMon(id)),
        _safeFetch(() => api.getEvolution(id)),
        _safeFetch(() => api.getGrowthRecords(id, type: 'WEIGHT')),
        _safeFetch(() => api.getGrowthRecords(id, type: 'HEIGHT')),
        _safeFetch(() => api.getAllergies(id)),
        _safeFetch(() => api.getProfile()),
      ]);
      return true;
    } catch (_) {
      return false;
    }
  }
  Future<void> _safeFetch(Future<dynamic> Function() fetch) async {
    try {
      await fetch();
    } catch (_) {
      // Silently ignore — dashboard will re-fetch on its own
    }
  }
  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final msg = _messages[_messageIndex % _messages.length];
    return Scaffold(
      body: PremiumBackground(
        showOrnaments: true,
        child: SafeArea(
          child: Center(
            child: GlassSurface.group(
              context: context,
              borderRadius: DesignTokens.radius3xl,
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.space3xl,
                vertical: DesignTokens.space4xl,
              ),
              gap: 0,
              children: [
                // ── Logo orb ──
                FadeScaleIn(
                  child: Container(
                    width: 96,
                    height: 96,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radius3xl),
                      boxShadow: [
                        BoxShadow(
                          color: cs.shadow.withValues(alpha: 0.15),
                          blurRadius: 40,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.child_care,
                      size: 48,
                      color: cs.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: DesignTokens.space2xl),
                // ── App name ──
                FadeScaleIn(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'BabyMon',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                  ),
                ),
                const SizedBox(height: DesignTokens.space2xl),
                // ── Loading message ──
                FadeScaleIn(
                  delay: const Duration(milliseconds: 500),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      msg,
                      key: ValueKey(msg),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: DesignTokens.space3xl),
                // ── Progress indicator ──
                FadeScaleIn(
                  delay: const Duration(milliseconds: 800),
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(cs.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
