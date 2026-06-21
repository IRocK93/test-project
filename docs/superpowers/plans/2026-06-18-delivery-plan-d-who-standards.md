# Delivery Plan D: Data Accuracy — WHO Standards Fix

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Fix head circumference percentile calculation (currently uses weight standards), correct WHO weight-for-age data, and implement proper LMS-based percentile calculation.

**Architecture:** Add head circumference standards to WHO_STANDARDS object. Replace ratio-based percentile approximation with Lambda-Mu-Sigma method using published WHO LMS parameters. Add prominent "not for clinical use" disclaimer until LMS method is fully validated.

**Tech Stack:** TypeScript, NestJS

**Related Reports:** S08 (DM-C01, DM-M04), S17 (DMN-C01, DMN-C02, DMN-H02)

---

### Task D-1: Fix head circumference — add WHO standards data

**Files:**
- Modify: `apps/api/src/growth/growth.service.ts`

- [ ] **Step 1: Add head circumference percentile data**

In the `WHO_STANDARDS` object, add `headCircumference` to both male and female:

```typescript
const WHO_STANDARDS = {
  male: {
    weight: { /* existing data */ },
    height: { /* existing data */ },
    headCircumference: {
      0: 34.5,   // Birth
      1: 37.3,   // 1 month
      2: 39.1,   // 2 months
      3: 40.5,   // 3 months
      4: 41.6,   // 4 months
      5: 42.6,   // 5 months
      6: 43.3,   // 6 months
      7: 44.0,   // 7 months
      8: 44.5,   // 8 months
      9: 45.0,   // 9 months
      10: 45.4,  // 10 months
      11: 45.8,  // 11 months
      12: 46.1,  // 12 months
      15: 46.8,  // 15 months
      18: 47.4,  // 18 months
      21: 47.8,  // 21 months
      24: 48.2,  // 24 months
    },
  },
  female: {
    weight: { /* existing data */ },
    height: { /* existing data */ },
    headCircumference: {
      0: 33.9,   // Birth
      1: 36.5,   // 1 month
      2: 38.3,   // 2 months
      3: 39.5,   // 3 months
      4: 40.6,   // 4 months
      5: 41.5,   // 5 months
      6: 42.2,   // 6 months
      7: 42.8,   // 7 months
      8: 43.4,   // 8 months
      9: 43.8,   // 9 months
      10: 44.2,  // 10 months
      11: 44.6,  // 11 months
      12: 44.9,  // 12 months
      15: 45.6,  // 15 months
      18: 46.2,  // 18 months
      21: 46.7,  // 21 months
      24: 47.1,  // 24 months
    },
  },
};
```

- [ ] **Step 2: Fix the type resolution in getGrowthAnalysis**

Find the line that maps `type` to standards:
```typescript
// OLD (broken for headCircumference):
const standards = type === 'HEIGHT' 
  ? WHO_STANDARDS[gender].height 
  : WHO_STANDARDS[gender].weight;

// NEW:
const typeKey = type === 'HEIGHT' ? 'height' 
  : type === 'WEIGHT' ? 'weight' 
  : type === 'HEAD_CIRCUMFERENCE' ? 'headCircumference' 
  : null;

if (!typeKey || !WHO_STANDARDS[gender]?.[typeKey]) {
  throw new BadRequestException(`Standards not available for type: ${type}`);
}

const standards = WHO_STANDARDS[gender][typeKey];
```

- [ ] **Step 3: Fix getPercentileData similarly**

Apply the same mapping fix to `getPercentileData()`.

- [ ] **Step 4: Commit**

```bash
git add apps/api/src/growth/growth.service.ts
git commit -m "fix(growth): add head circumference WHO standards and fix type mapping

Previously HEAD_CIRCUMFERENCE fell through to weight standards,
producing completely wrong percentiles. Now has dedicated HC data
and throws clear error if standards not available."
```

---

### Task D-2: Fix WHO weight data — replace with published values

**Files:**
- Modify: `apps/api/src/growth/growth.service.ts`

- [ ] **Step 1: Replace weight-for-age data with published WHO 2006 values**

Replace the existing weight data for both male and female with these corrected values (WHO 50th percentile, weight-for-age in kg):

```typescript
// Male weight (kg) — WHO 2006, 50th percentile
weight: {
  0: 3.35, 1: 4.47, 2: 5.57, 3: 6.38, 4: 7.00, 5: 7.51,
  6: 7.93, 7: 8.30, 8: 8.62, 9: 8.90, 10: 9.16, 11: 9.41,
  12: 9.65, 15: 10.52, 18: 11.32, 21: 12.09, 24: 12.85,
},

// Female weight (kg) — WHO 2006, 50th percentile
weight: {
  0: 3.23, 1: 4.19, 2: 5.13, 3: 5.85, 4: 6.42, 5: 6.90,
  6: 7.29, 7: 7.62, 8: 7.93, 9: 8.20, 10: 8.46, 11: 8.72,
  12: 8.95, 15: 9.82, 18: 10.63, 21: 11.40, 24: 12.14,
},
```

- [ ] **Step 2: Add comment citing source**

```typescript
// Source: WHO Child Growth Standards (2006)
// 50th percentile (P50 / median) values
// https://www.who.int/tools/child-growth-standards
```

- [ ] **Step 3: Commit**

```bash
git add apps/api/src/growth/growth.service.ts
git commit -m "fix(growth): replace weight data with published WHO 2006 values

Previous weight data deviated up to 2kg from WHO standards by 24 months.
Replaced with published 50th percentile values for both sexes."
```

---

### Task D-3: Add clinical disclaimer

**Files:**
- Modify: `apps/api/src/growth/growth.service.ts`

- [ ] **Step 1: Add disclaimer comment at the top of percentile methods**

```typescript
/**
 * ⚠️ IMPORTANT: This percentile calculation uses the Lambda-Mu-Sigma (LMS)
 * method based on WHO 2006 Child Growth Standards.
 * 
 * Results are APPROXIMATE and should NOT be used for clinical diagnosis.
 * Always consult a pediatrician for growth assessment.
 * 
 * Source: WHO Child Growth Standards, 2006
 * Reference: https://www.who.int/tools/child-growth-standards
 */
```

- [ ] **Step 2: If LMS is not yet implemented, use a stronger disclaimer**

Until LMS is properly implemented, add:
```typescript
/**
 * NOTE: Simplified percentile approximation.
 * For accurate percentiles, clinical software using the full WHO LMS
 * parameters is required. These values are estimates only.
 */
```

- [ ] **Step 3: Commit**

```bash
git commit -m "docs(growth): add clinical disclaimer to percentile calculations"
```

---

## Optional Enhancement: LMS Implementation

If time permits, replace the ratio-based approximation with proper LMS:

```typescript
interface LMSParams {
  L: number;  // Power transformation (skewness)
  M: number;  // Median
  S: number;  // Coefficient of variation
}

const WHO_LMS_PARAMS: Record<string, Record<number, LMSParams>> = {
  // Example: Male weight-for-age, birth
  male_weight: {
    0: { L: 0.3809, M: 3.3464, S: 0.14602 },
    // ... additional ages
  },
  // Add for all measurement types
};

function calculateZScore(value: number, params: LMSParams): number {
  const { L, M, S } = params;
  if (L === 0) {
    return Math.log(value / M) / S;
  }
  return (Math.pow(value / M, L) - 1) / (L * S);
}

function zScoreToPercentile(z: number): number {
  // Normal distribution CDF
  return 0.5 * (1 + erf(z / Math.sqrt(2)));
}
```

---

**Estimated time:** 1-2 days (basic fix) or 3-5 days (with LMS implementation).
