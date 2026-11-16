# Program: Deriv

| Field | Value |
| ----- | ----- |
| Platform | HackerOne |
| Program URL | https://hackerone.com/deriv |
| Status | Active |
| Policy last updated | [check the live policy page] |
| Scope last verified | 2026-11-16 |
| Researcher | e1gle |

**Verify this scope against the live HackerOne policy before testing.
Scope changes. This file is a snapshot, not the policy.**

## Bounty ranges

Important-business assets (maxima):

| Severity | Maximum |
| -------- | ------- |
| Critical | $5,000 |
| High | $2,500 |
| Medium | $500 |
| Low | $100 |

General tier is lower: $2,000 / $1,500 / $250 / $50. **Low is paid
ONLY on Important-business assets.** SLAs: first response 2 business
days, triage 2 days, bounty 2 days. 324 reports in the last 90 days;
$2,700 paid in 90 days; last report resolved 15 hours before the
2026-11-16 check. Duplicate pressure is high — only novel, PoC-proven
vectors win.

## In-scope assets

| Asset | Type | Notes |
| ----- | ---- | ----- |
| *.deriv.com | Wildcard | Main domain family |
| *.deriv.cloud | Wildcard | |
| *.derivws.com | Wildcard | WebSocket API hosts |
| api.deriv.com | Domain | API |
| app.deriv.com | Domain | Trading app |
| cashier.deriv.com | Domain | Cashier (Important-business) |
| oauth.deriv.com | Domain | OAuth |
| smarttrader.deriv.com | Domain | SmartTrader |
| secure-dfadmin.deriv.com | Domain | Admin |
| MT5 | Product | MetaTrader 5 |
| Deriv P2P | Product | Peer-to-peer trading |
| Deriv GO | Product | Mobile app |

In-scope examples from the policy: auth / OTP / 2FA bypass, account
takeover, privilege escalation, SSRF to intranet, payment and
trade-contract logic flaws, SQL injection.

## Out-of-scope assets

- *.api-core.deriv.com
- *.home.deriv.com — hosts the login UI. API testing on auth.deriv.com
  is fine; UI flows on home.deriv.com need a scope ruling (one live
  listing disagrees — treat as OUT until a browser check confirms).
- besquare, community, help, deriv.ae

## Excluded vulnerability types

Copy the current list from the policy before testing. Theoretical
vulnerabilities without a proof of concept are explicitly out of scope.

## Rules

- **Header `X-HackerOne-Research: e1gle` on EVERY testing request.**
- **Demo / virtual accounts only.** Never deposit real money, never
  make real-money trades. Demo accounts carry USD 10,000 virtual funds,
  are free, need no deposit and no KYC.
- Test only your own accounts A and B.
- No brute force, spam, DDoS, or social engineering.
- A proof of concept is required for any finding.

## Submitted reports

| Date | Title | Severity | Status | HackerOne report ID |
| ---- | ----- | -------- | ------ | ------------------- |
| | | | | |

## Notes

- Test accounts use the `e1gle@wearehackerone.com` alias (forwards to
  the researcher's inbox).
- Morocco (ma) is not on Deriv's restricted-residence list.
- The classic WebSocket v3 API (`wss://ws.derivws.com`) is unreachable
  from some networks (HTTP 520) — the new Options API is the working
  path.
- Token scopes: Read + Trade (Admin only if a test needs it). Tokens
  named `h1-e1gle-a` / `h1-e1gle-b`.
- No tokens or passwords are stored in this workspace.
