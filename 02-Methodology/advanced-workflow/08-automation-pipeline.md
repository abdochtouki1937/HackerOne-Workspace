# Stage 2 Deepening — The Automation Pipeline

Automation finds candidates; it does not find bugs. This file says
exactly what to automate, what must stay manual, in what order the
pipeline runs, and where it stops. It is built on three public designs:

- **ProjectDiscovery's Discover → Enrich → Detect** — the official
  layering of its tool suite (discovery: subfinder, cloudlist, naabu,
  katana, chaos, uncover, asnmap, alterx; enrichment: httpx, dnsx,
  tlsx; detection: nuclei, interactsh, notify). Source:
  https://projectdiscovery.io/open-source and
  https://github.com/projectdiscovery/docs/blob/HEAD/opensource/index.mdx
- **reconftw (six2dez)** — the community reference pipeline. Stages:
  OSINT → Subdomains → Hosts → Web → Vulns; modes: full, passive-only,
  subdomains, web, scan, recon, vuln; one config file, normalised
  output tree. Source: https://github.com/six2dez/reconftw
- **Gunnar Andrews, "Efficient Bug Bounty Automation Techniques",
  DEF CON 32** — judge a pipeline by findings per hour, not data
  collected; automate collection first, then scale; move off flat text
  files into structured, queryable data. Source: transcript at
  https://media.defcon.org/DEF%20CON%2032/DEF%20CON%2032%20villages/DEF%20CON%2032%20villages%20captions/DEF%20CON%2032%20-%20Bug%20Bounty%20Village%20-%20Efficient%20Bug%20Bounty%20Automation%20Techniques%20-%20Gunnar%20Andrews.eng.srt

## 8.1 What to automate vs what stays manual

| Automate (machines are better) | Stay manual (humans are better) |
|---|---|
| Subdomain collection (passive sources, CT logs) | Choosing the target and reading the scope |
| Live-host probing and tech fingerprinting | Understanding the app's business logic |
| Historical URL and JS endpoint extraction | Tracing data flow and trust boundaries |
| Nuclei template runs (known CVEs, exposures) | Chaining two lows into one finding |
| Duplicate Radar queries (Hacktivity, advisories) | Severity judgment and impact argument |
| Release watching (new release → re-audit) | Client-rendering checks (browser, side by side) |
| Change monitoring (new endpoints, new subdomains) | Deciding what to file and spending a trial report |
| Structured logging of every run | Writing the report |

