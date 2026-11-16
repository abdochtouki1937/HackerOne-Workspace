# Stage 3 — Testing Playbook

Testing turns inventory into leads, and leads into findings. Work the test
families in priority order, one family at a time, from the inventory. Every
test starts from a baseline and changes one variable. Every anomaly is
re-checked by hand before it becomes a lead.

Method detail lives in the skills — read them, do not duplicate them:

- `~/workspace/custom-skills/bug-bounty-web/SKILL.md` — web app testing.
- `~/workspace/custom-skills/bug-bounty-api/SKILL.md` — API testing.
- `~/workspace/custom-skills/bug-bounty-investigation/SKILL.md` — mapping
  features, tracing data flow, trust boundaries, differential testing.
- `~/workspace/custom-skills/bug-bounty-fuzzing/SKILL.md` — hidden
  parameters, endpoints, boundaries, value fuzzing.
- `~/workspace/custom-skills/bug-bounty-enumeration/SKILL.md` — object IDs,
  users, oracles, files, versions.

## 3.1 The testing rules (before any family)

1. **Baseline first.** Capture the normal request and its normal response
   (status, size, time). Every later result is compared to the baseline.
   Without a baseline, every response looks anomalous.
2. **One variable at a time.** Change one thing per request: one ID, one
   parameter, one role, one value. If two things change, you cannot say
   which one caused the result.
3. **Test accounts only, A vs B.** Two of your own test accounts. Run the
   same action as A and as B and compare. **One actor is half a finding** —
   a result tested with a single account is not a finding.
4. **Correct request format.** Use the encoding the endpoint actually
   accepts (see Stage 2, section 2.6). A denial produced by the wrong
   encoding is untested, not denied.
5. **Rate-limit everything. Stop on 429.** A 429 is a hard stop for that
   provider in this task. Never hammer a live target with default thread
   counts.
6. **Never brute-force credentials, tokens, OTPs, or passwords.** Never
   test destructive actions with live values. Demo/virtual funds only,
   own accounts only.
7. **Log everything.** Save every request/response pair that matters, with
   the token used, the encoding, and the date. A lead without a saved pair
   is a rumour.

## 3.2 Test families in priority order

### Family 1 — Auth and session

Highest priority: it decides who you are.

- Session survival: does the session/token survive password change, 2FA
  change, deactivation, logout? (Test with your own accounts.)
- OTP/2FA bypass or downgrade: can an AAL1 (password-only) session reach
  AAL2-gated actions (settings, API-token creation, cashier)? Probe the
  recovery-code flow. (Deriv lead A-L1: policy lists OTP/2FA bypass as
  High.)
- Token scope: can a lower-scope token reach a higher-scope action? A
  MANAGEMENT-scoped key minting an ALL-scoped key is the pattern
  (GPUStack N-M2, PoC-verified Medium).
- Session fixation: does the session ID change on login?
- Login oracles: does the error differ for existing vs non-existing
  identifiers? (Deriv F1, Low — see 3.5.)

### Family 2 — IDOR and authorisation (A vs B)

The highest-yield family on API-heavy targets. Work the inventory's
caller-supplied IDs in ranked order.

- For every object ID in the inventory, request B's object as A. Record
  both responses side by side. A 200 with B's data is the finding; a 403
  or 404 is the control.
- Test every action on the object, not just read: update, delete, share,
  change password, transfer, cancel. A read that is denied but a write
  that succeeds is a real finding.
- Test cross-tenant paths specifically: the Hostinger rule is "only
  cross-tenant issues qualify", and the best lead there was the
  `{username}`-keyed hosting endpoints — WordPress jwt-token/auto-login
  links, phpMyAdmin sign-on links, DB password change, file-content read,
  mailbox password change, DNS zone write, domain auth-code read, billing
  `payment_method_id` reuse.
- Test money-moving calls with swapped accounts: Deriv B-L1
  (`transfer_between_accounts` with a free-form `account_from`) is
  Critical if confirmed — one WS call, amount 1, demo funds only.
- Test trade/contract actions by sequential ID: Deriv D-T1
  (sell/cancel/update another account's contract by sequential integer
  `contract_id`) matches the program's own in-scope example.
- Test bulk/multi-account calls with cross-account pairs: Deriv E-L2
  (`bulk-purchase/demo` cross-account pairs) and C-L1 (legacy v3
  `buy_contract_for_multiple_accounts` with a caller-supplied `tokens`
  array).

### Family 3 — Business logic and money-moving calls

- Amounts and limits: are they server-resolved or client-side only?
  (Deriv wave 1: all amount/limit checks client-side only; no idempotency
  key on any money-moving call — both are leads, not findings, until a
  PoC shows the server accepts a tampered value.)
- Price tampering: can a price, quantity, or discount be changed in the
  request? First check whether the API even accepts a price field —
  Hostinger's public Billing API has none, so price tampering there is
  structurally impossible. A negative result like that is worth recording.
- State transitions: can an object move to a state it should not reach
  (draft → published, pending → approved, trial → active)? Map the states
  first (investigation skill, Step 1), then test the transitions.
- Race conditions: only where the program allows, on your own accounts,
  with safe values.

### Family 4 — Input handling and injection

