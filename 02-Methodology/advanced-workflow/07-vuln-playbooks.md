# Stage 3 Deepening — Vulnerability Playbooks

One playbook per high-yield class. Each playbook answers the same four
questions: **when to try it** (trigger conditions), **the exact test**
(A vs B, one variable at a time), **what is not a bug** (false positives),
and **what proof looks like** (the PoC bar). Read the playbook for the
class before you test it — do not spray payloads and hope.

These playbooks sit on top of Stage 3 (`03-testing-playbook.md`). The
testing rules there still apply to every class: baseline first, one
variable at a time, test accounts A vs B only, rate-limit, stop on 429,
log everything.

Class order is by yield on HackerOne-style targets, not by severity.
NahamSec's 2025 earnings breakdown put SSRF at ~25% of bounties and XSS
at ~18% — but on API-heavy targets in this workspace's own hunts, IDOR
and authz produced the most ranked leads (Hostinger: 353-path spec, 85%
caller-supplied IDs; Deriv: B-L1, D-T1, E-L2). Start with the class the
inventory points at, not the class you like most.

Sources for the class techniques: The Bug Hunters Methodology (TBHM) by
Jason Haddix — https://github.com/jhaddix/tbhm (class files 04–09, 12);
PortSwigger Web Security Academy — https://portswigger.net/web-security;
PayloadsAllTheThings — https://github.com/swisskyrepo/PayloadsAllTheThings.

---

## 1. IDOR / Broken Object-Level Authorisation (BOLA)

The highest-yield class on API-heavy targets. CWE-639 / CWE-862.

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

---

## 2. SSRF (Server-Side Request Forgery)

CWE-918. NahamSec's top earner (~25% of his 2025 bounties).

**Trigger conditions.** Anywhere the server fetches a caller-supplied
URL: webhook URLs, avatar/image URLs, link unfurl/preview fetchers,
file import from URL, PDF generation from URL, "check this link"
features. Also: any parameter that looks like a URL, a host, or a path
the server will resolve.

**The exact test.**

1. Point the fetcher at your own collaborator/interactsh URL (or a
   URL you control) and confirm the server actually fetches it
   (out-of-band callback = the fetcher is real).
2. Point it at a private address: `http://169.254.169.254/` (cloud
   metadata), `http://127.0.0.1/`, `http://localhost:PORT/`, and an
   internal hostname from the inventory. Use your own test instance
   for the internal target where possible; never fetch a real
   internal service you do not own.
3. Test the bypasses one at a time: redirect (does the fetcher follow
   a 302 from your server to a private address?), DNS rebinding
   (does it resolve the hostname once or twice?), URL parsing gaps
   (`http://127.0.0.1%09@public/`, `http://0x7f.0.0.1/`, decimal
   and octal IP forms), protocol confusion (`gopher://`, `file://`).
4. Record exactly what the server returns for each: status, body,
   timing, and whether the fetch happened at all.

**Common false positives.**

- The server fetches the URL but returns only a generic error and no
  response body — the fetch happened, but nothing is exfiltrated.
  That is a lead for a blind-SSRF chain, not a finding on its own.
- The fetcher strips credentials on cross-host redirect and forwards
  them only to the same host (standard, correct behaviour — the Slack
  fetcher did exactly this; it is not a finding).
- A fetch that only reaches public internet hosts (the fetcher has a
  private-IP blocklist that works). Test the blocklist, do not assume
  it fails.

**What proof looks like.** An out-of-band callback from the target's
server to your collaborator URL, plus a second request showing a
private address was reached (metadata body, internal response, or a
timing difference that only a private service explains). For blind
SSRF, the callback alone proves the fetch; the impact needs the
second step.

---

## 3. XSS — Stored, Reflected, DOM

CWE-79. ~18% of NahamSec's 2025 bounties.

**Trigger conditions.** Any field that is stored and later rendered
(stored), any parameter reflected in a response (reflected), or any
client-side code that writes attacker-controlled data into the DOM
with `innerHTML`, `document.write`, or a framework's unsafe binding
(DOM).

**The exact test.**

1. **Stored:** submit a marker payload as A in a field (name, bio,
   comment, title, file name), then view it as B in every context
   where it renders: the web UI, the mobile app, email, exports,
   notifications. Record where it executes and where it is escaped.
2. **Reflected:** put a marker in each parameter, header, and path
   segment; check whether it is reflected unescaped, and in which
   context (HTML body, attribute, script, URL).
3. **DOM:** read the client JS for sinks (`innerHTML`, `eval`,
   `location.hash` flows). Feed the sink a marker and watch whether
   it executes.