The rule from ai-bug-bounty-hunter (#6): **automation has the highest
duplicate rate — manual finds unique bugs.** Automation's job is to
hand a human a short, ranked list. If the pipeline produces a long
unranked list, it has failed, however much data it collected.
Source: https://github.com/federicopinan/ai-bug-bounty-hunter

The rule from DEF CON 34 ("Hackbots", Haddix & Bonner): **hackbots
need evidence, not confidence** — every candidate goes through
reproduction before it counts. A scanner hit without a manual
re-check is a lead, not a finding.

## 8.2 The pipeline order

One run, five layers, in this order. Each layer's output is the next
layer's input. Tools chain through stdin/stdout pipes; every tool
writes one result per line (`-silent`, `-jsonl`).

```
Layer 0 — SCOPE GATE (before anything touches a target)
  scope-check.sh <program> <host-or-url>
  Exit 1 = stop. Nothing runs on an unvalidated host.
  (HuntMCP's rule: a deterministic scope gate on every live action,
  regardless of which agent made it.
  https://github.com/ankitsingh015/HuntMCP)

Layer 1 — DISCOVER (passive first, no target interaction)
  subfinder -d <domain> -all          (passive subdomain sources)
  assetfinder --subs-only <domain>
  crt.sh (certificate transparency)
  asnmap / reverse WHOIS / acquisitions (TBHM seed expansion —
  assets come before subdomains)
  alterx -enrich (permutations from DISCOVERED names only,
  never blind-permute from a generic list)
  Output: subs-all.txt (sort -u)

Layer 2 — ENRICH (validate and describe)
  dnsx -l subs-all.txt -a -resp       (resolve, wildcard filter)
  httpx -l subs-all.txt -title -tech-detect -status-code -tls-probe
  naabu -l live.txt -top-ports 1000   (only on in-scope hosts)
  tlsx -l live.txt                    (certificate data)
  Output: live.txt, versions.md

Layer 3 — MAP (attack surface)
  katana -u <host> -jc                (crawl + JS extraction)
  gau / waybackurls                   (historical URLs)
  OpenAPI / Swagger / GraphQL introspection (endpoint inventory)
  arjun / param-fuzzer.py             (parameter discovery)
  Output: endpoints-all.txt, params-per-endpoint.md, objects.md

Layer 4 — DETECT (known issues only — this layer never confirms)
  nuclei -l live.txt -t cves/ -t exposures/ -severity critical,high
  nuclei -t <workspace custom templates> (exposed .env, exposed .git)
  dalfox (reflected XSS candidates, with a blind callback)
  interactsh (out-of-band callbacks for blind SSRF / blind XSS)
  Output: nuclei-results.jsonl (one line per match, with the request
  that proved it — nuclei's own rule, per ProjectDiscovery docs)

Layer 5 — DIFF (the edge: what changed since the last run)
  diff the new subs-all.txt / endpoints-all.txt against the last run
  new subdomain, new endpoint, new parameter = a lead, ranked first
  new release tag = re-audit the changed code (see 8.4)
```

This order is the workspace's `01-Recon/scripts/recon-run.sh`
(subfinder → httpx → katana → nuclei), extended with the reconftw
stages (OSINT first, hosts, diff last) and the ProjectDiscovery
layer names. The existing script stays the runner; this file is the
design it implements.

## 8.3 Structured output (not flat text files)

Gunnar Andrews' rule: move off flat text files into structured,
queryable data. In this workspace that means:

- **One JSONL file per layer** (`nuclei -jsonl`, `httpx -json`,
  `katana -jsonl`). A line is a record: host, tool, finding, request,
  response, timestamp. `jq` answers questions; `grep` on a text pile
  does not.
- **One `INDEX.md` per recon run** (the `recon-run.sh` behaviour):
  what ran, when, with which wordlists and flags, how many results
  per layer, and where the files are. A run without an index cannot
  be rebuilt.
- **One `inventory.md` per program** (Stage 2, `02-recon-enum.md`):
  the ranked handoff to testing. The inventory is the only file
  testing reads.
- **One `events.jsonl` per program** (optional, borrowed from
  ai-bug-bounty-hunter's Flight Recorder): every automated action
  logged as one JSON line (tool, target, result, timestamp). When a
  question comes up later — "did we test this?" — the log answers it.

## 8.4 Scheduled re-runs (change monitoring)

Recon rots. Two scheduled checks keep it fresh:

1. **Release watch (new release → re-audit).** When a target ships a
   new release, the changed code is the freshest attack surface in
   the program. The repo watcher cron already watches 17 GitHub repos
   for new releases and advisories. For any program target, run
   `01-Recon/scripts/release-watch.sh <owner>/<repo>` (see below):
   it records the latest release tag and reports when it changes.
   A changed tag means: read the changelog, diff the changed code,
   re-run the duplicate check, and re-run the PoC on the new version
   before filing anything from the old one.
2. **Diff runs (new asset → new lead).** Re-run Layers 1–3 on a
   schedule (weekly for an active program, monthly for a watched
   one) and diff against the last run. A new subdomain, endpoint, or
   parameter outranks everything else in the next testing wave —
   it is the least-hunted surface on the target. NahamSec's rule:
   forgotten and new assets are where the bugs live, because the
   core team has not hardened them yet.

Both checks are read-only against public sources (GitHub API,
certificate transparency, passive DNS). They never touch the target.

## 8.5 The script: release-watch.sh

`01-Recon/scripts/release-watch.sh <owner>/<repo>` — checks the latest
GitHub release tag for a repo and reports whether it changed since the
last check. Public GitHub API only (60 requests/hour unauthenticated),
rate-limited by design (one request per run), no target interaction.

```bash
#!/usr/bin/env bash
# release-watch.sh — report when a GitHub repo ships a new release.
# Usage: release-watch.sh <owner>/<repo>
# State lives in 01-Recon/shared-results/release-watch/<owner>-<repo>.txt
# Exit 0 = up to date (or first run, state recorded).
# Exit 2 = NEW RELEASE (tag changed) — re-audit the changed code.
set -u
REPO="${1:-}"
[ -n "$REPO" ] || { echo "usage: release-watch.sh <owner>/<repo>" >&2; exit 1; }
STATE_DIR="$HOME/workspace/HackerOne-Workspace/01-Recon/shared-results/release-watch"
mkdir -p "$STATE_DIR"
SAFE="$(echo "$REPO" | tr '/' '-')"
STATE_FILE="$STATE_DIR/$SAFE.txt"
TAG="$(curl -s --max-time 20 "https://api.github.com/repos/$REPO/releases/latest" \
  | grep -m1 '"tag_name"' | sed 's/.*: *"//;s/".*//')"
[ -n "$TAG" ] || { echo "[warn] could not fetch latest release for $REPO" >&2; exit 1; }
if [ ! -f "$STATE_FILE" ]; then
  echo "$TAG" > "$STATE_FILE"
  echo "[new] $REPO: first check, recorded $TAG"
  exit 0
fi
OLD="$(cat "$STATE_FILE")"
if [ "$TAG" = "$OLD" ]; then
  echo "[ok] $REPO: up to date ($TAG)"
  exit 0
else
  echo "$TAG" > "$STATE_FILE"
  echo "[NEW RELEASE] $REPO: $OLD -> $TAG — re-audit the changed code"
  exit 2
fi
```

Test it with `bash -n` first, then once against a repo you watch
(e.g. `release-watch.sh six2dez/reconftw`). Run it again to see the
up-to-date branch. The exit code is the signal: 2 means a new release,
and a new release means a re-audit, not a filing from the old version.

## 8.6 Limits (where the pipeline stops)

- **Scope gate on every live action.** Layer 0 runs before Layers
  2–4, and again before any manual test. A host that fails the gate
  is never touched, by any tool, by any agent.
- **Rate limits.** Every active tool runs rate-limited (`-rate`,
  `-rate-limit`, `-c`). A 429 is a hard stop for that provider in
  this task — do not sleep, retry, delegate, or schedule replacement
  work.
- **No credential brute force.** The pipeline never fuzzes passwords,
  tokens, OTPs, or session values. Wordlists are for paths, parameters,
  and subdomains — never for credentials.
- **No destructive actions.** The pipeline never sends a request that
  deletes, transfers, purchases, or changes state. Detection is
  read-only; state-changing tests are manual, on test accounts, with
  safe values.
- **Automation never confirms.** A nuclei hit, a dalfox alert, and an
  interactsh callback are all candidates. Confirmation is a human (or
  a separate verifier agent) reproducing the request by hand and
  saving the pair. See `09-triage-and-scoring.md` and the verifier
  rule in `04-verification-gate.md`.

## Sources

- ProjectDiscovery, Discover → Enrich → Detect —
  https://projectdiscovery.io/open-source and
  https://github.com/projectdiscovery/docs/blob/HEAD/opensource/index.mdx
- reconftw, pipeline stages and modes — https://github.com/six2dez/reconftw
- Gunnar Andrews, "Efficient Bug Bounty Automation Techniques", DEF CON 32
  — transcript linked in `08-Research/defcon-talks.md`
- ai-bug-bounty-hunter, rule #6 (automation = highest duplicate rate) —
  https://github.com/federicopinan/ai-bug-bounty-hunter
- HuntMCP, deterministic scope gate —
  https://github.com/ankitsingh015/HuntMCP
- NahamSec, recon-first and forgotten assets —
  https://github.com/zaakirio/reconductor/blob/HEAD/recon-methodology-research.md
- TBHM, seed expansion before subdomain enumeration —
  https://github.com/jhaddix/tbhm
