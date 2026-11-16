# Stage 3 Deepening — Vulnerability Playbooks

One playbook per high-yield class. Each playbook answers the same four
questions: **when to try it** (trigger conditions), **the exact test**
(A vs B, one variable at a time), **what is not a bug** (false positives),
and **what proof looks like** (the PoC bar). Read the playbook for the
class before you test it — do not spray payloads and hope.

These playbooks sit on top of Stage 3 (`03-testing-playbook.md`). The
testing rules there still apply to every class: baseline first, one
variable at a time, test accounts A vs B only, rate-limit, stop on 429,
log everything.

Class order is by yield on HackerOne-style targets, not by severity.
NahamSec's 2025 earnings breakdown put SSRF at ~25% of bounties and XSS
at ~18% — but on API-heavy targets in this workspace's own hunts, IDOR
and authz produced the most ranked leads (Hostinger: 353-path spec, 85%
caller-supplied IDs; Deriv: B-L1, D-T1, E-L2). Start with the class the
inventory points at, not the class you like most.

Sources for the class techniques: The Bug Hunters Methodology (TBHM) by
Jason Haddix — https://github.com/jhaddix/tbhm (class files 04–09, 12);
PortSwigger Web Security Academy — https://portswigger.net/web-security;
PayloadsAllTheThings — https://github.com/swisskyrepo/PayloadsAllTheThings.

---

## Playbook index

The per-class content lives in the individual files under
`vuln-playbooks/` — this file is the index only.

| # | Playbook | One line |
| --- | -------- | -------- |
| 1 | [IDOR / BOLA](vuln-playbooks/idor.md) | Caller-supplied object ID reaches another user's object — read, update, delete, share, transfer. |
| 2 | [SSRF](vuln-playbooks/ssrf.md) | The server fetches a caller-supplied URL — prove the fetch out-of-band, then reach a private address. |
| 3 | [XSS — Stored, Reflected, DOM](vuln-playbooks/xss.md) | Attacker input renders unescaped for another victim — check every render context, including the client-rendering gap. |
| 4 | [SQL Injection](vuln-playbooks/sqli.md) | A parameter reaches a database query — prove it with a boolean or time probe on your own data only. |
| 5 | [Authentication and Session Flaws](vuln-playbooks/auth-session.md) | Sessions, tokens, OTP/2FA, and custom auth that survive the change that should kill them, or accept edge values. |
| 6 | [Business Logic and Money-Moving Calls](vuln-playbooks/business-logic.md) | Amounts, trials, state machines, and limits the server trusts the client on — read the ledger, not the response. |
| 7 | [API Mass Assignment](vuln-playbooks/mass-assignment.md) | The server binds model fields the UI never sends — one extra field per request, read-back is the test. |
| 8 | [OAuth and OpenID Confusion](vuln-playbooks/oauth.md) | Confused issuer/audience, unverified-email fallback, code reuse, lax redirect URIs — login as the victim identity. |
| 9 | [File Upload and Path Traversal](vuln-playbooks/file-upload-traversal.md) | Uploads served in the wrong context, and paths that escape the intended directory — your own files only. |
| 10 | [Race Conditions](vuln-playbooks/race-conditions.md) | Check-then-act gaps on a shared resource — two parallel requests where only one should succeed. |
| 11 | [GraphQL](vuln-playbooks/graphql.md) | Field-level authz and mutation mass assignment — reconstruct the schema with Clairvoyance when introspection is off. |
| 12 | [Privilege Escalation](vuln-playbooks/privilege-escalation.md) | Vertical and horizontal escalation: forced browsing to admin endpoints, role tampering, self-promotion/approval flows. |

---

## After a confirmed bug: the sibling rule and the A-to-B signal

Two rules from the federicopinan/ai-bug-bounty-hunter repo
(https://github.com/federicopinan/ai-bug-bounty-hunter) that belong
in every playbook, not just in the triage file:

- **Sibling rule (#10).** After a confirmed bug, check every variant
  of the endpoint (`/api/user/{id}/...` and every sibling path that
  shares the handler). The same developer made the same mistake in
  the same code.
- **A-to-B signal (#11).** A confirmed bug A means the developer made
  the same mistake elsewhere. Hunt for bug B within 20 minutes,
  before writing the report. The window matters: the finding is fresh
  in your head, and the same pattern is fastest to spot now.

And the rule from STÖK ("hack, learn, share"):
after every confirmed bug, generalise the root cause into a detection
rule and write it into this file or into `notes.md`. The next target
gets tested against the rule, not just against the memory of one bug.
Source: https://github.com/maybe4a6f7365/agentic-bug-bounty-framework/blob/HEAD/knowledge-sources/creators/02-stok.md

## Sources

- The Bug Hunters Methodology (TBHM), Jason Haddix —
  https://github.com/jhaddix/tbhm (class files 04–09, 12; Fast Testing
  Checklist)
- PortSwigger Web Security Academy — https://portswigger.net/web-security
- PayloadsAllTheThings — https://github.com/swisskyrepo/PayloadsAllTheThings
- ai-bug-bounty-hunter, rules #10/#11 —
  https://github.com/federicopinan/ai-bug-bounty-hunter
- STÖK, "hack, learn, share" —
  https://github.com/maybe4a6f7365/agentic-bug-bounty-framework/blob/HEAD/knowledge-sources/creators/02-stok.md
- NahamSec earnings breakdown (SSRF ~25%, XSS ~18%) —
  https://github.com/zaakirio/reconductor/blob/HEAD/recon-methodology-research.md
- Farah Hawa, LinkedIn Promotion ID business-logic case —
  https://www.instagram.com/reel/DG-dSaUMMDZ/
- Hacker101, "How to Write a Good Report and Use the CVSS Calculator" —
  https://www.hacker101.com/resources/articles/writing_a_report_and_cvss
