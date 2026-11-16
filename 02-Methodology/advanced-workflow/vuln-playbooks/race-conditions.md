# Race Conditions

CWE-362, CWE-367. Test only where the program allows, on your own
accounts, with safe values. A race test is not a load test.

Part of the Stage 3 Deepening playbooks — see the index in
`../07-vuln-playbooks.md`. The testing rules in `../03-testing-playbook.md`
still apply: baseline first, one variable at a time, test accounts A vs B
only, rate-limit, stop on 429, log everything.

**Trigger conditions.** Any check-then-act sequence on a shared
resource: balance check then debit, quota check then use, coupon
validation then redemption, "only one" constraints (one vote, one
trial, one claim, one seat, one username). Any place the server reads
a value, decides, then writes — with a gap between the read and the
write. Time-of-check / time-of-use (TOCTOU) is the same shape in
files and state: check a permission or a path, then act on it after
it changed.

**Map the check and the act first.**

1. Find the two steps in the code or the API: the check (balance
   sufficient? coupon unused? seat free?) and the act (debit, redeem,
   reserve). The race lives between them.
2. Confirm the check and the act are separate operations — a single
   atomic database transaction (e.g. `UPDATE ... WHERE balance >= X`)
   has no race to win. If the code does the check and the write in
   one atomic statement, record that and move on.
3. Note what the shared resource is and what "only one" means:
   per-user, per-account, per-coupon, per-order. A limit scoped
   per-account is not violated by two accounts each using it once.

**The exact test.**

1. **Control (sequential).** Send the request once as A. Record the
   result and the resulting state (balance, count, claim). Then send
   it a second time sequentially. The second sequential request must
   fail — if it succeeds sequentially, there is no race to test; it
   is a plain business-logic bug (see `business-logic.md`).
2. **Parallel (2–3 at once, not a flood).** Send the same request in
   parallel — two or three simultaneous requests, e.g. with parallel
   curl, a small script, or Burp Turbo Intruder's single-packet mode
   where the program allows it. Use your own accounts and
   demo/virtual values only. Keep the parallel count small: two
   requests that both succeed prove the race; twenty is a DoS.
3. **Compare.** A second success in parallel where only one should
   succeed is the finding. Read the resulting state, not just the
   status codes: both debits applied, both redemptions recorded,
   count = 2 where the rule allows 1.
4. **Repeat once.** Run the parallel test a second time (fresh
   resource: a new coupon, a reset balance). A race that reproduces
   once is evidence; a one-off may be a retry, a cache, or a fluke.
   If it does not reproduce, record the attempt and do not file it.
5. **Vary one thing at a time.** If the parallel test fails, try:
   the same request from two different sessions of the same account,
   and from accounts A and B against the same shared resource
   (e.g. the same coupon code). Do not change the payload and the
   timing at once.
6. **TOCTOU variant.** Where the check is on a file or a path (e.g.
   a symlink check before a read/write — cf. the Sandcastle C-01
   symlink window in `file-upload-traversal.md`), change the target
   between the check and the act in a lab or on your own test
   instance only.

**Common false positives.**

- A second request that succeeds because the limit is per-account and
  each of your accounts has its own limit (check the scope of the
  limit first).
- A result that differs because of caching, a retry, or an
  asynchronous reversal — not because of the race. Re-read the final
  state after a pause.
- A parallel test that "succeeds" twice because the first request
  was actually rejected and retried by your tooling (check the
  request log, not just the count of 200s).
- A slow endpoint where both requests were processed sequentially
  after all — timing alone is not proof; the doubled state is.

**What proof looks like.** Two parallel requests, both succeeding,
where the business rule allows only one — with the resulting state
(balance, count, claim) saved, the sequential control showing the
second request normally fails, and the exact requests (timestamps
included). State the parallel count used (2–3) so the triager knows
this was not a load test.

**Grounded examples / related cases.**

- **Deriv (lead, not a finding):** no idempotency key on any
  money-moving call, and duplicate pairs honoured in
  `bulk-purchase/demo` (E-L2). The race/idempotency test is:
  send the same money-moving request twice in parallel with demo
  funds and read the ledger — a second debit is the finding;
  the missing key alone is not.
- **OpenMausBot Finding 1 (adjacent):** approval self-promotion via
  a loopback PATCH — a check-then-act gap in an approval flow, not
  a timing race, but the same "check it, then act before the state
  settles" shape. Test approval flows both sequentially and in
  parallel.
- **Coupon / trial "only one" constraints** are the classic race
  target on any target with a redemption flow: validate-then-redeem
  with no atomic claim is the pattern to look for in the code first.
