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
- [ ] A-vs-B proof saved — the same request run as account A (owner)
      and as account B (attacker), with both responses in the PoC.
- [ ] Cross-tenant effect shown, not just cross-account on a shared
      object — the victim's data/action is named, and it belongs to a
      different tenant/user.
- [ ] No admin rights needed unless stated — if the attack needs admin
      or a privileged role, the title and summary say so plainly.
- [ ] The object ID is genuinely caller-supplied — the PoC shows the
      ID was changed by the attacker, not taken from a URL the victim
      shared.
- [ ] Impact is another user's data or action — not a self-only effect
      (changing your own object is not an IDOR).

## Good vs Bad examples

**Title**

- GOOD: "Transfer IDOR: account A can move funds out of account B by
  setting `account_from` to B's loginid in `transfer_between_accounts`
  (Deriv cashier)"
- GOOD: "IDOR in `{username}`-keyed hosting endpoints lets one tenant
  read another tenant's WordPress auto-login link (Hostinger)"
- BAD: "Security issue" / "IDOR vulnerability" — no endpoint, no
  object, no victim; triage has to guess what was tested.
- BAD: "Critical account takeover via IDOR" when only a read of
  another tenant's file was proved — the title claims a severity the
  proof does not support.

**Summary**

- GOOD: "Any authenticated user can move funds out of another user's
  account: the client sends `account_from` / `account_to` as free-form
  loginids and the server does not enforce that both belong to the
  token owner. Account A sent a transfer with `account_from` set to
  account B's loginid and the funds left B's account (demo funds).
  No admin rights are needed."
- BAD: "I found an IDOR that lets hackers steal money from anyone."
  — no endpoint, no parameter, no A-vs-B proof, no note that demo
  funds were used; "steal money from anyone" is an unproved claim.

**Impact statement**

- GOOD: "Account A (attacker) drained funds from account B (victim)
  using only A's own credentials and a modified `account_from`
  value. Any user could do this to any other user. Demonstrated with
  demo funds; no real money moved."
- BAD: "This is basically RCE / full system compromise." — an IDOR
  that moves money is serious on its own; claiming RCE without proof
  is inflation and invites a downgrade.

Other BAD patterns to avoid at High: a CVSS vector copied from
another report with no per-metric justification; a PoC that only
shows account A acting on account A's own object; hiding "needs the
victim's loginid" as if loginids were secret when they are guessable
sequential values (or the reverse — claiming the ID is secret when
it is printed in the UI).

## Severity notes

High means serious, directly demonstrated cross-user or cross-tenant
impact: another user's sensitive data, another user's money or
actions, or privilege escalation — proved with an A-vs-B test, not
asserted. No bounty range is promised here; severity must match
proved impact, nothing more. Triage downgrades inflated reports, and
a report filed one level too high costs credibility and spends trial
budget on a finding that will come back lower. A High that is really
a Medium (bounded, needs an extra step, or only a low-value read)
should be filed as Medium with the bound stated honestly.
