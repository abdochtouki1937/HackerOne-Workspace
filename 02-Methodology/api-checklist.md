# API Checklist

Manual testing checklist for APIs (REST, GraphQL, WebSocket). Work it
top to bottom for each endpoint, as account A and then as account B, and
compare both responses.

## Setup

- [ ] API documentation found: OpenAPI/Swagger spec, GraphQL schema,
      or endpoints extracted from the app's JS.
- [ ] Baseline captured for each endpoint: method, auth, normal request,
      normal response (status, size, time).
- [ ] Test accounts A and B with API tokens. Record that tokens exist —
      never their values.
- [ ] Required research header set on every request (e.g.
      `X-HackerOne-Research: <username>` where the program requires it).

## Discovery

- [ ] All paths from the OpenAPI spec (`jq -r '.paths | keys[]'`).
- [ ] All endpoints from JS bundles (`grep -rhoE '"/api/[^"]+"'`).
- [ ] Historical API URLs (gau / waybackurls, filter `/api/`).
- [ ] Old API versions (`/api/v1/` while the app uses v2) — test them;
      old versions carry old bugs.
- [ ] GraphQL: introspection enabled? Full schema retrievable?
      (`graphql-endpoints.txt`, `graphql-fields.txt` in 05-Wordlists).
- [ ] WebSocket: which events exist, which need auth, which accept
      caller-supplied IDs?

## Authentication and authorisation

- [ ] Missing auth: does the endpoint work with no token at all?
- [ ] Token scope: does a low-scope token (read-only, management-only)
      gain higher rights (minting, escalation)?
- [ ] Object-level authorisation: every caller-supplied ID
      (`user_id`, `account_id`, `order_id`, `contract_id`) tested as B
      on A's object.
- [ ] Function-level authorisation: can a low-privilege role call admin
      endpoints directly?
- [ ] Tenant isolation: can account A act on account B's tenant
      objects (the decisive test for cross-tenant programs)?
- [ ] Mass assignment: extra fields in create/update bodies — stored
      or ignored?
- [ ] IDOR via related objects: an endpoint that lists A's objects
      leaking B's objects through a join, search, or export.

## Input handling

- [ ] Parameter discovery per endpoint (Arjun, param-fuzzer.py).
- [ ] Type confusion: string where a number is expected, array where
      an object is expected, null, boolean, nested objects.
- [ ] Boundary values: empty string, 1 char, 255/256, 4096, huge ints,
      negative ints, arrays with 1 vs 25 vs 100 items. Pin exact limits
      by bisection.
- [ ] Injection: SQLi, NoSQLi, command injection, SSRF in URL fields,
      XXE in XML bodies.
- [ ] GraphQL: field-level authorisation, query depth / complexity
      limits, batching (many queries in one request), IDOR in nested
      resolvers.
- [ ] Pagination / filtering: `limit`, `offset`, `sort`, `filter`
      parameters — do they leak other tenants' rows? Do counts and
      lists agree?
- [ ] HTTP methods: try GET/POST/PUT/PATCH/DELETE/OPTIONS on each
      endpoint — a method that should be blocked but returns 200 is a
      lead.
- [ ] Headers: `X-Forwarded-For`, `X-Original-URL`, `X-Rewrite-URL`,
      `X-User-Id`, `X-Tenant-Id` — does any of them change the response?

## Business logic

- [ ] Money-moving calls: `transfer_between_accounts`,
      `buy` / `sell` / `cancel`, refunds — is `account_from` /
      `account_to` / `contract_id` caller-supplied, and is ownership
      enforced server-side?
- [ ] Idempotency: is there an idempotency key? Can the same request be
      replayed for a double effect?
- [ ] Amounts and limits: server-resolved or client-trusted?
- [ ] Rate limits: per endpoint, per account — enforced? What happens
      past the limit (429, silent drop, or nothing)?
- [ ] Webhooks: signature verified? Replayable? Can an attacker forge
      an event with a chosen sender identity?
- [ ] Bulk endpoints: `bulk-purchase`, `buy_contract_for_multiple_accounts`
      — do the items' accounts have to belong to the token owner, and
      is that enforced?

## Response handling

- [ ] Error messages: do they leak existence (404 vs 403 vs 400 for
      real vs fake objects)? Record both responses, byte counts included.
- [ ] Verbose errors: stack traces, internal paths, database details?
- [ ] Sensitive data in responses: tokens, secrets, other users' PII,
      internal hostnames?
- [ ] Caching: are authenticated responses cached and served to other
      users?

## For every candidate finding

- [ ] Reproduced from a clean state.
- [ ] Request/response pair saved in `evidence/`.
- [ ] Tested as A and as B.
- [ ] Root cause written in one paragraph.
- [ ] Duplicate check done before the report is drafted.
