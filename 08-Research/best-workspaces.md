# Best Bug Bounty Workspaces on GitHub

New finds beyond the 8 repos in the workspace README, researched
2026-11-16. Stars and dates verified the same day. Each entry says what
to borrow — do not clone a repo wholesale; take the one idea that fits
this workspace and leave the rest.

## 1. shuvonsec/claude-bug-bounty — ~4,400 stars

- **Link:** https://github.com/shuvonsec/claude-bug-bounty
- **Updated:** active in 2026 (listed 2026-03-15, scanned 2026-04-25)
- **What it is:** a complete AI-powered bug bounty workflow in one
  skill: Recon -> Learn -> Hunt -> Validate -> Report. Works with or
  without a Claude subscription; also ships as a standalone CLI
  (`bughunter recon target.com`).
- **Borrow from it:**
  - **The 7-Question Gate.** A strict validation gate that kills weak
    findings before they waste a report. Same idea as the kill gate
    added to `checklist-master.md` Phase 5.
  - **A-to-B bug chaining.** IDOR -> auth bypass, SSRF -> cloud
    metadata, XSS -> ATO, open redirect -> OAuth theft. When one bug
    is confirmed, hunt the chain it enables.
  - **Bypass tables.** SSRF IP bypasses, open redirect bypasses,
    file-upload bypasses, kept as tables you can check in seconds.
  - **Language-specific grep.** JS prototype pollution, Python
    pickle, PHP type juggling, Go template.HTML, Ruby YAML.load —
    patterns to search for when auditing source.
  - **Pre-hunt learning.** Before testing, read the program's
    disclosed reports and the target's tech stack, and draw a mind
    map / threat model. This workspace does this in `notes.md`; the
    repo makes it a formal step.

## 2. six2dez/reconftw — ~8,300 stars

- **Link:** https://github.com/six2dez/reconftw
- **Updated:** 2026-11-15 (active maintenance), created 2020-12-30, MIT
- **What it is:** a Bash framework that runs the full recon pipeline
  in one command (`./reconftw.sh -d target.com -a`): subdomain enum
  (passive, brute force, permutations, CT logs), port scanning,
  vulnerability scanning (XSS, SSRF, SQLi, LFI, SSTI via nuclei and
  others), GitHub dorking. Orchestrates 80+ tools, normalizes output
  into a predictable directory tree, configurable through one
  `reconftw.cfg` file.
- **Borrow from it:**
  - **The pipeline order.** Passive -> active -> live hosts -> web
    analysis -> nuclei. That order is the model for
    `01-Recon/scripts/recon-run.sh` in this workspace.
  - **One config file, modules toggleable.** A single config that
    turns modules on/off without touching the core script. Copy that
    pattern before adding more steps to `recon-run.sh`.
  - **Normalized output tree.** Every run writes the same folder
    shape, so any finding can be rebuilt from the folder alone.
    Same principle as this workspace's `recon/` naming rule.
- **Warning:** it does active scanning (DNS brute force, port scans,
  nuclei). Only run it on in-scope assets with written authorization.
  This workspace's `recon-run.sh` gates every run through
  `scope-check.sh` first for exactly this reason.

## 3. federicopinan/ai-bug-bounty-hunter — 0 stars (new, 2026)

- **Link:** https://github.com/federicopinan/ai-bug-bounty-hunter
- **Updated:** created 2026-04-30, 18 commits
- **What it is:** an AI-assisted hunting workspace template with the
  best-organized structure found in this research: skills per phase,
  always-on rules, a scope guard, an evidence vault, and a report
  builder. Zero stars because it is new, not because it is bad —
  judge it on structure, not popularity.
- **Borrow from it:**
  - **Scope guard as a gate.** `scope-guard.sh` validates a host/URL
    against a machine-readable scope file and exits nonzero on
    anything unvalidated; out-of-scope rules are deny-first and
    cannot be overridden by a later broad in-scope rule. This
    workspace's `scope-check.sh` is the simpler version of the same
    idea.
  - **Evidence vault.** Per-finding vaults with metadata and capped
    evidence size; the report builder refuses to generate a report
    when required metadata, reproduction steps, or evidence files are
    missing (`--strict`). Same discipline as this workspace's
    "no proof, no report" rule, enforced by a script.
  - **The 20 hunting rules.** Best three: read the full scope first
    (one out-of-scope request can get you banned); never hunt
    theoretical bugs ("can an attacker do this RIGHT NOW?");
    automation has the highest duplicate rate — manual finds unique
    bugs.
  - **The sibling rule.** Check every variant of an endpoint
    (`/api/user/{id}/...`) after a confirmed bug.
  - **The A-to-B signal.** A confirmed bug means the developer made
    the same mistake elsewhere — hunt for B within 20 minutes,
    before writing the report. Added to `checklist-master.md`.
  - **Report rules.** Under 600 words (triagers skim); title
    formula `[Bug Class] in [Endpoint] allows [role] to [impact]`;
    never submit from the always-rejected list (missing CSP, GraphQL
    introspection alone, open redirect alone, self-XSS).

## 4. ankitsingh015/HuntMCP — 10 stars

