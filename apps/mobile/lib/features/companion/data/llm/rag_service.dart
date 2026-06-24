import 'dart:math' show log;

import 'package:baby_mon/features/companion/data/companion_repository.dart';

/// Retrieval-Augmented Generation service with TF-IDF semantic scoring.
///
/// Replaces the original naive keyword-match approach with proper term
/// weighting so that query relevance reflects how *distinctive* each
/// matched term is across the advice corpus, not just how many times it
/// appears.
class RagService {
  static const String _keyItems = 'items';
  static const String _keyTitle = 'title';
  static const String _keySummary = 'summary';
  static const int _maxCards = 3;
  static const double _minScore = 0.05;
  static const int _minWordLength = 2;

  final CompanionRepository _repository;

  RagService(this._repository);

  /// Retrieve the top [_maxCards] advice cards most relevant to [query]
  /// using TF-IDF scoring against the card corpus.
  Future<String> retrieveContext(String babyMonId, String query) async {
    final response = await _repository.getAdvice(babyMonId);
    final cards = _extractCards(response);
    if (cards.isEmpty) return '';

    final queryWords = _tokenize(query);
    if (queryWords.isEmpty) return _formatCards(cards.take(_maxCards).toList());

    // ── Index: token → { cardIndex → term frequency } ────────────
    final Map<String, Map<int, double>> index = {};
    final List<Map<String, double>> docTf = []; // per-document TF map

    for (int i = 0; i < cards.length; i++) {
      final text = _cardText(cards[i]);
      final tokens = _tokenize(text);
      final tf = _computeTf(tokens);
      docTf.add(tf);
      for (final term in tf.keys) {
        index.putIfAbsent(term, () => {});
        index[term]![i] = tf[term]!;
      }
    }

    final int nDocs = cards.length;

    // ── Score each card: sum of TF·IDF for each query term ─────────
    final List<_ScoredCard> scored = [];
    for (int i = 0; i < nDocs; i++) {
      double score = 0.0;
      for (final word in queryWords) {
        final postings = index[word];
        if (postings == null || !postings.containsKey(i)) continue;
        final double tf = postings[i]!;
        final double idf = _idf(nDocs, postings.length);
        score += tf * idf;
      }
      if (score > _minScore) scored.add(_ScoredCard(card: cards[i], score: score));
    }

    scored.sort((_ScoredCard a, _ScoredCard b) => b.score.compareTo(a.score));
    return _formatCards(scored.take(_maxCards).map((_ScoredCard s) => s.card).toList());
  }

  /// Convenience: format an entire advice response without a query.
  String formatContext(Map<String, dynamic> adviceResponse) =>
      _formatCards(_extractCards(adviceResponse));

  // ── Helpers ──────────────────────────────────────────────────────

  List<Map<String, dynamic>> _extractCards(Map<String, dynamic> response) {
    final items = response[_keyItems];
    return items is List ? items.cast<Map<String, dynamic>>() : <Map<String, dynamic>>[];
  }

  /// Concatenate title + summary for full-text indexing.
  String _cardText(Map<String, dynamic> card) {
    final title = (card[_keyTitle] as String? ?? '').toLowerCase();
    final summary = (card[_keySummary] as String? ?? '').toLowerCase();
    return '$title $summary';
  }

  /// Split text into lower-case tokens, filtering out short words.
  /// Returns a List (not Set) so term frequency actually varies.
  List<String> _tokenize(String text) => text
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9]+'))
      .where((String w) => w.length >= _minWordLength)
      .toList();

  /// Normalised term frequency: raw count / max count in document.
  Map<String, double> _computeTf(List<String> tokens) {
    final Map<String, int> raw = {};
    for (final t in tokens) {
      raw[t] = (raw[t] ?? 0) + 1;
    }
    final int maxFreq = raw.values.fold(0, (int a, int b) => a > b ? a : b);
    if (maxFreq == 0) return {};
    final Map<String, double> tf = {};
    for (final entry in raw.entries) {
      tf[entry.key] = 0.5 + 0.5 * (entry.value / maxFreq);
    }
    return tf;
  }

  /// Inverse document frequency: log(N / df).  Special-case df == 0
  /// (shouldn't happen) with a high IDF value.
  double _idf(int nDocs, int docFreq) {
    if (docFreq <= 0) return log((nDocs + 1).toDouble());
    return log((nDocs + 1) / docFreq);
  }

  String _formatCards(List<Map<String, dynamic>> cards) {
    if (cards.isEmpty) return '';
    final buffer = StringBuffer();
    for (int i = 0; i < cards.length; i++) {
      final card = cards[i];
      buffer.writeln('---');
      buffer.writeln('Title: ${card[_keyTitle] ?? ''}');
      buffer.writeln('Summary: ${card[_keySummary] ?? ''}');
    }
    return buffer.toString().trim();
  }
}

class _ScoredCard {
  final Map<String, dynamic> card;
  final double score;
  const _ScoredCard({required this.card, required this.score});
}
