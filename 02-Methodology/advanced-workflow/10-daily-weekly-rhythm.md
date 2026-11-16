# Operating Rhythm — Daily and Weekly

Hunting is a routine, not a marathon. This file sets the rhythm:
short focused blocks, one target at a time, a verification gate every
day, and a filing day every week. It is built for a student schedule —
university, a cyber club, and a life — not for 12-hour days. A push
to "not stop" never overrides this rhythm: take the duration named,
work silently inside it, and report only a verified bug or when asked.

## 10.1 The daily rhythm (hunting days)

Three blocks, about 3–4 hours total. If a day has less time, cut the
middle block first — never cut the evening gate.

| Block | Length | What happens | Output |
|---|---|---|---|
| **Morning — scope + recon** | ~45 min | Read the program policy if it changed; run the release watch (`release-watch.sh`); refresh the inventory (new subdomains, endpoints, versions); run Duplicate Radar on today's direction | Updated `inventory.md`, `notes.md` |
| **Afternoon — testing** | ~90 min | One test family (Stage 3) or one ranked lead, one area, time-boxed. Baseline first, one variable at a time, A vs B. Every anomaly re-checked by hand | Wave report or lead files with saved PoC pairs |
| **Evening — verification gate** | ~30 min | Dedupe the day's leads, score them (09), run the 7-Question Gate on the best one, update the findings tracker. Only gate-passing findings are presented to the user, one at a time | `findings-tracker.md` updated; finding file ready or lead parked |

**Rules for the day:**

- One program per day. Switching programs mid-day loses the context
  that makes the next finding.
- One area per testing block (Corben Leo's no-bug limit: about
  2–3 hours on one area, then move on — see `09-triage-and-scoring.md`).
- Stop on 429, on a safety flag, on a scope doubt. Report the block,
  do not route around it.
- End the day with the tracker updated. An unrecorded lead is a lost
  lead.

## 10.2 The weekly rhythm

| Day | Focus |
|---|---|
| **Monday — intake** | Pick the week's target (Stage 1). Read the scope, save it, set up the program folder, get the two test accounts. Run Duplicate Radar on the top three directions. |
| **Tuesday–Thursday — hunting** | Daily rhythm (10.1). Tuesday: wave 1 (unauthenticated + inventory check). Wednesday: wave 2 (authenticated A vs B). Thursday: wave 3+ (deepening: chaining, boundary pinning, browser checks, prior-art comparison) — only for leads that survived the gate's first pass. |
| **Friday — filing day** | Verification gate on the week's ranked leads (full five gates + 7-Question Gate + peer review). Filing-day re-checks (version, duplicate, scope, proof re-run). One filing question per finding, to the user. File only what he approves. Save receipts, update the trial count. |
| **Weekend — review + learning** | Weekly review (10.3). Archive finished programs. One learning block: one TBHM chapter (https://github.com/jhaddix/tbhm), one PortSwigger lab (https://portswigger.net/web-security), or one disclosed HackerOne report — read it, extract the pattern, add it to the playbooks (`07-vuln-playbooks.md`) or the kill list. |

If the week has fewer days (exams, club events, travel), compress:
intake + one hunting day + filing day is a valid week. A week with no
filing day is a week with no submissions — that is fine; a rushed
filing burns a trial report, and there are only 3.

## 10.3 The weekly review (30 minutes, every weekend)

Answer these in `notes.md` (workspace level or program level):

1. **What was filed?** Report IDs, severities, trial count now.
2. **What was confirmed but not filed?** Why — waiting on what?
3. **What died?** Leads killed, with reasons. Any new kill-list rows?
4. **What is the best lead right now?** Score, next step, what it needs
   (an account, a PoC, a browser check).
5. **What did I learn?** One pattern, one tool trick, one false
   positive — written down so the next hunt uses it.
6. **What is next week's target?** One program, one reason.

Then: archive finished programs (`07-Archive/`), update the kill
list, and update the playbooks with any new pattern (STÖK's rule:
after every bug, generalise the root cause into a detection rule).

## 10.4 The monthly rhythm

- **Re-audit on new releases.** The repo watcher and
  `release-watch.sh` flag new releases. A new release on a watched
  target means a focused re-audit of the changed code — the rule from
  2026-11-12: always audit the latest release; a bug fixed in the
  latest version is dead.
- **Program queue review.** The ranked list of next targets
  (Slack → Hostinger → Deriv → …). Drop programs that went paused,
  gated, or stale; add new ones from HackerOne's opportunities page
  and the repo watcher.
- **Workspace hygiene.** Check the trackers are current, the kill
  list is up to date, the wordlists and tool installs are current
  (`04-Tools/install.sh`), and no secrets have crept into any file.
- **Skill review.** One skill file re-read per month (recon,
  enumeration, fuzzing, investigation, filing) — the workflow only
  works if the skills stay true to what actually happened.

## 10.5 When the rhythm breaks (and how to restart)

- **Blocked on the user** (needs his sign-in, his code, his account):
  say so once and wait. Do not start new waves to fill the time.
- **A wave produced nothing:** that is a normal result. Record the
  clean surfaces with evidence, park the leads, move to the next
  area. A clean wave is not a failed day.
- **A finding died at the gate:** record it, update the kill list,
  and move on. The gate doing its job is a good day — it saved a
  trial report.
- **Missed a week:** do not catch up by doubling the next week.
  Restart at Monday intake with the best lead from the review.
- **Tired or busy:** one 45-minute morning block (recon + gate) is a
  valid hunting day. Short and done beats long and abandoned.

## Sources

- Corben Leo, no-bug limit — https://www.criticalthinkingpodcast.io/episode-21-chill-chat-with-legendary-dod-hacker-corben-leo/
- STÖK, hack, learn, share —
  https://github.com/maybe4a6f7365/agentic-bug-bounty-framework/blob/HEAD/knowledge-sources/creators/02-stok.md
- zseano's Methodology, "write notes as you hack", rinse and repeat —
  https://www.bugbountyhunter.com/zseano/
- TBHM, Fast Testing Checklist — https://github.com/jhaddix/tbhm
