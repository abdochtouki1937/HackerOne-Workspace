# Stage 5 — Filing, Follow-up, and Close-out

Filing is the last step, not the first. Nothing reaches this stage without
passing the verification gate (`04-verification-gate.md`).

## 5.1 Filing day — re-check before you submit

On filing day, re-run these four checks even if they passed yesterday:

1. **Version re-check.** Confirm the tested version is still the live
   version. A new release can fix the bug or change the affected versions.
   If the audited version is older than the latest release, re-run the
   duplicate check and re-run the PoC on the latest release.
2. **Duplicate re-check.** Search Hacktivity and the advisory list again
   for the same component and root cause. A report filed by someone else
   yesterday is a duplicate today.
3. **Scope re-check.** Re-read the live policy. Confirm the finding is
   still in scope and no new exclusion covers it.
4. **Proof re-run.** Reproduce the PoC from a clean state one more time
   and keep the fresh request/response pairs with the report.

## 5.2 The report (HackerOne format)

Use the templates in `~/workspace/HackerOne-Workspace/03-Templates/`
(`critical.md`, `high.md`, `medium.md`, `low.md`, `informative.md`) and
the guidance in `02-Methodology/report-writing-guide.md`. Every report has:

- **Title.** One line, mechanism first: what breaks, where, and the
  impact. Example (Slack, filed draft): "App can attach a forged link
  preview to another user's message with no domain verification — the
  forged title links to an attacker URL, with no warning shown to the
  reader."
- **Summary.** The chain in 3–5 sentences. What the attacker does, what
  the victim sees, what happens.
- **Severity + CVSS + CWE.** With per-metric justification. The severity
  follows the proved impact, not the scariest reading.
- **Asset.** The exact in-scope asset (api.slack.com, app.slack.com, …).
- **Steps to Reproduce.** Numbered, from a clean state, with the exact
  requests. Include the control (what the honest user sees, what account
  B gets) so triage can reproduce the difference.
- **Proof of Concept.** Request/response pairs, screenshots, and the
  evidence files (in the program folder's `evidence/`). State the proof
  level (live proof).
- **Impact.** Only what was proved. Anything unproved is labelled a
  hypothesis.
- **Remediation.** One concrete fix (validate the domain, check ownership
  on attach, label app-provided previews in the client…).
- **References.** Prior art and how this differs (see Stage 4, section
  4.3). Links to advisories checked.
- **Pre-submission checklist.** All five gates pass; trial-report budget
  checked; no secrets in the report or the evidence files.

**Rules:**

- One report per distinct root cause. Group a second endpoint that shares
  the same root cause into the same report.
- File in the route the program names (HackerOne submit form for
  HackerOne programs; GitHub Private Vulnerability Reporting for
  open-source repos). Do not open a public issue for a private report.
- Never put a secret, token, password, or cookie in the report or the
  evidence. Redact before attaching.
- Never report scanner output verbatim, and never claim an impact you did
  not prove.

## 5.3 The trial-report budget (filing decision)

The user has **only 3 trial reports, shared across all HackerOne
programs** (0 spent as of 2026-11-16). Before submitting, confirm:

- The finding passed all five gates in full.
- The duplicate check is clean, not uncertain.
- The severity is honest and the impact is proved.
- The user has said "file it" for this finding (one report at a time,
  one clear filing question — never file on your own).

If any of those is not true, do not spend the trial report. Wait, test
more, or drop it.

## 5.4 After filing

- **Save the receipt.** Report ID, date, program, severity as filed, in
  the program folder (`notes.md` or the finding file) and in the workspace
  record. Update the trial-report count.
- **Keep the evidence in place.** Do not delete test objects, messages, or
  accounts the report points to until the report is closed. (Slack: the
  YY1 and ZZ1 forged messages were left in victim #social deliberately —
  they cannot be removed via API, and deleting the message itself would
  destroy the evidence.)
- **Answer triage.** Reply to triage questions with the same evidence, in
  short simple sentences. If triage asks for a re-test, re-run the PoC
  from a clean state and report the result — including when the re-test
  fails and the finding is weaker than first thought. Correct the record
  in the same turn.
- **Do not re-file.** If a report is closed as duplicate / informative /
  N/A, do not re-file the same bug. Record the closure reason and what it
  teaches (add it to the kill list in `04-verification-gate.md` if it is a
  pattern).
- **Do not withdraw a filed report** without the user saying so. (GPUStack
  GHSA-4h25: duplicate risk is high, but the report stays — do not
  withdraw.)

## 5.5 Close-out (archive)

When the program is done — all findings filed or dropped, no open leads
worth testing — close it out:

1. Write the outcome in the program folder's `notes.md`: findings filed
   (with report IDs and outcomes), findings dropped (with reasons), leads
   left untested (with why).
2. Move the program folder to `07-Archive/` with a dated name, e.g.
   `07-Archive/Slack-2026-11/`.
3. Record the outcome in the workspace record (bounties, credits,
   duplicates, lessons).
4. Never test an archived program again without moving it back and
   re-verifying the scope and the version first.

## 5.6 Worked example — the Slack filing (pending, 2026-11-16)

- **Finding:** app-unfurl forgery phishing primitive, Medium, CWE-451.
  Chain verified end-to-end in the user's own test workspaces (waves
  43–47 + browser rendering checks). Cross-user escalation (ZZ1) is the
  lead claim. Prior art checked: Push Security research and HackerOne
  #481472 — both real, both different mechanisms; the report leads with
  the cross-user attachment.
- **Draft:** `HACKERONE-DRAFT-unfurl-forge.md`, updated 2026-11-16 19:06
  to lead with the cross-user attachment, with a "Prior art — how this
  differs" section.
- **Filing decision:** user chose "File the Slack bug now" on 2026-11-16
  18:55. He received the filing link (https://hackerone.com/slack), the
  title, severity Medium, asset api.slack.com, and the updated draft.
  **Submission not confirmed** — ask once, when natural, whether he
  submitted it; when he confirms, save the receipt and update the
  trial-report count to 1 of 3 spent.
- **Evidence left in place:** YY1 forged message (ts 1794769274.224049)
  and ZZ1 forge on the human owner's message (ts 1794761122.664239) in
  victim #social — do not delete before filing.