4. **Client-rendering gap (the Slack case):** when the API stores a
   label or a flag (e.g. `is_app_unfurl: true`) but the client does
   not show it, prove the gap with a browser rendering check —
   genuine control side by side with the forged one. The finding is
   the gap, not the API object.
5. Use a harmless marker first (`<script>` is not needed to prove
   reflection — a unique string in the response proves the sink; only
   use an executing payload when the program allows it and the impact
   needs it).

**Common false positives.**

- A payload that is stored but always escaped on render (check every
  render context — one escaped context does not prove all are).
- A reflected value inside a JSON response with the right content
  type (`application/json` is not HTML execution).
- A `javascript:` or `data:` link that the web client renders as
  plain text / `about:blank` / broken image (Slack waves 2 and 21 —
  dead in the client, however interesting it looks API-side).
- Self-XSS: a payload that only executes for the user who entered it.
  Most programs exclude it. The finding needs another victim.

**What proof looks like.** A screenshot or browser check showing the
payload executing (or the forged content rendering indistinguishably
from genuine content) in a victim's view — account B viewing
account A's content — plus the stored API object that produced it.

**Grounded example (this workspace).** Slack app-unfurl forgery
(Medium, CWE-451): any app claims any domain with zero ownership
verification, then attaches a forged preview via `chat.unfurl` with
an arbitrary title and a `title_link` to any URL. The web client
rendered the forged title as bright blue bold clickable text with no
domain line, no favicon, no app label, and no hover warning. The
escalation was cross-user: the forge attached to the human owner's
message was indistinguishable from a genuine preview.

---

## 4. SQL Injection

CWE-89. TBHM file `06_SQLi.md`.

**Trigger conditions.** Any parameter that reaches a database query:
search boxes, filters, sort/order parameters, IDs in query strings,
JSON fields that become WHERE clauses. Sort parameters are the most
commonly missed.

**The exact test.**

