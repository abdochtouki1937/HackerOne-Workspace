#!/usr/bin/env bash
# recon-run.sh — ordered, scope-checked, rate-limited recon runner.
#
# Runs the standard recon pipeline in the order the research supports:
# passive subdomains -> live hosts -> endpoints/JS -> nuclei.
# Modelled on the reconftw pipeline order (six2dez/reconftw) and the
# Gunnar Andrews rule: automate collection, judge the run by findings,
# not by gigabytes collected.
#
# Scope is enforced first: the run refuses to start unless
# scope-check.sh says the target is in scope. Rate limits are on by
# default. Tools that are not installed are skipped with a warning,
# never faked. A failing tool step never aborts the run — its failure
# (with exit code) is recorded in RUN-LOG.md in the output folder.
#
# Usage:
#   recon-run.sh [flags] <program-folder> <target-domain>
#   recon-run.sh ../../00-Programs/Slack slack.com
#   recon-run.sh --fast ../../00-Programs/Deriv api.deriv.com
#   recon-run.sh --slow ../../00-Programs/Deriv api.deriv.com
#   recon-run.sh --dry-run ../../00-Programs/Deriv api.deriv.com
#
# Flags:
#   --fast      Double the rate limits (httpx 100, katana/nuclei 40
#               at defaults). Use only on targets that tolerate it.
#   --slow      Halve the rate limits (minimum 5). Default when the
#               target is fragile or you want to stay quiet.
#   --dry-run   Print the plan (scope verdict, tool availability,
#               output path, effective limits) and exit 0 without
#               running any tool or creating the output folder.
#   -h, --help  Print this usage and exit 0.
#
# Environment variables:
#   RATE_LIMIT          Override for all three rate limits at once.
#   HTTPX_RATE_LIMIT    httpx requests/second (default 50).
#   KATANA_RATE_LIMIT   katana requests/second (default 20).
#   NUCLEI_RATE_LIMIT   nuclei requests/second (default 20).
#   A tool-specific variable beats RATE_LIMIT. --fast doubles and
#   --slow halves whatever the effective limits are (minimum 5).
#
# Output goes to <program-folder>/recon/<YYYY-MM-DD>-recon-run/.
# The folder holds the result files, an INDEX.md (one line per file)
# and a RUN-LOG.md (start/end times, command line, scope verdict,
# per-step status with exit codes, and counts).
#
# Exit codes:
#   0 = run finished (some steps may have been skipped/failed — see
#       RUN-LOG.md), or --dry-run plan printed.
#   1 = scope denied, missing/invalid arguments, or the output folder
#       could not be created.
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CMD_LINE="$0 $*"

# Tools installed via `go install` land in ~/go/bin, which is often not
# on PATH in non-interactive shells. Pick it up if it exists.
if [ -d "$HOME/go/bin" ]; then
  case ":$PATH:" in
    *":$HOME/go/bin:"*) ;;
    *) PATH="$HOME/go/bin:$PATH" ;;
  esac
fi

usage() {
  sed -n '2,/^set -u/p' "$0" | sed 's/^# \?//'
}

# --- Parse flags (allowed before or after the positional arguments). ---
FAST=0
SLOW=0
DRY_RUN=0
POSITIONAL=()
while [ $# -gt 0 ]; do
  case "$1" in
    --fast) FAST=1; shift ;;
    --slow) SLOW=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; while [ $# -gt 0 ]; do POSITIONAL+=("$1"); shift; done ;;
    -*) echo "[!] Unknown flag: $1" >&2; echo "Usage: $0 [--fast|--slow] [--dry-run] <program-folder> <target-domain>" >&2; exit 1 ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done

PROGRAM_DIR="${POSITIONAL[0]:-}"
TARGET="${POSITIONAL[1]:-}"

if [ -z "$PROGRAM_DIR" ] || [ -z "$TARGET" ]; then
  echo "[!] Missing argument." >&2
  echo "Usage: $0 [--fast|--slow] [--dry-run] <program-folder> <target-domain>" >&2
  echo "Example: $0 ../../00-Programs/Slack slack.com" >&2
  exit 1
fi
if [ "${#POSITIONAL[@]}" -gt 2 ]; then
  echo "[!] Too many arguments: expected <program-folder> <target-domain>." >&2
  echo "Usage: $0 [--fast|--slow] [--dry-run] <program-folder> <target-domain>" >&2
  exit 1
