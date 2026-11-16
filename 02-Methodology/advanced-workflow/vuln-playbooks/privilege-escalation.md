# Privilege Escalation

CWE-269, CWE-862, CWE-863, CWE-284. Vertical (a low-privileged user
gains a higher role) and horizontal (a user gains another user's
same-level privileges — see also `idor.md`, which is the
object-level form of the same failure).

Part of the Stage 3 Deepening playbooks — see the index in
`../07-vuln-playbooks.md`. The testing rules in `../03-testing-playbook.md`
still apply: baseline first, one variable at a time, test accounts A vs B
only, rate-limit, stop on 429, log everything. Test with your own
accounts only, and never grant yourself a real privilege on a shared
or production tenant — use your own test workspace/tenant, or a
privilege that only affects your own test data, and revert it after
the test.

**Trigger conditions.** Any role system: admin / moderator / member /
guest, tenant admin vs member, workspace owner vs admin vs member,
staff vs customer. Any admin function reachable by URL or API. Any
place the client sends a role, a permission, or an approval. Any
self-service flow that changes who you are: registration, invitation,
team join, role request, approval.

**Map the roles first — before testing.**

1. List every role the target has and what each role can do (docs,
   UI, API). Record which endpoints each role can call in the honest
   flow.
2. Create one test account per role (A = low role, B = high role
   where you legitimately hold it, e.g. your own second account you
   promoted yourself in your own test workspace). The control is:
   B can do it, A cannot.
3. Note where the role lives: server-side session, a JWT claim, a
   database field, a client-side flag. A role read from the
   server-side session cannot be changed by editing a token; a role
   read from a client JWT can be — test the actual source, not the
   guess. (Velora L7 lesson: the role was read from the server-side
   session, not the client JWT, so token tampering was dead.)

**The exact test — one variable at a time, control first.**

1. **Control.** As B (high role), call the admin function and record
   the success. As A (low role), call the same function honestly and
   record the rejection (403/404). Without this pair, a later
   "success" means nothing.
2. **Forced browsing to admin endpoints.** As A, request admin URLs
   and API paths directly, even when the UI hides them:
   `/admin`, `/dashboard`, `/console`, `/api/admin/...`, settings
   and user-management endpoints found in the JS or the OpenAPI
   spec. Try the path as-is, then with a trailing slash, then
   through the old API version. A 200 with admin data or an admin
   action performed is the finding; a redirect to login or a 403 is
   the control.
3. **Role parameter tampering.** In a request A can legitimately
   make (registration, profile update, team join, invite accept),
   add or change one role field: `"role": "admin"`,
   `"isAdmin": true`, `"permissions": ["admin"]`, `"tenantId"` to
   another tenant. One field per request (see
   `mass-assignment.md`). Read your own role back — did it change?
4. **Role in the token / session.** If the role is carried in a JWT
   or a cookie you control, change the role claim in your own token
   and replay it — but only after confirming the server actually
   trusts that token for the role (step: map the roles). If the
   server re-reads the role from its session/DB, the tampered token
   will fail; record that and move on.
5. **Self-promotion / approval flows.** Can an actor approve its own
   request, promote its own role, or approve a role request it
   submitted? Test: A submits a role-elevation request, then A (not
   B) approves it — via the UI flow and via the direct API call.
   OpenMausBot Finding 1: approval self-promotion via a loopback
   PATCH. Also test: A invites B, then A approves B's join as an
   admin; A creates a team, then grants itself owner.
6. **Horizontal escalation (same level, another user).** As A,
   perform an action scoped to B at the same role: change B's
   settings, read B's admin panel, act as B's team. This is IDOR
   with a privilege flavour — use the A-vs-B test in `idor.md`
   and state the privilege gained, not just the object read.
7. **Admin-function access via a lower-privileged API key / token.**
   Use a lower-scope token to call a higher-scope action (GPUStack
   N-M2: a MANAGEMENT-scoped key minted an ALL-scoped key via
   POST/PUT `/v2/api-keys` — PoC-verified Medium). Test each scope
   against each admin endpoint, one pair at a time.
8. **Step-up bypass.** Where a sensitive action requires a step-up
   (re-auth, OTP, AAL2), try the action with a password-only (AAL1)
   session, with a stale step-up, and with the step-up parameter
   omitted. A success without the step-up is the finding (see
   `auth-session.md`).

**Common false positives.**

- An admin endpoint that returns 200 but only your own data (the
  server ignores the admin path and serves the caller's scope —
  read the body, not the status).
- A role field that is accepted and echoed but not persisted (read
  your role back; see `mass-assignment.md`).
- A role the UI hides but the API correctly rejects (the UI hiding
  it is not the check; the API rejection is the control).
- An admin action you can perform because you legitimately hold
  that role in your own test workspace (check which account and
  which tenant you are in before calling it a finding).
- A "promotion" that only changes a display label, not any
  permission (test what the new role can actually do).
- An endpoint that is admin-only by URL but public by design
  (e.g. a public status page under `/admin/status` — check the docs).

**What proof looks like.** The control pair (B succeeds, A is
rejected) plus the tampered request as A succeeding — with the
read-back showing the new role/permission, and a demonstration of
what the new privilege can do (one admin action performed as A
after the escalation, on your own test data). State the privilege
gained in one line: "member → admin", "A approved its own elevation",
"MANAGEMENT key minted an ALL key".

**Grounded examples (this workspace).**

- **GPUStack N-M2 (PoC-verified Medium):** a MANAGEMENT-scoped key
  minted an ALL-scoped key via POST/PUT `/v2/api-keys`. The minting
  endpoint did not check the caller's scope — a vertical escalation
  through a lower-scope credential.
- **OpenMausBot Finding 1:** approval self-promotion via a loopback
  PATCH — an actor approving its own request. The approval flow did
  not check that approver ≠ requester.
- **Vikunja E-01/E-02 (HIGH, live-confirmed on 2.8.0):** OIDC
  email/username fallback account takeover — the fallback trusted a
  caller-influenced identifier, so the attacker landed in the
  victim's account with the victim's privileges. Full account
  takeover is the extreme form of privilege escalation.
- **AiSOC E-01 (LOW, CWE-521 — the negative control):** an empty
  password was accepted, but the endpoint needed tenant-admin rights
  and there was no escalation to admin — no privilege was gained, so
  the severity stayed Low. Always state what privilege, if any, the
  tampered request actually gained.
- **Hostinger (wave 2 plan, adjacent):** `{username}`-keyed hosting
  endpoints (WordPress auto-login link, phpMyAdmin sign-on, DB
  password change) — each is a horizontal escalation if A's request
  reaches B's hosting account. Test each endpoint as A against B.
- **Craft CMS C1 (live PoC, HIGH, adjacent):** an authenticated MCP
  user set admin-only nested fields — a privilege boundary (admin-only
  fields) crossed by a lower-privileged caller through a nested
  input the check did not cover.
