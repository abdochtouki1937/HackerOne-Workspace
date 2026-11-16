# Stage 2 — Recon and Enumeration

Recon finds the doors; it does not prove any of them open. This stage
produces one thing: a complete, deduped **inventory** that testing works
from. No testing starts before the inventory exists. No recon result is ever
presented as a finding.

Full command-level detail lives in the skills — read them, do not duplicate
them here:

- `~/workspace/custom-skills/bug-bounty-recon/SKILL.md` — the recon
  workflow (subdomains, live hosts, historical URLs, JS analysis, ports,
  content discovery, fingerprinting, scanning).
- `~/workspace/custom-skills/bug-bounty-enumeration/SKILL.md` — the
  enumeration workflow (subdomains, endpoints, parameters, object IDs,
  users/oracles, files, versions, error-based enumeration).
- `~/workspace/custom-skills/bug-bounty-fuzzing/SKILL.md` — fuzzing for
  hidden parameters, endpoints, and boundaries (used in Stage 2 for
  discovery, and again in Stage 3 for testing).

## 2.1 Order of work

1. **Passive first.** Subdomain sources, certificate transparency,
   historical URLs, JS bundles, public API specs and docs. No requests to
   the target beyond what a normal visitor makes.
2. **Active second, slow always.** Live-host probing, content discovery,
   parameter discovery. Rate-limited. Stop on 429.
3. **Fingerprint last.** Exact stack and version for every live host. A
   version number decides whether a known CVE applies — and the version
   must come from the actual code path, not the top-level number (see the
   LobeChat sharp case in the recon skill: root sharp 0.34.5 was vulnerable
   via `analyzeMedia`, while the Next.js optimizer resolved to nested
   0.35.5, fixed).

## 2.2 The outputs (one file per list, all `sort -u` deduped)

Save everything in the program folder's `recon/` directory:

| File | Contents | Source |
|---|---|---|
| `subs-all.txt` | All subdomains, deduped | subfinder, assetfinder, crt.sh, wordlist brute-force |
| `live.txt` | Live hosts with title, tech, status | httpx |
| `urls-all.txt` | Historical + crawled URLs | gau, waybackurls, katana |
| `endpoints-all.txt` | Endpoints from JS, OpenAPI/Swagger, history | JS grep, spec parsing, `urls-all.txt` |
| `params-per-endpoint.md` | Parameter list per endpoint | historical URLs, Arjun, `param-fuzzer.py` |
| `objects.md` | Object types + ID format + which account owns them | your own test accounts |
| `versions.md` | Stack + exact version per host | headers, JS bundles, lockfiles |
| `inventory.md` | The ranked handoff (see 2.4) | this stage's summary |

## 2.3 What to look for (ranked)

1. **Forgotten / staging subdomains and old API versions.** `dev`,
   `staging`, `test`, `api`, `admin`, `internal`, `beta`, `old`, `legacy`.
   Old hosts run old code with old bugs. An old API version (`/api/v1/`
   while the app uses v2) is a candidate.
2. **Exposed files.** `.env`, `.git/`, backups, Swagger/OpenAPI docs,
   `/graphql`, `/debug`. A 403 on `/admin` is interesting (it exists). A
   200 on `/.env` is a lead — fetch it once, record it, stop.
3. **Endpoints with caller-supplied object IDs.** The single best
   predictor of an IDOR hunt. Hostinger's public spec had 353 paths, 85%
   taking caller-supplied IDs — that inventory became the entire wave-2
   test list. Deriv's `transfer_between_accounts` takes free-form
   `account_from`/`account_to` loginids, and `bulk-purchase/demo` takes
   caller-supplied `{token, account_id}` pairs.
4. **Parameters that only appear in JS or old URLs.** A parameter the UI
   never sends is a candidate for the fuzzing skill.
