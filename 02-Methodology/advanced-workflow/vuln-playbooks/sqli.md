# SQL Injection

CWE-89. TBHM file `06_SQLi.md`.

Part of the Stage 3 Deepening playbooks — see the index in
`../07-vuln-playbooks.md`. The testing rules in `../03-testing-playbook.md`
still apply: baseline first, one variable at a time, test accounts A vs B
only, rate-limit, stop on 429, log everything.

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
