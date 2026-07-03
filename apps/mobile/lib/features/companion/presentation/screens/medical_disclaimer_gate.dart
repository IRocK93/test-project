import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/theme/design_tokens.dart';
import 'package:baby_mon/l10n/l10n_ext.dart';
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
                      label: context.l10n.warningMedicalDisclaimer,
                      child: Icon(PhosphorIconsLight.warning, size: 40, color: context.colorScheme.error),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Center(
                  child: Text(
                    context.l10n.medicalAiDisclaimerTitle,
                    style: const TextStyle(fontSize: DesignTokens.fontXl2, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    context.l10n.readCarefullySubtitle,
                    style: TextStyle(fontSize: DesignTokens.fontMd, color: context.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),

                // Key points
                _disclaimerItem(
                  icon: PhosphorIconsLight.heartbeat,
                  title: context.l10n.notMedicalDeviceTitle,
                  body: context.l10n.notMedicalDeviceDesc,
                ),
                _disclaimerItem(
                  icon: PhosphorIconsLight.warningOctagon,
                  title: context.l10n.notForEmergenciesTitle,
                  body: context.l10n.notForEmergenciesDesc,
                ),
                _disclaimerItem(
                  icon: PhosphorIconsLight.cpu,
                  title: context.l10n.onDeviceAiNoReviewTitle,
                  body: context.l10n.onDeviceAiNoReviewDesc,
                ),
                _disclaimerItem(
                  icon: PhosphorIconsLight.user,
                  title: context.l10n.youAreResponsibleTitle,
                  body: context.l10n.youAreResponsibleDesc,
                ),
                _disclaimerItem(
                  icon: PhosphorIconsLight.shieldCheck,
                  title: context.l10n.dataStaysOnDeviceTitle,
                  body: context.l10n.dataStaysOnDeviceDesc,
                ),

                const SizedBox(height: 24),

                // Checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      label: context.l10n.acceptMedicalDisclaimer,
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
                    Expanded(
                      child: Text(
                        context.l10n.understandAcceptCheckbox,
                        style: const TextStyle(fontSize: DesignTokens.fontSm2, height: 1.5),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Accept button
                Semantics(
                  label: _accepted
                      ? context.l10n.acceptMedicalDisclaimer
                      : context.l10n.checkToAccept,
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
                      child: Text(
                        context.l10n.iUnderstandContinue,
                        style: const TextStyle(fontSize: DesignTokens.fontLg, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Decline
                Center(
                  child: Semantics(
                    label: context.l10n.declineDisclaimer,
                    button: true,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        context.l10n.goBack,
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
