# Stage 6 — Agent Runbook

How to run this workflow with agents. The workflow is the same as the solo
version — agents only change who does each part. The coordinator owns the
gates; agents own the testing. No agent files, and no agent decides severity
alone.

## 6.1 Roles

### Coordinator (one per target)

- Reads the program scope and the inventory first. Writes the wave brief.
- Spawns the wave agents, one per test family, all reading the same
  `recon/inventory.md`.
- Dedupes leads across agents (the same lead from three agents is one
  lead).
- Ranks leads and routes them: back to testing, to the verification gate,
  or dropped.
- Runs the verification gate (`04-verification-gate.md`) — or hands the
  ranked leads to the parent agent for the gate. The gate is never run by
  the agent that found the lead.
- Reports to the user in short simple sentences, one finding at a time,
  with one clear question.

### Wave agents (five per target, one per test family)

| Agent | Family (from Stage 3) | Reads |
|---|---|---|
| A | Auth and session | inventory, auth endpoints, session flows |
| B | IDOR and authorisation (A vs B) | inventory, object IDs, caller-supplied IDs |
| C | Business logic and money-moving calls | inventory, payment/trade endpoints |
| D | Input handling and injection | inventory, parameters, JS-derived inputs |
| E | Client-rendering gaps and API-specific | inventory, rendering surfaces, methods/headers |

Each agent works only its own family, only on the inventory, only with the
test accounts, and only inside scope. An agent that finds a lead outside
its family records it and hands it to the coordinator — it does not chase
it.

## 6.2 What each agent must return

Every agent returns a report file (`agent-<letter>-REPORT.md`) in the
program folder with the same structure:

1. **Scope and accounts used.** Program, assets tested, accounts A/B.
2. **Baseline.** The normal request/response for each endpoint tested.
3. **Tests run.** Numbered, one variable at a time, with the request and
   the result for each.
4. **Leads.** Each lead with: the two requests (A and B), both responses,
   the saved PoC file path, and the next step needed. A lead without a
   saved PoC is not a lead — it is a note.
5. **Clean.** Surfaces tested with no finding, with the evidence (the
   control that proves the test ran). "Clean" means "tested and denied",
   never "not tested".
6. **Blocked.** Anything the agent could not test (missing scope, missing
   account, 429, safety flag) — with the reason, not a retry.

**The coordinator rejects a report that:** has no baselines, has leads
without saved request/response pairs, claims a severity, or claims a
finding without an A-vs-B comparison where one applies.

## 6.3 Wave structure (per target)

- **Wave 0 — Recon (1 agent or the coordinator).** Produces the inventory
  (Stage 2). No testing in wave 0.
- **Wave 1 — Unauthenticated + inventory check.** The five agents test
  only what is testable without accounts, and confirm the inventory is
  real (live hosts, endpoints, versions). Hostinger wave 1 (2026-11-16):
  0 confirmed, 49 leads, ~90 probes, 0 unauthenticated data exposures.
  Deriv wave 1 (2026-11-16): 1 confirmed Low (needs re-verification), 57
  leads, ~150 probes, 0 unauthenticated data exposures.
- **Wave 2 — Authenticated A vs B.** Once accounts exist, the five agents
  run their families with both accounts. This is where findings come from.
- **Wave 3+ — Deepening.** Only for leads that survived the gate's
  first pass: chaining, boundary pinning, browser rendering checks,
  prior-art comparison. Never start a wave 3 on a lead that failed the
  gate.

## 6.4 Stop rules (hard rules — no exceptions)

- **Safety flag on a spawn or a step:** stop that step. Do not re-create
  the spawn, do not retry by switching tools, do not route around the
  block. Report it to the coordinator and move on. (Slack hunt: the D1
  and F1 spawns were removed by safety classifiers and were never
  re-created; the workflow-webhook replay and the canvas javascript-link
  steps were safety-stopped and never repeated.)
- **429 / rate limit:** hard stop for that provider in this task. Do not
  sleep, retry, delegate, or schedule replacement work. Report it.
- **Scope doubt:** if an agent is unsure whether a host, endpoint, or
  action is in scope, it stops and asks. It never tests first and asks
  later.
- **Missing accounts or tokens:** the agent records the blocker and
  stops. It never creates an account for the user, never uses a password
  or token from chat, and never asks the user for a credential in chat
  (Secure Vault only).
- **A live production system that is not the user's test workspace:** do
  not test it. Testing is in the user's own test workspaces and test
  accounts only, inside the program's scope.

## 6.5 The daily rhythm

- **Morning — recon.** One agent (or the coordinator) refreshes the
  inventory: new release? new endpoints? new scope? Record the version.
- **Afternoon — testing.** The five agents run their families against the
  inventory. Each returns its report by the end of the wave.
- **Evening — verification gate.** The coordinator dedupes, ranks, and
  runs the gate on the ranked leads. Only gate-passing findings are
  presented to the user, one at a time, with one clear filing question.
- **Never run waves around the clock without a stop.** A push from the
  user ("don't stop") is never an open-ended rule — take the duration he
  names, work silently inside it, and report only a verified bug or when
  he asks. If work is blocked on his sign-in, say so once and wait rather
  than starting new waves.

## 6.6 Real wave history (what this runbook is built on)

- **Slack, waves 1–48 (2026-11-15):** 48 waves, 5 agents per wave in the
  early rounds, one confirmed finding (the unfurl forgery, Medium) and
  one dead "finding" (G1, the scheduling quirk). The hunt worked because
  every wave had a narrow brief, every result was recorded with its
  request/response, and the coordinator kept a consolidated
  `HUNT-SUMMARY.md` with a "CLOSED — do not re-test" list. The hunt also
  produced three corrections that prove the runbook's rules: J2
  `users.info` (a JSON-body artifact, not a real denial), I2
  `conversations.list` types filter (honoured form-encoded), and Z1's
  metadata boundary (100 chars, not 166 — `ok:true` hid a warning).
- **Hostinger wave 1 (2026-11-16, 19:13–19:21):** recon + unauthenticated
  only, 5 agents, 0 confirmed, 49 leads. The wave was useful because it
  produced a ranked lead (the `{username}`-keyed IDOR surface) and a PoC
  plan (T1–T14) for wave 2 — and because it stopped cleanly at the
  account blocker instead of guessing.
- **Deriv wave 1 (2026-11-16, 19:31–19:40):** recon + unauthenticated
  only, 5 agents, 1 confirmed Low (F1, needs re-verification), 57 leads.
  The wave was useful because it ranked the leads (B-L1 Critical if
  confirmed, D-T1, E-L2, C-L1, A-L1) and recorded exactly what wave 2
  needs (demo accounts A+B, PATs) — and because F1 was honestly labelled
  Low with its caveats, not filed as-is.

## 6.7 Coordinator checklist (per wave)

- [ ] Brief names the program, the inventory path, the test family, the
  accounts, the scope limits, and the stop rules.
- [ ] Every agent's report is read in full before ranking.
- [ ] Leads deduped across agents (same root cause = one lead).
- [ ] Each lead has a saved PoC (request/response pairs, A and B) or it
  is sent back.
- [ ] Clean surfaces recorded with evidence (not assumed).
- [ ] Blockers recorded with reasons (not retried).
- [ ] Ranked lead list handed to the verification gate.
- [ ] Consolidated summary updated (`WAVE<N>-SUMMARY.md` +
  `HUNT-SUMMARY.md` or the program folder's `notes.md`).
- [ ] No agent was asked to re-do a safety-stopped step.
