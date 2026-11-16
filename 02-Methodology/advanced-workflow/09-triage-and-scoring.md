# Stage 2–3 Deepening — Triage and Scoring

Triage is the decision of what to test next. It happens twice: once
when a lead is found (is it worth testing time?), and once before
filing (is it worth a trial report?). This file covers the first. The
second is the verification gate (`04-verification-gate.md`).

The cost of bad triage is the whole hunt: hours spent on a lead that
was a duplicate, a known quirk, or an excluded class — while the real
bug sat untested in the same inventory. The cost of good triage is
five minutes per lead.

## 9.1 The lead-scoring model

Score every lead 0–2 on five factors. Total 0–10. Test in score order.
A lead that scores below 4 is parked, not tested — it can come back
later if nothing better exists.

| Factor | 0 | 1 | 2 |
|---|---|---|---|
| **Freshness** | Old, heavily hunted surface; mature code | Recently changed surface; new feature in an old app | Fresh code (< 3 months), new release, new feature, new endpoint |
| **Scope fit** | Asset or class the policy excludes, or a scope flag is open | In scope, but a low-value asset or a class the program pays little for | Core in-scope asset, class the program lists as in scope with examples |
| **Impact if true** | Cosmetic, self-only, or no data/action involved | Another user's low-value data, or a limited action | Account takeover, money movement, admin action, sensitive data of another user |
| **Ease of proof** | Needs a paid plan, a live victim, or a third party to cooperate | Needs two accounts and a few steps | One request as A vs B, demo funds, provable in minutes |
| **Duplicate risk (inverted)** | Same endpoint + class already in Hacktivity or advisories | Same class on this program, different endpoint | No prior art found for this endpoint + class |

**Worked example — Deriv B-L1 (transfer_between_accounts
`account_from` IDOR):** Freshness 1 (cashier is a core flow, recently
in scope), Scope fit 2 (program lists "manipulating trade contracts"
and payment logic as in scope), Impact 2 (A drains B — Critical if
confirmed), Ease of proof 2 (one WS call, demo funds), Duplicate risk
1 (transfer IDOR is a known class, but no prior art found for this
endpoint). Total 8/10 — test first.

**Worked example — Deriv F1 (user enumeration on the login flow):**
Freshness 0, Scope fit 1 (enumeration alone is usually excluded or
Low), Impact 0 (existence oracle only), Ease of proof 2, Duplicate
risk 0 (stock Ory Kratos behaviour). Total 3/10 — park it. It was
confirmed Low and correctly not filed as-is.

A second, complementary model lives in `lead-scoring.md`: four
factors (Freshness × Attack Surface × Duplicate Pressure × Potential
Impact), each scored 1–5 and multiplied (max 625), with bands at
≥ 200 (test now), 80–199 (test next), and < 80 (park). It is
multiplicative, so a lead dead on any one factor cannot be rescued
by the others — use it when two leads tie on the 0–10 model, or to
decide which good lead gets the next wave. When the two models
disagree, test the lead anyway if either scores in its top band, and
record why in `notes.md`.

## 9.2 Duplicate Radar (before choosing a direction)

