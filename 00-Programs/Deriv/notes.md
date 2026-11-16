# Research notes — Deriv

## What the target is

- Online trading platform: Options, CFDs (MT5), multipliers, P2P, and
  a cashier (deposits, withdrawals, transfers between accounts).
- Two APIs: the classic WebSocket v3 API and the new Options API
  (REST + WebSocket). The classic WS is HTTP 520 from some networks;
  the new API is the working path.
- Demo accounts carry USD 10,000 virtual funds, free, no deposit,
  no KYC. One login can hold multiple demo accounts via the Trader's
  Hub account switcher.

## Recon summary

- Wave 1 (2026-11-16, recon + unauthenticated only): 1 confirmed Low
  (do NOT file as-is), 57 leads, ~150 probes, 0 unauthenticated data
  exposures.
- New API is clean from outside: uniform auth errors, no existence
  oracle. P2P lives on classic WS only.
- No idempotency key on any money-moving call; all amount/limit checks
  are client-side only (lead, not a finding).
- Cashier is Important-business (up to $5,000 Critical).

## Confirmed finding (Low — do NOT file as-is)

- **F1 user enumeration.** POSTing a nonexistent identifier to
  `https://auth.deriv.com/self-service/login?flow=<id>` returns HTTP 400,
  message 4000037, "This account does not exist or has no login
  method configured."
  - Caveats: the positive branch (an existing identifier advancing to
    the password step) could NOT be verified without an account; this
    is stock Ory Kratos behaviour, so duplicate / wont-fix risk is
    real. **Re-verify with account A before filing.**
  - Full PoC: `~/workspace/bug-bounty-hunt/daily/2026-11-16/deriv/agent-a-REPORT.md`

## Ranked leads (all need demo accounts A and B; none are findings yet)

1. **B-L1 — `transfer_between_accounts` `account_from` IDOR
   (Critical if confirmed).** The client sends `account_from` /
   `account_to` as free-form loginids. If the server does not enforce
   that both belong to the token owner, account A can drain account B.
2. **D-T1 — sell / cancel / update another account's trade contract
   by sequential integer `contract_id`.** Matches the program's
   in-scope example "manipulating trade contracts".
3. **E-L2 — new-API `bulk-purchase/demo` cross-account pairs.** The
   schema says each pair's account "must belong to the token's owner";
   parameters pass through unmodified, no price cap, duplicate pairs
   honoured. Testable from this network the moment API tokens exist.
4. **C-L1 — legacy v3 `buy_contract_for_multiple_accounts`** with a
   caller-supplied `tokens` array (needs a network where classic WS
   works).
5. **A-L1 — 2FA / AAL2 bypass or downgrade.** The policy lists OTP/2FA
   bypass as High.

## Tested and closed

- Unauthenticated data exposure: none found in wave 1.
- New API auth errors: uniform, no existence oracle.

## Setup status

- Account A signup is in progress (email e1gle@wearehackerone.com,
  Morocco, demo account with USD 10,000 virtual funds).
- Second demo account is a CFDs (MT5) demo account; activating it
  needs an MT5 password (set by the user via the Secure Vault).
- After both demo accounts exist, create API tokens `h1-e1gle-a` and
  `h1-e1gle-b` (Read + Trade) and record them in the Deriv SETUP.md
  file only — never in this workspace.
- Wave 2 order: E-L2, D-T1, B-L1, A-L1, then F1 re-verification with
  account A.

## Rules reminder

- Header `X-HackerOne-Research: e1gle` on every request.
- Demo accounts only. Never real money, never real-money trades.
