# GraphQL

CWE-862, CWE-200. (TBHM's web-services section; PortSwigger's GraphQL
material.)

Part of the Stage 3 Deepening playbooks — see the index in
`../07-vuln-playbooks.md`. The testing rules in `../03-testing-playbook.md`
still apply: baseline first, one variable at a time, test accounts A vs B
only, rate-limit, stop on 429, log everything.

**Trigger conditions.** Any `/graphql` endpoint, or any API that
accepts a GraphQL query. Introspection enabled is a lead, not a
finding on its own — most programs list it as always-rejected.

**The exact test.**

1. **Introspection first.** Query `__schema` and record the types,
   fields, and mutations. This is your endpoint inventory for
   GraphQL — treat it like the JS endpoint extraction in Stage 2.
   Also try `__type(name: "...")` for a single type if the full
   schema is blocked.
2. **Introspection off — Clairvoyance schema reconstruction.** When
   `__schema` is disabled, the schema is still recoverable by
   brute force, because GraphQL error messages leak field names.
   Use Clairvoyance (nikitastupin/clairvoyance) or the same
   technique by hand:
   a. Start from a known entry point (a query the UI uses — read it
      from the client JS / network traffic).
   b. Probe candidate field names from a wordlist against each type:
      send a query naming the candidate field; a "Cannot query field"
      error means the field does not exist, while a different error
      (an auth error, a type error, a non-null error) means it does
      exist. Each probe is one field, one response — record which
      error means "exists" on this target before trusting it.
   c. Reconstruct the schema field by field, then arguments, then
      nested types: for each confirmed field, probe its sub-fields
      the same way.
   d. Validate the reconstructed schema by running a real query
      against it as A (your own data first). A reconstructed field
      that returns data is confirmed; one that only ever errors is
      not.
   e. Do not flood: Clairvoyance with a large wordlist is many
      requests — keep the rate inside the program's limits, stop on
      429, and prefer a targeted wordlist (fields the UI uses, plus
      the usual suspects: `id`, `email`, `role`, `admin`, `owner`,
      `password`, `token`) over a huge generic one.
3. **Field-level authz.** For every field that returns an object,
   request B's object as A (same test as IDOR, `idor.md`). A field
   the UI never queries is a candidate — the UI's query is not the
   server's check. Test read fields first, then mutations.
4. **Mass assignment via mutations.** Add a field to a mutation the
   UI does not send (`mass-assignment.md`). Read the object back.
   Test nested input objects separately from top-level inputs — the
   check that covers the top level often does not cover the nested
   one (Craft CMS C1 pattern).
5. **Batching / aliases.** Send several aliased queries in one
   request (e.g. the same password-reset or OTP-guess query aliased
   many times). If the server runs them all without a batch limit,
   that is a rate-limit bypass lead — record it, and only pursue it
   if the program's scope covers it.
6. **Depth / complexity.** Test query depth and circular nesting only
   within the program's limits — a depth limit that is not enforced
   is a DoS lead, and DoS is usually out of scope. Record it, do
   not pursue it as a filing.

**Common false positives.**

- Introspection alone (always-rejected on most programs — needs a
  chain to file). A reconstructed schema alone is also not a
  finding; it is inventory.
- A field that returns data the caller already owns.
- A deep query that is slow but bounded (a limit exists and works).
- A Clairvoyance "field exists" signal that turns out to be a
  generic error the server returns for every unknown field — always
  calibrate the error signal against a known-good and a known-bad
  field first.
- An aliased batch that the server rejects or rate-limits correctly.

**What proof looks like.** The GraphQL response returning B's data
to A's query, or the mutation persisting an injected field — with the
exact query and the read-back. For a Clairvoyance reconstruction,
the proof is the reconstructed schema plus a real query against it
returning data (your own data first, then the A-vs-B test).

**Grounded examples (this workspace).**

- **Craft CMS C1/C2 (live PoCs, adjacent):** the nested-field bypass
  (C1, MCP) and the unchecked custom-field write (C2, control panel)
  are the pattern to test inside GraphQL mutations too — top-level
  fields checked, nested input objects not. Controls held in the
  Craft case: GraphQL rejected C1 and a normal save dropped C2, so
  test the GraphQL path separately from the REST/UI path; a check
  on one does not imply a check on the other.
- **Hostinger (adjacent):** 353-path OpenAPI spec, 85%
  caller-supplied IDs — the same inventory discipline applies to a
  GraphQL schema: enumerate first (introspection or Clairvoyance),
  then A-vs-B every object-returning field.