Borrowed from naliazheli/agent-workspace
(https://github.com/naliazheli/agent-workspace): run a duplicate /
prior-art pass **BEFORE** selecting a target direction and **BEFORE**
decomposing it into test ideas. A direction that is already disclosed
is not a direction.

For each candidate direction (program + endpoint + class), run these
searches and record the results in `notes.md` with the date:

1. **Hacktivity:** `site:hackerone.com/reports <program> <endpoint>
   <CWE>` and the program's Hacktivity search for the endpoint name
   and the bug class.
2. **Advisories:** GitHub Advisory Database search for the component
   and package name; the program's own disclosed reports for the
   same component.
3. **Public research:** `<endpoint> <bug class> writeup`,
   `<program> <bug class>`, and the distinctive field names
   (`account_from`, `title_link`, `app_settings`) as search terms.
4. **The distinctive-field trick:** search the exact parameter or
   field name, not just the bug class. Advisory titles rarely use
   your wording — a second search with different words (or a second
   agent) catches what the first missed.

If the Radar finds a disclosed report for the same endpoint + class,
the direction is dead — pick the next one. If it finds the same class
on a different endpoint, the direction is alive but the report must
lead with what is new (see `04-verification-gate.md`, section 4.3).

## 9.3 The sibling rule and the A-to-B signal

From ai-bug-bounty-hunter, rules #10 and #11
(https://github.com/federicopinan/ai-bug-bounty-hunter):

- **Sibling rule (#10).** After a confirmed bug, check every variant
  of the endpoint (`/api/user/{id}/...` and every sibling path that
  shares the handler). The same developer made the same mistake in
  the same code. Siblings are the cheapest findings in the hunt —
  the hard part (finding the pattern) is already done.
- **A-to-B signal (#11).** A confirmed bug A means the developer made
  the same mistake elsewhere. Hunt for bug B **within 20 minutes**,
  before writing the report. The window matters: the finding is
  fresh, the pattern is in your head, and the same mistake is fastest
  to spot now. Writing the report first lets the pattern cool.

**How to run them:** when a bug is confirmed, stop filing work for
20 minutes. List the sibling endpoints (same handler, same parameter
names, same object type) from the inventory and test each one with
the same A-vs-B request. Only then write the report — and file one
report per root cause, grouping the siblings that share it.

## 9.4 Kill criteria (when to drop a lead fast)

Kill a lead immediately — do not spend a wave on it — when any of
these is true. This is the fast version of the 7-Question Gate
(`04-verification-gate.md`, section 4.7); the full gate runs before
filing.

1. **It is on the always-rejected list** (missing CSP/headers alone,
   GraphQL introspection alone, open redirect alone, self-XSS,
   version disclosure alone, no rate limit without a demonstrated
   abuse). One item needs a chain to file; alone it is dead.
2. **It cannot be written as a real HTTP request right now.** If you
   cannot write step 2 of the attack (exact method, URL, headers,
   body) as a copy-paste request, it is a theory, not a lead.
3. **It needs privileged access an attacker cannot realistically get**
   (admin, another tenant's admin, an internal service) with no path
   to that privilege.
4. **It is already known behaviour** — the program's docs, a disclosed
   report, or a public quirk explains it (the Slack G1 pattern).
5. **The impact cannot be proved beyond technical possibility.**
   "The server returns an error" is not impact. "Account B's data
   is in account A's response" is impact.
6. **It is on the kill list** (`04-verification-gate.md`, section
   4.4) or it matches a pattern already closed as duplicate / N/A
   on this program.

A killed lead is recorded in `notes.md` with the reason and the date.
A killed lead is not wasted work — it is a trial report saved, and it
stops the next wave from re-testing the same dead surface.

## 9.5 Time-boxing (how long a lead gets)

From Corben Leo (Critical Thinking podcast, episode 21):
**give yourself a no-bug limit — three hours on one area, then move
on.** The exact number is a starting point, not a law; the principle
is the rule: a lead that has produced nothing in a bounded block gets
parked, and the next lead gets the block. Endless grinding on one
endpoint is how a hunt dies.
Source: https://www.criticalthinkingpodcast.io/episode-21-chill-chat-with-legendary-dod-hacker-corben-leo/

From NahamSec: **depth beats breadth** — most of his bounties came
from programs whose core business he deeply understood, not from
spraying tools across many targets. The time-box applies per area,
not per program: stay on one program, move between its areas.
Source: https://github.com/zaakirio/reconductor/blob/HEAD/recon-methodology-research.md

From STÖK: **time-boxed, target-focused recon over spraying tools
blindly** — pick a program, understand its attack surface deeply,
then go wide. And after every bug: generalise the root cause into a
detection rule ("hack, learn, share").
Source: https://github.com/maybe4a6f7365/agentic-bug-bounty-framework/blob/HEAD/knowledge-sources/creators/02-stok.md

**The rule for this workspace:** one area gets one focused block
(about 2–3 hours of testing, or one wave). If it produces no lead,
park it and move to the next area in the ranked inventory. If it
produces a lead, the lead gets its own block. The coordinator (or the
solo hunter) enforces the box — a push from the user ("don't stop")
is never an open-ended rule; take the duration he names, work
silently inside it, and report only a verified bug or when he asks.

## 9.6 Lead lifecycle

Every lead lives in one state, tracked in
`findings-tracker.md` (see `00-Programs/_Template-Program/`):

```
Lead → Confirmed → Draft → Submitted → Triaged → Bounty / Resolved
                                          ↘ Duplicate / N/A / Dropped
```

- **Lead:** an anomaly re-checked by hand, with a saved PoC, scored
  4+ in 9.1. No PoC, no lead.
- **Confirmed:** passes the 7-Question Gate and the five gates
  (`04-verification-gate.md`). Only confirmed findings get a draft.
- **Draft:** report written from the proof, under 600 words, title
  formula `[Bug Class] in [Endpoint] allows [role] to [impact]`.
- **Submitted:** user said "file it", trial budget confirmed, receipt
  saved.
- **Triaged / Bounty / Resolved / Duplicate / N/A / Dropped:**
  the outcome, recorded with the reason. A duplicate or N/A adds a
  row to the kill list; a bounty adds the pattern to the playbooks
  (`07-vuln-playbooks.md`).

Never delete a row. A dropped lead with a reason is the record that
stops the next hunt from paying for the same lesson twice.

## Sources

- Duplicate Radar, naliazheli/agent-workspace —
  https://github.com/naliazheli/agent-workspace
- Sibling rule (#10) and A-to-B signal (#11), ai-bug-bounty-hunter —
  https://github.com/federicopinan/ai-bug-bounty-hunter
- Corben Leo, no-bug limit / three-hour rule —
  https://www.criticalthinkingpodcast.io/episode-21-chill-chat-with-legendary-dod-hacker-corben-leo/
- NahamSec, depth over breadth —
  https://github.com/zaakirio/reconductor/blob/HEAD/recon-methodology-research.md
- STÖK, time-boxed target-focused recon; hack, learn, share —
  https://github.com/maybe4a6f7365/agentic-bug-bounty-framework/blob/HEAD/knowledge-sources/creators/02-stok.md
- 7-Question Gate, shuvonsec/claude-bug-bounty —
  https://github.com/shuvonsec/claude-bug-bounty
