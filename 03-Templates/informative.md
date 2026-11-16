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
- [ ] No impact claimed beyond fingerprinting — the report does not
      say the disclosure "leads to" access, data, or takeover.
- [ ] Program actually accepts Informative reports — checked against
      the live policy / program page today; if the program only pays
      for Low and above, the report is not filed (or is filed only if
      the program invites Informative findings).
- [ ] The disclosed detail is named exactly — which paths, versions,
      or internal values appear, and where (request + response in PoC).
- [ ] No chained impact claimed without proof — "helps fingerprint
      the stack for a later attack" is the ceiling, not a stepping
      stone to a severity.

## Good vs Bad examples

**Title**

- GOOD: "Verbose error messages disclose internal paths and library
  versions on the password-reset endpoint"
- BAD: "Security issue" / "Server leak exposes sensitive data" — the
  first says nothing; the second claims sensitive data exposure when
  only stack details were disclosed.

**Summary**

- GOOD: "The password-reset endpoint returns a stack trace containing
  internal file paths and library versions when given a malformed
  email address. No user data is disclosed and no action can be taken
  from it, but the information helps an attacker fingerprint the
  stack."
- BAD: "I found a bug that leaks server info and could let hackers
  break in." — "could let hackers break in" is an unproved chain
  presented as impact.

**Impact statement**

- GOOD: "An unauthenticated attacker learns internal file paths and
  library versions from the error response. No user data is disclosed,
  no session or credential is exposed, and no action can be taken
  from this alone. It helps fingerprint the stack for a later attack,
  which is the full extent of the impact."
- BAD: "This exposes the internal infrastructure and allows full
  compromise." — fingerprinting is not compromise; claiming it as
  such is the inflation that gets Informative reports closed as N/A.

Other BAD patterns to avoid at Informative: a copy-paste CVSS vector
with a nonzero score and no per-metric justification (Informative is
CVSS 0.0 unless the program scores it); filing an Informative finding
on a program that does not accept them; describing the observation
in one vague sentence with no request/response pair.

## Severity notes

Informative means no direct impact: an observation worth fixing —
verbose errors, stack fingerprinting, a hardening note — that gives
an attacker no access, no data beyond fingerprinting, and no action
on its own. No bounty range is promised here; severity must match
proved impact, nothing more. Triage downgrades inflated reports, and
a report filed one level too high costs credibility and spends trial
budget on a finding that will come back lower. Before filing, confirm
the program actually accepts Informative reports: on a program that
only triages Low and above, an Informative report costs time and
credibility for nothing. When in doubt, keep the observation in the
workspace notes and attach it as supporting detail to a real finding
instead of filing it alone.