1. Start with a logic probe, not a payload: `'`, `"`, `\`, and a
   boolean (`AND 1=1` vs `AND 1=2`) — compare the two responses.
   A difference in content, count, or timing is the signal.
2. Confirm with a time-based probe only if the program allows it and
   the target is your own test account's data: `SLEEP(5)` vs `SLEEP(0)`.
3. Map the query: number of columns (ORDER BY), then extract one
   value you already own (your own account's data) to prove the
   channel works. Never extract other users' data.
4. Check the error path: does a database error leak the query, the
   table names, or the driver? Record the exact error text.

**Common false positives.**

- An error message that changes with a quote but is a generic
  validation error, not a database error.
- A timing difference caused by caching or a slow endpoint, not by
  the query. Repeat the probe three times.
- A WAF block (403 with a WAF signature) is not an injection — it is
  a block. Record it and move on.

**What proof looks like.** A boolean-based difference on your own
data (e.g. `AND 1=1` returns your rows, `AND 1=2` returns none), or
a time delay that tracks the sleep value, plus the exact request.
Extraction of your own data only.

---

## 5. Authentication and Session Flaws

CWE-287, CWE-384, CWE-613. TBHM file `04_Authorization_and_Session.md`.

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

---

## 6. Business Logic and Money-Moving Calls

CWE-840, CWE-841. The class Farah Hawa's work shows best: understand
the app's logic, think like an attacker, and no fancy tools are needed.

**Trigger conditions.** Any flow that moves value: payments, transfers,
trades, purchases, discounts, trials, quotas, votes, invitations,
exports, approvals. Any state machine: draft → published, pending →
approved, trial → active.

**The exact test.**

1. **Map the flow first.** Write the states and who can move an object
   between them (investigation skill, Step 1). Test the transitions
   that should not exist.
2. **Amounts and limits:** change the amount, quantity, price, or
   discount in the request. First check whether the API even accepts
   the field — Hostinger's public Billing API has no price field, so
   price tampering there is structurally impossible. If the server
   resolves the price, the test is dead; record it.
3. **Cross-account value:** swap the source or destination account
   (Deriv B-L1: `transfer_between_accounts` with `account_from` set
   to B's loginid — demo funds only).
4. **Idempotency:** send the same money-moving request twice. No
   idempotency key on any money-moving call (Deriv wave 1) is a lead
   until a PoC shows the second request moves money again.
5. **Trial/eligibility reuse:** copy a value that gates eligibility
   from an account that has it to one that used it up (Farah Hawa's
   LinkedIn case: a Promotion ID copied from an eligible account A
   into account B's trial request, which had already used its trial —
   the server granted the trial; High, $2,500–$5,000).
6. **Approval/self-promotion:** can an actor approve its own request,
   or promote its own role? (OpenMausBot Finding 1: approval
   self-promotion via a loopback PATCH.)

**Common false positives.**

- A client-side check that the server re-checks (the UI hides the
  button, the API rejects the request — test the API, not the UI).
- A price/amount that the server ignores and re-resolves (the
  tampered value never reaches the ledger).
- A state transition that an admin can do by design (check the role
  first).

**What proof looks like.** The ledger/balance/state after the tampered
request, showing value moved or a state reached that should not exist
— with the request that did it, and the control (the honest request
for comparison). Demo/virtual funds only, own accounts only.

---

## 7. API Mass Assignment

CWE-915. TBHM file `09_Privledge_Logic_Transport.md`.

**Trigger conditions.** Any endpoint that accepts a JSON object and
writes it to a model: profile update, settings, create/update calls.
The API takes more fields than the UI sends.

**The exact test.**

1. Get the model: read the API docs, the OpenAPI spec, or the JS that
   builds the request. List the fields the model has (role, isAdmin,
   tenantId, price, approved, ownerId).
2. Send the normal request as A, then the same request with one extra
   field (e.g. `"role": "admin"`, `"isAdmin": true`, `"ownerId": "<B>"`).
   One field per request.
3. Read the object back. A field that stuck is the finding.
4. Test nested fields too: the Craft CMS C1 case was a nested-field
   bypass — the fix enforced field-layout conditions only when
   `fromRequest=true`, but MCP writes normalised nested Matrix/Content
   Block/Addresses values with `fromRequest=false`, so an authenticated
   MCP user could set admin-only nested fields (live PoC: stored
   `adminOnlyNote` in a Matrix block). Top-level was rejected; nested
   was not. Test both levels.

**Common false positives.**

- The API accepts the field and returns it in the response but does
  not persist it (read-back is the test, not the response).
- The field is writable by design for that role (check the role).

**What proof looks like.** The read-back of the object showing the
injected field persisted, with the request that set it.

---

## 8. OAuth and OpenID Confusion

CWE-287, CWE-441. TBHM file `09_Privledge_Logic_Transport.md`.

**Trigger conditions.** Any login with a third party (Google, GitHub,
OIDC), any "login with" button, any token or code the client hands to
the server, any email/username fallback in the identity flow.

**The exact test.**

1. **Confused issuer/audience:** does the server check `iss` and `aud`
   on the token it accepts? A token issued for another app, or by
   another issuer, that the server accepts is the finding.
2. **Email/username fallback:** when the IdP does not return a verified
   email, does the server fall back to a caller-supplied or unverified
   value? (Vikunja E-01/E-02: OIDC email-fallback and username-fallback
   account takeover — the fallback trusted an identifier the caller
   influenced. Live-confirmed on 2.8.0.)
3. **Code/token reuse:** can an authorisation code or token be replayed
   for a second account, or used after expiry?
4. **Redirect URI:** does the authorisation server validate the
   redirect URI exactly, or does it accept a prefix/pattern match an
   attacker can abuse? (Test with your own domains only.)

**Common false positives.**

- A redirect-URI check that accepts a subdomain the program owns and
  controls (check who owns the subdomain).
- A fallback that stores an unusable marker when the email is
  unverified (AiSOC pattern — a marker that cannot log in is not a
  takeover).

**What proof looks like.** A login as B (or as a victim identity)
achieved through the confused value, with the token/code and the
server's acceptance saved.

---

## 9. File Upload and Path Traversal

CWE-434, CWE-22. TBHM files `07_File_Upload.md`, `06_SQLi.md` (file
inclusion).

**Trigger conditions.** Any file upload (avatar, attachment, import),
any parameter that names a file or a path (download, export, include,
template name), any archive extraction.

**The exact test.**

1. **Upload:** upload a file with a double extension, a null byte
   (where the program allows testing it), a case change, or a
   content-type mismatch. Check where it lands and how it is served
   (content type, content-disposition, same origin or a separate
   domain). A file served as HTML/JS from the app's origin is the
   finding.
2. **Traversal:** request a file by path and try `../` sequences,
   URL encodings (`%2e%2e%2f`), and separators (`..\;`, `....//`).
   Read a file you own first (your own upload) to prove the channel,
   then try one step outside the intended directory — on your own
   test data only.
3. **Symlink/archive:** where archives are extracted, test whether a
   symlink inside the archive is followed (Sandcastle C-01 pattern:
   symlink window, verified end-to-end in a sandbox). Only in a lab
   or on your own test instance.

**Common false positives.**

- An upload that is stored but served with a safe content type and a
  `Content-Disposition: attachment` from a separate domain.
- A traversal probe that returns a generic error with no file content
  (the error text alone is not a read).

**What proof looks like.** The file served and executed/rendered in
the wrong context, or the content of a file outside the intended
directory that you own — saved, with the request.

