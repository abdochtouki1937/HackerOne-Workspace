# Bypasses

Reusable bypass patterns. Each one is a generic technique — verify it
live on the target before treating it as a finding. Test accounts only.

## Authentication bypasses

- **Missing check on one path:** the UI requires login, but the API
  endpoint does not. Call the API directly with no token.
- **Role in the request:** a `role`, `is_admin`, or `plan` field in a
  request body or JWT that the server trusts. Try changing it as a
  low-privilege user.
- **Token confusion:** a token minted for one purpose (password reset,
  invite, email change) accepted for another.
- **OTP / 2FA:** missing step (direct navigation to the post-2FA page),
  code not tied to the session, code reuse, code in the response.
- **OAuth:** `state` not validated, `redirect_uri` not validated,
  authorisation `code` reusable, account linking by email only.
- **JWT:** `alg: none`, RS256→HS256 confusion, missing signature
  check, `kid` pointing at an attacker URL, expiry ignored.

## Authorisation (IDOR) bypasses

- **Sequential IDs:** `id=101` → `id=102` as the other account.
- **UUID in the response:** a UUID is not guessable, but it is often
  leaked in a list, export, or error message — then it is usable.
- **Related objects:** an endpoint that lists your objects also returns
  another tenant's objects through a join, search, or export.
- **Parameter pollution:** two `account_id` values — which one wins?
- **Old API version:** v1 still serves the object while v2 enforces
  the check.
- **Method change:** GET is blocked, POST to the same path is not.
- **Header override:** `X-User-Id`, `X-Tenant-Id`, `X-Original-URL`
  trusted by the server.

## Rate-limit bypasses

- **Do not bypass rate limits to brute-force credentials.** That is
  forbidden. These patterns are for testing whether a limit exists at
  all, on your own test accounts:
- Different casing or trailing slash on the path.
- Different `X-Forwarded-For` value (only to test whether the limit
  keys on it — never to evade a limit for an attack).
- Missing vs present session (anonymous vs authenticated limits).

## WAF / filter bypasses

- Case variation, double encoding, Unicode normalisation.
- Parameter in the body instead of the URL (or the reverse).
- JSON instead of form-encoded (or the reverse) — some filters only
  inspect one content type.
- Null byte, semicolon, or whitespace tricks in file extensions.

## 403 / 401 bypasses

- Add a trailing slash, `/.`, `//`, or `/%2e/` to the path.
- Try `X-Original-URL` / `X-Rewrite-URL` with the protected path.
- Try the same path on a different host (api vs app vs cdn).
- Try HTTP instead of HTTPS, or the reverse.
- These are leads: a 200 that returns another user's data is the
  finding; a 200 that returns a login page is not.

## References

- [PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings)
- [PayloadsAllTheThings — bypasses section](https://swisskyrepo.github.io/PayloadsAllTheThings/)
