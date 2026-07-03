import { ValidationError } from 'class-validator';

/**
 * Maps a class-validator constraint name to a machine-readable error code.
 *
 * These codes are returned in the `details` array of validation error
 * responses so the mobile app can show per-field localized messages.
 */
function mapConstraintName(constraint: string): string {
  return (
    {
      isEmail: 'INVALID_EMAIL',
      isNotEmpty: 'REQUIRED',
      minLength: 'MIN_LENGTH',
      maxLength: 'MAX_LENGTH',
      matches: 'INVALID_FORMAT',
      isString: 'INVALID_TYPE',
      isNumber: 'INVALID_TYPE',
      isInt: 'INVALID_TYPE',
      isBoolean: 'INVALID_TYPE',
      isArray: 'INVALID_TYPE',
      isDateString: 'INVALID_DATE',
      isEnum: 'INVALID_VALUE',
      isOptional: 'INVALID_VALUE',
      isUUID: 'INVALID_FORMAT',
      validateNested: 'INVALID_FORMAT',
      whitelistValidation: 'UNEXPECTED_FIELD',
    } as Record<string, string>
  )[constraint] ?? 'INVALID_VALUE';
}

/**
 * Lower numbers = higher priority (more specific).
 * Ensures that `isEmail` is preferred over `isString`, etc.
 */
const _constraintPriority: Record<string, number> = {
  isNotEmpty: 0, // Most specific: field is missing
  isEmail: 1,
  matches: 1,
  isEnum: 1,
  isUUID: 1,
  minLength: 2,
  maxLength: 2,
  isDateString: 2,
  validateNested: 2,
  whitelistValidation: 2,
  isString: 3,
  isNumber: 3,
  isInt: 3,
  isBoolean: 3,
  isArray: 3,
  isOptional: 3,
};

/**
 * Transforms class-validator ValidationError[] into a structured array of
 * field-level error codes suitable for API responses.
 *
 * @returns Array of { field, code } objects. If a field has multiple
 * constraint failures, only the first is returned (most specific).
 */
export function mapValidationErrors(
  errors: ValidationError[],
): Array<{ field: string; code: string }> {
  const result: Array<{ field: string; code: string }> = [];

  for (const error of errors) {
    const constraints = error.constraints;
    if (!constraints || Object.keys(constraints).length === 0) {
      // Handle nested validation errors recursively
      if (error.children && error.children.length > 0) {
        const nested = mapValidationErrors(error.children);
        for (const n of nested) {
          result.push({
            field: `${error.property}.${n.field}`,
            code: n.code,
          });
        }
      }
      continue;
    }

    // Pick the most specific constraint key (e.g. isEmail over isString)
    const sortedConstraints = Object.keys(constraints).sort(
      (a, b) =>
        (_constraintPriority[a] ?? 99) - (_constraintPriority[b] ?? 99),
    );
    const firstConstraint = sortedConstraints[0];
    result.push({
      field: error.property,
      code: mapConstraintName(firstConstraint),
    });
  }

  return result;
}