---

## 10. Race Conditions

CWE-362, CWE-367. Test only where the program allows, on your own
accounts, with safe values.

**Trigger conditions.** Any check-then-act sequence on a shared
resource: balance check then debit, quota check then use, coupon
validation then redemption, "only one" constraints (one vote, one
trial, one claim).

**The exact test.**

1. Map the check and the act (two separate steps in the code or the
   API). The race lives between them.
2. Send the same request in parallel (two or three at once, not a
   flood) from your own accounts, with demo/virtual values.
3. Compare the result with a single sequential request. A second
   success where only one should succeed is the finding.
4. Keep the parallel count small. A race test is not a load test —
   hammering the target is a DoS, not a PoC.

**Common false positives.**

- A second request that succeeds because the limit is per-account and
  each of your accounts has its own limit (check the scope of the
  limit first).
- A result that differs because of caching, not because of the race.

**What proof looks like.** Two parallel requests, both succeeding,
where the business rule allows only one — with the resulting state
(balance, count, claim) saved.

---

## 11. GraphQL

CWE-862, CWE-200. (TBHM's web-services section; PortSwigger's GraphQL
material.)

**Trigger conditions.** Any `/graphql` endpoint, or any API that
accepts a GraphQL query. Introspection enabled is a lead, not a
finding on its own — most programs list it as always-rejected.

**The exact test.**

1. **Introspection:** query `__schema` and record the types, fields,
   and mutations. This is your endpoint inventory for GraphQL —
   treat it like the JS endpoint extraction in Stage 2.
2. **Field-level authz:** for every field that returns an object,
   request B's object as A (same test as IDOR, §1). A field the UI
   never queries is a candidate.
3. **Mass assignment via mutations:** add a field to a mutation the
   UI does not send (§7). Read the object back.
4. **Depth / batching:** test query depth and aliased batching only
   within the program's limits — a depth limit that is not enforced
   is a DoS lead, and DoS is usually out of scope. Record it, do not
   pursue it as a filing.
5. **Nested-field bypass:** like Craft CMS C1, test nested objects
   inside mutations separately from top-level fields — the check that
   covers the top level often does not cover the nested one.

**Common false positives.**

- Introspection alone (always-rejected on most programs — needs a
  chain to file).
- A field that returns data the caller already owns.
- A deep query that is slow but bounded (a limit exists and works).

**What proof looks like.** The GraphQL response returning B's data
to A's query, or the mutation persisting an injected field — with the
exact query and the read-back.

---

## After a confirmed bug: the sibling rule and the A-to-B signal

Two rules from the federicopinan/ai-bug-bounty-hunter repo
(https://github.com/federicopinan/ai-bug-bounty-hunter) that belong
in every playbook, not just in the triage file:

- **Sibling rule (#10).** After a confirmed bug, check every variant
  of the endpoint (`/api/user/{id}/...` and every sibling path that
  shares the handler). The same developer made the same mistake in
  the same code.
- **A-to-B signal (#11).** A confirmed bug A means the developer made
  the same mistake elsewhere. Hunt for bug B within 20 minutes,
  before writing the report. The window matters: the finding is fresh
  in your head, and the same pattern is fastest to spot now.

And the rule from STÖK ("hack, learn, share"):
after every confirmed bug, generalise the root cause into a detection
rule and write it into this file or into `notes.md`. The next target
gets tested against the rule, not just against the memory of one bug.
Source: https://github.com/maybe4a6f7365/agentic-bug-bounty-framework/blob/HEAD/knowledge-sources/creators/02-stok.md

## Sources

- The Bug Hunters Methodology (TBHM), Jason Haddix —
  https://github.com/jhaddix/tbhm (class files 04–09, 12; Fast Testing
  Checklist)
- PortSwigger Web Security Academy — https://portswigger.net/web-security
- PayloadsAllTheThings — https://github.com/swisskyrepo/PayloadsAllTheThings
- ai-bug-bounty-hunter, rules #10/#11 —
  https://github.com/federicopinan/ai-bug-bounty-hunter
- STÖK, "hack, learn, share" —
  https://github.com/maybe4a6f7365/agentic-bug-bounty-framework/blob/HEAD/knowledge-sources/creators/02-stok.md
- NahamSec earnings breakdown (SSRF ~25%, XSS ~18%) —
  https://github.com/zaakirio/reconductor/blob/HEAD/recon-methodology-research.md
- Farah Hawa, LinkedIn Promotion ID business-logic case —
  https://www.instagram.com/reel/DG-dSaUMMDZ/
- Hacker101, "How to Write a Good Report and Use the CVSS Calculator" —
  https://www.hacker101.com/resources/articles/writing_a_report_and_cvss
