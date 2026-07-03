#!/bin/bash
# check_textdirection.sh
#
# CI / local check: prevents hardcoded TextDirection.ltr / TextDirection.rtl
# in production Dart code. Comparisons like `== TextDirection.rtl` are allowed
# because they are legitimate directional logic.
#
# Usage:
#   bash scripts/check_textdirection.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/../lib"

echo "Checking for hardcoded TextDirection values in production code..."

# Find lines containing TextDirection.ltr or TextDirection.rtl.
# Exclude:
#   - lines with == TextDirection   (comparisons are OK)
#   - test files under lib/         (shouldn't exist, but defensive)
violations=$(grep -r -n --include="*.dart" -E "TextDirection\.(ltr|rtl)" "$LIB_DIR" \
  | grep -v "== TextDirection" \
  | grep -v "/test/" \
  || true)

if [ -n "$violations" ]; then
  echo ""
  echo "❌ ERROR: Hardcoded TextDirection values found in production code:"
  echo "$violations"
  echo ""
  echo "Use Directionality.of(context) instead of hardcoding TextDirection.ltr/rtl."
  exit 1
fi

echo "✅ No hardcoded TextDirection values found."
