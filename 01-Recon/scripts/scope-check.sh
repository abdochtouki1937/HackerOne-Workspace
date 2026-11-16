#!/usr/bin/env bash
# scope-check.sh — scope enforcement helper.
#
# Prints the in-scope assets from a program's assets.txt and checks
# whether a target is covered before any scan runs.
# Borrowed from the scope-guard idea in DevCop95/bugbounty-lab101:
# no scope file, no scan.
#
# Matching rules
#   - Exact match: the target equals an asset line (case-insensitive
#     on the host part, e.g. API.Deriv.COM matches api.deriv.com).
#   - Wildcard: an asset written as "*.domain" matches any subdomain
#     of that domain (e.g. "*.deriv.com" matches "api.deriv.com").
#   - A PLAIN domain asset does NOT cover its subdomains: a bare
#     "deriv.com" asset matches only "deriv.com" itself, never
#     "api.deriv.com", unless the file also lists it or a wildcard.
#     This is deliberate — scope is only what the file says.
#   - Asset lines are read case-insensitively, ignore surrounding
#     whitespace, skip "#" comments and blank lines, and tolerate
#     CRLF line endings.
#
# Usage:
#   scope-check.sh [flags] <program-folder> <target>
#   scope-check.sh ../../00-Programs/Slack slack.com
#   scope-check.sh ../../00-Programs/Deriv api.deriv.com
#   scope-check.sh -v ../../00-Programs/Deriv api.deriv.com
#   scope-check.sh --quiet ../../00-Programs/Deriv example.com
#
# Flags:
#   -v, --verbose   Print each asset as it is checked.
#   --quiet         Print only the final verdict line.
#   -h, --help      Print this usage and exit 0.
#
# Exit codes:
#   0 = target is in scope (Scope OK).
#   1 = target is NOT in scope, or bad input (missing/invalid
#       program folder, missing/empty target, target contains
#       whitespace or a URL scheme, no usable assets.txt).
set -u

VERBOSE=0
QUIET=0

usage() {
  sed -n '2,/^set -u/p' "$0" | sed 's/^# \?//'
}

# --- Parse flags (allowed before or after the positional arguments). ---
POSITIONAL=()
while [ $# -gt 0 ]; do
  case "$1" in
    -v|--verbose) VERBOSE=1; shift ;;
    --quiet) QUIET=1; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; while [ $# -gt 0 ]; do POSITIONAL+=("$1"); shift; done ;;
    -*) echo "[!] Unknown flag: $1" >&2; echo "Usage: $0 [-v|--verbose] [--quiet] <program-folder> <target>" >&2; exit 1 ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done

PROGRAM_DIR="${POSITIONAL[0]:-}"
TARGET="${POSITIONAL[1]:-}"

if [ -z "$PROGRAM_DIR" ] || [ -z "$TARGET" ]; then
  echo "[!] Missing argument." >&2
  echo "Usage: $0 [-v|--verbose] [--quiet] <program-folder> <target>" >&2
  echo "Example: $0 ../../00-Programs/Slack slack.com" >&2
  exit 1
fi

if [ "${#POSITIONAL[@]}" -gt 2 ]; then
  echo "[!] Too many arguments: expected <program-folder> <target>." >&2
  echo "Usage: $0 [-v|--verbose] [--quiet] <program-folder> <target>" >&2
  exit 1
fi

# --- Validate the target: no scheme, no whitespace, not empty. ---
case "$TARGET" in
  *://*)
    echo "[!] Invalid target '$TARGET': do not pass a URL — pass a bare hostname (e.g. api.deriv.com, no https://)." >&2
    exit 1
    ;;
  *[[:space:]]*)
    echo "[!] Invalid target '$TARGET': targets must not contain whitespace." >&2
    exit 1
    ;;
esac

# --- Validate the program folder and its assets file. ---
if [ ! -d "$PROGRAM_DIR" ]; then
  echo "[!] Program folder '$PROGRAM_DIR' does not exist or is not a directory — scope is not documented. Aborting." >&2
  exit 1
fi

ASSETS_FILE="$PROGRAM_DIR/assets.txt"
if [ ! -f "$ASSETS_FILE" ]; then
  echo "[!] No assets.txt found in $PROGRAM_DIR — scope is not documented. Aborting." >&2
  exit 1
fi

# Read assets: strip CR (CRLF files), trim whitespace, drop comments/blanks.
ASSETS="$(tr -d '\r' < "$ASSETS_FILE" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | grep -v '^#' | grep -v '^$')"

if [ -z "$ASSETS" ]; then
  echo "[!] assets.txt in $PROGRAM_DIR is empty — no in-scope assets listed. Aborting." >&2
  exit 1
fi

# Hostnames are case-insensitive: compare lowercased on both sides.
TARGET_LC="$(printf '%s' "$TARGET" | tr '[:upper:]' '[:lower:]')"

if [ "$QUIET" -eq 0 ]; then
  echo "In-scope assets for $(basename "$PROGRAM_DIR"):"
  echo "$ASSETS" | sed 's/^/  - /'
  echo ""
fi

# Match: exact line, or a *.domain wildcard covering a subdomain.
# A plain domain asset matches ONLY itself — never its subdomains.
while IFS= read -r asset; do
  asset_lc="$(printf '%s' "$asset" | tr '[:upper:]' '[:lower:]')"
  if [ "$VERBOSE" -eq 1 ] && [ "$QUIET" -eq 0 ]; then
    echo "  [check] $asset"
  fi
  if [ "$TARGET_LC" = "$asset_lc" ]; then
    echo "[✓] Scope OK — $TARGET is listed in $ASSETS_FILE"
    exit 0
  fi
  case "$asset_lc" in
    \*.*)
      suffix="${asset_lc#\*.}"
      case "$TARGET_LC" in
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

# --- DENIED: hint at the closest assets (same base domain suffix). ---
# Base domain = last two labels of the target (e.g. api.deriv.com -> deriv.com).
BASE="$(printf '%s' "$TARGET_LC" | awk -F. '{ if (NF >= 2) print $(NF-1)"."$NF; else print $0 }')"
CLOSEST=""
while IFS= read -r asset; do
  asset_lc="$(printf '%s' "$asset" | tr '[:upper:]' '[:lower:]')"
  asset_domain="${asset_lc#\*.}"
  case "$asset_domain" in
    "$BASE"|*".$BASE")
      CLOSEST="${CLOSEST}  - $asset
"
      ;;
    *)
      case "$BASE" in
        *".$asset_domain") CLOSEST="${CLOSEST}  - $asset
" ;;
      esac
      ;;
  esac
done <<EOF
$ASSETS
EOF

echo "[!] Scope DENIED — $TARGET is not listed in $ASSETS_FILE. Do not test it." >&2
if [ -n "$CLOSEST" ]; then
  echo "[?] Closest in-scope assets (same base domain '$BASE'):" >&2
  printf '%s' "$CLOSEST" >&2
else
  echo "[?] No in-scope asset shares the base domain '$BASE' — nothing close to $TARGET is in scope." >&2
fi
exit 1
