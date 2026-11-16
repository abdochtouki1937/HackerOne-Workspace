#!/usr/bin/env bash
# scope-check.sh — scope enforcement helper.
# Prints the in-scope assets from a program's assets.txt and checks
# whether a target is covered before any scan runs.
# Borrowed from the scope-guard idea in DevCop95/bugbounty-lab101:
# no scope file, no scan.
#
# Usage:
#   ./scope-check.sh <program-folder> <target>
#   ./scope-check.sh ../../00-Programs/Slack slack.com
#   ./scope-check.sh ../../00-Programs/Deriv api.deriv.com
#
# Exit 0 = Scope OK. Exit 1 = target is NOT in scope, do not test it.
set -u

PROGRAM_DIR="${1:-}"
TARGET="${2:-}"

if [ -z "$PROGRAM_DIR" ] || [ -z "$TARGET" ]; then
  echo "Usage: $0 <program-folder> <target>" >&2
  echo "Example: $0 ../../00-Programs/Slack slack.com" >&2
  exit 1
fi

ASSETS_FILE="$PROGRAM_DIR/assets.txt"
if [ ! -f "$ASSETS_FILE" ]; then
  echo "[!] No assets.txt found in $PROGRAM_DIR — scope is not documented. Aborting." >&2
  exit 1
fi

# Strip comments and blank lines.
ASSETS=$(grep -v '^\s*#' "$ASSETS_FILE" | grep -v '^\s*$' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

if [ -z "$ASSETS" ]; then
  echo "[!] assets.txt in $PROGRAM_DIR is empty — no in-scope assets listed. Aborting." >&2
  exit 1
fi

echo "In-scope assets for $(basename "$PROGRAM_DIR"):"
echo "$ASSETS" | sed 's/^/  - /'
echo ""

# Match: exact line, or a *.domain wildcard covering a subdomain.
while IFS= read -r asset; do
  if [ "$TARGET" = "$asset" ]; then
    echo "[✓] Scope OK — $TARGET is listed in $ASSETS_FILE"
    exit 0
  fi
  case "$asset" in
    \*.*)
      suffix="${asset#\*.}"
      case "$TARGET" in
        *".$suffix")
          echo "[✓] Scope OK — $TARGET is covered by wildcard $asset in $ASSETS_FILE"
          exit 0
          ;;
      esac
      ;;
  esac
done <<EOF
$ASSETS
EOF

echo "[!] Scope DENIED — $TARGET is not listed in $ASSETS_FILE. Do not test it." >&2
exit 1
