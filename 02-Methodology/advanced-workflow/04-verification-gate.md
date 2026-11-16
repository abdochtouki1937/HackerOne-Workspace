# Stage 4 — The Verification Gate

This is the core of the workflow. **Nothing is called a bug, ranked, or
filed until it passes this gate.** A finding that fails the gate goes back
to testing or is dropped — never filed.

The gate exists because the user's history shows the cost of skipping it:
a Critical claim corrected to Low by a live check (AiSOC), a "confirmed"
finding that was a documented product quirk (Slack G1), a report that died
because the bug was fixed on the latest main (Vercel H7), and a trial
report that would have been burned on each of them. The user has only 3
trial reports, shared across all HackerOne programs. The gate protects them.

## 4.1 The five gates (all must pass)

### Gate 1 — In scope

- [ ] The bug is on an asset the **live** HackerOne policy names as in
  scope (re-read the policy on filing day, not from memory).
- [ ] The finding is not in an excluded class (self-XSS, missing headers
  alone, enumeration alone, theoretical vuln without a PoC, and any other
  exclusion the policy names).
- [ ] No scope flag is open on the host (e.g. Hostinger's
  auth/access/cart.hostinger.com, Deriv's home.deriv.com — both needed a
  ruling first).
- [ ] The test stayed inside the program's rules (test accounts only, no
  DoS, no brute force, required header present on every request).

### Gate 2 — Live-proved

- [ ] Reproduced **from a clean state**: fresh login, fresh object, same
  steps, same result.
- [ ] Request/response pairs saved in the program folder's `evidence/`,
  for **both** accounts A and B where the finding is an access-control
  issue. A single-actor proof is half a proof.
- [ ] The proof is on the **live target**, not only in code and not only
  in a local lab. Code-only and local-proof are proof levels — state them
  as such, never present them as confirmed.
- [ ] The exact request format is recorded (JSON vs form-encoded, headers,
  token used) so anyone can reproduce it.
- [ ] For a client-rendering finding, a browser rendering check proves
  what the user sees (screenshot + page state), with a genuine control
  side by side.

### Gate 3 — Latest version

- [ ] The tested version is still the live version **on filing day**.
  Re-check: a new release can fix the bug or change the affected versions.
- [ ] For open-source targets, the bug is present in the **latest release**
  (not only in the audited older version). A bug fixed in the latest
  version is dead — do not file it.
- [ ] If the audited version is older than the latest release, re-run the
  duplicate check and re-run the PoC on the latest release.
- [ ] The affected versions in the report match the re-check, not the
  first audit.

### Gate 4 — Not a duplicate

- [ ] HackerOne Hacktivity searched for the same program + component.
- [ ] Published advisories searched for the same component and the same
  root cause (not only for a CVE identifier). A published GHSA with no CVE
  is a duplicate match when it describes the same root cause and the same
  affected versions. Record the advisory identifiers checked and the date.
- [ ] Public research searched (write-ups, blog posts, prior art). If
  prior art exists, the report names **exactly what is new** here.
- [ ] A second agent (or a second search with different words) repeated
  the advisory search when the first found nothing — advisory titles
  rarely use your wording.
- [ ] If an advisory is close but not clearly the same bug, the user was
  asked before filing.

### Gate 5 — Honest severity

- [ ] The impact is **only what was proved**. Anything unproved is
  labelled a hypothesis, not stated as impact.
- [ ] No unproven escalation ("could lead to RCE" without a working chain).
- [ ] No inflated rating. The severity follows the proved impact and the
  program's own examples, not the scariest possible reading.
- [ ] The proof level is stated for every finding: code-only, local proof,
  or live proof. Never present a code-only finding as confirmed.