fi
if [ "$FAST" -eq 1 ] && [ "$SLOW" -eq 1 ]; then
  echo "[!] --fast and --slow contradict each other — pick one." >&2
  exit 1
fi

# --- Validate the target the same way scope-check.sh does. ---
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
if [ ! -d "$PROGRAM_DIR" ]; then
  echo "[!] Program folder '$PROGRAM_DIR' does not exist or is not a directory. Aborting." >&2
  exit 1
fi

# --- Rate limits: env overrides, then --fast (x2) / --slow (/2, min 5). ---
HTTPX_LIMIT="${HTTPX_RATE_LIMIT:-${RATE_LIMIT:-50}}"
KATANA_LIMIT="${KATANA_RATE_LIMIT:-${RATE_LIMIT:-20}}"
NUCLEI_LIMIT="${NUCLEI_RATE_LIMIT:-${RATE_LIMIT:-20}}"
# Env values must be numbers; fall back to defaults on garbage.
case "$HTTPX_LIMIT" in ''|*[!0-9]*) echo "[!] HTTPX_RATE_LIMIT/RATE_LIMIT must be a number, got '$HTTPX_LIMIT'. Using 50." >&2; HTTPX_LIMIT=50 ;; esac
case "$KATANA_LIMIT" in ''|*[!0-9]*) echo "[!] KATANA_RATE_LIMIT/RATE_LIMIT must be a number, got '$KATANA_LIMIT'. Using 20." >&2; KATANA_LIMIT=20 ;; esac
case "$NUCLEI_LIMIT" in ''|*[!0-9]*) echo "[!] NUCLEI_RATE_LIMIT/RATE_LIMIT must be a number, got '$NUCLEI_LIMIT'. Using 20." >&2; NUCLEI_LIMIT=20 ;; esac
if [ "$FAST" -eq 1 ]; then
  HTTPX_LIMIT=$((HTTPX_LIMIT * 2)); KATANA_LIMIT=$((KATANA_LIMIT * 2)); NUCLEI_LIMIT=$((NUCLEI_LIMIT * 2))
elif [ "$SLOW" -eq 1 ]; then
  HTTPX_LIMIT=$((HTTPX_LIMIT / 2)); KATANA_LIMIT=$((KATANA_LIMIT / 2)); NUCLEI_LIMIT=$((NUCLEI_LIMIT / 2))
  [ "$HTTPX_LIMIT" -lt 5 ] && HTTPX_LIMIT=5
  [ "$KATANA_LIMIT" -lt 5 ] && KATANA_LIMIT=5
  [ "$NUCLEI_LIMIT" -lt 5 ] && NUCLEI_LIMIT=5
fi
echo "[+] Rate limits: httpx=$HTTPX_LIMIT/s katana=$KATANA_LIMIT/s nuclei=$NUCLEI_LIMIT/s"

# --- Tool availability, checked once at the start. ---
have() { command -v "$1" >/dev/null 2>&1; }
tool_version() {
  # Prints "<tool>: <version line>" or "<tool> (installed, version unknown)".
  # Only accepts output when the version flag exits 0, and skips
  # unrelated warning lines (e.g. nuclei's sonic/ast notice).
  local tmp rc out flag
  tmp="$(mktemp)"
  for flag in -version --version; do
    "$1" "$flag" >"$tmp" 2>&1; rc=$?
    if [ "$rc" -eq 0 ]; then
      out="$(grep -m1 -iE 'version|^[[:space:]]*v[0-9]' "$tmp")"
      [ -z "$out" ] && out="$(head -1 "$tmp")"
      if [ -n "$out" ]; then
        printf '%s: %s' "$1" "$out"
        rm -f "$tmp"
        return 0
      fi
    fi
  done
  rm -f "$tmp"
  printf '%s (installed, version unknown)' "$1"
}
TOOLS="subfinder assetfinder httpx katana nuclei"
AVAILABLE=""
MISSING=""
for t in $TOOLS; do
  if have "$t"; then
    AVAILABLE="$AVAILABLE $t"
  else
    MISSING="$MISSING $t"
  fi
done
echo "[+] Tools available:${AVAILABLE:- none}"
if [ -n "$MISSING" ]; then
  echo "[!] Tools missing (those steps will be skipped):${MISSING}"
fi
for t in $AVAILABLE; do
  echo "    - $(tool_version "$t")"
done

DATE="$(date +%Y-%m-%d)"
OUT="$PROGRAM_DIR/recon/$DATE-recon-run"

