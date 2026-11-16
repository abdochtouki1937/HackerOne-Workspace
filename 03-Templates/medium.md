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
- [ ] Precondition stated in the title AND the summary — e.g. "requires
      a malicious app installed", "requires a victim to click" — not
      buried in step 4.
- [ ] Impact bounded honestly — what the attacker gains is named, and
      what they do NOT gain is named too (no access, no data beyond
      what is shown).
- [ ] The extra step is real — if the attack needs a victim click, an
      install, or a second bug, that step is demonstrated or stated as
      a stated precondition, not assumed away.
- [ ] Prior art addressed — the closest disclosed report / research is
      named and the differentiator is stated (see References).

## Good vs Bad examples

**Title**

- GOOD: "App can attach a forged link preview to another user's
  message with no domain verification — requires a malicious app
  installed (Slack unfurl forgery)"
- BAD: "Slack phishing vulnerability" — no mechanism, no precondition;
  triage cannot tell whether this is a real primitive or a theory.
- BAD: "Critical account takeover via Slack link preview" — the
  proved impact is a forged preview a reader may click, not account
  takeover; the title inflates one level (or two).

**Summary**

- GOOD: "Any app can claim any domain as an unfurl domain with no
  ownership check, then attach a forged preview to any message —
  including another user's message — with an arbitrary title linking
  to any URL. The client shows no domain, no favicon, and no warning,
  so a reader takes the forged preview as genuine and clicks through
  to the attacker's site. Precondition: a malicious app installed in
  the workspace."
- BAD: "I found a bug in Slack that lets hackers phish everyone."
  — no endpoint, no mechanism, no precondition, no bound on impact.

**Impact statement**

- GOOD: "A malicious app installed in a workspace can make any user's
  message appear to link to a trusted domain while the title actually
  points to an attacker URL, with no client-side warning. This is a
  phishing primitive: it needs a victim to click, and a careful
  side-by-side reader can spot the missing favicon/domain lines. It
  gives no access and no data on its own."
- BAD: "Attackers can take over any Slack workspace and steal all
  credentials." — nothing in the proof shows takeover or credential
  theft; this is the inflation that gets a Medium closed as N/A or
  downgraded to Low.

Other BAD patterns to avoid at Medium: a copy-paste CVSS vector with
no per-metric justification (especially UI:R vs UI:N, and PR:L when
the precondition is really a victim install); a title that hides the
precondition and only admits it in the Impact section.

## Severity notes

Medium means real but bounded impact: phishing, limited data
exposure, or a privilege issue that needs an extra step — with the
precondition stated up front in the title and the summary. No bounty
range is promised here; severity must match proved impact, nothing
more. Triage downgrades inflated reports, and a report filed one
level too high costs credibility and spends trial budget on a finding
that will come back lower. A Medium filed honestly, precondition and
all, is worth more than a Medium dressed up as a High: triage trusts
the next report from the same reporter.