- [ ] The claimed thing itself was tested, not its neighbour:
  - Is the credential field actually read and required? (A field that
    returns an error when omitted and stores a hash when present is not
    ignored.)
  - Does each provisioning path store a **usable** credential or an
    **unusable marker**? (A marker that cannot log in does not create an
    account takeover.)
  - Which privilege does the endpoint actually require, and can the
    claimed target role be reached through that path? (A tenant-admin-only
    path with no escalation to admin is not an email-only takeover.)
  - Is the secret value still present in the runtime environment on the
    latest version, or did a fix commit replace the whole mechanism? (A
    replaced mechanism means the leak is dead even when the surrounding
    lines remain.)

## 4.2 The control tests (run these before you believe a finding)

### The outside-window control (timing / queue findings)

A test inside a vendor lock window cannot tell a bug from normal
behaviour. Always run a control **outside** the near-term window:

- Schedule 10 minutes ahead and delete at once; then schedule 60 seconds
  ahead and delete at once. Compare.
- Check the vendor docs and public discussion for a known quirk before
  presenting a timing finding as fileable.
- Do not say you are sure a timing finding is real until the
  outside-window control AND the docs check both pass. Mark the draft
  "do not file" when either one fails.

**The Slack G1 case (2026-11-15):** `chat.deleteScheduledMessage`
returned ok while the message still delivered — reproduced 5/5 in 90–150 s
windows, and it looked like a confirmed finding. It was a publicly known
product quirk: Slack pre-fetches messages ~1–5 min before send, and the
documented delete limit is 60 s. A public test (slack.green, Sep 30 2026)
had already tested exactly this. Decisive 10-minute tests (API + web UI)
both confirmed the cancel works outside the window. The draft is marked
DO NOT FILE. Filing it would have burned 1 of 3 trial reports.

### The clean-state control

Reproduce from a clean state: fresh login, fresh object, same steps. If
the bug only reproduces on a stale object, a cached response, or a
half-configured account, it is not a finding yet.

### The positive control

Before trusting a negative result (zero hits, no fetch, no leak), run a
positive control that proves the measurement works — a known fetch, a
known hit, a known leak. Slack wave 44: claiming a domain suppressed the
automatic unfurl fetch for that domain, so a zero-hit result on the claimed
domain meant nothing until the is.gd control proved the fetcher was alive.

### The other-actor control

Run the same action as the other account (A vs B) and as an unauthenticated
caller. A finding that only reproduces as the owner, or only with a token
that already has the right, is not an access-control finding.

## 4.3 Prior-art comparison (what is new vs known)

When the surface is known, the report must name exactly what is new.
The Slack unfurl case is the model:

- **Known:** Push Security's published research (link-preview spoofing via
  serving different content to Slackbot-LinkExpanding vs humans — needs an
  attacker web server, preview generated by Slack's own crawl) and
  HackerOne report #481472 "URL link spoofing" ($250, ~356 upvotes, 2020 —
  spoofing a link's destination inside the attacker's own message).
- **New here:** (a) no web server needed — preview injected directly via
  the `chat.unfurl` API, bypassing Slack's crawler; (b) `title_link`
  fully attacker-controlled with no hover warning; (c) attaching to
  ANOTHER user's message — not in any prior art found, the strongest novel
  claim. The report leads with (c).
- **Rule:** file leading with the novel part. If there is no novel part,
  it is a duplicate — do not file.

## 4.4 The kill list (dead patterns — do not file, do not re-test without new evidence)

