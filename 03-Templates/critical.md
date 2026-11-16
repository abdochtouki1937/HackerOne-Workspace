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
