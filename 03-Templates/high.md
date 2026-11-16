# Report — High

## Title

[One line: vulnerable function + what an attacker can do + impact.
Example: "Authenticated user can read any tenant's invoices by changing
the account_id parameter"]

## Summary

[2-3 sentences: what the bug is, who can exploit it, what they gain.
Example: "Any authenticated user can read another tenant's invoices by
changing the account_id parameter in the invoice API. No admin rights
are needed. The attacker can read every tenant's billing data, including
names, amounts, and payment references."]

## Severity

- Severity: High
- CVSS: [7.0–8.9 — CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:N]
- CWE: [CWE-XXX: Name]
- Asset: [exact in-scope asset]
- Affected version: [exact version under test]

CVSS justification (one line per metric):

- AV: [why Network]
- AC: [why Low]
- PR: [why Low — authenticated low-privilege user]
- UI: [why None / Required]
- S: [why Unchanged / Changed]
- C / I / A: [why each is High / Low / None]

## Steps to Reproduce

### Prerequisites

[What is needed: test accounts A and B, setup.]

### Steps

1. [Step — as account A]
2. [Step — as account B, same request with A's object ID]
3. [Step]

### Expected result

[What should happen — e.g. 403 Forbidden]

### Actual result

[What happens with the bug — e.g. 200 with A's data]

## Proof of Concept

```http
[Exact request as account B]
```

```http
[Exact response — B receives A's data]
```

Evidence: [files in evidence/, e.g. evidence/2026-11-16-idor-invoice.png]

## Impact

[Only what was proved. Who is affected, what an attacker can read /
change / do, and the precondition if any. For High, the impact must be
serious and directly demonstrated: cross-tenant data access, account
takeover of another user, or privilege escalation.]

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