- Injection points from the inventory: parameters, headers, JSON fields,
  file names, URLs. Fuzz values by type (string, number, boolean, null,
  array, object), by boundary (empty, 1, 255/256, 4096), and by shape
  (nested objects, arrays of 1 vs 25 vs 100).
- Stored vs reflected: a stored value that renders in a second context is
  the finding. Trace the data flow (investigation skill, Step 2) — a field
  validated at creation but trusted at render is an XSS; a field checked
  on the web UI but not on the API is an authz bug.
- Server-side fetch: does the server fetch a caller-supplied URL? With
  what headers, what redirects, what credentials? (Slack fetcher work:
  credentials are forwarded to the same host named in the URL but stripped
  on cross-host redirect — standard, correct behaviour, not a finding.
  Record the fetcher's exact behaviour before claiming SSRF.)

### Family 5 — Client-rendering gaps

API truth and client truth are different things. A stored object can be
correctly labelled API-side and still render dangerously client-side.
This is where the Slack finding lived.

- **The Slack unfurl case (2026-11-15, waves 43–47):** API-side, a forged
  unfurl is labelled `is_app_unfurl: true` — designed behaviour, not a
  finding on its own. Client-side, the web client rendered the forged
  title as bright blue bold clickable link text, with NO domain
  header/footer, NO favicon, NO app-provided label, and hovering showed
  NO destination warning — while in-text links show Slack's Link popup.
  The escalation was cross-user: the forge attached to the HUMAN owner's
  message was indistinguishable from a genuine preview. The finding is
  the **gap between the API label and the client rendering**, proved by a
  browser rendering check, not by the API response alone.
- **Rule:** when a finding depends on what the client shows, prove it with
  a browser rendering check (screenshot + the exact page state), not with
  the API object. And test the control: a genuine preview side by side
  with the forged one.
- **Dead ends in this family (Slack waves 2, 21):** rich_text
  `javascript:`/`data:` links and SVG accessories render as plain text /
  `about:blank` / broken image in the web client — dead, not findings.
  A candidate that is dead in the client is dead, however interesting it
  looks API-side.

### Family 6 — API-specific

- Method fuzzing: does an endpoint accept a method it should not (GET on
  a POST-only endpoint, DELETE without auth)?
- Header fuzzing: `X-Forwarded-For`, `X-Original-URL`, `X-Rewrite-URL`,
  `X-User-Id`, `X-Tenant-Id` — a header that changes the response is a
  lead. Confirm by hand.
- Version gaps: does the old API version (`/api/v1/`) enforce the same
  checks as the current one? Old versions are where checks are missing.
- Error vocabulary: record the exact error for each failure mode
  (`cannot_unfurl_url`, `cannot_find_message`, `channel_not_found`…).
  Different errors for the same logical failure are a map of the
  server's internal branches — and a wrong-branch error is a lead.

## 3.3 Boundary pinning (bisection)

When a limit exists, pin it exactly. Do not guess it.

- Binary-search the boundary: try 100, then 101, then 1000 — do not guess.
- Record the exact number and the method. Slack metadata, pinned by
  bisection: event_type ≤ 100 chars stored (101+ dropped with a warning);
  whole metadata object ≤ 4,000 bytes (4,000 stored, 4,001 dropped with
  `metadata_too_large`); event_type counts toward the same budget.
- An early claim of "166" for the event_type boundary was wrong — the
  `ok:true` response hid a warning. Bisection plus read-back corrected it.
  **Never trust `ok:true` alone; check the warning field and read back.**

## 3.4 Chaining small issues

One Low rarely files. Two Lows that chain into one Medium/High do:

- An IDOR that only reads a low-value field + an endpoint that acts on
  that field = full impact.
- An enumeration oracle + a missing rate limit = an account-takeover path.
- A stored value that renders in a second context = stored XSS.

Write the chain as numbered steps, each with its own PoC, and file ONE
report per distinct root cause (group same-root-cause endpoints).

## 3.5 Severity honesty during testing

Do not rank a lead while testing. Rank it only after the verification
gate (Stage 4). Two cautionary cases:

- **Deriv F1 (2026-11-16):** user enumeration on the identifier-first
  login flow — confirmed Low, reproducible PoC. But the positive branch
  (existing identifier advancing to the password step) could NOT be
  verified without an account, and it is stock Ory Kratos behaviour —
  duplicate/wont-fix risk is real. **Do NOT file as-is; re-verify with
  account A first.** A confirmed Low with an unverified branch is still a
  lead, not a filing.
- **AiSOC E-01 (2026-11-12):** the hunt claimed a Critical account
  takeover from an empty-password endpoint. The user's own live HTTP check
  proved it was a LOW password-policy bug: the password IS read and
  required, SCIM/waitlist store unusable markers, and the endpoint needs
  tenant-admin rights with no escalation. The claim was corrected in the
  same turn. Test the claimed thing itself — the field, the marker, the
  privilege — not its neighbour.

## 3.6 Deliverable

For each test family, a section in the program folder's `notes.md` (or a
per-wave report) with:

- What was tested (endpoints, parameters, accounts A/B).
- The baseline for each test.
- Each anomaly: the two requests (A and B), both responses, and the
  verdict — lead (with next step), clean (with evidence), or dead (with
  the reason).
- The ranked lead list for Stage 4, with the PoC file path for each lead.