# --- Step 0: scope gate. No scope file, no scan. ---
SCOPE_VERDICT="denied"
if SCOPE_OUT="$("$SCRIPT_DIR/scope-check.sh" --quiet "$PROGRAM_DIR" "$TARGET" 2>&1)"; then
  SCOPE_VERDICT="OK — $SCOPE_OUT"
  echo "[+] Scope OK for $TARGET. Starting recon."
else
  echo "[!] Scope DENIED for $TARGET — run scope-check.sh to see why. Aborting." >&2
  exit 1
fi

# --- Dry run: print the plan, run nothing, create nothing. ---
if [ "$DRY_RUN" -eq 1 ]; then
  echo ""
  echo "[dry-run] Plan for $TARGET (program: $PROGRAM_DIR):"
  echo "[dry-run]   scope: $SCOPE_VERDICT"
  echo "[dry-run]   rate limits: httpx=$HTTPX_LIMIT/s katana=$KATANA_LIMIT/s nuclei=$NUCLEI_LIMIT/s"
  echo "[dry-run]   output folder (would be created): $OUT"
  echo "[dry-run]   steps:"
  echo "[dry-run]     1. subfinder + assetfinder (passive subdomains) -> subdomains.txt"
  echo "[dry-run]     2. httpx (live hosts, $HTTPX_LIMIT/s) -> live.txt"
  echo "[dry-run]     3. katana (crawl + JS, $KATANA_LIMIT/s) -> js-files.txt"
  echo "[dry-run]     4. nuclei ($NUCLEI_LIMIT/s) -> nuclei-results.txt"
  echo "[dry-run]     5. write INDEX.md + RUN-LOG.md"
  echo "[dry-run] Nothing was run and no folder was created."
  exit 0
fi

# --- Create the output folder (fail loudly if impossible). ---
mkdir -p "$OUT" || { echo "[!] Cannot create $OUT" >&2; exit 1; }
echo "[+] Output: $OUT"

START_TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
RUN_LOG="$OUT/RUN-LOG.md"
{
  echo "# Recon run log — $TARGET — $DATE"
  echo ""
  echo "- Started (UTC): $START_TS"
  echo "- Command: $CMD_LINE"
  echo "- Program folder: $PROGRAM_DIR"
  echo "- Target: $TARGET"
  echo "- Scope verdict: $SCOPE_VERDICT"
  echo "- Rate limits: httpx=$HTTPX_LIMIT/s katana=$KATANA_LIMIT/s nuclei=$NUCLEI_LIMIT/s"
  echo "- Tools available:${AVAILABLE:- none}"
  echo "- Tools missing:${MISSING:- none}"
  echo ""
  echo "## Steps"
  echo ""
} > "$RUN_LOG"

# log_step <name> <status: ok|skipped|failed> <exit-code|-> <note>
log_step() {
  echo "- $1: **$2** (exit $3) $4" >> "$RUN_LOG"
  case "$2" in
    ok) echo "[+] $1 done." ;;
    skipped) echo "[!] $1 skipped. $4" ;;
    failed) echo "[!] $1 FAILED (exit $3) — recorded in RUN-LOG.md, continuing. $4" ;;
  esac
}

count_lines() { [ -f "$1" ] && wc -l < "$1" 2>/dev/null | tr -d ' ' || echo 0; }

# Step 1: passive subdomain enumeration. No traffic to the target.
SUB_RC="-"
if have subfinder; then
  echo "[1/4] subfinder (passive)..."
  subfinder -d "$TARGET" -all -o "$OUT/subdomains-subfinder.txt" 2>"$OUT/subfinder.err"; SUB_RC=$?
  if [ "$SUB_RC" -eq 0 ]; then log_step "1a subfinder" "ok" "$SUB_RC" ""; else log_step "1a subfinder" "failed" "$SUB_RC" "see subfinder.err"; fi
else
  log_step "1a subfinder" "skipped" "-" "not installed"
fi

if have assetfinder; then
  echo "[1/4] assetfinder (passive)..."
  assetfinder --subs-only "$TARGET" >> "$OUT/subdomains-subfinder.txt" 2>/dev/null; AF_RC=$?
  if [ "$AF_RC" -eq 0 ]; then log_step "1b assetfinder" "ok" "$AF_RC" ""; else log_step "1b assetfinder" "failed" "$AF_RC" ""; fi
else
  log_step "1b assetfinder" "skipped" "-" "not installed"
fi

