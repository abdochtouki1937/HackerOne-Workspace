# Report — Critical

## Title

[One line: vulnerable function + what an attacker can do + impact.
Example: "Unauthenticated remote code execution via file upload in the
admin import endpoint"]

## Summary

[2-3 sentences: what the bug is, who can exploit it, what they gain.
Example: "An unauthenticated attacker can upload a crafted file to the
import endpoint, which the server executes as the application user. No
user interaction is needed. The attacker gains full control of the
application server and its database."]

## Severity

- Severity: Critical
- CVSS: [9.0–10.0 — CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H]
- CWE: [CWE-XXX: Name]
- Asset: [exact in-scope asset]
- Affected version: [exact version under test]

CVSS justification (one line per metric):

- AV: [why Network]
- AC: [why Low]
- PR: [why None]
- UI: [why None]
- S: [why Changed — only if the exploit breaks out of the vulnerable component's authority]
- C / I / A: [why each is High]

## Steps to Reproduce

### Prerequisites

[What is needed: test accounts, setup, tools.]

### Steps

1. [Step]
2. [Step]
3. [Step]

### Expected result

[What should happen]

### Actual result

[What happens with the bug]

## Proof of Concept

```http
[Exact request]
```

```http
[Exact response]
```

Evidence: [files in evidence/, e.g. evidence/2026-11-16-rce-poc.txt]

## Impact

[Only what was proved. Who is affected, what an attacker can read /
change / do, and the precondition if any. For Critical, the impact must
be severe and directly demonstrated: full account takeover, remote code
execution, or complete data exposure.]

## Remediation

[Concrete fix: what to change, where, and how to verify it.]

## References

- [Prior art and how this finding differs]
- [Program policy URL]
- [CVE / advisory, if one exists]

## Pre-submission checklist

- [ ] Scope verified against the live HackerOne policy today.
- [ ] Finding reproduced from a clean state.
- [ ] Proof saved in evidence/ and referenced above.
- [ ] Tested as account A and account B.
- [ ] Duplicate check done (Hacktivity + public advisories).
- [ ] Severity is honest — only the impact proved is claimed.
- [ ] No secrets, tokens, or passwords in the report or evidence.
- [ ] Version under test recorded (latest release, re-checked today).
- [ ] Full chain demonstrated end-to-end — no step is "assumed to work";
      every step in the chain has a saved request/response.
- [ ] Impact is total compromise (RCE, full ATO, complete data exposure)
      — not a partial read or a self-only effect dressed up as Critical.
- [ ] No precondition hidden — if the attack needs any setup (a victim
      action, a specific configuration, a prior step), it is stated in
      the title, the summary, AND the Impact section.
- [ ] The vulnerable component and the compromised component are both
      named (scope-change claim needs both, or S:U is the honest call).
- [ ] No other severity's evidence is borrowed — the Critical claim
      rests on this finding's own PoC, not on a related Medium/Low.

## Good vs Bad examples

Write like the GOOD column. The BAD column is the mistake triage sees
every day.

**Title**

- GOOD: "Unauthenticated remote code execution via crafted file upload
  in the admin import endpoint — attacker gains full server control"
- BAD: "Security issue" / "Critical vulnerability in your app" /
  "RCE???" — no endpoint, no mechanism, no impact; triage cannot
  route it and the report starts at a credibility deficit.

**Summary**

- GOOD: "An unauthenticated attacker uploads a crafted file to the
  import endpoint; the server stores it under a web-accessible path
  and executes it as the application user. No user interaction is
  needed. The attacker gains full control of the application server
  and its database, as shown in the PoC (shell output / database rows
  returned)."
- BAD: "I found a bug that lets hackers take over your system. It is
  very critical. Please fix it." — no attacker, no endpoint, no
  mechanism, no proof; reads as a guess, not a finding.

**Impact statement**

- GOOD: "Any unauthenticated attacker can execute arbitrary commands
  as the application user on the production server, read and modify
  all application data, and pivot to internal services reachable from
  the server. Demonstrated end-to-end in the PoC: [what was actually
  run / read]."
- BAD: "This could allow full compromise of the company, all user
  data, and maybe the whole infrastructure." — "could" and "maybe" with
  no demonstrated step; triage downgrades speculation, it does not
  reward it.

Other BAD patterns to avoid at Critical: a copy-paste CVSS vector with
no per-metric justification; claiming ATO when only a self-account
effect was shown; hiding "requires admin to import the file" in step
7 while the title says "unauthenticated".

## Severity notes

Critical is the highest severity on HackerOne and the hardest to keep.
It must match proved impact: the report must demonstrate total
compromise — remote code execution, full account takeover of any user,
or complete exposure of sensitive data — end-to-end, with no hidden
precondition. No bounty range is promised here; severity must match
proved impact, nothing more. Triage downgrades inflated reports, and
a report filed one level too high costs credibility and spends trial
budget on a finding that will come back lower. If any step of the
chain is unproved, file at the severity the proved impact supports
and say what is still unproved.
