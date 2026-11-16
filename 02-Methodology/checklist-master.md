# Checklist Master — HackerOne Hunting Workflow

The full flow, from choosing a program to filing a report. Work the
checklist in order. Skip a step only when you can say why it does not
apply, and write the reason in the program's `notes.md`.

## Standing rules (apply to every step)

- **Scope first.** Read the live HackerOne policy before touching the
  target. Copy scope, rules, and bounty ranges into `scope.md`.
- **Choose targets by "can we find a REAL, verifiable bug?"** — not by
  money, not by CVE prestige. Fresh code (< 3 months old), new features,
  and large attack surfaces score highest.
- **Always audit the LATEST release** and re-check the version on
  filing day. A bug fixed in the latest version is dead.
- **Every finding needs a live proof** — a reproducible request/response
  pair saved in `evidence/`. Theoretical vulnerabilities do not file.
- **Test accounts only (A vs B).** Never use real users' accounts or
  data. Differential testing is the minimum: the same action as two
  different actors, compared.
- **Never brute-force credentials, tokens, OTPs, or passwords.**
- **Rate-limit everything.** Stop on HTTP 429 or a spike of 5xx.
- **Honest severity.** Claim only the impact you proved. Never overclaim.
- **Check duplicates** in HackerOne Hacktivity and public advisories
  before filing.
- **One report per distinct root cause.** Group same-root-cause
  endpoints into one report.
- **No secrets in this workspace.** No tokens, passwords, or cookies in
  any file.

## Phase 1 — Choose and scope (30–60 minutes)

- [ ] Pick a program from the live program list. Prefer fresh targets
      with a large attack surface over big, mature companies.
- [ ] Score it with the target-assessment checklist (freshness, attack
      surface, bounty range, response time, duplicate pressure).
- [ ] **Duplicate Radar (before you invest time).** Before choosing
      a test direction, search HackerOne Hacktivity and disclosed
      reports for the program name, asset, endpoint, method, CWE, and
      distinctive field names, plus `site:hackerone.com/reports
      <program> <endpoint> <CWE>`. If the direction is already
      mined out, pick another one first. (Borrowed from
      naliazheli/agent-workspace.)
- [ ] Copy the program: `cp -r 00-Programs/_Template-Program
      00-Programs/<Name>`.
- [ ] Fill in `scope.md` from the live HackerOne policy: program URL,
      policy last-updated date, bounty ranges, in-scope assets table,
      out-of-scope list, excluded vulnerability types, special rules.
- [ ] Fill in `assets.txt` — one asset per line, in sync with scope.md.
- [ ] Record any required research header (name only, never a value).
- [ ] Run the scope check: `01-Recon/scripts/scope-check.sh
      00-Programs/<Name> <target>` — it must say "Scope OK" before any
      scan.
- [ ] Create test accounts A and B (and a second test workspace / org
      where the program needs one). Record only that they exist, never
      their credentials.

## Phase 2 — Recon (half a day)

See `recon-checklist.md` for the full steps. In short:

- [ ] Subdomain enumeration (passive first: subfinder, assetfinder,
      crt.sh; active second, slow).
- [ ] Live host detection (httpx: title, tech, status).
- [ ] Historical URLs (gau, waybackurls) — keep the parameter list.
- [ ] JS file analysis (katana) — hidden endpoints and secrets.
- [ ] Port scanning, only where the scope allows it.
- [ ] Content discovery (ffuf / gobuster, rate-limited).
- [ ] Technology fingerprinting — record the EXACT stack and version.
- [ ] Automated scan (nuclei) — a hit is a lead, not a bug.
- [ ] Write the ranked lead list into `notes.md` and save every output
      file in `recon/`, named by date and step.
- [ ] **Keep a recon index.** Write one `INDEX.md` in the recon folder
      listing every output file with its line count and what it holds,
      so the run is queryable instead of a pile of text files.
      (Gunnar Andrews, DEF CON 32: move off flat text files.) The
      `recon-run.sh` script writes this index automatically.

## Phase 3 — Enumeration

See the enumeration skill. In short:

- [ ] Endpoints: from JS, OpenAPI/Swagger docs, and historical URLs.
- [ ] Parameters: per endpoint (Arjun, param-fuzzer.py, JS).
- [ ] Object IDs: list every object type and its ID format; enumerate
      from YOUR OWN objects only.
- [ ] Users / existence oracles: compare the error for a real vs a fake
      identifier (both branches, byte counts).
