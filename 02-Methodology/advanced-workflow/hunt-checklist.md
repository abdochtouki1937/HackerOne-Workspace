# Hunt Checklist — Advanced Workflow (one page)

Use this from target selection to archive. Check each box as you go. If a
box cannot be checked, stop at that stage — do not carry the gap forward.

## Stage 0 — Ongoing (automation, radar, rhythm — `08-`, `09-`, `10-`)

- [ ] Duplicate Radar run before choosing today's direction (Hacktivity + advisories + public research, date recorded).
- [ ] Release watch checked (`release-watch.sh` on watched repos; a new release means a re-audit, not a filing from the old version).
- [ ] Recon diff run on schedule; new subdomains/endpoints/parameters ranked first.
- [ ] Every automated run logged (INDEX.md); scope gate passed before any live action.
- [ ] Today's work fits the daily rhythm (morning recon, afternoon testing, evening gate).

## Stage 1 — Target selection (`01-target-selection.md`)

- [ ] Program is OPEN, submit button works, no pause notice.
- [ ] No Signal gate, or the user already holds the required Signal.
- [ ] Bounty ranges, response times, and 90-day report volume recorded.
- [ ] Scope read in full and saved in `00-Programs/<Program>/scope.md` (date read).
- [ ] `assets.txt` copied exactly from the policy; scope-check script passes.
- [ ] Exclusions and testing rules noted (test accounts only, required header, etc.).
- [ ] Scope flags recorded (hosts that look in scope but are not in the asset list).
- [ ] Freshness scored: latest release, new features, large attack surface.
- [ ] Testability confirmed: two test accounts obtainable, or demo/sandbox mode exists.
- [ ] Trial-report budget checked (3 shared across all programs; 0 spent as of 2026-11-16).

## Stage 2 — Recon and enumeration (`02-recon-enum.md`)

- [ ] Passive recon done first (subdomains, crt.sh, history, JS, specs).
- [ ] Active recon done slow and rate-limited; stopped on 429 if hit.
- [ ] `recon/inventory.md` written: live hosts, endpoints, parameters, object IDs, versions.
- [ ] Endpoints from JS / OpenAPI / history extracted (not just wordlists).
- [ ] Object IDs listed from your own test accounts only.
- [ ] Versions pinned on the real code path (not the top-level number).
- [ ] Clean results recorded with evidence (not assumed).
- [ ] Inventory ranked: caller-supplied IDs first, then hidden parameters, then old API versions.

## Stage 3 — Testing (`03-testing-playbook.md`)

- [ ] Baseline captured for every endpoint tested.
- [ ] One variable changed per request.
- [ ] Every test run as A and as B (one actor is half a finding).
- [ ] Correct request format used (JSON vs form-encoded — a wrong-encoding denial is untested).
- [ ] Test families run in priority order: auth/session, IDOR/authz, business logic, input handling, client rendering, API-specific.
- [ ] The playbook for the class was read before testing it (`07-vuln-playbooks.md`).
- [ ] Auth matrix drawn before testing auth/IDOR/OAuth (role, tenant, ownership, auth-state coverage).
- [ ] Sibling hunt done within 20 minutes of any confirmed bug (same handler, same parameter names).
- [ ] Every anomaly re-checked by hand before it becomes a lead.
- [ ] Boundaries pinned by bisection with the exact number recorded.
- [ ] Chains written as numbered steps, each with its own PoC.
- [ ] No credentials/tokens/OTPs brute-forced; no destructive action with live values.
- [ ] All request/response pairs saved in `evidence/` with token and encoding noted.

## Stage 4 — Verification gate (`04-verification-gate.md`) — all five must pass

- [ ] Gate 1 — In scope: live policy re-read, not in an excluded class, no open scope flag.
- [ ] Gate 2 — Live-proved: reproduced from a clean state, A and B pairs saved, browser check done if client-rendered.
- [ ] Gate 3 — Latest version: re-checked on filing day, bug present in the latest release.
- [ ] Gate 4 — Not a duplicate: Hacktivity + advisories + public research checked, prior art distinguished, what is new is named.
- [ ] Gate 5 — Honest severity: impact is only what was proved; proof level stated; claimed thing itself tested.
- [ ] Control tests run: outside-window control (timing), clean-state control, positive control, other-actor control.
- [ ] Kill list checked (G1, V-03, AiSOC overclaim, Vercel H7, Kyverno F2/F5, V-01, and the Slack closed list).
- [ ] 7-Question Gate passed first (Q1: the attack is a real HTTP request, written out; one wrong answer kills the lead).
- [ ] Second pair of eyes: the gate was run by someone (or a role) other than the finder; PoC re-run from the saved request.
- [ ] Evidence packaged (strict): PoC as copy-paste text, A and B pairs, browser check if client-rendered, version re-check, duplicate-check record, severity justification, no secrets.
- [ ] 60-second triage test passed: a stranger can answer in-scope, reproducible, impact, new in 60 seconds.
- [ ] Timed pre-submission gates passed (Gate 0 reality 30s, Gate 1 impact 2m, Gate 2 dedup 5m, Gate 3 quality 10m).
- [ ] Gate outcome recorded: file / back to testing (missing piece named) / dropped (reason named).

## Stage 5 — Filing (`05-filing.md`)

- [ ] Filing-day re-checks done: version, duplicate, scope, proof re-run.
- [ ] Report written from the proof (HackerOne format, template used).
- [ ] Severity + CVSS + CWE with per-metric justification.
- [ ] Prior-art section names what is new.
- [ ] No secrets in the report or the evidence.
- [ ] One report per distinct root cause; same-root-cause endpoints grouped.
- [ ] User said "file it" for this finding.
- [ ] Trial-report budget confirmed before submitting.
- [ ] Receipt saved (report ID, date, severity as filed); trial count updated.
- [ ] Evidence left in place until the report is closed.
- [ ] Triage questions answered; closure reason recorded if closed.
- [ ] Program folder archived in `07-Archive/` with the outcome recorded.

## Weekly rhythm (`10-daily-weekly-rhythm.md`)

- [ ] Monday intake done (target picked, scope saved, accounts ready).
- [ ] Tuesday–Thursday hunting done (wave 1, wave 2, wave 3+ deepening).
- [ ] Friday filing day done (full gate, filing-day re-checks, receipts saved, trial count updated).
- [ ] Weekend review done (filed / confirmed-not-filed / died / best lead / learned / next target).
- [ ] One learning block done (one TBHM chapter, one PortSwigger lab, or one disclosed report — pattern added to the playbooks or the kill list).
