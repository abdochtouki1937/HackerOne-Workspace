# Report — Informative

## Title

[One line: what was observed. Example: "Verbose error messages
disclose internal paths on the password-reset endpoint"]

## Summary

[2-3 sentences: what was observed and why it matters. Example: "The
password-reset endpoint returns a stack trace containing internal file
paths and library versions when given a malformed email address. No
user data is disclosed and no action can be taken from it, but the
information helps an attacker fingerprint the stack."]

## Severity

- Severity: Informative
- CVSS: [0.0 — or a Low score if the program scores it; CVSS:3.1/...]
- CWE: [CWE-XXX: Name, if one applies]
- Asset: [exact in-scope asset]
- Affected version: [exact version under test]

## Steps to Reproduce

### Prerequisites

[What is needed.]

### Steps

1. [Step]
2. [Step]

### Expected result

[What should happen — e.g. a generic error]

### Actual result

[What happens — e.g. a verbose error with internal details]

## Proof of Concept

```http
[Exact request]
```

```http
[Exact response]
```

Evidence: [files in evidence/]

## Impact

[Only what was proved. For Informative, the impact is minimal: no
direct access, no data exposure beyond fingerprinting, no action an
attacker can take from this alone. Say what it could help with (e.g.
fingerprinting for a later attack) without inflating it.]

## Remediation

[Concrete fix: what to change, where, and how to verify it.]

## References

- [Prior art, if any]
- [Program policy URL]

## Pre-submission checklist

- [ ] Scope verified against the live HackerOne policy today.
- [ ] Finding reproduced from a clean state.
- [ ] Proof saved in evidence/ and referenced above.
- [ ] Duplicate check done (Hacktivity + public advisories).
- [ ] Severity is honest — Informative means no direct impact.
- [ ] No secrets, tokens, or passwords in the report or evidence.
- [ ] Version under test recorded (latest release, re-checked today).
