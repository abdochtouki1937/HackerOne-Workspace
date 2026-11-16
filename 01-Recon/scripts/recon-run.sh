#!/usr/bin/env bash
# recon-run.sh — ordered, scope-checked, rate-limited recon runner.
# Runs the standard recon pipeline in the order the research supports:
# passive subdomains -> live hosts -> endpoints/JS -> nuclei.
# Modelled on the reconftw pipeline order (six2dez/reconftw) and the
# Gunnar Andrews rule: automate collection, judge the run by findings,
# not by gigabytes collected.
#
# Scope is enforced first: the run refuses to start unless
# scope-check.sh says the target is in scope. Rate limits are on by
# default. Tools that are not installed are skipped with a warning,
# never faked.
#
# Usage:
#   ./recon-run.sh <program-folder> <target-domain>
#   ./recon-run.sh ../../00-Programs/Slack slack.com
#
# Output goes to <program-folder>/recon/<YYYY-MM-DD>-<step>/.
# Exit 0 = run finished (some steps may have been skipped).
# Exit 1 = scope denied, missing arguments, or the output folder
# could not be created.
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROGRAM_DIR="${1:-}"
TARGET="${2:-}"

if [ -z "$PROGRAM_DIR" ] || [ -z "$TARGET" ]; then
  echo "Usage: $0 <program-folder> <target-domain>" >&2
  echo "Example: $0 ../../00-Programs/Slack slack.com" >&2
  exit 1
fi

# Step 0: scope gate. No scope file, no scan.
if ! "$SCRIPT_DIR/scope-check.sh" "$PROGRAM_DIR" "$TARGET" >/dev/null 2>&1; then
  echo "[!] Scope DENIED for $TARGET — run scope-check.sh to see why. Aborting." >&2
  exit 1
fi
echo "[+] Scope OK for $TARGET. Starting recon."

DATE="$(date +%Y-%m-%d)"
OUT="$PROGRAM_DIR/recon/$DATE-recon-run"
mkdir -p "$OUT" || { echo "[!] Cannot create $OUT" >&2; exit 1; }
echo "[+] Output: $OUT"

have() { command -v "$1" >/dev/null 2>&1; }

# Step 1: passive subdomain enumeration. No traffic to the target.
if have subfinder; then
  echo "[1/4] subfinder (passive)..."
  subfinder -d "$TARGET" -all -o "$OUT/subdomains-subfinder.txt" 2>"$OUT/subfinder.err" || true
else
  echo "[!] subfinder not installed — skipping step 1 (passive subdomains)."
fi

if have assetfinder; then
  echo "[1/4] assetfinder (passive)..."
  assetfinder --subs-only "$TARGET" >> "$OUT/subdomains-subfinder.txt" 2>/dev/null || true
fi

if [ -f "$OUT/subdomains-subfinder.txt" ]; then
  sort -u "$OUT/subdomains-subfinder.txt" -o "$OUT/subdomains.txt"
  echo "[+] Subdomains found: $(wc -l < "$OUT/subdomains.txt")"
else
  echo "[!] No subdomain output — check that subfinder is installed."
  touch "$OUT/subdomains.txt"
fi

# Step 2: live host detection, rate-limited.
if have httpx; then
  echo "[2/4] httpx (live hosts, rate-limited)..."
  httpx -l "$OUT/subdomains.txt" -o "$OUT/live.txt" \
    -title -tech-detect -status-code -follow-redirects \
    -rate-limit 50 -timeout 10 2>"$OUT/httpx.err" || true
  echo "[+] Live hosts: $(wc -l < "$OUT/live.txt" 2>/dev/null || echo 0)"
else
  echo "[!] httpx not installed — skipping step 2 (live hosts)."
fi

# Step 3: endpoint and JS discovery from live hosts.
if have katana; then
  echo "[3/4] katana (crawl + JS)..."
  if [ -s "$OUT/live.txt" ]; then
    head -1 "$OUT/live.txt" | awk '{print $1}' > "$OUT/_seed.txt"
    katana -list "$OUT/_seed.txt" -jc -o "$OUT/js-files.txt" \
      -rate-limit 20 2>"$OUT/katana.err" || true
    rm -f "$OUT/_seed.txt"
  else
    echo "[!] No live hosts to crawl — skipping katana."
  fi
else
  echo "[!] katana not installed — skipping step 3 (JS/endpoints)."
fi

# Step 4: nuclei scan on live hosts, rate-limited. A hit is a lead, not a bug.
if have nuclei; then
  echo "[4/4] nuclei (rate-limited)..."
  if [ -s "$OUT/live.txt" ]; then
    awk '{print $1}' "$OUT/live.txt" > "$OUT/_live-urls.txt"
    nuclei -l "$OUT/_live-urls.txt" -o "$OUT/nuclei-results.txt" \
      -rate-limit 20 2>"$OUT/nuclei.err" || true
    rm -f "$OUT/_live-urls.txt"
    echo "[+] Nuclei hits: $(wc -l < "$OUT/nuclei-results.txt" 2>/dev/null || echo 0)"
  else
    echo "[!] No live hosts to scan — skipping nuclei."
  fi
else
  echo "[!] nuclei not installed — skipping step 4 (vuln scan)."
fi

# Step 5: recon index — one line per result file, so the run is queryable
# instead of a pile of text files (Gunnar Andrews, DEF CON 32).
{
  echo "# Recon index — $TARGET — $DATE"
  echo "# Run: recon-run.sh (scope-checked, rate-limited)"
  echo ""
  for f in "$OUT"/*; do
    [ -f "$f" ] || continue
    echo "- $(basename "$f"): $(wc -l < "$f" 2>/dev/null || echo 0) lines"
  done
} > "$OUT/INDEX.md"

echo ""
echo "[+] Recon run finished. Results in $OUT"
echo "[+] Next: read $OUT/INDEX.md, rank the leads in notes.md,"
echo "    then test the top lead by hand. A scanner hit is a lead, not a bug."
