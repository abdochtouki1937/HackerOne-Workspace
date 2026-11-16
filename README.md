# HackerOne Workspace

A clean, production-ready workspace for HackerOne bug bounty hunting.
One program per folder, scope enforced before any test, every finding backed
by a saved proof, and reports written the way triagers like to read them.

This workspace borrows its shape from
[DevCop95/bugbounty-lab101](https://github.com/DevCop95/bugbounty-lab101)
(program-based structure, scope check before scanning, HackerOne-optimised
report format) and keeps the tool list small on purpose: the tools in
`04-Tools/` and the wordlists in `05-Wordlists/` are the ones actually used
every day. The 400+ tool arsenal stays in the reference repos, not here.

## Layout

| Folder | What lives there |
| ------ | ---------------- |
| `00-Programs/` | One folder per HackerOne program. This is where the hunting happens. |
| `01-Recon/` | Shared recon scripts and results that span programs. |
| `02-Methodology/` | The checklists. Read `checklist-master.md` before every new program. |
| `03-Templates/` | Report templates by severity, in HackerOne format. |
| `04-Tools/` | Install script, safe aliases, and the recommended toolchain. |
| `05-Wordlists/` | Starter wordlists plus a SecLists download script. |
| `06-Notes/` | Bypasses, payload cheat sheets, triage notes. |
| `07-Archive/` | Finished, paused, or closed programs. |
| `08-Research/` | DEF CON talks and the best GitHub workspaces, with takeaways. |

## Start a new program (5 minutes)

```bash
cd 00-Programs
cp -r _Template-Program/ NewProgram
cd NewProgram
```

Then fill in, in this order:

1. `scope.md` — copy the scope, rules, and bounty ranges from the live
   HackerOne policy page. **Never test from memory.** Scope changes; the
   policy page is the only source of truth.
2. `assets.txt` — list every in-scope domain, wildcard, IP, and mobile app.
   Comment out anything you have not verified.
3. `recon/` — run recon (see `02-Methodology/recon-checklist.md`) and save
   every output file here, named by date and step.
4. `notes.md` — record what the target does, how it works, and your ranked
   leads as you go.
5. `findings/` — one file per confirmed finding, using
   `findings/finding-template.md`. Record every finding in
   `findings-tracker.md` too, and update its status whenever it
   changes (Lead -> Confirmed -> Draft -> Submitted -> Triaged ->
   Bounty / Resolved / Duplicate / N/A).
6. `report-draft.md` — when a finding is confirmed, copy the matching
   template from `03-Templates/` into `report-draft.md` and write it up.
7. Submit on HackerOne, then record the report ID, date, and status in
   `scope.md` (Submitted Reports table) and in the finding file.

## Daily workflow

1. Pick one program. Re-read its `scope.md` and confirm the policy has not
   changed since your last session.
2. Run the scope check before any scan:
   `../01-Recon/scripts/scope-check.sh <program-folder> <target>`
   It refuses to proceed if the target is not listed in `assets.txt`.
3. Recon in the morning, manual testing in the afternoon. For the
   standard recon run, use `../01-Recon/scripts/recon-run.sh
   <program-folder> <domain>` — it checks scope first, then runs
   subfinder, httpx, katana, and nuclei in order, rate-limited, and
   writes a recon index. Recon finds doors; manual testing proves
   they open. A scanner hit is a lead, not a bug.
4. Every finding gets a live proof: the exact request and response, saved in
   `evidence/`, named `YYYY-MM-DD-short-name.ext`. No proof, no report.
5. Before filing, check duplicates in HackerOne Hacktivity and the program's
   disclosed reports. One report per distinct root cause; group
   same-root-cause endpoints into one report.
6. End of day: update `notes.md` with what was tested, what is still open,
   and what to test next. Never leave state only in your head.

## How findings flow

```
recon/ (raw output)
  -> notes.md (ranked leads)
    -> findings/<name>.md (confirmed, with PoC)
      -> report-draft.md (written for the triager)
        -> HackerOne submission (record ID + status back in scope.md)
          -> 07-Archive/ (when the program closes or the report is resolved)
```

## Rules (non-negotiable)

- **Scope first.** Only test assets listed in the program's `scope.md`.
  If it is not in scope, it does not exist.
- **Test accounts only.** Create dedicated test accounts (A and B) for
  cross-account testing. Never use real users' accounts or data.
- **Choose targets by "can we find a REAL, verifiable bug?"** — not by
  money, not by CVE prestige. Fresh code and new features score highest.
- **Always audit the LATEST release** and re-check the version on filing
  day. A bug fixed in the latest version is dead.
- **Every finding needs a live proof** — a reproducible request/response
  pair saved in `evidence/`. Theoretical vulnerabilities do not file.
- **Differential testing (A vs B).** Run the same action as two different
  actors and compare. A difference is the finding.
- **Never brute-force credentials, tokens, OTPs, or passwords.** Ever.
- **Rate-limit everything.** Stop on HTTP 429 or a spike of 5xx. Never
  look like a denial-of-service attack.
- **Honest severity.** Claim only the impact you proved. Never overclaim
  (no "could lead to RCE" without a working chain).
- **No secrets in this workspace.** No tokens, passwords, cookies, or API
  keys in any file. Credentials live only in the Secure Vault.
- **Log everything.** Save all output files per program, named by date
  and step, so any finding can be rebuilt from the folder alone.

## Reference repos

- [DevCop95/bugbounty-lab101](https://github.com/DevCop95/bugbounty-lab101) — the model for this workspace: program-based structure, scope enforcement, recon-to-report pipeline, HackerOne report templates, CVE/CWE watchlists, local practice lab.
- [vavkamil/awesome-bugbounty-tools](https://github.com/vavkamil/awesome-bugbounty-tools) — the best curated tool list: recon, scanners, fuzzers, exploitation helpers, sorted by category.
- [swisskyrepo/PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings) — payloads and bypass techniques for every web vulnerability class; the reference to check while testing.
- [djadmin/awesome-bug-bounty](https://github.com/djadmin/awesome-bug-bounty) — classic list of programs and write-ups from real hunters; read the write-ups to learn how good reports are structured.
- [projectdiscovery/public-bugbounty-programs](https://github.com/projectdiscovery/public-bugbounty-programs) — machine-readable list of public programs (domains, bounty flags); the data behind ProjectDiscovery Chaos.
- [lissy93/bug-bounties](https://github.com/lissy93/bug-bounties) — modern program directory (3,000+ programs) with an API and MCP support; use it to discover new programs.
- [leetCipher/bug-bounty-labs](https://github.com/leetCipher/bug-bounty-labs) — practice labs that simulate real bugs found in the wild; train here before touching a live program.
- [Alirewa/cyber-toolkit](https://github.com/Alirewa/cyber-toolkit) — self-hosted toolkit and labs with a findings tracker; useful as a local practice dashboard.
- [shuvonsec/claude-bug-bounty](https://github.com/shuvonsec/claude-bug-bounty) (~4,400 stars) — complete workflow Recon -> Learn -> Hunt -> Validate -> Report, with a 7-Question Gate and A-to-B bug chaining.
- [six2dez/reconftw](https://github.com/six2dez/reconftw) (~8,300 stars) — full recon pipeline in one command; the model for `01-Recon/scripts/recon-run.sh`.
- [federicopinan/ai-bug-bounty-hunter](https://github.com/federicopinan/ai-bug-bounty-hunter) (new, 2026) — the best-organized workspace template found: scope guard, evidence vault, 20 hunting rules, sibling rule, A-to-B signal.
- [ankitsingh015/HuntMCP](https://github.com/ankitsingh015/HuntMCP) — multi-agent hunting with a scope file per engagement; scan output is always a candidate, never confirmed.
- [naliazheli/agent-workspace](https://github.com/naliazheli/agent-workspace) — Duplicate Radar: check Hacktivity before choosing a target direction.
- [mert-erkoc/security-prompts](https://github.com/mert-erkoc/security-prompts) — AI prompts for hunting that validate before reporting.
- [sricharan996/hydra](https://github.com/sricharan996/hydra) — 7-agent pipeline with a separate verifier; take the pipeline idea, not the whole system.
- [ametel01/ametel-skills](https://github.com/ametel01/ametel-skills) — HackerOne submission skill with paste-ready form fields.

Full research notes, with stars, dates, and what to borrow from each
repo, live in `08-Research/best-workspaces.md`. DEF CON talks that
shaped this workspace are in `08-Research/defcon-talks.md`.