- **Link:** https://github.com/ankitsingh015/HuntMCP
- **Updated:** created 2026-07-06, 321 commits
- **What it is:** multi-level AI agent orchestration for autonomous
  bug bounty hunting, built on OpenCode + MCP. One orchestrator
  (HuntBrain) delegates to specialist agents (Recon, Scan, Exploit,
  Chain-Planner, Report) that drive real tools through MCP. Covers
  30+ vulnerability classes across the OWASP WSTG, with 52 technique
  skills.
- **Borrow from it:**
  - **Scope as a file.** Every engagement is bound to an
    `engagement.yaml` scope file. Same idea as `scope.md` +
    `assets.txt` here, but machine-readable — worth copying if the
    workspace ever scripts scope checks beyond `scope-check.sh`.
  - **Candidate is not confirmed.** Scan-agent output is always a
    candidate; nothing is called confirmed until validated. Same
    rule as this workspace's lead-vs-finding split.
  - **A deterministic gate on every live action.** Every tool call
    that touches the target passes the same scope gate, regardless
    of which agent made it.

## 5. naliazheli/agent-workspace — 0 stars (new, 2026)

- **Link:** https://github.com/naliazheli/agent-workspace
- **Updated:** created 2026-04-21, last push 2026-08-05, MIT
- **What it is:** an agent workspace with a HackerOne bounty workflow
  skill: opportunity research, scope handling, and a "Duplicate
  Radar".
- **Borrow from it:**
  - **Duplicate Radar.** Run a duplicate / prior-art pass BEFORE
    selecting a target direction and BEFORE decomposing it into test
    ideas: search HackerOne Hacktivity and disclosed reports for the
    program name, asset, endpoint, method, CWE, package name, and
    distinctive field names, plus `site:hackerone.com/reports
    <program> <endpoint> <CWE>`. Added to `checklist-master.md`
    Phase 1 and Phase 6.
  - **Opportunity discovery.** Start from HackerOne's opportunities
    page and program data instead of picking a target by name.

## 6. mert-erkoc/security-prompts — 6 stars

- **Link:** https://github.com/mert-erkoc/security-prompts
- **Updated:** created 2026-10-09
- **What it is:** a small collection of reusable AI prompts for
  authorized security testing and source-code auditing, including a
  Burp Suite + AI workflow (burp2claude) and a full methodology
  prompt (recon to reporting).
- **Borrow from it:**
  - **Prompts that validate before reporting.** The prompts tell the
    AI to validate a finding before writing it up — no unverified or
    speculative findings. Use this pattern when briefing agents for
    a hunt.
  - **Burp history as input.** Feed Burp proxy history to the AI
    and let it drive Repeater — a practical way to mix manual
    testing with AI assistance.

## 7. sricharan996/hydra — 2 stars (new, 2026)

- **Link:** https://github.com/sricharan996/hydra
- **Updated:** created 2026-08-21, 32 commits
- **What it is:** a 7-headed AI bug bounty system for opencode:
  hunter, verifier, reporter, plan, auditor, recon, debug agents,
  928 skill modules, one-command setup, MITRE ATT&CK coverage.
- **Borrow from it:**
  - **Separate the verifier from the hunter.** The agent that finds
    a bug is not the agent that confirms it. That separation is the
    same reason this workspace keeps recon, testing, and reporting
    as separate phases with separate checklists.
  - **Finding hashing.** Findings are hashed and saved the moment
    they are found, so nothing is lost or double-reported.
- **Caution:** very new, 2 stars, 928 modules is a lot of surface
  to trust. Take the pipeline idea (hunt -> verify -> report as
  separate roles), not the whole system.

## 8. ametel01/ametel-skills — stars not verified

- **Link:** https://github.com/ametel01/ametel-skills
- **Updated:** active in 2026 (file last crawled 2026-11-10)
- **Note:** the star count could not be verified on 2026-11-16
  (GitHub API denied access for this repo); the content below comes
  from its public skill file, which was readable.
- **What it is:** a HackerOne bug-hunt submission skill: find credible
  targets, verify scope and reward eligibility, produce reproducible
  evidence, and prepare a complete submission.
- **Borrow from it:**
  - **Paste-ready submission fields.** Keep a
    `reports/hackerone-submission-fields.md` next to the full report
    with the exact form fields (title, asset, severity, summary) so
    filing is copy-paste, not retyping. This workspace's
    `report-draft.md` serves the same purpose — keep it in sync with
    the finding file.
  - **Package artifacts with the report.** PoC attachment (patch,
    script, screenshots, logs, zip) created at the same time as the
    report, not after.
  - **Verify scope from the official page.** Prefer the official
    HackerOne program page and the target's SECURITY.md; use mirrors
    only as supporting evidence.

## What NOT to copy

- **Do not copy any repo's full tool list.** The point of this
  workspace is a small set of tools used every day. The 400+ tool
  arsenals stay in the reference repos.
- **Do not copy AI-agent frameworks wholesale.** Their value is the
  workflow shape (scope gate, separate verifier, kill gate), not
  their 900 modules.
- **Do not trust star counts alone.** Two of the best-structured
  repos here have 0 stars because they are months old. Judge a repo
  by whether its rules and scripts are sound, not by popularity.
