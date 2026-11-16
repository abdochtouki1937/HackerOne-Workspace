# Finding: [Short descriptive title]

| Field | Value |
| ----- | ----- |
| Severity | Critical / High / Medium / Low / Informative |
| CVSS | [X.X — vector: CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H] |
| CWE | [CWE-XXX: Name] |
| Asset | [Exact in-scope asset: domain / URL / app] |
| Status | Lead / Confirmed / Draft written / Submitted / Triaged / Resolved / Duplicate / N/A |
| HackerOne report ID | [filled after submission] |
| Date found | YYYY-MM-DD |
| Date submitted | YYYY-MM-DD |

## Summary

[2-3 sentences: what the bug is, who can exploit it, and what they gain.
Write it so a triager understands the finding without reading further.]

## Steps to Reproduce

Numbered, exact, reproducible from a clean state. Include the test
accounts used (A and B) and any setup.

1. [Step]
2. [Step]
3. [Step]

Expected result: [what should happen]
Actual result: [what happens with the bug]

## Proof of Concept

Paste the exact requests and responses. Redact nothing that matters,
invent nothing. Point to the saved evidence files in `../evidence/`.

```http
[Request 1 — method, URL, headers, body]
```

```http
[Response 1 — status, headers, body]
```

Evidence files:

- `../evidence/YYYY-MM-DD-name.png` — [what it shows]
- `../evidence/YYYY-MM-DD-name.txt` — [request/response pair]

## Impact

[Only what was proved. State the exact impact: who is affected, what an
attacker can read / change / do, and the precondition (e.g. "requires a
malicious app installed in the workspace"). Do not claim impact you did
not demonstrate.]

## Root cause

[What the code does, what it should do, and the exact condition that is
wrong or missing. One paragraph.]

## Remediation

[Concrete fix: what to change, where, and how to verify it.]

## References

- [Program policy: HackerOne program URL]
- [Public research / prior art, if any — and how this finding differs]
- [CVE / advisory, if the issue has a known identifier]

## Duplicate check

- [ ] Searched HackerOne Hacktivity for this program and issue class.
- [ ] Searched public advisories for the same root cause.
- [ ] Result: [no duplicate found / possible duplicate: link and reason]
