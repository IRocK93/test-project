/// Canonical trait system — single source of truth for baby-mon traits.
///
/// Traits are stored as English canonical keys in the database. Display
/// strings are derived from [AppLocalizations] at render time.
///
/// The reverse map [kTraitLocaleToEnglish] handles legacy data that was
/// stored in localized form (e.g. Arabic 'فضولي' instead of 'Curious').
/// It covers all 9 supported locales. When a user edits a BabyMon with
/// legacy traits, they are automatically normalized to English keys on save.
library;

/// Canonical English trait keys — stored in DB, used as map keys everywhere.
const kTraitKeys = <String>[
  'Curious',
  'Peaceful',
  'Playful',
  'Gentle',
  'Adventurous',
  'Creative',
];

/// Reverse map: any locale's trait display string → English canonical key.
///
/// Derived from l10n trait getters across all 9 supported locales. Shared
/// translations (e.g. "Curioso" in both Spanish & Italian) appear once.
///
/// Must stay in sync with:
///   app_localizations_ar.dart, _de, _en, _es, _fr, _he, _it, _pt, _zh
const kTraitLocaleToEnglish = <String, String>{
  // ── Arabic (ar) ──
  'فضولي': 'Curious',
  'مسالم': 'Peaceful',
  'مرح': 'Playful',
  'لطيف': 'Gentle',
  'مغامر': 'Adventurous',
  'مبدع': 'Creative',
  // ── German (de) ──
  'Neugierig': 'Curious',
  'Friedlich': 'Peaceful',
  'Verspielt': 'Playful',
  'Sanft': 'Gentle',
  'Abenteuerlich': 'Adventurous',
  'Kreativ': 'Creative',
  // ── English (en) — identity passthrough ──
  'Curious': 'Curious',
  'Peaceful': 'Peaceful',
  'Playful': 'Playful',
  'Gentle': 'Gentle',
  'Adventurous': 'Adventurous',
  'Creative': 'Creative',
  // ── Spanish (es) / Italian (it) / Portuguese (pt) ──
  // Shared forms are listed once; each maps to the same English key.
  'Curioso': 'Curious', // es, it
  'Pacífico': 'Peaceful', // es, pt
  'Juguetón': 'Playful', // es
  'Gentil': 'Gentle', // es, pt
  'Aventurero': 'Adventurous', // es
  'Creativo': 'Creative', // es, it
  // ── French (fr) ──
  'Curieux': 'Curious',
  'Paisible': 'Peaceful',
  'Joueur': 'Playful',
  'Doux': 'Gentle',
  'Aventureux': 'Adventurous',
  'Créatif': 'Creative',
  // ── Hebrew (he) ──
  'סקרן': 'Curious',
  'שליו': 'Peaceful',
  'שובב': 'Playful',
  'עדין': 'Gentle',
  'הרפתקן': 'Adventurous',
  'יצירתי': 'Creative',
  // ── Italian (it) — forms distinct from Spanish ──
  'Pacifico': 'Peaceful',
  'Giocherellone': 'Playful',
  'Gentile': 'Gentle',
  'Avventuroso': 'Adventurous',
  // ── Portuguese (pt) — forms distinct from Spanish ──
  'Aventureiro': 'Adventurous',
  'Criativo': 'Creative',
  'Brincalhão': 'Playful',
  // ── Chinese (zh) ──
  '好奇': 'Curious',
  '平和': 'Peaceful',
  '爱玩': 'Playful',
  '温柔': 'Gentle',
  '爱冒险': 'Adventurous',
  '有创意': 'Creative',
};

/// Normalize any stored trait value to its English canonical key.
///
/// Legacy data persisted in a localized form (Arabic, German, etc.) is
/// resolved via [kTraitLocaleToEnglish]. Unknown values (custom traits)
/// pass through unchanged.
String normalizeTrait(String value) => kTraitLocaleToEnglish[value] ?? value;

/// Map an English canonical trait key to its localized display string.
///
/// Falls back to [key] for custom traits (keys not in [kTraitKeys]).
String traitDisplay(String key, dynamic l10n) {
  final idx = kTraitKeys.indexOf(key);
  if (idx < 0) return key;
  return switch (idx) {
    0 => l10n.traitCurious as String,
    1 => l10n.traitPeaceful as String,
    2 => l10n.traitPlayful as String,
    3 => l10n.traitGentle as String,
    4 => l10n.traitAdventurous as String,
    5 => l10n.traitCreative as String,
    _ => key,
  };
}

/// Map an English canonical trait key to its localized flavor text.
///
/// Returns an empty string for custom traits or null keys.
String traitFlavorText(String? key, dynamic l10n) {
  if (key == null) return '';
  final idx = kTraitKeys.indexOf(key);
  if (idx < 0) return '';
  return switch (idx) {
    0 => l10n.traitFlavorCurious as String,
    1 => l10n.traitFlavorPeaceful as String,
    2 => l10n.traitFlavorPlayful as String,
    3 => l10n.traitFlavorGentle as String,
    4 => l10n.traitFlavorAdventurous as String,
    5 => l10n.traitFlavorCreative as String,
    _ => '',
  };
}
