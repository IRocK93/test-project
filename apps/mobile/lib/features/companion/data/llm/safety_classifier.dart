/// Safety classifier for AI-generated companion responses.
///
/// Runs rule-based checks on model output before display to the user.
/// Detects: medical emergencies, medication dosage suggestions, anti-vaccine content.
/// Each flagged category produces a warning that is shown alongside the AI response.
class SafetyClassifier {
  static const _emergencyPatterns = [
    'seizure',
    'not breathing',
    'blue',
    'unresponsive',
    'passed out',
    'swallowed poison',
    'anaphylaxis',
    'difficulty breathing',
    'turning blue',
    'stopped breathing',
  ];

  static const _dangerousDrugPatterns = [
    'aspirin for',
    'give them ibuprofen',
    'give them acetaminophen',
    'dose of tylenol',
    'dose of motrin',
  ];

  static const _antiVaccinePatterns = [
    'vaccines cause',
    'vaccine injury',
    'vaccines are dangerous',
    'no vaccines',
    'anti-vax',
    'anti vax',
  ];

  /// Check a response for safety concerns.
  /// Returns a [SafetyResult] indicating whether the response was flagged
  /// and what warning should be shown to the user.
  static SafetyResult check(String response) {
    final lower = response.toLowerCase();

    for (final pattern in _emergencyPatterns) {
      if (lower.contains(pattern)) {
        return const SafetyResult(
          flagged: true,
          category: SafetyCategory.emergency,
          warning:
              'If this is a medical emergency, stop using this app '
              'and call 911 or your local emergency number immediately.',
        );
      }
    }

    for (final pattern in _dangerousDrugPatterns) {
      if (lower.contains(pattern)) {
        return const SafetyResult(
          flagged: true,
          category: SafetyCategory.medication,
          warning:
              'The AI cannot provide medication dosage advice. '
              'Always consult your pediatrician before giving any medication.',
        );
      }
    }

    for (final pattern in _antiVaccinePatterns) {
      if (lower.contains(pattern)) {
        return const SafetyResult(
          flagged: true,
          category: SafetyCategory.antiVaccine,
          warning:
              'Content about vaccine safety may not be accurate. '
              'Vaccines are safe and effective. Consult your pediatrician.',
        );
      }
    }

    return const SafetyResult(flagged: false, category: SafetyCategory.safe, warning: null);
  }
}

enum SafetyCategory {
  safe,
  emergency,
  medication,
  antiVaccine,
}

class SafetyResult {
  final bool flagged;
  final SafetyCategory category;
  final String? warning;

  const SafetyResult({
    required this.flagged,
    required this.category,
    this.warning,
  });
}
