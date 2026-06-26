import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/utils/json_utils.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/core/constants/constants.dart';
import 'package:baby_mon/core/widgets/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
class CreateBabyMonScreen extends ConsumerStatefulWidget {
  const CreateBabyMonScreen({super.key});
  @override
  ConsumerState<CreateBabyMonScreen> createState() =>
      _CreateBabyMonScreenState();
}
class _CreateBabyMonScreenState extends ConsumerState<CreateBabyMonScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  static const int _totalSteps = 5;
  final _nameController = TextEditingController();
  String _stageType = 'BORN';
  DateTime? _birthDate;
  DateTime? _conceptionDate;
  DateTime? _ideaDate;
  String _gender = 'MONIOUS';
  final List<String> _selectedTraits = [];
  final _specialMoveController = TextEditingController();
  bool _isLoading = false;
  // ── MJ Voice System ──
  String _mjMessage = '';
  // ── Flavor Text System ──
  String? _lastTappedTrait;
  // ── Splash Animation ──
  late final AnimationController _orbController;
  late final Animation<double> _orbPulse;
  late final AnimationController _splashFadeController;
  late final Animation<double> _splashLine1Opacity;
  late final Animation<double> _splashLine2Opacity;
  late final Animation<double> _splashButtonOpacity;
  bool _splashAnimationStarted = false;
  // ── Naming chime debounce ──
  bool _chimePlayed = false;
  // ── Splash debounce ──
  bool _splashTransitioning = false;
  // ── Review step active ──
  bool _isCompleting = false;
  late final AnimationController _particleController;
  bool _showParticles = false;
  // ── Loading phase ──
  bool _loadingStep = false;
  int _loadingMessageIndex = 0;
  Timer? _loadingTimer;
  static const List<String> _loadingMessages = [
    'Weaving the nest…',
    'Gathering tiny blankets…',
    'Warming the incubator…',
    'Preparing a gentle arrival…',
    'Writing the first lullaby…',
    'Almost ready…',
  ];
  // ── Calendar state ──
  DateTime _calendarMonth =
      DateTime(DateTime.now().year, DateTime.now().month);
  static const List<String> _traitOptions = [
    'Curious',
    'Peaceful',
    'Playful',
    'Gentle',
    'Adventurous',
    'Creative',
  ];
  static const Map<String, String> traitFlavorText = {
    'Curious': 'Curious — always exploring the world with wide eyes.',
    'Peaceful':
        'Peaceful — a calm presence that soothes everyone around them.',
    'Playful': 'Playful — finding joy in every tiny moment.',
    'Gentle': 'Gentle — the softest touch, the kindest heart.',
    'Adventurous': 'Adventurous — ready to discover something new every day.',
    'Creative': 'Creative — seeing the world differently, beautifully.',
  };
  // ── Suggested name rotation ──
  static const List<String> _suggestedNames = [
    'Luna',
    'Milo',
    'Nova',
    'Theo',
    'Zara',
    'Kai',
    'Aria',
    'Finn',
    'Sage',
    'Rumi',
    'Sky',
    'Juno',
  ];
  List<String> get _rotatedNames {
    final now = DateTime.now();
    final seed = now.day + now.month * 31;
    final start = seed % (_suggestedNames.length - 3);
    return _suggestedNames.sublist(start, start + 3);
  }
  @override
  void initState() {
    super.initState();
    // ── Orb pulse animation ──
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _orbPulse = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _orbController, curve: Curves.easeInOut),
    );
    // ── Splash fade animation ──
    _splashFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _splashLine1Opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _splashFadeController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );
    _splashLine2Opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _splashFadeController,
        curve: const Interval(0.25, 0.55, curve: Curves.easeOut),
      ),
    );
    _splashButtonOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _splashFadeController,
        curve: const Interval(0.55, 0.8, curve: Curves.easeOut),
      ),
    );
    // ── Particle burst controller ──
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }
  @override
  void dispose() {
    _nameController.dispose();
    _specialMoveController.dispose();
    _orbController.dispose();
    _splashFadeController.dispose();
    _particleController.dispose();
    _loadingTimer?.cancel();
    super.dispose();
  }
  // ═══════════════════════════════════════
  //  THEME-AWARE TEXT COLOR HELPER
  // ═══════════════════════════════════════
  /// Returns the resolved on-surface color from the current theme.
  /// This is the correct text-on-background color for both light and dark modes.
  /// Use with [withValues] for alpha-tinted secondary text.
  Color get _textColor => Theme.of(context).colorScheme.onSurface;
  // ═══════════════════════════════════════
  //  MJ MESSAGE SYSTEM
  // ═══════════════════════════════════════
  String _getMjMessage() {
    switch (_currentStep) {
      case 0:
        return 'Every great journey begins with a single heartbeat.';
      case 1:
        return 'Names carry stories. What will yours be called?';
      case 2:
        return 'Every journey begins at a different point. When did yours begin?';
      case 3:
        return "Every BabyMon has a unique spirit. Let's discover yours.";
      case 4:
        return "You've written the first page of your story together.\nAre you ready to begin?";
      default:
        return '';
    }
  }
  Widget _buildMjMessage() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Padding(
        key: ValueKey(_currentStep),
        padding: const EdgeInsets.fromLTRB(
          DesignTokens.spaceLg,
          DesignTokens.spaceSm,
          DesignTokens.spaceLg,
          DesignTokens.spaceSm,
        ),
        child: Text(
          _mjMessage,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
                color: _textColor,
                height: 1.5,
              ),
        ),
      ),
    );
  }
  // ═══════════════════════════════════════
  //  VALIDATION
  // ═══════════════════════════════════════
  bool get _canProceed {
    switch (_currentStep) {
      case 0:
        return !_splashTransitioning;
      case 1:
        return _nameController.text.trim().isNotEmpty;
      case 2:
        if (_stageType == 'BORN') return _birthDate != null;
        if (_stageType == 'INCUBATING') return _conceptionDate != null;
        return _ideaDate != null;
      case 3:
        return true;
      case 4:
        return true;
      default:
        return false;
    }
  }
  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
        _mjMessage = _getMjMessage();
      });
      if (_currentStep == 4) {
        setState(() {});
      }
    }
  }
  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _mjMessage = _getMjMessage();
      });
    }
  }
  // ═══════════════════════════════════════
  //  CREATE BABY MON — IDENTICAL
  // ═══════════════════════════════════════
  Future<void> _createBabyMon() async {
    setState(() {
      _isLoading = true;
      _isCompleting = true;
      _showParticles = true;
    });
    _particleController.forward(from: 0);
    try {
      final data = <String, dynamic>{
        'name': _nameController.text.trim(),
        'stageStartType': _stageType,
        'gender': _gender,
        'traits': _selectedTraits,
        if (_specialMoveController.text.isNotEmpty)
          'specialMove': _specialMoveController.text.trim(),
      };
      if (_stageType == 'BORN' && _birthDate != null) {
        data['birthDate'] = DateFormat('yyyy-MM-dd').format(_birthDate!);
      } else if (_stageType == 'INCUBATING' && _conceptionDate != null) {
        final dateStr = DateFormat('yyyy-MM-dd').format(_conceptionDate!);
        data['conceptionDate'] = dateStr;
        data['lmpDate'] = dateStr;
      } else if (_stageType == 'PLAN' && _ideaDate != null) {
        data['ideaDate'] = DateFormat('yyyy-MM-dd').format(_ideaDate!);
      }
      final response =
          await ref.read(apiClientProvider).post('/baby-mons', data: data);
      await ref
          .read(apiClientProvider)
          .setSelectedBabyMonId(parseString(response.data['id']));
      ref.read(appRefreshProvider.notifier).state++;
      // ── Loading phase: cycle messages for ~6 seconds ──
      setState(() {
        _loadingStep = true;
        _isLoading = false;
        _isCompleting = false;
        _showParticles = false;
      });
      _particleController.reset();
      _loadingMessageIndex = 0;
      _loadingTimer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          _loadingMessageIndex = (_loadingMessageIndex + 1) % _loadingMessages.length;
        });
      });
      // Navigate home after the loading phase
      await Future<void>.delayed(const Duration(milliseconds: 6200));
      _loadingTimer?.cancel();
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() {
        _isCompleting = false;
        _showParticles = false;
      });
      _particleController.reset();
      String message = 'Failed to create BabyMon';
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          message = 'Server error. Please try again.';
        } else if (e.response?.data != null) {
          final data = e.response!.data;
          if (data is Map) {
            final msg = data['message'];
            if (msg is List) {
              message = msg.join(', ');
            } else if (msg is String) {
              message = msg;
            }
          }
        } else if (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout) {
          message = 'Cannot connect to server. Please check your connection.';
        } else {
          message = 'Request failed. Please try again.';
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (!_isCompleting && mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  // ═══════════════════════════════════════
  //  STEP INDICATOR (updated to 5 dots)
  // ═══════════════════════════════════════
  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.spaceXl,
        DesignTokens.spaceMd,
        DesignTokens.spaceXl,
        DesignTokens.spaceMd,
      ),
      child: Row(
        children: List.generate(_totalSteps, (i) {
          final isActive = i == _currentStep;
          final isCompleted = i < _currentStep;
          return Expanded(
            child: Row(
              children: [
                AnimatedContainer(
                  duration: DesignTokens.durationNormal,
                  curve: DesignTokens.curvePremium,
                  width: isActive || isCompleted ? 32 : 10,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isActive
                        ? context.colorScheme.primary
                        : isCompleted
                            ? context.colorScheme.primary
                            : _textColor.withValues(alpha: DesignTokens.opacitySubtle),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color:
                                  context.colorScheme.primary.withValues(alpha: DesignTokens.opacityDim),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: isCompleted
                      ? Icon(PhosphorIconsLight.check,
                          size: 16, color: context.colorScheme.onPrimary)
                      : i == 0
                          ? Icon(
                              PhosphorIconsLight.heart,
                              size: 16,
                              color: isActive
                                  ? context.colorScheme.onPrimary
                                  : _textColor.withValues(alpha: 0.5),
                            )
                          : Text(
                              '$i',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isActive
                                    ? Colors.white
                                    : _textColor.withValues(alpha: 0.5),
                              ),
                            ),
                ),
                if (i < _totalSteps - 1)
                  Expanded(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: i < _currentStep
                              ? [
                                  context.colorScheme.primary,
                                  context.colorScheme.primary.withValues(alpha: DesignTokens.opacityDim)
                                ]
                              : [
                                  _textColor.withValues(alpha: 0.12),
                                  _textColor.withValues(alpha: 0.05),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
  // ═══════════════════════════════════════
  //  STEP 0 — SPLASH
  // ═══════════════════════════════════════
  Widget _buildSplash() {
    if (!_splashAnimationStarted) {
      _splashAnimationStarted = true;
      _splashFadeController.forward();
    }
    return AnimatedBuilder(
      animation: _splashFadeController,
      builder: (context, child) {
        return SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: DesignTokens.spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: DesignTokens.space3xl),
              // ── Glowing Orb ──
              AnimatedBuilder(
                animation: _orbPulse,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _orbPulse.value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 0.5,
                          colors: [
                            context.colorScheme.primary.withValues(alpha: 0.8),
                            context.colorScheme.primary.withValues(alpha: DesignTokens.opacityDisabled),
                            context.colorScheme.primaryContainer.withValues(alpha: 0.1),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                context.colorScheme.primary.withValues(alpha: DesignTokens.opacityDim),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: DesignTokens.space3xl),
              // ── MJ Line 1 ──
              Opacity(
                opacity: _splashLine1Opacity.value,
                child: Text(
                  'Every great journey\nbegins with a single heartbeat.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: _textColor,
                        height: 1.4,
                      ),
                ),
              ),
              const SizedBox(height: DesignTokens.spaceLg),
              // ── MJ Line 2 ──
              Opacity(
                opacity: _splashLine2Opacity.value,
                child: Text(
                  'Yours started the moment\nyou decided to welcome a new life.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: _textColor.withValues(alpha: 0.7),
                        height: 1.5,
                      ),
                ),
              ),
              const SizedBox(height: DesignTokens.space4xl),
              // ── Begin Button ──
              Opacity(
                opacity: _splashButtonOpacity.value,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1.0, end: 1.02),
                  duration: const Duration(seconds: 2),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: ThemeButton(
                    text: 'Begin Your Journey',
                    onPressed:
                        _splashButtonOpacity.value > 0.8
                            ? _onSplashBegin
                            : null,
                    fullWidth: true,
                    icon: PhosphorIconsLight.heart,
                    borderRadius: DesignTokens.radiusFull,
                    height: 56,
                    semanticLabel: 'Begin your BabyMon journey',
                  ),
                ),
              ),
              const SizedBox(height: DesignTokens.spaceXl),
            ],
          ),
        );
      },
    );
  }
  void _onSplashBegin() {
    if (_splashTransitioning) return;
    setState(() => _splashTransitioning = true);
    Future<void>.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _currentStep = 1;
          _mjMessage = _getMjMessage();
          _splashTransitioning = false;
        });
      }
    });
  }
  // ═══════════════════════════════════════
  //  STEP 1 — NAME YOUR BABYMON
  // ═══════════════════════════════════════
  Widget _buildNameStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: DesignTokens.spaceMd),
          // ── Avatar orb ──
          AnimatedBuilder(
            animation: _orbPulse,
            builder: (context, child) {
              return Transform.scale(
                scale: _orbPulse.value,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.5,
                      colors: [
                        context.colorScheme.primary.withValues(alpha: 0.6),
                        context.colorScheme.primary.withValues(alpha: DesignTokens.opacityDim),
                        context.colorScheme.primaryContainer.withValues(alpha: 0.05),
                      ],
                    ),
                    boxShadow: _nameController.text.isNotEmpty
                        ? [
                            BoxShadow(
                              color: context.colorScheme.primary
                                  .withValues(alpha: 0.25),
                              blurRadius: 16,
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    PhosphorIconsLight.baby,
                    size: 40,
                    color: context.colorScheme.primary,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: DesignTokens.space2xl),
          // ── Naming text field ──
          PremiumDoubleBezel(
            outerRadius: DesignTokens.radius2xl,
            gap: 5.0,
            outerColor: context.colorScheme.primary.withValues(alpha: DesignTokens.opacityGhost),
            innerPadding: const EdgeInsets.all(DesignTokens.spaceSm),
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter a name...',
                hintStyle:
                    Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: _textColor.withValues(alpha: 0.35),
                          fontStyle: FontStyle.italic,
                        ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spaceLg,
                  vertical: DesignTokens.spaceMd,
                ),
                suffixIcon: _nameController.text.isNotEmpty
                    ? IconButton(
                        icon:
                            const Icon(PhosphorIconsLight.x, size: 18),
                        onPressed: () {
                          _nameController.clear();
                          setState(() {
                            _chimePlayed = false;
                          });
                        },
                      )
                    : null,
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: (value) {
                if (value.isNotEmpty && !_chimePlayed) {
                  _chimePlayed = true;
                  HapticFeedback.lightImpact();
                } else if (value.isEmpty) {
                  _chimePlayed = false;
                }
                setState(() {});
              },
              maxLength: 50,
              autofocus: true,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _textColor,
                    letterSpacing: -0.3,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          // ── Suggested name chips ──
          Wrap(
            spacing: DesignTokens.spaceSm,
            runSpacing: DesignTokens.spaceSm,
            alignment: WrapAlignment.center,
            children: _rotatedNames.map((name) {
              return ActionChip(
                label: Text(
                  name,
                  style: TextStyle(
                    color: _textColor.withValues(alpha: 0.8),
                  ),
                ),
                backgroundColor:
                    context.colorScheme.primary.withValues(alpha: 0.10),
                side: BorderSide(
                  color: context.colorScheme.primary.withValues(alpha: DesignTokens.opacitySubtle),
                ),
                onPressed: () {
                  _nameController.text = name;
                  if (!_chimePlayed) {
                    _chimePlayed = true;
                    HapticFeedback.lightImpact();
                  }
                  setState(() {});
                },
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(DesignTokens.radiusFull),
                ),
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  // ═══════════════════════════════════════
  //  STEP 2 — WHEN DOES YOUR JOURNEY START?
  // ═══════════════════════════════════════
  Widget _buildStageStep() {
    final pageController = PageController(
      initialPage: _stageType == 'BORN' ? 0 : _stageType == 'INCUBATING' ? 1 : 2,
      viewportFraction: 0.82,
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: DesignTokens.spaceSm),
          // ── Stage cards — horizontal swipeable carousel ──
          SizedBox(
            height: 176,
            child: PageView(
              controller: pageController,
              onPageChanged: (i) {
                setState(() {
                  _stageType = i == 0 ? 'BORN' : i == 1 ? 'INCUBATING' : 'PLAN';
                });
              },
              children: [
                _buildStageCard(
                  value: 'BORN',
                  icon: PhosphorIconsLight.baby,
                  title: 'Born',
                  description: 'A gentle arrival.\nThe world welcomed them.',
                  subText: 'Your BabyMon is already in the wild.\nWhen did you first meet?',
                ),
                _buildStageCard(
                  value: 'INCUBATING',
                  icon: PhosphorIconsLight.heart,
                  title: 'Incubating',
                  description: 'A beautiful surprise.\nThe journey began in stillness.',
                  subText: 'Expecting a surprise!\nWhen is it due?',
                ),
                _buildStageCard(
                  value: 'PLAN',
                  icon: PhosphorIconsLight.lightbulb,
                  title: 'Plan',
                  description: 'A heartfelt wish.\nLong before they existed,\nthey were loved.',
                  subText: "Wouldn't it be nice to catch\n1 or 2 little BabyMons?",
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.spaceSm),
          // ── Page dots ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              final active = i == (_stageType == 'BORN' ? 0 : _stageType == 'INCUBATING' ? 1 : 2);
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 16 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active
                      ? context.colorScheme.primary
                      : _textColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: DesignTokens.spaceLg),
          // ── Calendar grid ──
          _buildCalendarGrid(),
        ],
      ),
    );
  }
  Widget _buildStageCard({
    required String value,
    required IconData icon,
    required String title,
    required String description,
    required String subText,
  }) {
    final isSelected = _stageType == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedScale(
      scale: isSelected ? 1.04 : 0.95,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceSm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Card ──
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: PremiumDoubleBezel(
                outerRadius: DesignTokens.radiusXl,
                gap: 4.0,
                outerColor: isSelected
                    ? context.colorScheme.primary.withValues(alpha: 0.18)
                    : _textColor.withValues(alpha: 0.04),
                innerColor: isSelected
                    ? context.colorScheme.primary.withValues(alpha: 0.1)
                    : (isDark ? context.glass.background : context.glass.surface),
                innerPadding: const EdgeInsets.symmetric(
                  vertical: DesignTokens.spaceSm,
                  horizontal: DesignTokens.spaceXs,
                ),
                showInnerHighlight: isSelected,
                onTap: () => setState(() => _stageType = value),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedScale(
                      scale: isSelected ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      child: Icon(
                        icon,
                        size: isSelected ? 30 : 22,
                        color: isSelected
                            ? context.colorScheme.primary
                            : _textColor.withValues(alpha: 0.45),
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spaceXs),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      style: TextStyle(
                        fontSize: isSelected ? 15 : 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? context.colorScheme.primary
                            : _textColor.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                      child: Text(title),
                    ),
                    const SizedBox(height: 2),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      style: TextStyle(
                        fontSize: isSelected ? 11 : 10,
                        color: isSelected
                            ? _textColor.withValues(alpha: 0.85)
                            : _textColor.withValues(alpha: 0.45),
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                      child: Text(description),
                    ),
                  ],
                ),
              ),
            ),
            // ── Sub-text (visible only when selected) ──
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(top: DesignTokens.spaceMd),
                      child: Text(
                        subText,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _textColor.withValues(alpha: 0.55),
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                            ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildCalendarGrid() {
    final selectedDate = _stageType == 'BORN'
        ? _birthDate
        : _stageType == 'INCUBATING'
            ? _conceptionDate
            : _ideaDate;
    final year = _calendarMonth.year;
    final month = _calendarMonth.month;
    final firstDayOfMonth = DateTime(year, month, 1);
    final lastDayOfMonth = DateTime(year, month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;
    final today = DateTime.now();
    final isCurrentMonth = year == today.year && month == today.month;
    final now = DateTime.now();
    // Incubating allows future dates up to ~40 weeks (due date range)
    // Plan allows up to a year in the future
    final maxAllowed = _stageType == 'INCUBATING'
        ? DateTime(now.year, now.month, now.day).add(const Duration(days: 280))
        : _stageType == 'PLAN'
            ? DateTime(now.year, now.month, now.day).add(const Duration(days: 365))
            : DateTime(now.year, now.month, now.day);
    const weekdayHeaders = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return PremiumDoubleBezel(
      outerRadius: DesignTokens.radius2xl,
      gap: 5.0,
      outerColor: context.colorScheme.primary.withValues(alpha: DesignTokens.opacityGhost),
      innerPadding: const EdgeInsets.all(DesignTokens.spaceMd),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Month header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(PhosphorIconsLight.caretLeft, size: 20),
                onPressed: () {
                  setState(() {
                    _calendarMonth = DateTime(year, month - 1, 1);
                  });
                },
                color: _textColor.withValues(alpha: 0.6),
                visualDensity: VisualDensity.compact,
              ),
              Text(
                DateFormat('MMMM yyyy').format(_calendarMonth),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _textColor,
                    ),
              ),
              IconButton(
                icon: const Icon(PhosphorIconsLight.caretRight, size: 20),
                onPressed: () {
                  setState(() {
                    _calendarMonth = DateTime(year, month + 1, 1);
                  });
                },
                color: _textColor.withValues(alpha: 0.6),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceSm),
          // ── Weekday headers ──
          Row(
            children: weekdayHeaders.map((d) {
              return Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(
                          color: _textColor.withValues(alpha: 0.45),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: DesignTokens.spaceXs),
          // ── Day grid ──
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
            itemCount: firstWeekday + daysInMonth,
            itemBuilder: (context, index) {
              if (index < firstWeekday) return const SizedBox.shrink();
              final day = index - firstWeekday + 1;
              final date = DateTime(year, month, day);
              final isSelected = selectedDate != null &&
                  selectedDate.year == year &&
                  selectedDate.month == month &&
                  selectedDate.day == day;
              final isToday = date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;
              final isFuture = date.isAfter(maxAllowed);
              final isPast = date.isBefore(DateTime(2020, 1, 1));
              final bool canSelect = !isFuture && !isPast;
              return GestureDetector(
                onTap: canSelect
                    ? () {
                        setState(() {
                          if (_stageType == 'BORN') {
                            _birthDate = date;
                          } else if (_stageType == 'INCUBATING') {
                            _conceptionDate = date;
                          } else {
                            _ideaDate = date;
                          }
                        });
                      }
                    : null,
                child: AnimatedContainer(
                  duration: DesignTokens.durationFast,
                  curve: DesignTokens.curvePremium,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.colorScheme.primary
                        : isToday
                            ? context.colorScheme.primary.withValues(alpha: DesignTokens.opacitySubtle)
                            : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(DesignTokens.radiusSm),
                    border: isToday && !isSelected
                        ? Border.all(
                            color: context.colorScheme.primary
                                .withValues(alpha: DesignTokens.opacityDim),
                            width: 1,
                          )
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected || isToday
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? context.colorScheme.onPrimary
                          : isFuture
                              ? _textColor.withValues(alpha: 0.2)
                              : _textColor.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: DesignTokens.spaceSm),
          // ── Today button ──
          if (isCurrentMonth)
            TextButton(
              onPressed: () {
                final todayDate =
                    DateTime(today.year, today.month, today.day);
                if (!todayDate.isAfter(maxAllowed)) {
                  setState(() {
                    if (_stageType == 'BORN') {
                      _birthDate = todayDate;
                    } else if (_stageType == 'INCUBATING') {
                      _conceptionDate = todayDate;
                    } else {
                      _ideaDate = todayDate;
                    }
                  });
                }
              },
              child: Text(
                'Today',
                style: TextStyle(
                  color: context.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
  // ═══════════════════════════════════════
  //  STEP 3 — DISCOVER THEIR SPIRIT
  // ═══════════════════════════════════════
  Widget _buildSpiritStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: DesignTokens.spaceMd),
          // ── Gender orbs ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildGenderOrb(
                value: 'MONIESE',
                label: 'Moniese',
                gradientColors: [
                  AppColors.genderMonieseAccent,
                  AppColors.genderMoniese,
                ],
                icon: PhosphorIconsLight.genderFemale,
              ),
              _buildGenderOrb(
                value: 'MONIOUS',
                label: 'Monious',
                gradientColors: [
                  AppColors.genderMoniousAccent,
                  AppColors.genderMonious,
                ],
                icon: PhosphorIconsLight.genderMale,
              ),
              _buildGenderOrb(
                value: 'MO',
                label: 'Neutral',
                gradientColors: [
                  AppColors.genderNeutralAccent,
                  AppColors.genderNeutral,
                ],
                icon: PhosphorIconsLight.genderNonbinary,
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.space2xl),
          // ── Trait hint ──
          Text(
            'What words feel like them?',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _textColor.withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          // ── Trait chips ──
          Wrap(
            spacing: DesignTokens.spaceSm,
            runSpacing: DesignTokens.spaceSm,
            children: _traitOptions.map((trait) {
              final selected = _selectedTraits.contains(trait);
              return FilterChip(
                label: Text(trait),
                selected: selected,
                onSelected: (s) {
                  setState(() {
                    if (s) {
                      _selectedTraits.add(trait);
                      _lastTappedTrait = trait;
                    } else {
                      _selectedTraits.remove(trait);
                      if (_lastTappedTrait == trait) {
                        _lastTappedTrait = _selectedTraits.isNotEmpty
                            ? _selectedTraits.last
                            : null;
                      }
                    }
                  });
                },
                selectedColor: context.colorScheme.primaryContainer,
                checkmarkColor: context.colorScheme.primary,
                backgroundColor: _textColor.withValues(alpha: DesignTokens.opacityGhost),
                side: BorderSide(
                  color: selected
                      ? context.colorScheme.primary.withValues(alpha: 0.5)
                      : _textColor.withValues(alpha: 0.1),
                ),
                labelStyle: TextStyle(
                  color: selected
                      ? context.colorScheme.primary
                      : _textColor.withValues(alpha: 0.7),
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(DesignTokens.radiusFull),
                ),
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
          const SizedBox(height: DesignTokens.spaceSm),
          // ── Flavor text ──
          AnimatedSwitcher(
            duration: DesignTokens.durationFast,
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.05),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _lastTappedTrait != null
                ? Padding(
                    key: ValueKey(_lastTappedTrait),
                    padding: const EdgeInsets.only(
                        top: DesignTokens.spaceSm),
                    child: Text(
                      traitFlavorText[_lastTappedTrait] ?? '',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            color: _textColor.withValues(alpha: 0.7),
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: DesignTokens.space2xl),
          // ── Special gift ──
          Text(
            "Every BabyMon has a special gift. What's yours?",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _textColor.withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
          ),
          const SizedBox(height: DesignTokens.spaceSm),
          PremiumDoubleBezel(
            outerRadius: DesignTokens.radiusXl,
            gap: 4.0,
            outerColor: context.colorScheme.primary.withValues(alpha: 0.04),
            innerPadding: const EdgeInsets.all(DesignTokens.spaceSm),
            child: TextField(
              controller: _specialMoveController,
              decoration: InputDecoration(
                hintText: 'e.g. "Loves bath time", "Funny laugh"',
                hintStyle:
                    Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _textColor.withValues(alpha: DesignTokens.opacityDim),
                        ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spaceMd,
                  vertical: DesignTokens.spaceSm,
                ),
              ),
              maxLines: 2,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _textColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildGenderOrb({
    required String value,
    required String label,
    required List<Color> gradientColors,
    required IconData icon,
  }) {
    final isSelected = _gender == value;
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.6,
                  colors: isSelected
                      ? [
                          gradientColors[0].withValues(alpha: 0.9),
                          gradientColors[1].withValues(alpha: 0.6),
                        ]
                      : [
                          gradientColors[0].withValues(alpha: DesignTokens.opacityDim),
                          gradientColors[1].withValues(alpha: 0.2),
                        ],
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: gradientColors[0]
                              .withValues(alpha: 0.35),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 28,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: DesignTokens.spaceSm),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? gradientColors[0]
                        : _textColor.withValues(alpha: 0.5),
                  ),
            ),
          ],
        ),
      ),
    );
  }
  // ═══════════════════════════════════════
  //  STEP 4 — REVIEW & BEGIN
  // ═══════════════════════════════════════
  Widget _buildReviewStep() {
    // ── Loading phase overlay ──
    if (_loadingStep) {
      return _buildLoadingPhase();
    }
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: DesignTokens.spaceMd),
              // ── Journal card ──
              PremiumDoubleBezel(
                outerRadius: DesignTokens.radius2xl,
                gap: 5.0,
                outerColor: context.colorScheme.primary.withValues(alpha: 0.08),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: DesignTokens.spaceSm),
                    // ── Sparkle icon ──
                    Icon(
                      PhosphorIconsLight.sparkle,
                      size: 24,
                      color: context.colorScheme.primary,
                    ),
                    const SizedBox(height: DesignTokens.spaceMd),
                    // ── Name ──
                    Text(
                      _nameController.text.trim(),
                      style: GoogleFonts.syne(
                        textStyle: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: _textColor,
                              letterSpacing: -0.5,
                            ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: DesignTokens.spaceMd),
                    // ── Poetic date ──
                    Text(
                      _formatPoeticDate(),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color: _textColor.withValues(alpha: 0.7),
                            fontStyle: FontStyle.italic,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: DesignTokens.spaceXs),
                    // ── Stage descriptor ──
                    Text(
                      _stageDescriptor,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            color: _textColor.withValues(alpha: 0.6),
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: DesignTokens.spaceLg),
                    // ── Gender symbol ──
                    if (_gender.isNotEmpty)
                      _reviewRow(
                        PhosphorIconsLight.genderIntersex,
                        'Gender',
                        _gender == 'MONIESE'
                            ? 'Moniese'
                            : _gender == 'MONIOUS'
                                ? 'Monious'
                                : 'Neutral',
                      ),
                    // ── Traits ──
                    if (_selectedTraits.isNotEmpty)
                      _reviewRow(
                        PhosphorIconsLight.sparkle,
                        'Traits',
                        _selectedTraits.join(', '),
                      ),
                    // ── Special gift ──
                    if (_specialMoveController.text.trim().isNotEmpty)
                      _reviewRow(
                        PhosphorIconsLight.lightning,
                        'Special gift',
                        _specialMoveController.text.trim(),
                      ),
                    const SizedBox(height: DesignTokens.spaceLg),
                    // ── Begin button (in-card) ──
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 1.0, end: 1.02),
                      duration: const Duration(seconds: 2),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: _isLoading ? 1.0 : value,
                          child: child,
                        );
                      },
                      child: ThemeButton(
                        text: _isLoading
                            ? 'Writing the next page...'
                            : 'Begin Your Story',
                        onPressed: _isLoading ? null : _createBabyMon,
                        isLoading: _isLoading,
                        fullWidth: true,
                        icon: PhosphorIconsLight.heart,
                        borderRadius: DesignTokens.radiusFull,
                        height: 56,
                        semanticLabel: 'Begin your story',
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spaceSm),
                  ],
                ),
              ),
              const SizedBox(height: DesignTokens.spaceXl),
            ],
          ),
        ),
        // ── Particle burst overlay ──
        if (_showParticles) _buildParticleBurst(),
      ],
    );
  }
  Widget _buildLoadingPhase() {
    final msg = _loadingMessages[_loadingMessageIndex];
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space2xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Animated orb ──
            AnimatedBuilder(
              animation: _orbPulse,
              builder: (context, child) {
                return Transform.scale(
                  scale: _orbPulse.value,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          context.colorScheme.primary.withValues(alpha: 0.7),
                          context.colorScheme.primary.withValues(alpha: 0.2),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: context.colorScheme.primary.withValues(alpha: 0.25),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const Icon(
                      PhosphorIconsLight.sparkle,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: DesignTokens.space2xl),
            // ── Cycling message ──
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.05),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Text(
                msg,
                key: ValueKey(msg),
                textAlign: TextAlign.center,
                style: GoogleFonts.syne(
                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _textColor,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            // ── Spinner ──
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
  String _formatPoeticDate() {
    final date = _stageType == 'BORN'
        ? _birthDate
        : _stageType == 'INCUBATING'
            ? _conceptionDate
            : _ideaDate;
    if (date == null) return 'The journey has begun';
    final hour = date.hour;
    final weekday = DateFormat('EEEE').format(date);
    final month = DateFormat('MMMM').format(date);
    final day = DateFormat('d').format(date);
    String timeOfDay;
    if (hour >= 5 && hour < 12) {
      timeOfDay = 'morning';
    } else if (hour >= 12 && hour < 17) {
      timeOfDay = 'afternoon';
    } else if (hour >= 17 && hour < 22) {
      timeOfDay = 'evening';
    } else {
      timeOfDay = 'night';
    }
    return 'A $weekday $timeOfDay · $month $day';
  }
  String get _stageDescriptor {
    switch (_stageType) {
      case 'BORN':
        return 'A gentle arrival';
      case 'INCUBATING':
        return 'A beautiful surprise';
      case 'PLAN':
        return 'A heartfelt wish';
      default:
        return '';
    }
  }
  Widget _reviewRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius:
                  BorderRadius.circular(DesignTokens.radiusSm),
            ),
            child: Icon(
              icon,
              size: 16,
              color: context.colorScheme.primary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(width: DesignTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(
                        color: _textColor.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _textColor,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // ── Particle burst ──
  Widget _buildParticleBurst() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        final t = _particleController.value;
        return Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _ParticleBurstPainter(
                progress: t,
                color: context.colorScheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }
  // ═══════════════════════════════════════
  //  CURRENT STEP DISPATCH
  // ═══════════════════════════════════════
  Widget _buildCurrentStep() {
    if (_currentStep == 0) return _buildSplash();
    if (_currentStep == 4) return _buildReviewStep();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceLg),
      child: Column(
        children: [
          const SizedBox(height: DesignTokens.spaceMd),
          // ── MJ message ──
          _buildMjMessage(),
          const SizedBox(height: DesignTokens.spaceMd),
          // ── Step content card ──
          PremiumDoubleBezel(
            outerRadius: DesignTokens.radius2xl,
            gap: 5.0,
            outerColor: _bezelTint,
            child: _buildInnerStep(),
          ),
          const SizedBox(height: DesignTokens.spaceXl),
        ],
      ),
    );
  }
  Color get _bezelTint {
    switch (_currentStep) {
      case 0:
        return context.colorScheme.primary.withValues(alpha: DesignTokens.opacityGhost);
      case 1:
        return context.colorScheme.primary.withValues(alpha: DesignTokens.opacityGhost);
      case 2:
        return context.colorScheme.secondary.withValues(alpha: DesignTokens.opacityGhost);
      case 3:
        return AppColors.genderNeutral.withValues(alpha: 0.08);
      case 4:
        return context.colorScheme.primary.withValues(alpha: DesignTokens.opacityGhost);
      default:
        return context.colorScheme.primary.withValues(alpha: DesignTokens.opacityGhost);
    }
  }
  Widget _buildInnerStep() {
    switch (_currentStep) {
      case 1:
        return _buildNameStep();
      case 2:
        return _buildStageStep();
      case 3:
        return _buildSpiritStep();
      default:
        return const SizedBox.shrink();
    }
  }
  // ═══════════════════════════════════════
  //  CUSTOM TRAIT DIALOG
  // ═══════════════════════════════════════
  // ignore: unused_element
  void _showCustomTraitDialog() {
    final traitController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        ),
        title: const Text('Add Custom Trait'),
        content: TextField(
          controller: traitController,
          decoration: const InputDecoration(
              hintText: 'e.g., Brave, Silly, Kind'),
          maxLength: 20,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: Theme.of(context).textTheme.labelLarge),
          ),
          TextButton(
            onPressed: () {
              final trait = traitController.text.trim();
              if (trait.isNotEmpty) {
                setState(() => _selectedTraits.add(trait));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
  // ═══════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: const PreferredSize(
            preferredSize: Size.fromHeight(0),
            child: SizedBox.shrink(),
          ),
          body: PremiumBackground(
            child: Column(
              children: [
                SizedBox(
                    height: MediaQuery.of(context).padding.top + 54),
                _buildStepIndicator(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: DesignTokens.durationPage,
                    switchInCurve: DesignTokens.curvePremium,
                    switchOutCurve: DesignTokens.curvePremium,
                    transitionBuilder:
                        DesignTokens.pageTransitionBuilder,
                    child: StaggeredFadeSlide(
                      key: ValueKey(_currentStep),
                      index: 0,
                      child: _buildCurrentStep(),
                    ),
                  ),
                ),
                // ── Bottom navigation (hidden on Step 0 & Step 4) ──
                if (_currentStep > 0 &&
                    _currentStep < _totalSteps - 1)
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        DesignTokens.spaceLg,
                        DesignTokens.spaceSm,
                        DesignTokens.spaceLg,
                        DesignTokens.spaceSm,
                      ),
                      child: Row(
                        children: [
                          if (_currentStep > 1)
                            Expanded(
                              child: ThemeButton(
                                text: 'Back',
                                onPressed: _prevStep,
                                variant: ThemeButtonVariant.outlined,
                                fullWidth: true,
                                borderRadius: DesignTokens.radiusFull,
                                height: 56,
                                semanticLabel:
                                    'Go back to previous step',
                              ),
                            ),
                          if (_currentStep > 1)
                            const SizedBox(
                                width: DesignTokens.spaceMd),
                          Expanded(
                            flex: 2,
                            child: ThemeButton(
                              text: _canProceed
                                  ? 'Continue'
                                  : _currentStep == 2
                                      ? 'Select a date'
                                      : 'Enter a name',
                              onPressed:
                                  _canProceed ? _nextStep : null,
                              fullWidth: true,
                              icon: _canProceed
                                  ? PhosphorIconsLight.arrowRight
                                  : null,
                              borderRadius: DesignTokens.radiusFull,
                              height: 56,
                              semanticLabel: _canProceed
                                  ? 'Continue to next step'
                                  : 'Fill in required fields',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        // ── Floating pill back button overlay ──
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          child: PremiumDoubleBezel(
            outerRadius: DesignTokens.radiusFull,
            gap: 2.0,
            outerColor: context.colorScheme.outline.withValues(alpha: 0.12),
            innerPadding: EdgeInsets.zero,
            innerColor:
                Theme.of(context).brightness == Brightness.dark
                    ? context.glass.background
                    : context.glass.surface,
            showInnerHighlight: false,
            onTap: _currentStep > 0
                ? _prevStep
                : () {
                    if (GoRouter.of(context).canPop()) {
                      GoRouter.of(context).pop();
                    } else {
                      GoRouter.of(context).go('/home');
                    }
                  },
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: Icon(
                PhosphorIconsLight.arrowLeft,
                size: 18,
                color: _textColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
// ═══════════════════════════════════════════════════════════════════
//  PARTICLE BURST PAINTER
// ═══════════════════════════════════════════════════════════════════
class _ParticleBurstPainter extends CustomPainter {
  final double progress;
  final Color color;
  _ParticleBurstPainter({required this.progress, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rng = math.Random(42);
    const particleCount = 30;
    for (int i = 0; i < particleCount; i++) {
      final angle =
          (i / particleCount) * 2 * math.pi + rng.nextDouble() * 0.3;
      final distance = 40 + rng.nextDouble() * 120 * progress;
      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance - 40;
      final radius =
          (2.0 + rng.nextDouble() * 3.0) * (1.0 - progress * 0.5);
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = color.withValues(alpha: opacity * 0.7)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }
  @override
  bool shouldRepaint(covariant _ParticleBurstPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color;
  }
}