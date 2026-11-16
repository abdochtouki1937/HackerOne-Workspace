# Business Logic and Money-Moving Calls

CWE-840, CWE-841. The class Farah Hawa's work shows best: understand
the app's logic, think like an attacker, and no fancy tools are needed.

Part of the Stage 3 Deepening playbooks — see the index in
`../07-vuln-playbooks.md`. The testing rules in `../03-testing-playbook.md`
still apply: baseline first, one variable at a time, test accounts A vs B
only, rate-limit, stop on 429, log everything. Demo/virtual funds only,
own accounts only — never real money, never another user's funds.

**Trigger conditions.** Any flow that moves value: payments, transfers,
trades, purchases, discounts, trials, quotas, votes, invitations,
exports, approvals. Any state machine: draft → published, pending →
approved, trial → active, cart → paid → fulfilled. Any limit the
business relies on: one trial per user, one vote per user, one coupon
per order, a spending cap, a free-tier quota.

**Map the flow first — before any tampering.**

1. Write the states and the transitions: who (which role) can move an
   object from which state to which state, and what the server checks
   at each step. Use the investigation skill, Step 1.
2. List every value the client sends that the business trusts:
   amount, quantity, price, discount, currency, account IDs, coupon
   code, trial/eligibility flag, promotion ID.
3. For each value, ask: does the server re-resolve it, or does it
   trust the client's number? If the server re-resolves it, the test
   is dead — record that and move on. Hostinger's public Billing API
   has no price field at all, so price tampering there is
   structurally impossible; do not waste a wave on it.

**The exact test — one variable at a time, control first.**

1. **Control (honest request).** Run the flow honestly as A, with the
   UI's values. Record the ledger/balance/state before and after.
   This is the baseline every tampered test is compared against.
2. **Amount / quantity / price.** Send the same request with one
   changed value: amount `0`, amount `-1`, quantity `0`, quantity
   `-1`, price `0.01` for a `100.00` item, a discount larger than
   the total. One change per request. Read the ledger back — did the
   tampered value reach it, or did the server re-resolve it?
3. **Currency / rounding.** Change `currency` (e.g. USD → a
   lower-value currency) while keeping the numeric amount, and send
   fractional amounts that test rounding (e.g. `0.001`, many small
   purchases). Check the charged amount and the credited amount
   separately — a mismatch between the two is the finding.
4. **Cross-account value.** Swap the source or destination account
   in the request (Deriv B-L1: `transfer_between_accounts` with
   `account_from` set to B's loginid — demo funds only). Also swap
   the account inside a bulk call (Deriv E-L2: `bulk-purchase/demo`
   pairs whose account "must belong to the token's owner" — pass B's
   account in A's pair). See also `idor.md` — the test shape is the
   same, the impact is money.
5. **Idempotency / replay.** Send the same money-moving request twice,
   byte-identical, seconds apart. Then send it twice with a different
   idempotency key, and twice with no key at all. Deriv wave 1 found
   no idempotency key on any money-moving call — that is a lead, not
   a finding, until a PoC shows the second request moves money again.
   The proof is the second debit/credit in the ledger, not the
   missing header.
6. **Trial / eligibility reuse.** Copy a value that gates eligibility
   from an account that has it to one that used it up. Farah Hawa's
   LinkedIn case: a Promotion ID copied from an eligible account A
   into account B's trial request, which had already used its trial
   — the server granted the trial; High, $2,500–$5,000. Test the
   same shape for coupons, referral codes, and free-tier grants:
   reuse B's used coupon as A, reuse A's referral as B, claim a
   trial twice as the same user under a different identifier.
7. **State-machine transitions.** Try the transitions that should not
   exist: approve a draft you do not own, publish without review,
   mark an unpaid order paid, cancel after fulfilment and keep the
   goods/refund, re-open a closed claim. Try them via the API even
   when the UI hides the button — the UI is not the check.
8. **Limits and quotas.** Use the resource once past its limit: a
   second vote, a second free export, an 11th item on a 10-item plan,
   a coupon applied twice to one order. First confirm the limit is
   per-user (not per-account — see false positives) and that the
   control (one use) works.
9. **Approval / self-promotion.** Can an actor approve its own
   request, or promote its own role? OpenMausBot Finding 1: approval
   self-promotion via a loopback PATCH. See also
   `privilege-escalation.md` — the two classes overlap here; file
   under the root cause, not the symptom.

**Common false positives.**

- A client-side check that the server re-checks (the UI hides the
  button, the API rejects the request — test the API, not the UI).
- A price/amount that the server ignores and re-resolves (the
  tampered value never reaches the ledger). Read the ledger, not the
  response.
- A state transition that an admin can do by design (check the role
  first — see `privilege-escalation.md`).
- A second request that succeeds because the limit is per-account
  and each of your accounts has its own limit (check the scope of
  the limit first).
- A duplicate charge that the server reverses asynchronously (wait,
  re-read the ledger, and check for a reversal before calling it a
  finding).
- A "discount" that is a display-only field the checkout never uses.

**What proof looks like.** The ledger/balance/state after the tampered
request, showing value moved or a state reached that should not exist
— with the request that did it, the control (the honest request for
comparison), and the before/after balances. Demo/virtual funds only,
own accounts only. A missing idempotency key, a client-side-only
check, or a tampered value the server ignored is a lead, not proof.

**Grounded examples (this workspace).**

- **Deriv B-L1 (Critical if confirmed):** `transfer_between_accounts`
  with `account_from` = B's loginid. Demo funds only.
- **Deriv E-L2:** `bulk-purchase/demo` cross-account pairs — each
  pair's account "must belong to the token's owner"; parameters pass
  through unmodified, no price cap, duplicate pairs honoured.
- **Deriv idempotency lead:** no idempotency key on any money-moving
  call; all amount/limit checks client-side only. Lead until a
  double-submit PoC moves money twice.
- **Hostinger (closed):** price tampering structurally impossible —
  no price fields in the public Billing API.
- **Farah Hawa, LinkedIn:** Promotion ID copied from eligible
  account A into account B's used-up trial request — server granted
  the trial. High, $2,500–$5,000.
- **OpenMausBot Finding 1:** approval self-promotion via a loopback
  PATCH — an actor approving its own request.
