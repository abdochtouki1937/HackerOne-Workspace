# Report draft — [Program Name]

Copy the matching template from `../../03-Templates/` (critical, high,
medium, low, or informative) into this file, then fill it in. One draft
per finding — if you have two findings, finish and submit the first
before drafting the second in this file, and keep the submitted report in
`findings/` as the permanent record.

## Title

[One line, specific, naming the vulnerable function and the impact.
Example: "App can attach a forged link preview to another user's message
with no domain verification".]

## Summary

[2-3 sentences: what the bug is, who can exploit it, what they gain.]

## Severity

- Severity: [Critical / High / Medium / Low / Informative]
- CVSS: [X.X — CVSS:3.1/...]
- CWE: [CWE-XXX: Name]
- Asset: [exact in-scope asset]

## Steps to Reproduce

1. [Prerequisite: test accounts, setup]
2. [Step]
3. [Step]

Expected result: [what should happen]
Actual result: [what happens with the bug]

## Proof of Concept

```http
[Exact request]
```

```http
[Exact response]
```

Evidence: [files in evidence/, e.g. evidence/2026-11-16-name.png]

## Impact

[Only what was proved. Preconditions, affected users, and the concrete
consequence.]

## Remediation

[Concrete fix and how to verify it.]

## References

- [Prior art and how this finding differs]
- [Program policy URL]

## Pre-submission checklist

- [ ] Scope verified against the live HackerOne policy today.
- [ ] Finding reproduced from a clean state.
- [ ] Proof saved in evidence/ and referenced above.
- [ ] Tested as account A and account B (differential test).
- [ ] Duplicate check done (Hacktivity + public advisories).
- [ ] Severity is honest — only the impact proved is claimed.
- [ ] No secrets, tokens, or passwords in the report or evidence.
- [ ] Version under test recorded (latest release, re-checked today).
