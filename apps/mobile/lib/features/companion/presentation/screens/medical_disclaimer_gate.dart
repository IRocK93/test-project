import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/theme/design_tokens.dart';
import 'package:baby_mon/features/companion/presentation/widgets/companion_theme.dart';

class MedicalDisclaimerGate extends StatefulWidget {
  final VoidCallback onAccept;

  const MedicalDisclaimerGate({super.key, required this.onAccept});

  @override
  State<MedicalDisclaimerGate> createState() => _MedicalDisclaimerGateState();
}

class _MedicalDisclaimerGateState extends State<MedicalDisclaimerGate>
    with SingleTickerProviderStateMixin {
  bool _accepted = false;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: DesignTokens.durationSlow,
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(DesignTokens.space2xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Warning icon
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(DesignTokens.spaceXl),
                    decoration: BoxDecoration(
                      color: context.colorScheme.error.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Semantics(
                      label: 'Warning: Medical disclaimer',
                      child: Icon(PhosphorIconsLight.warning, size: 40, color: context.colorScheme.error),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                const Center(
                  child: Text(
                    'Medical & AI Disclaimer',
                    style: TextStyle(fontSize: DesignTokens.fontXl2, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Please read carefully before using the AI Companion',
                    style: TextStyle(fontSize: DesignTokens.fontMd, color: context.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),

                // Key points
                _disclaimerItem(
                  icon: PhosphorIconsLight.heartbeat,
                  title: 'Not a Medical Device',
                  body: 'BabyMon is not a medical device. It does not diagnose, treat, or provide medical advice.',
                ),
                _disclaimerItem(
                  icon: PhosphorIconsLight.warningOctagon,
                  title: 'Not for Emergencies',
                  body: 'If your child needs immediate medical attention, call 911 (or your local emergency number). Do not use the AI Companion for emergencies.',
                ),
                _disclaimerItem(
                  icon: PhosphorIconsLight.cpu,
                  title: 'On-Device AI — No Human Review',
                  body: 'The AI Companion runs entirely on your device. No professional reviews individual responses before you see them. AI-generated advice may be inaccurate, incomplete, or not applicable to your child.',
                ),
                _disclaimerItem(
                  icon: PhosphorIconsLight.user,
                  title: 'You Are Responsible',
                  body: 'You must independently verify any AI Companion advice with a qualified healthcare professional before acting on it. You assume all risks when using this feature.',
                ),
                _disclaimerItem(
                  icon: PhosphorIconsLight.shieldCheck,
                  title: 'Your Data Stays On-Device',
                  body: 'No child health data is sent to external AI services. All AI inference happens locally on your phone.',
                ),

                const SizedBox(height: 24),

                // Checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      label: 'I understand and accept the medical disclaimer',
                      checked: _accepted,
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _accepted,
                          onChanged: (v) => setState(() => _accepted = v ?? false),
                          activeColor: context.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'I understand that the AI Companion is not a substitute for professional medical advice. I accept all risks associated with using AI-generated parenting guidance.',
                        style: TextStyle(fontSize: DesignTokens.fontSm2, height: 1.5),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Accept button
                Semantics(
                  label: _accepted
                      ? 'I understand — Continue. Accept medical disclaimer'
                      : 'I understand — Continue. Check the box to accept',
                  enabled: _accepted,
                  button: true,
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _accepted ? widget.onAccept : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colorScheme.primary,
                        disabledBackgroundColor: context.textSecondary.withValues(alpha: 0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                        ),
                      ),
                      child: const Text(
                        'I Understand — Continue',
                        style: TextStyle(fontSize: DesignTokens.fontLg, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Decline
                Center(
                  child: Semantics(
                    label: 'Decline disclaimer and go back',
                    button: true,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Go Back',
                        style: TextStyle(color: context.textSecondary, fontSize: DesignTokens.fontMd),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _disclaimerItem({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spaceLg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: context.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: DesignTokens.fontMd, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(body, style: TextStyle(fontSize: DesignTokens.fontSm2, color: context.textSecondary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
