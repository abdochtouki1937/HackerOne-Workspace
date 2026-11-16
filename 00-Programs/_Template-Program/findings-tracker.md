# Findings Tracker — [Program Name]

One row per finding, from first lead to final outcome. Update this file
every time a finding changes state. It is the single place that answers
"what did we find, what did we file, and what happened to it?"

Copy this file into a program folder when you create it (it lives in
`_Template-Program/` so every new program starts with one). Do not
track findings only in `notes.md` — notes are for leads, this file is
for findings.

## Status values

- `Lead` — seen in recon or testing, not yet reproduced.
- `Confirmed` — reproduced with a saved request/response pair in
  `evidence/`, finding file written in `findings/`.
- `Draft` — report written in `report-draft.md`, pre-submission
  checklist done.
- `Submitted` — filed on HackerOne (record the report ID).
- `Triaged` — accepted as valid by the program.
- `Bounty` — bounty awarded (record the amount).
- `Resolved` — fixed and confirmed fixed.
- `Duplicate` — closed as a duplicate (record the original report ID
  if known).
- `N/A` — closed as not applicable / out of scope / wont-fix (record
  the reason).
- `Dropped` — investigated and closed by you before filing (record
  why: not reproducible, fixed in latest version, out of scope).

## Tracker

| # | Finding | Severity | CWE | Status | Report ID | Bounty | Date found | Date filed | Notes |
| - | ------- | -------- | --- | ------ | --------- | ------ | ---------- | ---------- | ----- |
| 1 | [Short title — link to findings/<name>.md] | Medium | CWE-451 | Submitted | [H1 ID] | — | 2026-11-15 | 2026-11-16 | [one line: what it is] |
| 2 | | | | Lead | | | | | |

## Rules

- One row per finding. Never delete a row — change its status and
  record the reason. A dropped finding is still a record: it stops
  the next hunt from repeating the same work.
- A finding moves to `Confirmed` only when the evidence pair is saved
  in `evidence/` and the finding file exists. A scanner hit stays a
  lead in `notes.md`, not a row here.
- When triage closes a report, update the status and the reason the
  same day. If it was a duplicate, write down what the original
  report covered so the next similar lead gets killed earlier.
- At the end of a program, copy the final table into the archive
  README entry for that program.
