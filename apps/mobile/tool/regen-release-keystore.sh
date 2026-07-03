#!/usr/bin/env bash
# apps/mobile/tool/regen-release-keystore.sh
#
# Regenerates the Android release keystore + matching key.properties.
# Both files live in apps/mobile/android/ and are gitignored by default.
#
# CRITICAL: use ONLY before your first Google Play upload. After upload,
# the keystore is locked — regenerating will produce a mismatched new
# keystore that cannot update any existing app.
#
# Pre-requisites:
#   - Java JDK installed (keytool on PATH, or pass --keytool=PATH)
#   - openssl on PATH (for password generation)
#   - git on PATH (to verify the files stay gitignored)
#
# Usage:
#   bash apps/mobile/tool/regen-release-keystore.sh
#   bash apps/mobile/tool/regen-release-keystore.sh --dname="CN=BabyMon Inc., OU=Mobile, O=BabyMon Inc., L=NYC, S=NY, C=US"
#   bash apps/mobile/tool/regen-release-keystore.sh --keytool=/path/to/keytool

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Defaults: Windows-friendly, since founders edit on Windows. Override with --keytool=.
KEYSTORE_DIR="$SCRIPT_DIR/../android"
KEYSTORE_FILE="upload-keystore.jks"
KEY_PROPERTIES="key.properties"
ALIAS="upload"
VALIDITY_DAYS=10000
KEYSIZE=2048
DNAME_DEFAULT='CN=BabyMon, OU=Mobile, O=BabyMon, L=San Francisco, S=California, C=US'
KEYTOOL_DEFAULT='C:/Program Files/Java/jdk-26.0.1/bin/keytool.exe'

# Override parsing
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dname=*)        DNAME="${1#*=}"        ;;
        --keytool=*)      KEYTOOL="${1#*=}"      ;;
        --keystore-dir=*) KEYSTORE_DIR="${1#*=}" ;;
        --help|-h)
            cat <<USAGE
Usage: $0 [--dname="..."] [--keytool=PATH] [--keystore-dir=PATH]

  --dname=DN     Distinguished name for the X.509 cert
                 (note: use --dname= form, NOT space-separated)
  --keytool=PATH Path to keytool binary (default: $KEYTOOL_DEFAULT)
  --keystore-dir=PATH Directory for upload-keystore.jks + key.properties
                 (default: $KEYSTORE_DIR)

Note about your dname: replace defaults if/when you incorporate (e.g.
  --dname='CN=BabyMon Inc., OU=Mobile, O=BabyMon Inc., L=New York, S=NY, C=US').

Both files are gitignored. The script refuses to overwrite either file
without explicit confirmation, so they stay in sync.
USAGE
            exit 0
            ;;
        *) echo "Unknown argument: $1 (try --help)" >&2; exit 1 ;;
    esac
    shift
done

DNAME="${DNAME:-$DNAME_DEFAULT}"
KEYTOOL="${KEYTOOL:-$KEYTOOL_DEFAULT}"

# Sanity: files exist in the project tree
[[ -d "$KEYSTORE_DIR" ]] || { echo "Not a directory: $KEYSTORE_DIR" >&2; exit 1; }

# Pre-flight 1 (cheapest first): keytool must be reachable. We don't try
# `command -v $KEYTOOL` because absolute Windows paths with spaces don't
# resolve via PATH; just probe executability directly.
if [[ ! -x "$KEYTOOL" ]]; then
    echo "FATAL: cannot find keytool at: $KEYTOOL" >&2
    echo "Install a JDK (java.com) or re-run with --keytool=/path/to/keytool" >&2
    exit 3
fi

# Pre-flight 2: secrets must already be gitignored. Doing this BEFORE keytool
# means a misconfigured .gitignore aborts cleanly, with no freshly-generated
# keystore that we have to clean up.
cd "$REPO_ROOT"
if ! git check-ignore "$KEYSTORE_DIR/$KEYSTORE_FILE" "$KEYSTORE_DIR/$KEY_PROPERTIES" >/dev/null 2>&1; then
    echo "FATAL: secrets would NOT be gitignored at:" >&2
    echo "  $KEYSTORE_DIR/$KEYSTORE_FILE" >&2
    echo "  $KEYSTORE_DIR/$KEY_PROPERTIES" >&2
    echo "Add these patterns to your .gitignore and re-run:" >&2
    echo "  apps/mobile/android/key.properties" >&2
    echo "  apps/mobile/android/**.jks"       >&2
    exit 2
fi

