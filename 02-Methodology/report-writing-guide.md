# Report Writing Guide

How to write a HackerOne report a triager can accept fast. A good report
is short, specific, and provable. Triagers read hundreds of reports;
yours must make the bug obvious in the first 30 seconds. Write it so
the triager can reproduce the bug without asking you a question — a
report that needs a clarifying question loses days (DEF CON 34,
"Eating Our Own Dogfood": the triage-engineering loop runs in hours
only when triage and engineering share one complete thread of
context). Keep the whole report under 600 words; triagers skim.

## The title formula

`[Vulnerable function] + [what an attacker can do] + [impact]`

Good: "App can attach a forged link preview to another user's message
with no domain verification — the forged title links to an attacker URL"

Bad: "Security issue in the app", "XSS vulnerability", "Bug in API".

- Name the exact function or endpoint.
- Name the impact in the title, not just the vulnerability class.
- One finding per title. If the title needs "and", it is two reports.

## Structure (use the template in 03-Templates/)

1. **Summary** — 2–3 sentences: what the bug is, who can exploit it,
   what they gain. A triager who reads only this must understand the
   finding.
2. **Severity + CVSS + CWE** — severity with a CVSS score and vector,
   and the CWE. Justify each CVSS metric in one line (attack vector,
   complexity, privileges, user interaction, scope, confidentiality,
   integrity, availability). Justifying the metrics pre-empts the most
   common cause of re-triage: disputed severity. It also stops you
   inflating the score by accident.
3. **Asset** — the exact in-scope asset (domain, URL, app, version).
4. **Steps to Reproduce** — numbered, exact, reproducible from a clean
   state. Include prerequisites (test accounts, setup). End with
   "Expected result" and "Actual result".
5. **Proof of Concept** — the exact requests and responses. No
   paraphrase, no "then I did something similar". Attach screenshots
   or recordings only as support for the text PoC, never as a
   replacement for it.
6. **Impact** — only what you proved. State the precondition, who is
   affected, and the concrete consequence. If the impact needs a
   precondition (a malicious app installed, a victim clicking a link),
   say so plainly.
7. **Remediation** — a concrete fix and how to verify it.
8. **References** — prior art and how this finding differs, public
   research, CVE/advisory if one exists.

## Severity: be honest

- Claim only the impact you demonstrated. "Could lead to RCE" without
  a working chain is a hypothesis — label it as one, or leave it out.
- A finding that needs a malicious app installed, a victim's click, or
  an admin's mistake is lower severity than one that needs none of
  those. Say the precondition in the impact section.
- When your own live check contradicts your first reading, correct the
  severity, the report, and the filing order in the same turn. Never
  file the old draft.
- User enumeration, missing headers, and informational issues are
  usually Low or Informative, and often closed as wont-fix. Say so in
  the report instead of inflating them.

## What NOT to include

- Scanner output pasted verbatim (nuclei, Burp, ffuf). A scanner hit
  is a lead; the report needs your manual reproduction.
- Unproven impact claims ("an attacker could take over the server").
- Credentials, tokens, session cookies, or passwords — redact them.
- Real users' data. Test accounts only.
- Screenshots as the only proof. The text PoC is the proof; a
  screenshot is support.
- Multiple root causes in one report. One report per distinct root
  cause; group same-root-cause endpoints into one report.

## Prior art and duplicates

- Before filing, search HackerOne Hacktivity for the program and the
  issue class, and search public advisories for the same root cause.
- If a public report or research exists on the same surface, add a
  "Prior art — how this differs" section naming it and stating exactly
  what is new in your finding (new mechanism, new precondition removed,
  new target such as cross-user attachment). This stops duplicate
  closures.
- If the finding is not a 0-day on the full surface, say so honestly
  and lead with the novel part.

## After submission

- Record the report ID, date, and status in `scope.md` and in the
  finding file.
- Do not delete evidence until the report is resolved or closed.
- If triage asks a question, answer with a fresh PoC, not with
  argument.
- If the report is closed as duplicate or N/A, record the reason in
  the finding file and move on. Do not re-file the same root cause.
