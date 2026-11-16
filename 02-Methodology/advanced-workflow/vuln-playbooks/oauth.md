# OAuth and OpenID Confusion

CWE-287, CWE-441. TBHM file `09_Privledge_Logic_Transport.md`.

Part of the Stage 3 Deepening playbooks — see the index in
`../07-vuln-playbooks.md`. The testing rules in `../03-testing-playbook.md`
still apply: baseline first, one variable at a time, test accounts A vs B
only, rate-limit, stop on 429, log everything. Test with your own
accounts and your own domains only.

**Trigger conditions.** Any login with a third party (Google, GitHub,
OIDC), any "login with" button, any token or code the client hands to
the server, any email/username fallback in the identity flow, any
account-linking step ("link your Google account"), any "login with"
that creates an account on first use (just-in-time provisioning).

**The exact test.**

1. **Confused issuer / audience (`iss` / `aud`).** Does the server
   check `iss` and `aud` on the token it accepts? Test: take a token
   issued for another app (a different `aud`) or by another issuer
   (a different `iss`) — one you legitimately hold — and present it
   to this server. A token accepted for the wrong audience or issuer
   is the finding. Change only `iss`/`aud` context, one at a time.
2. **Email / username fallback.** When the IdP does not return a
   verified email, does the server fall back to a caller-supplied or
   unverified value? Test: start an OIDC login where the IdP returns
   no verified email (or an unverified one), and see what identity
   the server creates or links to. Vikunja E-01/E-02: OIDC
   email-fallback and username-fallback account takeover — the
   fallback trusted an identifier the caller influenced.
   Live-confirmed on 2.8.0. (See also `idor.md` — same shape: a
   trusted identifier the caller controls.)
3. **Account linking / pre-hijacking.** Create an account on the
   target with B's email (or link B's IdP identity) before B ever
   signs up, then have B log in via the IdP. Does B land in the
   attacker-created account? Test the order both ways: IdP-first
   then password, and password-first then IdP. Use only your own
   test accounts.
4. **Code / token reuse and expiry.** Can an authorisation code be
   replayed for a second account, or used after expiry? Exchange the
   same code twice; exchange an expired code; present a refresh token
   after the account was deactivated (cf. OpenEMR O-E01 in
   `auth-session.md` — refresh tokens surviving deactivation).
5. **Redirect URI.** Does the authorisation server validate the
   redirect URI exactly, or does it accept a prefix/pattern match?
   Test with your own domains only: an exact registered URI vs the
   same URI with a trailing path, a subdomain, or a different scheme.
   A lax match that sends the code to a host you control is the
   finding — but only test hosts you own.
6. **State / nonce / PKCE.** Omit `state`, replay a used `state`,
   omit the PKCE `code_verifier`, and swap in a `code_verifier` from
   a different flow. A login that completes without `state` is a
   CSRF lead; a code exchanged without the right verifier is the
   finding. One omission per test.
7. **Scope confusion.** Request a token with a lower scope and use it
   for a higher-scope action (cf. GPUStack N-M2 in
   `auth-session.md`: a MANAGEMENT-scoped key minted an ALL-scoped
   key). For OAuth, the same test is: an `openid`-only token used
   against a profile/admin endpoint.

**Common false positives.**

- A redirect-URI check that accepts a subdomain the program owns and
  controls (check who owns the subdomain).
- A fallback that stores an unusable marker when the email is
  unverified (AiSOC pattern — a marker that cannot log in is not a
  takeover). The test is whether the fallback identity can actually
  authenticate, not whether the field is stored.
- A token accepted for a different `aud` when the server is
  documented as a multi-audience resource server (check the docs).
- A code that can be exchanged twice because the first exchange
  failed (check the first exchange's result before calling the
  second a replay).

**What proof looks like.** A login as B (or as a victim identity)
achieved through the confused value, with the token/code and the
server's acceptance saved — plus the control (the same token/code
correctly rejected when the confused value is fixed). State which
check was missing (`iss`, `aud`, verified-email, `state`, PKCE).

**Grounded examples (this workspace).**

- **Vikunja E-01/E-02 (HIGH, live-confirmed on 2.8.0):** OIDC
  email-fallback and username-fallback account takeover. The
  fallback trusted a caller-influenced identifier instead of the
  verified one.
- **AiSOC E-01 (LOW, CWE-521, CVSS ~3.8 — the negative control):**
  an empty password was accepted, but the endpoint needed
  tenant-admin rights and there was no escalation — and a fallback
  that stores an unusable marker is not a takeover. Test the
  claimed thing itself.
- **GPUStack N-M2 (PoC-verified Medium, adjacent):** a
  MANAGEMENT-scoped key minted an ALL-scoped key via POST/PUT
  `/v2/api-keys`. Same root cause as a scope-confusion OAuth test:
  the minting endpoint did not check the caller's scope.