5. **Error oracles.** Different errors for existing vs non-existing objects
   (404 vs 403 vs 400), different response times, different error text.
   Record both responses, byte counts included. An oracle alone is a lead;
   what it enables is the finding.
6. **Technologies with known CVEs at the exact version found.** Only after
   the version is confirmed on the real code path.

## 2.4 The inventory file (`inventory.md`)

This is the handoff to Stage 3. Write it in the program folder's `recon/`
directory. Format:

```markdown
# Inventory — <Program> — <date>
## Live hosts
- host (stack + version, notes)
## Endpoints (method + auth + notes)
- POST /api/v1/orders — Bearer, caller-supplied order_id
## Parameters per endpoint
- /api/v1/orders: order_id, status, limit
## Objects (type + ID format + owner)
- order: sequential int, owned by account A/B
## Files found
- /openapi.json (200), /.env (404)
## Versions
- app 2.3.1, api 1.9.0
## Oracles
- login: nonexistent id -> 400 "does not exist"; existing id -> password step
## Ranked test order
1. caller-supplied IDs (IDOR candidates)
2. hidden parameters
3. old API versions
4. everything else
## Closed / do not re-test
- (list anything already proven clean, with the wave/date)
```

**Rules for the inventory:**

- Dedupe at every step. `sort -u` or you test the same host five times.
- Never list, read, or export other customers' objects. IDs come from your
  own test accounts and your own responses only.
- A 200 on a wordlist hit means "something is there", not "it is
  vulnerable". Recon findings are leads.
- Filter wildcard DNS and custom 404 pages (200 with the same body for
  every path) or every brute-forced name looks live.
- Re-request historical URLs live. A URL from 2021 may be gone.

## 2.5 Negative results worth keeping

Record clean results with the same care as leads. They stop the next wave
from re-testing the same surface, and they stop a "clean" from being
mistaken for "untested":

- Hostinger wave 1: password-reset enumeration clean (generic message);
  client-side price tampering via the public Billing API structurally
  impossible (no price fields, server-resolved); no unauthenticated data
  exposure anywhere tested; no `wss://` endpoints in analysed JS bundles.
- Deriv wave 1: no unauthenticated call returned account-specific data on
  any surface; the new API is clean from outside (uniform auth errors, no
  existence oracle); P2P lives on classic WS only.
- Slack waves 1–48: the "CLOSED — do not re-test" list in
  `HUNT-SUMMARY.md` (metadata validation map, unfurl dedup rule,
  archived-name reuse, foreign team_id, usergroup writes with a bot token,
  Slack Code on that workspace, MCP/RTS from bot tokens, legacy-attachment
  link fields).

## 2.6 Method quirks (learned the hard way)

These cost real waves. Keep them in mind when a result looks like a denial:

- **Request encoding matters.** On Slack, `pins.list`, `bookmarks.list`,
  `conversations.members`, `files.*`, and `users.*` reads need
  form-encoded bodies — JSON bodies return errors or false denials. Any
  result obtained with the wrong encoding is **untested, not denied**.
  Re-test with the correct encoding before believing a denial. (Slack
  waves: J2 `users.info`, I2 `conversations.list` types filter, CC1
  re-test with form-encoded bodies.)
- **Never trust `ok:true` alone.** Check the `warning` field and read back
  the stored object. Slack metadata: `ok:true` with a warning meant the
  metadata was silently dropped; the real boundary was event_type ≤ 100
  chars, not 166.
- **Run a positive control before trusting a zero-hit result.** Prove the
  measurement works (a known fetch, a known hit) before concluding that
  nothing happened.
- **Record the exact request format that produced each result** (JSON vs
  form-encoded, headers, token used), so the next wave can reproduce it.

## 2.7 Deliverable

`recon/inventory.md` plus the list files in 2.2, all in the program folder.
Testing (Stage 3) works from the inventory and nothing else. If the
inventory is thin, go back to recon — do not start testing on a thin
inventory and hope.
