/// Stable API keys for health record values that are stored in the backend.
///
/// Using these keys instead of localized display strings ensures that data
/// remains consistent when users switch languages. The UI localizes these
/// keys at display time via `context.l10n`.
///
/// All keys use camelCase and are guaranteed to be stable — never rename
/// without a migration strategy.
library;

// ── Injury Severity ──
class InjurySeverityKey {
  static const mild = 'mild';
  static const moderate = 'moderate';
  static const severe = 'severe';
  static const critical = 'critical';

  static const Set<String> all = {mild, moderate, severe, critical};
}

// ── Bowel Color ──
class BowelColorKey {
  static const brown = 'brown';
  static const green = 'green';
  static const yellow = 'yellow';
  static const red = 'red';
  static const black = 'black';
  static const whiteClay = 'whiteClay';
  static const orange = 'orange';

  static const Set<String> all = {brown, green, yellow, red, black, whiteClay, orange};
}

// ── Stool Type / Consistency ──
class StoolTypeKey {
  static const watery = 'watery';
  static const loose = 'loose';
  static const mushy = 'mushy';
  static const softFormed = 'softFormed';
  static const normal = 'normal';
  static const firm = 'firm';
  static const hardPellets = 'hardPellets';
  static const constipated = 'constipated';

  static const Set<String> all = {watery, loose, mushy, softFormed, normal, firm, hardPellets, constipated};
}

// ── Vaccine Names ──
class VaccineKey {
  static const other = 'other';
  static const hepB = 'hepB';
  static const rotavirus = 'rotavirus';
  static const dtap = 'dtap';
  static const hib = 'hib';
  static const pcv13 = 'pcv13';
  static const ipv = 'ipv';
  static const flu = 'flu';
  static const mmr = 'mmr';
  static const varicella = 'varicella';
  static const hepA = 'hepA';
  static const menACWY = 'menACWY';
  static const covid = 'covid';
  static const hpv = 'hpv';
  static const tdap = 'tdap';
  static const rsv = 'rsv';

  static const Set<String> all = {
    other, hepB, rotavirus, dtap, hib, pcv13, ipv,
    flu, mmr, varicella, hepA, menACWY, covid, hpv, tdap, rsv,
  };
}

// ── Allergy Names ──
class AllergyNameKey {
  static const other = 'other';
  static const peanuts = 'peanuts';
  static const treeNuts = 'treeNuts';
  static const milkDairy = 'milkDairy';
  static const eggs = 'eggs';
  static const soy = 'soy';
  static const wheat = 'wheat';
  static const fish = 'fish';
  static const shellfish = 'shellfish';
  static const sesame = 'sesame';
  static const pollen = 'pollen';
  static const dustMites = 'dustMites';
  static const mold = 'mold';
  static const petDander = 'petDander';
  static const insectStings = 'insectStings';
  static const latex = 'latex';
  static const penicillin = 'penicillin';
  static const nsaids = 'nsaids';
  static const sulfaDrugs = 'sulfaDrugs';

  static const Set<String> all = {
    other, peanuts, treeNuts, milkDairy, eggs, soy, wheat,
    fish, shellfish, sesame, pollen, dustMites, mold, petDander,
    insectStings, latex, penicillin, nsaids, sulfaDrugs,
  };
}

// ── Allergy Severity ──
class AllergySeverityKey {
  static const mild = 'mild';
  static const moderate = 'moderate';
  static const severe = 'severe';
  static const lifeThreatening = 'lifeThreatening';

  static const Set<String> all = {mild, moderate, severe, lifeThreatening};
}

/// Localizes health value API keys using the app's ARB translations.
///
/// Used at display time to convert stable backend keys into human-readable
/// strings for the current locale.
class HealthValueLocalizer {
  final dynamic l10n;
  HealthValueLocalizer(this.l10n);

  String localizeInjurySeverity(String key) {
    switch (key) {
      case InjurySeverityKey.mild: return l10n.severityMild;
      case InjurySeverityKey.moderate: return l10n.severityModerate;
      case InjurySeverityKey.severe: return l10n.severitySevere;
      case InjurySeverityKey.critical: return l10n.severityCritical;
      default: return key;
    }
  }