- [ ] Files and versions: robots.txt, .well-known, .env, .git, Swagger,
      openapi.json — one request each, record the response, stop there.
- [ ] Write `inventory.md` in the program folder: what exists, ranked
      for testing (caller-supplied IDs first).

## Phase 4 — Manual testing

- [ ] Pick the top-ranked lead. Read the feature first: what it should
      do, who may do it, which states the object can be in.
- [ ] Trace the data flow: input → validation → storage → output.
- [ ] Map the trust boundaries: where is auth checked, where is
      authorisation checked, what lives only in the client?
- [ ] State the invariant in one sentence, then design the smallest
      test that would break it.
- [ ] Test as account A, then as account B, and compare both responses.
- [ ] Test the web UI, the raw API, and the mobile API — a check that
      exists in only one of them is not a check.
- [ ] Test outside any vendor lock window (for timing/queue behaviour,
      always run the outside-window control).
- [ ] Fuzz the boundary: pin exact limits by bisection (max length,
      max count, max depth), do not guess them.
- [ ] For every anomaly: re-run by hand, compare with the baseline,
      check scope and version, check A vs B.
- [ ] Record tested-and-closed leads in `notes.md` with the date and
      the reason, so nobody repeats the work.

## Phase 5 — Confirm the finding

- [ ] **Kill weak findings fast (7-question gate).** Before spending
      more than 30 seconds on a lead, ask: is it in scope? Is it on
      the latest version? Can an attacker do this RIGHT NOW? Is the
      impact real, not theoretical? Is there a PoC? Would triage
      accept it, or is it on the always-rejected list? If any answer
      is no, kill it and record why in `notes.md`. (Borrowed from
      federicopinan/ai-bug-bounty-hunter and
      shuvonsec/claude-bug-bounty.)
- [ ] Reproduce from a clean state: fresh login, fresh object, same
      steps.
- [ ] Save the exact request/response pairs in `evidence/`, named
      `YYYY-MM-DD-short-name.ext`.
- [ ] Verify the claimed thing itself (not its neighbour): the field is
      actually read, the check is actually on this path, the version is
      the latest.
- [ ] Verify the privilege actually required and whether the claimed
      target role is reachable through this path.
- [ ] Check the vendor docs for a known quirk before presenting a
      timing/queue finding as fileable.
- [ ] Write the root cause in one paragraph. If you cannot, you do not
      understand the bug yet — go back to Phase 4.
- [ ] Write the finding file in `findings/` using
      `finding-template.md` (severity, CVSS with per-metric
      justification, CWE, asset, steps, PoC, impact, remediation).
- [ ] Chain small issues only when each step has its own PoC.
- [ ] **Sibling rule + A-to-B signal (20 minutes, before the report).**
      A confirmed bug means the developer made the same mistake
      elsewhere. Spend up to 20 minutes checking every variant of the
      same endpoint and the same pattern on sibling endpoints, then
      write the report. Do not file first and hunt variants later —
      the variant is often the bigger finding, and someone else will
      file it. (Borrowed from federicopinan/ai-bug-bounty-hunter
      rules #10 and #11.)

## Phase 6 — Duplicate check and reporting

- [ ] Search HackerOne Hacktivity for this program and issue class.
- [ ] Search public advisories (GitHub Security Advisories, CVE
      databases) for the same root cause.
- [ ] Write the report from the matching template in `03-Templates/`.
      See `report-writing-guide.md`.
- [ ] **Keep the report under 600 words.** Triagers skim. If the
      report needs more words, the PoC is not clear enough — rewrite
      the reproduction steps, do not add explanation. (Borrowed from
      federicopinan/ai-bug-bounty-hunter reporting rules.)
- [ ] Severity is honest: only the impact proved is claimed. No
      "could lead to RCE" without a working chain.
- [ ] Pre-submission checklist in `report-draft.md` is fully ticked.
- [ ] Submit on HackerOne. Record the report ID, date, and status in
      `scope.md` and in the finding file.
- [ ] Do not delete evidence until the report is resolved or closed.
- [ ] If triage asks a question, answer with a fresh PoC, not with
      argument. If the report is closed as duplicate or N/A, record the
      reason in the finding file and move on.

## Phase 7 — Close out

- [ ] When the program is finished, paused, or all reports are
      resolved, move its folder to `07-Archive/` and note the date and
      outcome in the archive README.
- [ ] Write one line in `06-Notes/` if the program taught a reusable
      technique (a bypass, an oracle pattern, a triage behaviour).