| Pattern | Why it is dead | Source |
|---|---|---|
| Slack G1 — scheduled-message delete still delivers | Documented 60 s lock window + public pre-fetch quirk; 10-min control proves cancel works | Slack hunt, waves 4/11, 2026-11-15 |
| Vikunja V-03 | Proven NOT a bug — the fan-out gate existed in 2.7.1 too | Vikunja 2.8.0 hunt, 2026-11-11 |
| AiSOC E-01 as Critical | Overclaim corrected by a live check to a LOW password-policy bug (CVSS ~3.8) | AiSOC, 2026-11-12; published as GHSA-xh3r-vqgc-cv78 (Low) |
| Vercel H7 / bridge-token leak | Fixed on latest main — token auth replaced by per-session Ed25519 challenge-response; `BRIDGE_CHANNEL_TOKEN` has zero occurrences in source | Vercel, 2026-11-15 |
| Kyverno F2 | Verification safety-stopped; unverified — do not retry | Kyverno, 2026-11-11 |
| Kyverno F5 | Exact duplicate of public issue #17633 | Kyverno, 2026-11-11 |
| Vikunja V-01 | Duplicate of GHSA-hjx8 (2026-10-03) | Vikunja, 2026-11-11 |
| GPUStack GHSA-4h25 chain as filed | Fixed in v2.3.0; affected ≤2.2.3; duplicate risk vs GHSA-3r33 is high | GPUStack, filed 2026-11-10 |
| Slack C2 / rich_text `javascript:` links | Dead in the web client (plain text / `about:blank` / broken image) | Slack hunt, waves 2/21 |
| Slack metadata edge values, unfurl dedup variants, archived-name reuse, foreign team_id, usergroup writes with a bot token, Slack Code on that workspace, MCP/RTS from bot tokens | Maps complete / gates closed — re-testing wastes waves | Slack hunt, waves 25–48 |

## 4.5 Gate outcome

- **Pass all five gates:** the finding moves to Stage 5 (filing). Write
  the report from the proof, not from the theory.
- **Fail any gate:** the finding goes back to Stage 3 (testing) with a
  named missing piece, or it is dropped and recorded in `notes.md` with
  the reason. **Never file a finding that failed the gate.** A dropped
  finding is not wasted work — it is a trial report saved.
- **Uncertain:** ask the user. When the user is sure about something,
  share it with him to read and confirm — do not just act on it alone.
  When he asks "are you sure this is a valid bug", answer with the exact
  confidence and the honest limits.

## 4.6 Deliverable

For each claimed finding, a `findings/<name>.md` file in the program
folder with:

- The five gates, each marked pass/fail with the evidence (links to PoC
  files, advisory IDs checked, date of the version re-check).
- The proof level (code-only / local proof / live proof).
- The severity with per-metric justification, and the impact limited to
  what was proved.
- The prior-art comparison (what is new).
- The control tests run and their results.
- The filing decision: file / back to testing (with the missing piece) /
  dropped (with the reason).

## 4.7 The 7-Question Gate (run this first — fast pre-check)

