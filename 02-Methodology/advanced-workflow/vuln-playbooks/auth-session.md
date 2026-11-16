# Authentication and Session Flaws

CWE-287, CWE-384, CWE-613. TBHM file `04_Authorization_and_Session.md`.

Part of the Stage 3 Deepening playbooks — see the index in
`../07-vuln-playbooks.md`. The testing rules in `../03-testing-playbook.md`
still apply: baseline first, one variable at a time, test accounts A vs B
only, rate-limit, stop on 429, log everything.

**Trigger conditions.** Login, password reset, OTP/2FA, session
tokens, API tokens, OAuth flows, "remember me", logout, account
recovery, and any endpoint that mints or accepts a credential.

**The exact test.**

1. **Session survival:** log in as A, change the password, change
   2FA, deactivate the account, log out — after each step, try the
   old session/token. A surviving token after password change or
   deactivation is the finding (OpenEMR O-E01 pattern: refresh tokens
   surviving password change / MFA removal / deactivation).
2. **OTP/2FA bypass or downgrade:** can a password-only (AAL1)
   session reach an AAL2-gated action (settings, API-token creation,
   cashier)? Probe the recovery-code flow and the step-up check.
3. **Token scope:** can a lower-scope token reach a higher-scope
   action? (GPUStack N-M2: a MANAGEMENT-scoped key minted an
   ALL-scoped key via POST/PUT `/v2/api-keys` — PoC-verified Medium.)
4. **Session fixation:** does the session ID change on login? Log in,
   record the ID, log in again — the same ID after login is the
   finding.
5. **Password policy:** does the endpoint accept an empty or trivial
   password? (AiSOC E-01: `POST /api/v1/tenants/me/users` accepted
   `"password": ""` → 201, and `/auth/login` accepted `""` → 200.
   Real but LOW, CWE-521, CVSS ~3.8 — because the endpoint needed
   tenant-admin rights and there was no escalation. Test the claimed
   thing itself: is the field read, is it required, who can call it?)
6. **SRP / custom auth:** where the server implements its own crypto
   (SRP, custom challenge-response), check the edge values the
   implementer forgot: A = 0, A = N, A = 2N. (thinbus-srp JS server,
   Critical, CWE-287: `step2()` rejected only the literal string
   `"0"`; A = N with no password returned M2 with session key
   S = "0". Local lab PoC. The Java thinbus server was safe — it
   delegated to Nimbus, which validates.)

**Common false positives.**

- A session that survives a password change on a different device
  when the program documents that behaviour (check the docs first).
- An OTP that can be re-used once inside its validity window (often
  by design — check the window).
- An empty-password acceptance on an endpoint that no unprivileged
  caller can reach and that stores an unusable marker (AiSOC lesson).

**What proof looks like.** The old token/session used successfully
after the change that should have killed it (saved request/response
pair), or the lower-scope token performing the higher-scope action,
or the A = N authentication succeeding with no password.
