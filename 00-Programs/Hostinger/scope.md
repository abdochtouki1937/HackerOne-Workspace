# Program: Hostinger

| Field | Value |
| ----- | ----- |
| Platform | HackerOne |
| Program URL | https://hackerone.com/hostinger |
| Status | Active |
| Policy last updated | 2026-10-21 |
| Scope last verified | 2026-11-16 |
| Researcher | e1gle |

**Verify this scope against the live HackerOne policy before testing.
Scope changes. This file is a snapshot, not the policy.**

## Bounty ranges

| Severity | Range |
| -------- | ----- |
| Critical | up to $25,000 |
| High | — |
| Medium | — |
| Low | from $100 |

Overall bounty range: $100–$25,000. Average payout $250–$500.
Severity averages: Critical $10,440 / High $2,671 / Medium $740 /
Low $200. Response efficiency: 100%. About 5 days to bounty.
1,014 resolved reports; $352,340 paid in the last 90 days.

## In-scope assets

34 in-scope assets, including:

| Asset | Type | Notes |
| ----- | ---- | ----- |
| www.hostinger.com | Domain | Main site |
| hpanel.hostinger.com | Domain | Control panel |
| cpanel.hostinger.com | Domain | Control panel |
| payments.hostinger.com | Domain | Payments |
| builder.hostinger.com | Domain | Website builder |
| horizons.hostinger.com | Domain | Horizons |
| reach.hostinger.com | Domain | Reach |
| agents.hostinger.com | Domain | Agents |
| mail.hostinger.com | Domain | Mail |
| H5G | Product | |
| Managed OpenClaw | Product | |
| *.000webhost.com | Wildcard | |
| zyro.com | Domain | |
| hosting24.com | Domain | |
| niagahoster.co.id | Domain | |

## Out-of-scope assets / scope flags

- **auth.hostinger.com, access.hostinger.com, and cart.hostinger.com
  are NOT in the 34-asset list** but host the login flow and the cart.
  Findings there need program clarification before testing or filing.
- Own-account-only issues are out of scope (see Rules).

## Excluded vulnerability types

Copy the current list from the policy before testing.

## Rules

- **Decisive rule: ONLY cross-tenant issues qualify.** An issue that
  affects only your own account is closed as N/A.
- **No working proof of concept = closed as N/A.** Theoretical
  vulnerabilities do not file.
- Test accounts only (A and B) for cross-tenant testing.
- No denial of service, no spam, no phishing, no brute force of
  credentials, tokens, OTPs, or passwords.
- No social engineering.

## Submitted reports

| Date | Title | Severity | Status | HackerOne report ID |
| ---- | ----- | -------- | ------ | ------------------- |
| | | | | |

## Notes

- Wave 1 (recon + unauthenticated only, 2026-11-16): 0 confirmed
  findings, 49 leads, ~90 probes, 0 unauthenticated data exposures.
- Best lead (not a finding): convergent IDOR surface — `{username}`-keyed
  hosting endpoints. Highest-value PoC targets once accounts exist:
  WordPress jwt-token / auto-login links for another account's site,
  phpMyAdmin sign-on link for another account's DB, DB password change
  on another account's DB, file-content read on another account's files,
  mailbox password change, DNS zone write, domain auth-code read,
  billing `payment_method_id` reuse.
- The official OpenAPI spec lists 353 paths; 85% take caller-supplied
  object IDs; a single global Bearer token carries the same rights as
  the hPanel user.
- Price tampering via the public Billing API is structurally impossible
  (no price fields; prices are server-resolved).
- Setup is blocked on the user: register Account A and Account B, send
  the coupon email to security@hostinger.com asking for a free 1-month
  Premium Shared Hosting coupon, activate the plan, generate API tokens
  for both accounts. No paid plan — the free coupon is the only route.
