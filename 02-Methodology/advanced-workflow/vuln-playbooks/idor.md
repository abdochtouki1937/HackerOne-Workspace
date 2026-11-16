# IDOR / Broken Object-Level Authorisation (BOLA)

The highest-yield class on API-heavy targets. CWE-639 / CWE-862.

Part of the Stage 3 Deepening playbooks — see the index in
`../07-vuln-playbooks.md`. The testing rules in `../03-testing-playbook.md`
still apply: baseline first, one variable at a time, test accounts A vs B
only, rate-limit, stop on 429, log everything.

**Trigger conditions.** The inventory lists an endpoint that takes a
caller-supplied object ID (path, query, or body): `/users/{id}`,
`/orders/{id}`, `/files/{id}`, `account_from`, `contract_id`. The object
belongs to a user, a tenant, or an account. The action reads, updates,
deletes, shares, or transfers it.

**The exact test.**

1. As account A, create object O_A. Record its ID and its response.
2. As account B, create object O_B. Record its ID.
3. As account A, request O_B by ID (read first, then update, delete,
   share, transfer — test every action, not just read). Save both
   responses.
4. Compare: 200 with B's data = the finding. 403/404 = the control.
5. Test the neighbours: O_B+1, O_B-1, the first object (id 1), the
   object of a third tenant if one exists. Test the same ID through the
   old API version (`/api/v1/`) and through the mobile API if one exists.
6. Test the mass form: bulk endpoints that take an array of IDs or a
   caller-supplied `tokens` array — pass B's ID inside A's list.

**Common false positives.**

- A 200 that returns only your own data (the server ignores the ID and
  returns the caller's object). Read the body, not the status.
- A 200 on a public object (shared link, public profile). The object was
  meant to be public — check the sharing state first.
- A 403 that leaks the object's existence through a different error or
  timing (that is an oracle, a lead — not an IDOR).
- Sequential IDs that are actually random per tenant (the ID only works
  inside your own tenant).

**What proof looks like.** Two requests, A asking for B's object, both
responses saved: A's own object returns A's data; A's request for B's
object returns B's data (field values that only B should see). State the
proof level: live proof, A vs B.

**Grounded examples (this workspace).**

- **Deriv B-L1 (Critical if confirmed):** `transfer_between_accounts`
  takes free-form `account_from`/`account_to` loginids. Test: A sends a
  transfer with `account_from` = B's loginid, demo funds only. If the
  server does not enforce that both accounts belong to the token owner,
  A drains B.
- **Deriv D-T1:** sell/cancel/update another account's trade contract by
  sequential integer `contract_id`. Test: A's token, B's `contract_id`.
- **Hostinger wave 2 plan (T1–T14):** `{username}`-keyed hosting
  endpoints — WordPress jwt-token/auto-login link, phpMyAdmin sign-on
  link, DB password change, file-content read, mailbox password change,
  DNS zone write, domain auth-code read, billing `payment_method_id`
  reuse. Each is one A-vs-B test.
- **Vikunja E-01/E-02 (filed drafts, HIGH, live-confirmed on 2.8.0):**
  OIDC email-fallback and username-fallback account takeover — the
  fallback trusted a caller-influenced identifier instead of the
  verified one. Same shape as IDOR: a trusted identifier that the
  caller controls.
