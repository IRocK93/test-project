/**
 * Stable API keys for health record values stored in the backend.
 *
 * These constants mirror the mobile app's HealthValueKeys so that both
 * sides agree on the canonical values. Using API keys instead of localized
 * display strings ensures data consistency across language switches.
 */

// ── Injury Severity ──
export const INJURY_SEVERITY_KEYS = new Set([
  'mild',
  'moderate',
  'severe',
  'critical',
]);

// ── Bowel Color ──
export const BOWEL_COLOR_KEYS = new Set([
  'brown',
  'green',
  'yellow',
  'red',
  'black',
  'whiteClay',
  'orange',
]);

// ── Stool Type / Consistency ──
export const STOOL_TYPE_KEYS = new Set([
  'watery',
  'loose',
  'mushy',
  'softFormed',
  'normal',
  'firm',
  'hardPellets',
  'constipated',
]);

// ── Vaccine Names ──
export const VACCINE_KEYS = new Set([
  'hepB',
  'rotavirus',
  'dtap',
  'hib',
  'pcv13',
  'ipv',
  'flu',
  'mmr',
  'varicella',
  'hepA',
  'menACWY',
  'covid',
  'hpv',
  'tdap',
  'rsv',
]);

// ── Allergy Names ──
export const ALLERGY_NAME_KEYS = new Set([
  'peanuts',
  'treeNuts',
  'milkDairy',
  'eggs',
  'soy',
  'wheat',
  'fish',
  'shellfish',
  'sesame',
  'pollen',
  'dustMites',
  'mold',
  'petDander',
  'insectStings',
  'latex',
  'penicillin',
  'nsaids',
  'sulfaDrugs',
]);

// ── Allergy Severity ──
export const ALLERGY_SEVERITY_KEYS = new Set([
  'mild',
  'moderate',
  'severe',
  'lifeThreatening',
]);

/**
 * Validates a HealthRecord.value based on its category and unit.
 * Throws BadRequestException if the value is not a known API key
 * for the given category context.
 *
 * @param category HealthCategory enum value
 * @param value The stored value (optional)
 * @param unit The stored unit (optional)
 */
export function validateHealthRecordValue(
  category: string,
  value?: string,
  unit?: string,
): void {
  if (!value) return;

  const trimmed = value.trim();
  if (trimmed.length === 0) return;

  if (category === 'INJURY') {
    if (!INJURY_SEVERITY_KEYS.has(trimmed)) {
      throw new Error(
        `Invalid injury severity key "${trimmed}". Must be one of: ${Array.from(INJURY_SEVERITY_KEYS).join(', ')}`,
      );
    }
    return;
  }

  if (category === 'BOWEL_MOVEMENT') {
    if (!BOWEL_COLOR_KEYS.has(trimmed)) {
      throw new Error(
        `Invalid bowel color key "${trimmed}". Must be one of: ${Array.from(BOWEL_COLOR_KEYS).join(', ')}`,
      );
    }
    return;
  }

  if (category === 'VACCINATION') {
    // Known vaccine keys are valid; custom vaccine names (e.g. "other" or free text) are also allowed
    if (trimmed === 'other' || VACCINE_KEYS.has(trimmed)) {
      return;
    }
    // Any non-empty string is accepted as a custom vaccine name
    return;
  }

  if (category === 'BOWEL_MOVEMENT' && unit === 'consistency') {
    if (!STOOL_TYPE_KEYS.has(trimmed)) {
      throw new Error(
        `Invalid stool type key "${trimmed}". Must be one of: ${Array.from(STOOL_TYPE_KEYS).join(', ')}`,
      );
    }
    return;
  }

  // All other categories (WEIGHT, HEIGHT, TEMPERATURE, VISIT, etc.) accept free-form values
}

/**
 * Validates an Allergy.severity value.
 * Throws BadRequestException if the value is not a known severity key.
 */
export function validateAllergySeverity(value?: string): void {
  if (!value) return;
  const trimmed = value.trim();
  if (trimmed.length === 0) return;
  if (!ALLERGY_SEVERITY_KEYS.has(trimmed)) {
    throw new Error(
      `Invalid allergy severity key "${trimmed}". Must be one of: ${Array.from(ALLERGY_SEVERITY_KEYS).join(', ')}`,
    );
  }
}
