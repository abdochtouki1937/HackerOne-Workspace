# Advanced Workflow — Finding Valid Bugs on HackerOne

## What "valid" means here

A finding is only called a **bug** when it passes all five gates. A lead that
fails any gate is not a finding yet — it goes back to testing, or it is
dropped. Nothing is filed on a failed gate.

1. **In scope.** The bug is on an asset the live HackerOne policy names as
   in scope, tested inside the program's rules. A bug on an out-of-scope host
   is not a bug for this program.
2. **Live-proved.** Reproduced from a clean state on the live target, with
   request/response pairs saved. Code-only and local-lab-only are proof
   levels, not confirmations.
3. **Latest version.** The bug is still present in the latest release,
   re-checked on filing day. A bug fixed in the latest version is dead.
4. **Not a duplicate.** HackerOne Hacktivity, published advisories, and
   public research were checked, and the finding is distinct from all of
   them — or its new part is named explicitly.
5. **Honest severity.** The impact is only what was proved. No unproven
   escalation, no unproven RCE, no inflated rating.

## The workflow at a glance (7 stages)

| Stage | File | Done when |
|---|---|---|
| 1. Select a target | `01-target-selection.md` | Program is open, scope is read and saved, accounts plan exists |
| 2. Recon and enumerate | `02-recon-enum.md` | `inventory.md` exists: live hosts, endpoints, parameters, IDs, versions |
| 3. Test | `03-testing-playbook.md` | Each test family run; every anomaly is a lead with a manual re-check, or closed |
| 4. Verify (the gate) | `04-verification-gate.md` | Every claimed finding passes all five gates, or is dropped |
| 5. File | `05-filing.md` | Report submitted in the program's route; receipt saved |
| 6. Follow up | `05-filing.md` | Triage questions answered; status tracked |
| 7. Archive | `05-filing.md` | Program folder moved to `07-Archive/` with the outcome recorded |

## How to run it

**Solo.** Work the stages in order, one target at a time. Do not start
testing before the inventory exists. Do not start filing before the
verification gate passes. The `hunt-checklist.md` is the one-page version —
print it (mentally) and check each box as you go.

**With agents.** Use `06-agent-runbook.md`. One coordinator, five agents per
target, one test family per agent, all reading the same inventory. The
coordinator dedupes, ranks, and routes; agents never file and never decide
severity alone.

## The rules that sit above every stage

These come from the user's own hunting history. They are not optional.

- **Scope first.** Read the program policy and save it before any request.
  If the scope is unclear, clarify before testing — never test first and
  ask later.
- **Choose by "can we find a REAL, verifiable bug here?"** — not by money,
  not by CVE prestige. Fresh code, new features, and large attack surfaces
  score highest.
- **Latest release, always.** Audit and verify against the latest release.
  Re-check the version again on filing day.
- **Live PoC required.** Every finding needs a live proof: saved
  request/response pairs, reproduced from a clean state.
- **Test accounts only, A vs B.** Two of your own test accounts. Never real
  users' data. One actor is half a finding.
- **Never brute-force credentials, tokens, OTPs, or passwords.** Ever.
- **Rate-limit everything. Stop on 429.** A 429 is a hard stop for that
  provider in this task.
- **Honest severity.** Impact is only what was proved. When a live check
  contradicts a code reading, correct the severity, the totals, and the
  filing order in the same turn, and mark the old draft superseded.
- **Duplicate check before filing.** Hacktivity, advisories, public
  research. One report per distinct root cause; group same-root-cause
  endpoints.
- **Never route around a safety stop.** A safety flag, a blocked PoC, a
  scope doubt — stop and report. Never switch tools to retry the same
  blocked step.

## Files in this folder

- `01-target-selection.md` — picking a target worth hunting.
- `02-recon-enum.md` — the recon-to-inventory pipeline.
- `03-testing-playbook.md` — the testing stage, test families in priority order.
- `04-verification-gate.md` — the validity gate every finding must pass.
- `05-filing.md` — filing, follow-up, and close-out.
- `06-agent-runbook.md` — running the workflow with agents.
- `hunt-checklist.md` — the one-page checklist version of the whole workflow.

## Advanced modules (deepen stages 2–7)

These files extend the seven stages above with material borrowed from
the best public workflows (see `11-sources.md` for every source).
Read them when a stage needs depth; the seven stages above are still
the spine.

- `07-vuln-playbooks.md` — one playbook per high-yield class (IDOR,
  SSRF, XSS, SQLi, auth/session, business logic, mass assignment,
  OAuth, file upload/traversal, race conditions, GraphQL). Deepens
  Stage 3.
- `08-automation-pipeline.md` — what to automate vs what stays manual,
  the Discover → Enrich → Detect pipeline order, structured output,
  scheduled re-runs, and the release-watch script. Deepens Stage 2.
- `09-triage-and-scoring.md` — the lead-scoring model, Duplicate Radar,
  the sibling rule and A-to-B signal, kill criteria, time-boxing, and
  the lead lifecycle. Deepens Stages 2–3.
- `10-daily-weekly-rhythm.md` — the time-boxed operating rhythm:
  daily blocks, weekly schedule, weekly review, monthly rhythm.
  Built for a student schedule.
- `11-sources.md` — every workflow idea traced to its source, with
  links.

## Related workspace files (read, do not duplicate)

- Skills: `~/workspace/custom-skills/bug-bounty-recon/SKILL.md`,
  `~/workspace/custom-skills/bug-bounty-enumeration/SKILL.md`,
  `~/workspace/custom-skills/bug-bounty-fuzzing/SKILL.md`,
  `~/workspace/custom-skills/bug-bounty-investigation/SKILL.md`,
  `~/workspace/custom-skills/bug_bounty_filing/SKILL.md`
- Checklists: `~/workspace/HackerOne-Workspace/02-Methodology/checklist-master.md`,
  `recon-checklist.md`, `web-app-checklist.md`, `api-checklist.md`,
  `report-writing-guide.md`
- Report templates: `~/workspace/HackerOne-Workspace/03-Templates/`
  (`critical.md`, `high.md`, `medium.md`, `low.md`, `informative.md`)
- Program folders: `~/workspace/HackerOne-Workspace/00-Programs/`
  (one folder per program; copy `_Template-Program` for a new target)