  String localizeBowelColor(String key) {
    switch (key) {
      case BowelColorKey.brown: return l10n.colorBrown;
      case BowelColorKey.green: return l10n.colorGreen;
      case BowelColorKey.yellow: return l10n.colorYellow;
      case BowelColorKey.red: return l10n.colorRed;
      case BowelColorKey.black: return l10n.colorBlack;
      case BowelColorKey.whiteClay: return l10n.colorWhiteClay;
      case BowelColorKey.orange: return l10n.colorOrange;
      default: return key;
    }
  }

  String localizeStoolType(String key) {
    switch (key) {
      case StoolTypeKey.watery: return l10n.stoolTypeWatery;
      case StoolTypeKey.loose: return l10n.stoolTypeLoose;
      case StoolTypeKey.mushy: return l10n.stoolTypeMushy;
      case StoolTypeKey.softFormed: return l10n.stoolTypeSoftFormed;
      case StoolTypeKey.normal: return l10n.stoolTypeNormal;
      case StoolTypeKey.firm: return l10n.stoolTypeFirm;
      case StoolTypeKey.hardPellets: return l10n.stoolTypeHardPellets;
      case StoolTypeKey.constipated: return l10n.stoolTypeConstipated;
      default: return key;
    }
  }

  String localizeVaccine(String key) {
    switch (key) {
      case VaccineKey.other: return l10n.vaccineOther;
      case VaccineKey.hepB: return l10n.vaccineHepB;
      case VaccineKey.rotavirus: return l10n.vaccineRotavirus;
      case VaccineKey.dtap: return l10n.vaccineDTaP;
      case VaccineKey.hib: return l10n.vaccineHib;
      case VaccineKey.pcv13: return l10n.vaccinePCV13;
      case VaccineKey.ipv: return l10n.vaccineIPV;
      case VaccineKey.flu: return l10n.vaccineFlu;
      case VaccineKey.mmr: return l10n.vaccineMMR;
      case VaccineKey.varicella: return l10n.vaccineVaricella;
      case VaccineKey.hepA: return l10n.vaccineHepA;
      case VaccineKey.menACWY: return l10n.vaccineMenACWY;
      case VaccineKey.covid: return l10n.vaccineCOVID;
      case VaccineKey.hpv: return l10n.vaccineHPV;
      case VaccineKey.tdap: return l10n.vaccineTdap;
      case VaccineKey.rsv: return l10n.vaccineRSV;
      default: return key;
    }
  }

  String localizeAllergyName(String key) {
    switch (key) {
      case AllergyNameKey.other: return l10n.allergyOtherOption;
      case AllergyNameKey.peanuts: return l10n.allergyPeanutsOption;
      case AllergyNameKey.treeNuts: return l10n.allergyTreeNutsOption;
      case AllergyNameKey.milkDairy: return l10n.allergyMilkDairyOption;
      case AllergyNameKey.eggs: return l10n.allergyEggsOption;
      case AllergyNameKey.soy: return l10n.allergySoyOption;
      case AllergyNameKey.wheat: return l10n.allergyWheatOption;
      case AllergyNameKey.fish: return l10n.allergyFishOption;
      case AllergyNameKey.shellfish: return l10n.allergyShellfishOption;
      case AllergyNameKey.sesame: return l10n.allergySesameOption;
      case AllergyNameKey.pollen: return l10n.allergyPollenOption;
      case AllergyNameKey.dustMites: return l10n.allergyDustMitesOption;
      case AllergyNameKey.mold: return l10n.allergyMoldOption;
      case AllergyNameKey.petDander: return l10n.allergyPetDanderOption;
      case AllergyNameKey.insectStings: return l10n.allergyInsectStingsOption;
      case AllergyNameKey.latex: return l10n.allergyLatexOption;
      case AllergyNameKey.penicillin: return l10n.allergyPenicillinOption;
      case AllergyNameKey.nsaids: return l10n.allergyNSAIDsOption;
      case AllergyNameKey.sulfaDrugs: return l10n.allergySulfaDrugsOption;
      default: return key;
    }
  }

  String localizeAllergySeverity(String key) {
    switch (key) {
      case AllergySeverityKey.mild: return l10n.allergySeverityMild;
      case AllergySeverityKey.moderate: return l10n.allergySeverityModerate;
      case AllergySeverityKey.severe: return l10n.allergySeveritySevere;
      case AllergySeverityKey.lifeThreatening: return l10n.allergySeverityLifeThreatening;
      default: return key;
    }
  }
}
