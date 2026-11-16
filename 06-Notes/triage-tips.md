# Triage Tips

How triagers think, and how to avoid the common closures.

## What triagers do first

1. Read the title and summary. If the bug is not clear in 30 seconds,
   the report starts at a disadvantage.
2. Reproduce the PoC. If the steps do not reproduce from a clean
   state, the report is closed as "not reproducible" — no matter how
   good the theory is.
3. Check scope. If the asset is not in scope, or the vulnerability
   class is excluded, the report is closed as out of scope / N/A.
4. Check duplicates. If the same root cause was already reported, the
   report is closed as duplicate — even if your PoC is better.
5. Set severity from the demonstrated impact, not from the
   vulnerability class. An XSS that needs an admin to click a link in
   a test workspace is not the same severity as a stored XSS on every
   user's dashboard.

## The most common closures (and how to avoid them)

- **Duplicate.** Search Hacktivity and public advisories before
  filing. If a public report or research covers the same surface, lead
  with exactly what is new in your finding.
- **N/A — no working PoC.** A theoretical vulnerability, a scanner
  screenshot, or a code reading with no live reproduction is closed.
  Always include the exact request and response.
- **N/A — own account only.** For cross-tenant programs, an issue
  that affects only your own account is not a finding. Prove the
  cross-account effect (A vs B) or do not file.
- **Informative / wont-fix.** User enumeration, missing headers, and
  informational issues are usually closed this way. Rank them honestly
  and do not let them crowd out stronger leads.
- **Working as intended.** A feature behaving as designed, even if it
  looks odd, is closed. Read the docs and the program's known
  behaviours before filing a timing, queue, or lock-window finding —
  and always run the outside-window control.
- **Severity disputed.** Justify each CVSS metric in one line. The
  most common dispute is Scope (Changed vs Unchanged) and Privileges
  Required. If the impact needs a precondition (malicious app
  installed, victim click), say so plainly — triagers downgrade
  silently when they discover it themselves.

## What gets paid

- Novel, PoC-proven vectors. Duplicate pressure is high on popular
  programs (hundreds of reports in 90 days) — only the new mechanism
  wins.
- Cross-tenant and cross-user impact. A bug that affects another
  tenant or another user is worth more than one that affects only
  your own account.
- Clear impact. A report that says exactly who is affected and what
  an attacker gains is triaged faster and paid higher.
- One report per root cause. Grouping same-root-cause endpoints into
  one report is preferred; splitting them into five reports is not.

## After a closure

- Record the reason in the finding file and move on. Do not re-file
  the same root cause.
- If triage asks a question, answer with a fresh PoC, not with
  argument.
- A duplicate closure still teaches you the program's blind spots —
  note what was already known in `notes.md`.
