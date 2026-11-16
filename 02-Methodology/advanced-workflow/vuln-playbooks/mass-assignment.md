# API Mass Assignment

CWE-915. TBHM file `09_Privledge_Logic_Transport.md`.

Part of the Stage 3 Deepening playbooks — see the index in
`../07-vuln-playbooks.md`. The testing rules in `../03-testing-playbook.md`
still apply: baseline first, one variable at a time, test accounts A vs B
only, rate-limit, stop on 429, log everything.

**Trigger conditions.** Any endpoint that accepts a JSON object and
writes it to a model: profile update, settings, create/update calls.
The API takes more fields than the UI sends. The tell is an endpoint
whose request body is a model object (or a nested object) rather than
a small fixed set of fields.

**Get the model first — before sending anything.**

1. Read the API docs, the OpenAPI spec, or the JS that builds the
   request. List the fields the model has: `role`, `isAdmin`,
   `tenantId`, `price`, `approved`, `ownerId`, `balance`,
   `isVerified`, `plan`.
2. Compare what the UI sends with what the model has. Every model
   field the UI does not send is a candidate — the server may bind
   it anyway.
3. Check how the server binds: does it whitelist fields, blacklist
   a few, or bind everything it receives? Error messages, the
   OpenAPI schema, and the response shape all hint at this. A
   response that echoes back a field you sent is a hint, not proof.

**The exact test.**

1. **Control.** Send the normal request as A (exactly what the UI
   sends). Read the object back and record its fields.
2. **One extra field per request.** Send the same request with one
   extra field (e.g. `"role": "admin"`, `"isAdmin": true`,
   `"ownerId": "<account-B>"`). One field per request — never stack
   several, or you will not know which one stuck.
3. **Read the object back.** A field that stuck (persisted in the
   read-back) is the finding. The response echoing the field is not
   enough — the server may echo and discard. Read-back is the test.
4. **Test nested fields too.** The Craft CMS C1 case was a nested-field
   bypass — the fix enforced field-layout conditions only when
   `fromRequest=true`, but MCP writes normalised nested Matrix/Content
   Block/Addresses values with `fromRequest=false`, so an authenticated
   MCP user could set admin-only nested fields (live PoC: stored
   `adminOnlyNote` in a Matrix block). Top-level was rejected; nested
   was not. Test both levels: top-level fields, then the same field
   inside each nested object/array.
5. **Test arrays and nested IDs.** Inside a nested object, try
   swapping an owner/tenant ID, adding an entry with a privileged
   flag, or reordering entries where order carries privilege.
6. **Test every method.** The same model may be bound differently by
   POST (create), PUT (replace), and PATCH (partial update). GPUStack
   N-M2 was reachable via both POST and PUT `/v2/api-keys` — test
   each method separately.
7. **Test via GraphQL mutations too.** A mutation that takes an input
   object has the same binding surface (see `graphql.md`).

**Common false positives.**

- The API accepts the field and returns it in the response but does
  not persist it (read-back is the test, not the response).
- The field is writable by design for that role (check the role —
  an admin setting `role` is not a finding; a plain user doing it is).
- The field sticks in the object but has no effect (e.g. a display
  label the server never enforces). The finding needs the persisted
  field to change behaviour or privilege — state what it changes.
- A nested field that sticks only inside your own object and grants
  nothing (same check: does it change what you can do?).

**What proof looks like.** The read-back of the object showing the
injected field persisted, with the request that set it, the control
read-back without it, and a statement of what the persisted field
changes (role, ownership, approval, price). One field per proof.

**Grounded examples (this workspace).**

- **Craft CMS C1 (live PoC, HIGH):** MCP nested-field bypass —
  `adminOnlyNote` stored in a Matrix block via `fromRequest=false`
  normalisation. Top-level `internalNote` was rejected; nested was
  not. Test both levels.
- **Craft CMS C2 (live PoC, MEDIUM, adjacent):** control-panel
  `entries/create` set every custom field with no condition check —
  `internalNote` stored in a draft. Same root cause (no field-level
  check), different entry point.
- **GPUStack N-M2 (PoC-verified Medium, adjacent):** a
  MANAGEMENT-scoped key minted an ALL-scoped key via POST/PUT
  `/v2/api-keys` — the minting endpoint bound a scope the caller
  should not have been able to set. Test scope/role fields in
  creation endpoints the same way.
- **OpenMausBot (code-only Medium, adjacent):** an `app_settings`
  "safe" tier let a bot's turn apply security-relevant changes at
  once with no person approval — a settings object bound more than
  the caller should have been able to set. Code-only until a live
  demo; do not file on the binding alone.
