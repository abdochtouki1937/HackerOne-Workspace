# Report — Medium

## Title

[One line: vulnerable function + what an attacker can do + impact.
Example: "App can attach a forged link preview to another user's message
with no domain verification — the forged title links to an attacker URL"]

## Summary

[2-3 sentences: what the bug is, who can exploit it, what they gain.
Example: "Any app can claim any domain as an unfurl domain with no
ownership check, then attach a forged preview to any message — including
another user's message — with an arbitrary title linking to any URL.
The client shows no domain, no favicon, and no warning, so a reader
takes the forged preview as genuine and clicks through to the attacker's
site."]

## Severity

- Severity: Medium
- CVSS: [4.0–6.9 — CVSS:3.1/AV:N/AC:L/PR:L/UI:R/S:U/C:L/I:L/A:N]
- CWE: [CWE-XXX: Name]
- Asset: [exact in-scope asset]
- Affected version: [exact version under test]

CVSS justification (one line per metric):

- AV: [why Network]
- AC: [why Low / High]
- PR: [why Low — e.g. requires a malicious app installed]
- UI: [why Required — e.g. a victim must click]
- S: [why Unchanged / Changed]
- C / I / A: [why each is High / Low / None]

## Steps to Reproduce

### Prerequisites

[What is needed: test accounts, setup, precondition.]

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

Evidence: [files in evidence/, e.g. evidence/2026-11-16-forged-preview.png]

## Impact

[Only what was proved. State the precondition plainly (e.g. "requires
a malicious app installed in the workspace", "requires a victim to
click"). For Medium, the impact is real but bounded: phishing, limited
data exposure, or a privilege issue that needs an extra step.]

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