Borrowed from shuvonsec/claude-bug-bounty
(https://github.com/shuvonsec/claude-bug-bounty). This gate is
numbered last only so the existing section references above stay
valid — in time, it runs **before** the five gates, on every lead.
Ask in order. One wrong answer = stop, kill the lead, move on.

1. **Q1 — Can an attacker use this RIGHT NOW, step by step?**
   Write the attack as five lines: setup (what account you need),
   request (exact method, URL, headers, body — copy-paste ready),
   result (what exact data/action the response shows), impact (the
   real-world consequence), cost (time, money). **If you cannot write
   the request as a real HTTP request, kill it.** A theory is not a
   lead.
2. **Q2 — Is the impact on the program's accepted impact list?**
   Check the program page. If the class is excluded or the impact is
   not on the accepted list, kill it.
3. **Q3 — Is the root cause in an in-scope asset?** The asset that
   holds the bug, not the asset that holds the link to it.
4. **Q4 — Does it require privileged access an attacker cannot
   realistically get?** Admin, another tenant's admin, an internal
   service — with no path to that privilege. If yes, kill it (or
   chain it — see 4.8).
5. **Q5 — Is this already known or accepted behaviour?** Disclosed
   reports (search the endpoint name + bug class), the program's
   docs, public research. If it is known, kill it.
6. **Q6 — Can you prove impact beyond technical possibility?**
   "The server returns an error" is not impact. "Account B's data is
   in account A's response" is impact. If the impact is only
   theoretical, kill it.
7. **Q7 — Is this a known-invalid bug class?** Missing CSP/headers
   alone, GraphQL introspection alone, open redirect alone, self-XSS,
   version disclosure alone. On the always-rejected list without a
   chain = kill it.

The rule that comes with the gate: **"N/A hurts your validity ratio.
Informative is neutral. Only submit what passes all 7 questions."**
With only 3 trial reports, the ratio is the asset.

## 4.8 Second pair of eyes (verifier ≠ hunter)

Borrowed from sricharan996/hydra
(https://github.com/sricharan996/hydra): the agent that finds a bug
is not the agent that confirms it. The separation exists because the
finder is invested in the finding and stops seeing its weaknesses.

- **With agents:** the verification gate is run by the coordinator
  or by a different agent — never by the agent that found the lead
  (`06-agent-runbook.md`, section 6.1 already says this; this is the
  reason why).
- **Solo:** the "second pair of eyes" is a role, not a person. Re-run
  the PoC from a clean state as if you had never seen the finding,
  then read your own report as triage would — the 60-second test
  (Hacker101): can a stranger answer, in 60 seconds, is it in scope,
  can I reproduce it, what can an attacker do, and is it new? If any
  answer needs a clarifying question, the report is not ready.
  Source: https://www.hacker101.com/resources/articles/writing_a_report_and_cvss
- **The peer-review checklist:** someone (or you, in the reviewer
  role) checks the five gates independently, re-runs the PoC from the
  saved request (not from your notes), and signs the finding file
  with the date. No signature, no filing.

## 4.9 Evidence packaging (strict builder)

Borrowed from federicopinan/ai-bug-bounty-hunter's evidence vault
(https://github.com/federicopinan/ai-bug-bounty-hunter) and
ametel01/ametel-skills (https://github.com/ametel01/ametel-skills):
package the artifacts with the report, at the same time as the
report, not after — and refuse to generate a report when required
pieces are missing.

For each finding, the evidence vault (the program folder's
`evidence/` + the finding file) must contain, before filing:

- [ ] The minimal PoC request and response as **text** (copy-paste),
  not only as a screenshot. Hacker101's rule: triage must be able to
  copy and paste the reproduction steps. Screenshots support the
  text; they never replace it.
- [ ] The A and B request/response pairs (for access-control findings).
- [ ] The browser rendering check (for client-rendered findings):
  genuine control side by side with the forged one.
- [ ] The version re-check (date + version under test).
- [ ] The duplicate-check record (Hacktivity + advisories + public
  research searched, with the date and the identifiers checked).
- [ ] The severity justification (CVSS per metric + impact limited
  to what was proved).
- [ ] No secrets anywhere in the vault (no tokens, passwords, cookies
  — redacted before attaching).

**The strict rule:** if any box above is empty, the report is not
generated and not filed. A missing piece is a reason to test more,
not a reason to file anyway. (The ai-bug-bounty-hunter builder fails
with `--strict` when required metadata, reproduction steps, or
evidence files are missing — same discipline, applied by hand here.)

## 4.10 Timed pre-submission gates (last check before filing)

Borrowed from claude-bug-bounty (`validate.py`):
run in sequence, all four must pass, timed so they actually happen.

| Gate | Time | What it checks |
|---|---|---|
| Gate 0 — Reality Check | 30 seconds | The PoC still reproduces right now, from a clean state. |
| Gate 1 — Impact Validation | 2 minutes | The impact is proved and written in one sentence, with the evidence file named. |
| Gate 2 — Dedup | 5 minutes | Hacktivity + advisories searched again today (a report filed yesterday is a duplicate today). |
| Gate 3 — Quality | 10 minutes | Title follows the formula `[Bug Class] in [Endpoint] allows [role] to [impact]`; report under 600 words; steps copy-paste; no secrets. |

If any gate fails, stop. Fix the gap or drop the finding. The gates
are timed because an untimed check is a skipped check.