echo
echo "target dir:  $KEYSTORE_DIR"
echo "keystore:    $KEYSTORE_FILE"
echo "cred file:   $KEY_PROPERTIES"
echo "alias:       $ALIAS"
echo "keytool:     $KEYTOOL"
echo "dname:       $DNAME"
echo "validity:    $VALIDITY_DAYS days ($((VALIDITY_DAYS/365)) years)"
echo

# Guard 1 — check partial state BEFORE any cleanup
PARTIAL=0
[[ -f "$KEYSTORE_DIR/$KEYSTORE_FILE" ]] && PARTIAL=1 && echo "FOUND: $KEYSTORE_FILE"
[[ -f "$KEYSTORE_DIR/$KEY_PROPERTIES"  ]] && PARTIAL=1 && echo "FOUND: $KEY_PROPERTIES"

if [[ "$PARTIAL" -eq 1 ]]; then
    echo
    echo "WARNING: one or both files already exist."
    echo "If you proceed, BOTH files will be DELETED and regenerated together"
    echo "so they stay in sync. Otherwise the next `flutter build appbundle`"
    echo "would fail with a stale password."
    echo
    read -rp "Delete both and regenerate? [y/N] " CONFIRM
    [[ "$CONFIRM" =~ ^[Yy]$ ]] || { echo "Aborted — existing files unchanged."; exit 0; }
    rm -f "$KEYSTORE_DIR/$KEYSTORE_FILE" "$KEYSTORE_DIR/$KEY_PROPERTIES"
    echo "Deleted. Proceeding with regeneration..."
fi

# Guard 2 — atomic gate
if [[ -f "$KEYSTORE_DIR/$KEYSTORE_FILE" || -f "$KEYSTORE_DIR/$KEY_PROPERTIES" ]]; then
    echo "ERROR: post-deletion state still has files?" >&2
    exit 1
fi

# Generate
PASSWORD=$(openssl rand -base64 24 | tr -d '\n')

"$KEYTOOL" -genkey -noprompt \
    -alias "$ALIAS" \
    -storetype JKS \
    -keyalg  RSA \
    -keysize "$KEYSIZE" \
    -validity "$VALIDITY_DAYS" \
    -dname "$DNAME" \
    -keystore "$KEYSTORE_DIR/$KEYSTORE_FILE" \
    -storepass "$PASSWORD" \
    -keypass  "$PASSWORD"

cat > "$KEYSTORE_DIR/$KEY_PROPERTIES" <<EOF
storePassword=$PASSWORD
keyPassword=$PASSWORD
keyAlias=$ALIAS
storeFile=$KEYSTORE_FILE
EOF

echo
echo "Generated:"
ls -la "$KEYSTORE_DIR/$KEYSTORE_FILE" "$KEYSTORE_DIR/$KEY_PROPERTIES"
echo

# Verify integrity (capture keytool's exit code via PIPESTATUS so a corrupt
# keystore or wrong password doesn't slip past silently when piped to head)
set +o pipefail
"$KEYTOOL" -list \
    -storetype JKS \
    -keystore "$KEYSTORE_DIR/$KEYSTORE_FILE" \
    -storepass "$PASSWORD" 2>&1 | head -8
KT_RC=${PIPESTATUS[0]}
set -o pipefail
echo
if [[ "$KT_RC" -ne 0 ]]; then
    echo "FATAL: integrity check failed (keytool exit $KT_RC)" >&2
    echo "Your freshly-minted keystore may be malformed — re-run the script." >&2
    rm -f "$KEYSTORE_DIR/$KEYSTORE_FILE" "$KEYSTORE_DIR/$KEY_PROPERTIES"
    exit 4
fi

# (gitignore pre-flight was done at top of script; no post-check needed)
echo "OK: both files gitignored (verified by pre-flight check)."

echo
echo "======================================================================"
echo "  SAVE THESE CREDENTIALS NOW (one-time display)"
echo "======================================================================"
echo "  Alias:                  $ALIAS"
echo "  Keystore file:          $KEYSTORE_DIR/$KEYSTORE_FILE"
echo "  Store password:         $PASSWORD"
echo "  Key password:           $PASSWORD  (intentionally identical)"
echo "  DName:                  $DNAME"
echo "  Validity:               $VALIDITY_DAYS days"
echo "  Type:                   JKS  (matches the .jks file extension)"
echo "======================================================================"
echo
echo "  Add to your password manager:"
echo "    Title:    BabyMon Android release keystore"
echo "    Notes:    CN=BabyMon, OU=Mobile, O=BabyMon, RSA-2048, 10000 days"
echo
echo "  The keystore file + password are BOTH required to publish any"
echo "  future app update. If you lose either, you must re-publish under"
echo "  a brand-new applicationId — losing all existing installs."
echo "======================================================================"
