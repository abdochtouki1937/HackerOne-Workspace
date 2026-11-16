# Report — Low

## Title

[One line: vulnerable function + what an attacker can do + impact.
Example: "Login error message reveals whether an account exists"]

## Summary

[2-3 sentences: what the bug is, who can exploit it, what they gain.
Example: "Posting a nonexistent identifier to the login endpoint
returns 'This account does not exist', while an existing identifier
advances to the password step. An attacker can enumerate which email
addresses have accounts. This is a standard behaviour of the underlying
identity library and enables targeted phishing, but on its own it gives
no access."]

## Severity

- Severity: Low
- CVSS: [0.1–3.9 — CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:N/A:N]
- CWE: [CWE-XXX: Name]
- Asset: [exact in-scope asset]
- Affected version: [exact version under test]

CVSS justification (one line per metric):

- AV: [why Network]
- AC: [why Low]
- PR: [why None]
- UI: [why None]
- S: [why Unchanged]
- C / I / A: [why each is Low / None — e.g. C:L because only account
  existence is disclosed, I:N, A:N]

## Steps to Reproduce

### Prerequisites

[What is needed.]

### Steps

1. [Step — nonexistent identifier]
2. [Step — existing identifier (your own test account)]
3. [Compare the two responses]

### Expected result

[What should happen — e.g. identical generic error for both]

### Actual result

[What happens — e.g. different error revealing existence]

## Proof of Concept

```http
[Exact request — nonexistent identifier]
```

```http
[Exact response — "account does not exist"]
```

```http
[Exact request — existing identifier]
```

```http
[Exact response — advances to password step]
```

Evidence: [files in evidence/]

## Impact

[Only what was proved. For Low, the impact is limited: information
disclosure that enables a further attack (such as targeted phishing),
a minor bypass with a narrow precondition, or a hardening gap with a
small real-world effect. Say honestly what it does NOT enable.]

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
- [ ] Both branches verified (existing vs nonexistent, A vs B).
- [ ] Duplicate check done (Hacktivity + public advisories) — Low
      findings have high duplicate / wont-fix risk; say so if it applies.
- [ ] Severity is honest — only the impact proved is claimed.
- [ ] No secrets, tokens, or passwords in the report or evidence.
- [ ] Version under test recorded (latest release, re-checked today).