if [ -f "$OUT/subdomains-subfinder.txt" ]; then
  sort -u "$OUT/subdomains-subfinder.txt" -o "$OUT/subdomains.txt"
  echo "[+] Subdomains found: $(count_lines "$OUT/subdomains.txt")"
else
  echo "[!] No subdomain output — check that subfinder is installed."
  touch "$OUT/subdomains.txt"
fi

# Step 2: live host detection, rate-limited.
if have httpx; then
  echo "[2/4] httpx (live hosts, rate-limited)..."
  httpx -l "$OUT/subdomains.txt" -o "$OUT/live.txt" \
    -title -tech-detect -status-code -follow-redirects \
    -rate-limit "$HTTPX_LIMIT" -timeout 10 2>"$OUT/httpx.err"; HTTPX_RC=$?
  if [ "$HTTPX_RC" -eq 0 ]; then log_step "2 httpx" "ok" "$HTTPX_RC" ""; else log_step "2 httpx" "failed" "$HTTPX_RC" "see httpx.err"; fi
  echo "[+] Live hosts: $(count_lines "$OUT/live.txt")"
else
  log_step "2 httpx" "skipped" "-" "not installed"
fi

# Step 3: endpoint and JS discovery from live hosts.
if have katana; then
  echo "[3/4] katana (crawl + JS)..."
  if [ -s "$OUT/live.txt" ]; then
    head -1 "$OUT/live.txt" | awk '{print $1}' > "$OUT/_seed.txt"
    katana -list "$OUT/_seed.txt" -jc -o "$OUT/js-files.txt" \
      -rate-limit "$KATANA_LIMIT" 2>"$OUT/katana.err"; KATANA_RC=$?
    rm -f "$OUT/_seed.txt"
    if [ "$KATANA_RC" -eq 0 ]; then log_step "3 katana" "ok" "$KATANA_RC" ""; else log_step "3 katana" "failed" "$KATANA_RC" "see katana.err"; fi
  else
    log_step "3 katana" "skipped" "-" "no live hosts to crawl"
  fi
else
  log_step "3 katana" "skipped" "-" "not installed"
fi

# Step 4: nuclei scan on live hosts, rate-limited. A hit is a lead, not a bug.
if have nuclei; then
  echo "[4/4] nuclei (rate-limited)..."
  if [ -s "$OUT/live.txt" ]; then
    awk '{print $1}' "$OUT/live.txt" > "$OUT/_live-urls.txt"
    nuclei -l "$OUT/_live-urls.txt" -o "$OUT/nuclei-results.txt" \
      -rate-limit "$NUCLEI_LIMIT" 2>"$OUT/nuclei.err"; NUCLEI_RC=$?
    rm -f "$OUT/_live-urls.txt"
    if [ "$NUCLEI_RC" -eq 0 ]; then log_step "4 nuclei" "ok" "$NUCLEI_RC" ""; else log_step "4 nuclei" "failed" "$NUCLEI_RC" "see nuclei.err"; fi
    echo "[+] Nuclei hits: $(count_lines "$OUT/nuclei-results.txt")"
  else
    log_step "4 nuclei" "skipped" "-" "no live hosts to scan"
  fi
else
  log_step "4 nuclei" "skipped" "-" "not installed"
fi

# Step 5: recon index — one line per result file, so the run is queryable
# instead of a pile of text files (Gunnar Andrews, DEF CON 32).
{
  echo "# Recon index — $TARGET — $DATE"
  echo "# Run: recon-run.sh (scope-checked, rate-limited)"
  echo ""
  for f in "$OUT"/*; do
    [ -f "$f" ] || continue
    echo "- $(basename "$f"): $(count_lines "$f") lines"
  done
} > "$OUT/INDEX.md"

END_TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
{
  echo ""
  echo "## Counts"
  echo ""
  echo "- Subdomains: $(count_lines "$OUT/subdomains.txt")"
  echo "- Live hosts: $(count_lines "$OUT/live.txt")"
  echo "- JS files: $(count_lines "$OUT/js-files.txt")"
  echo "- Nuclei hits: $(count_lines "$OUT/nuclei-results.txt")"
  echo ""
  echo "- Finished (UTC): $END_TS"
} >> "$RUN_LOG"

echo ""
echo "[+] Recon run finished. Results in $OUT"
echo "[+] Run log: $OUT/RUN-LOG.md"
echo "[+] Next: read $OUT/INDEX.md, rank the leads in notes.md,"
echo "    then test the top lead by hand. A scanner hit is a lead, not a bug."
