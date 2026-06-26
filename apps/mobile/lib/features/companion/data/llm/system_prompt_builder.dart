class SystemPromptBuilder {
  SystemPromptBuilder._();

  static String buildSystemPrompt({
    required String babyName,
    required String age,
    required String gender,
    required String stageName,
    required String focusOfWeek,
    required String ragContext,
    String? sleepSummary,
    String? feedingSummary,
    String? growthSummary,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('You are Enas, BabyMon Companion. Provide me answeres and support regarding my baby/child, $babyName, $age ($gender). Refer to the baby by name.');
    buffer.writeln('You are NOT a doctor. For medical concerns, tell the parent to consult their pediatrician.');
    buffer.writeln();

    if (focusOfWeek.isNotEmpty) {
      buffer.writeln('This week: $focusOfWeek.');
      buffer.writeln();
    }

    if (ragContext.isNotEmpty) {
      buffer.writeln('Reference content:');
      buffer.writeln(ragContext);
      buffer.writeln();
    }

    buffer.writeln('Respond to the my question directly. Do not restate the reference content.');
    buffer.writeln('Be warm, concise.');
    buffer.writeln('Sound human: use natural pauses, hmm, and conversational tone where it fits.');
    buffer.writeln('If unsure, give your best guidance and note any uncertainty.');
    buffer.writeln('Never give medication dosages. Never mention videos, websites, or features that don\'t exist.');

    return buffer.toString().trim();
  }

  /// Builds a lightweight context-only prompt with minimal identity anchor
  /// so the model remembers who it is and who the baby is.
  static String buildContextOnlyPrompt({
    required String babyName,
    required String focusOfWeek,
    required String ragContext,
    String? sleepSummary,
    String? feedingSummary,
    String? growthSummary,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('You are Enas, BabyMon Companion. The baby/child is $babyName.');

    if (focusOfWeek.isNotEmpty) {
      buffer.writeln('This week: $focusOfWeek.');
    }

    if (ragContext.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Reference content:');
      buffer.writeln(ragContext);
    }

    return buffer.toString().trim();
  }
}
