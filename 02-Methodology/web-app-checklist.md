# Web App Checklist

Manual testing checklist for web applications. Work it top to bottom
for each feature, as account A and then as account B, and compare both
responses. A difference is the finding.

## Setup

- [ ] Test accounts A and B exist. Proxy (Burp / ZAP) is running and
      logging every request.
- [ ] Baseline captured: the normal request and its normal response
      (status, size, time) for each feature you test.
- [ ] Scope and version recorded in `notes.md`.

## Authentication and sessions

- [ ] Login: error messages for wrong password vs nonexistent user —
      identical? (An oracle is a lead; both branches must be verified.)
- [ ] Password reset: token in URL, Host header, rate limit, expiry,
      single-use?
- [ ] Session: cookie flags (HttpOnly, Secure, SameSite), session
      fixation (does the session ID change after login?), logout
      invalidates the session server-side?
- [ ] Session survival: does the session survive password change,
      2FA change, account deactivation? (Test with your own accounts.)
- [ ] 2FA: can it be bypassed, downgraded, or skipped (missing step,
      parameter, or direct navigation to the post-2FA page)?
- [ ] OAuth / SSO: `state` validated? `redirect_uri` validated?
      `code` single-use? Account linking confusion (same email, two
      providers)?
- [ ] JWT: algorithm confusion (`none`, RS256→HS256), missing
      signature check, weak secret, `kid` / `jku` header injection,
      expiry ignored?

## Authorisation (IDOR / broken access control)

- [ ] Every object ID in a URL or body: try account B on account A's
      object (sequential IDs, UUIDs found in responses, slugs).
- [ ] Role checks: can a member call an admin endpoint directly
      (bypassing the UI)? Test the raw API, not the button.
- [ ] Tenant checks: can account A read, write, or delete account B's
      tenant objects (the decisive test for cross-tenant programs)?
- [ ] Hidden parameters: fuzz for `role`, `is_admin`, `tenant_id`,
      `owner_id`, `price`, `discount` (see the fuzzing skill).
- [ ] Mass assignment: extra JSON fields in create/update requests —
      are they ignored or stored?
- [ ] State transitions: can a draft be published, an order shipped, a
      ticket closed by someone who should not be able to?
- [ ] Deleted / archived objects: still readable? Still writable?

## Injection

- [ ] XSS: stored (in every field that renders elsewhere), reflected
      (in every parameter), DOM (in JS sinks). Check where the value
      renders, not just where it is stored.
- [ ] SQL injection: in parameters, headers, JSON fields, sort/order
      parameters. Time-based and error-based, not only boolean.
- [ ] SSRF: in URL / webhook / image / import fields. Test with your
      own callback server; never probe internal infrastructure beyond
      proving the request is made.
- [ ] Command injection / SSTI / XXE / file inclusion: only where the
      feature plausibly passes input to a shell, template, parser, or
      filesystem.
- [ ] Open redirect: in `next`, `returnUrl`, `redirect_back_url` —
      confirm the redirect actually happens to the attacker host.
- [ ] CSRF: state-changing requests without a token, token not tied to
      the session, token validated only in the client.

## Business logic

- [ ] Prices, quantities, discounts: server-resolved or client-trusted?
      (If the client sends the price, test it — with test accounts and
      safe values only, never a real purchase.)
- [ ] Limits: rate limits, quotas, trial limits — enforced server-side?
- [ ] Workflows: can a step be skipped, repeated, or reordered
      (double-spend, double-apply, replay)?
- [ ] Race conditions: two simultaneous requests for the same limited
      action (test accounts only, low concurrency).
- [ ] File upload: extension, content-type, size, and storage checks —
      and where the file is served from afterwards.
- [ ] Scheduled / queued actions: delete, edit, or cancel inside and
      OUTSIDE the vendor's lock window (the outside-window control
      decides timing findings).

## Client-side and rendering

- [ ] Link previews / unfurls: who can attach a preview, to whose
      message, with what title and link target? Is the target shown?
- [ ] Rich text / blocks: which schemes (`javascript:`, `data:`) and
      HTML are allowed, and how does the client render them?
- [ ] File previews: SVG, HTML, or PDF rendered in the app's origin?
- [ ] PostMessage / deep links: origins validated? Parameters trusted?

## For every candidate finding

- [ ] Reproduced from a clean state.
- [ ] Request/response pair saved in `evidence/`.
- [ ] Tested as A and as B.
- [ ] Root cause written in one paragraph.
- [ ] Duplicate check done before the report is drafted.
