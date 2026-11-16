# Research notes — Hostinger

## What the target is

- Web hosting platform: shared hosting, hPanel control panel, website
  builder, domains, mail, billing.
- Main roles: account owner (tenant), with hosting accounts, domains,
  databases, mailboxes, and files under each tenant.

## Recon summary

- Wave 1 (2026-11-16, recon + unauthenticated only): 0 confirmed, 49
  leads, ~90 probes, 0 unauthenticated data exposures.
- Official OpenAPI spec: 353 paths, 85% take caller-supplied object
  IDs; a single global Bearer token has the same rights as the hPanel
  user. All 19 unauthenticated probes returned 401.
- Real API base: developers.hostinger.com (90 req/min).
- No wss:// endpoints (realtime is SSE/fetch).
- developers.hostinger.com and mail APIs return
  `Access-Control-Allow-Origin: *` (lead only, not a finding).
- payments.hostinger.com is untestable from this network (Cloudflare
  403/418).
- Price tampering via the public Billing API is structurally impossible
  (no price fields; prices are server-resolved).

## Ranked leads

1. **Convergent IDOR surface — `{username}`-keyed hosting endpoints**
   (ranked #1 by three agents). PoC targets once accounts exist:
   - WordPress jwt-token / auto-login links for another account's site
   - phpMyAdmin sign-on link for another account's DB
   - DB password change on another account's DB
   - File-content read on another account's files
   - Mailbox password change, DNS zone write, domain auth-code read,
     billing `payment_method_id` reuse
2. Auth flow: `sso_session` cookie clean; password-reset enumeration
   clean; `redirect_back_url` accepted without visible validation —
   unconfirmed, needs a browser login.
3. `redirect_back_url` open-redirect candidate (unconfirmed).

## Tested and closed

- Unauthenticated data exposure: none found in wave 1.
- Billing price tampering: structurally impossible (see above).

## Confirmed findings

- None yet.

## Open questions

- Scope clarification needed for auth.hostinger.com,
  access.hostinger.com, and cart.hostinger.com (login flow and cart
  live there, but they are not in the 34-asset list).
- Setup blocked on the user: register Accounts A and B, send the
  coupon email (draft in
  `~/workspace/bug-bounty-hunt/daily/2026-11-16/hostinger/SETUP.md`),
  activate the Premium plan, generate API tokens for both accounts.
  No paid plan — the free coupon is the only route to a plan.
- Wave 2 (authenticated A↔B cross-tenant testing + live-browser
  hPanel/checkout capture) starts when accounts and tokens exist.
