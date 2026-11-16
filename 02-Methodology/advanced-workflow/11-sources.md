# Sources — Where Every Workflow Idea Comes From

Every idea in this advanced workflow traces to a source below. Nothing
here is invented. If a claim has no source, treat it as untested and
verify it before relying on it.

## GitHub repos (workflow and methodology)

- **The Bug Hunters Methodology (TBHM), Jason Haddix** — 4,424 stars.
  Philosophy, discovery, mapping, authorization/sessions, XSS, SQLi,
  file upload, CSRF, privilege/logic/transport, mobile, IDOR, Fast
  Testing Checklist. The 80/20 rule, "find the road less traveled",
  acquisitions before subdomains, the 15-minute web test.
  https://github.com/jhaddix/tbhm
- **claude-bug-bounty, shuvonsec** — ~4,400 stars. Recon → Learn →
  Hunt → Validate → Report. The 7-Question Gate and the 4 timed
  pre-submission gates. "N/A hurts your validity ratio."
  https://github.com/shuvonsec/claude-bug-bounty
- **reconftw, six2dez** — ~8,300 stars. Full recon pipeline in one
  command. Stages OSINT → Subdomains → Hosts → Web → Vulns; modes
  full / passive-only / subdomains / web / scan / recon / vuln;
  normalised output tree.
  https://github.com/six2dez/reconftw
- **ai-bug-bounty-hunter, federicopinan** — SCOPE → RECON → HUNT →
  VALIDATE → REPORT. 20 hunting rules (scope first; never theoretical;
  kill weak findings fast; automation = highest duplicate rate;
  sibling rule #10; A-to-B signal #11; mobile/CI/CD/SAML highest
  density 2025–2026) and 12 reporting rules (no theoretical language;
  always PoC; under 600 words; title formula). Auth matrix, evidence
  vault with strict builder, scope guard deny-first.
  https://github.com/federicopinan/ai-bug-bounty-hunter
- **HuntMCP, ankitsingh015** — Multi-agent hunting (HuntBrain +
  specialists), scope as `engagement.yaml`, scan output always a
  candidate, deterministic scope gate on every live action.
  https://github.com/ankitsingh015/HuntMCP
- **agent-workspace, naliazheli** — Duplicate Radar: check Hacktivity
  before choosing a direction and before decomposing it into test
  ideas; `site:hackerone.com/reports <program> <endpoint> <CWE>`.
  https://github.com/naliazheli/agent-workspace
- **hydra, sricharan996** — 7-agent pipeline with a separate verifier;
  finding hashing (a finding is hashed and saved the moment it is
  found).
  https://github.com/sricharan996/hydra
- **security-prompts, mert-erkoc** — AI prompts that validate before
  reporting; Burp history as input.
  https://github.com/mert-erkoc/security-prompts
- **ametel01/ametel-skills** — HackerOne submission skill;
  paste-ready form fields; package PoC artifacts with the report.
  https://github.com/ametel01/ametel-skills
- **PayloadsAllTheThings, swisskyrepo** — payloads and techniques by
  class, the reference for the playbooks in `07-vuln-playbooks.md`.
  https://github.com/swisskyrepo/PayloadsAllTheThings
- **Bugcrowd Vulnerability Rating Taxonomy (VRT)** — open-source
  classification standard for rating vulnerabilities consistently.
  https://github.com/bugcrowd/vulnerability-rating-taxonomy

## Hunter methodologies (web)

- **NahamSec (Ben Sadeghipour)** — 7 phases: Build Your Foundation,
  Choose Your Program, Recon Everything, Hunt the JS Files, Manual
  Testing, Write the Report, Build Your Edge. Recon-first: more recon
  = easier exploitation. 2025 earnings: ~25% SSRF, ~18% XSS.
  "Automation breadth ≠ bounty" — most bounties came from programs
  whose core business he deeply understood.
  https://www.nahamsec.com/
  https://github.com/zaakirio/reconductor/blob/HEAD/recon-methodology-research.md
- **STÖK (Fredrik Alexandersson)** — "hack, learn, share": after every
  bug, generalise the root cause into a detection rule. Time-boxed,
  target-focused recon over spraying tools blindly; depth before
  breadth; impact-first reports.
  https://github.com/maybe4a6f7365/agentic-bug-bounty-framework/blob/HEAD/knowledge-sources/creators/02-stok.md
- **zseano's Methodology (Bret Buerhaus)** — 1,000+ vulnerabilities.
  Three steps: Getting a feel for things → Expanding the attack
  surface → Rinse and Repeat. Question everything; focus on one
  program and learn its scope and features deeply; write notes as
  you hack.
  https://www.bugbountyhunter.com/zseano/
- **Corben Leo** — focused recon (one app at a time, deep JS/API
  analysis); the no-bug limit (about three hours on one area, then
  move on); "six 1k mediums pay more than one 5k crit — don't ignore
  any bugs"; reports as a communication tool, justify each CVSS metric.
  https://www.criticalthinkingpodcast.io/episode-21-chill-chat-with-legendary-dod-hacker-corben-leo/
- **Farah Hawa** — manual, tool-light hunting: understand the app's
  logic, think like an attacker. Business-logic case: LinkedIn
  Promotion ID copied from an eligible account into an account that
  had used its trial — High, $2,500–$5,000.
  https://undercodetesting.com/how-to-hack-instagram-uncovering-vulnerabilities-without-fancy-tools/
- **Frans Rosén** — knowledge-centric hunting: learn the technology
  deeply before testing (cited in the recon methodology research
  below).
  https://github.com/zaakirio/reconductor/blob/HEAD/recon-methodology-research.md
- **Modern Bug Bounty Recon & Automation Methodology (2024–2026),
  zaakirio/reconductor** — the research file that compares the
  leaders' methodologies and the current pipeline shape
  (Discover → Enrich → Detect).
  https://github.com/zaakirio/reconductor/blob/HEAD/recon-methodology-research.md

## Platform and tool documentation

- **Hacker101, "How to Write a Good Report and Use the CVSS
  Calculator"** — title in 140 characters, CWE + CVSS with
  per-metric justification, numbered repro steps as copy-paste text
  (not screenshots), impact statement, short and to the point.
  https://www.hacker101.com/resources/articles/writing_a_report_and_cvss
- **ProjectDiscovery, Discover → Enrich → Detect** — the official
  layering of the tool suite; tools chain through stdin/stdout pipes;
  nuclei `-jsonl`, `-rate-limit`, ~13,600 templates.
  https://projectdiscovery.io/open-source
  https://github.com/projectdiscovery/docs/blob/HEAD/opensource/index.mdx
- **PortSwigger Web Security Academy** — free, structured labs by
  vulnerability class; the practice ground for the playbooks.
  https://portswigger.net/web-security

## DEF CON talks (already in `08-Research/defcon-talks.md`)

- "Eating Our Own Dogfood" (DEF CON 34) — write the report so triage
  can reproduce it without asking you anything.
- "Hackbots" (DEF CON 34) — hackbots need evidence, not confidence.
- "Efficient Bug Bounty Automation Techniques", Gunnar Andrews
  (DEF CON 32) — findings per hour, not data collected; structured,
  queryable recon data.
- "Leveraging AI for Smarter Bug Bounties" (DEF CON 32) — the agent
  that hunts like a human: recon → register → login → save state →
  research.
- "How I Built Recon to Scale with Serverless Architecture", Gunnar
  Andrews (DEF CON 31) — the value is in the step order, not the
  infrastructure.
- "Easy EASM" (DEF CON 31) — forgotten subdomains run old code with
  old bugs.
- Classics: "How to Shot Web" (Haddix, DEF CON 23), "Domain Discovery"
  (Haddix, DEF CON 25), "Bug Bounty Hunting on Steroids" (DEF CON 26).

## The user's own hunts (grounding, not external sources)

The workflow's examples come from the user's real hunts in
`~/workspace/bug-bounty-hunt/daily/2026-11-15/slack/`,
`~/workspace/bug-bounty-hunt/daily/2026-11-16/hostinger/` and
`.../deriv/`, and from `~/MEMORY.md`: Slack unfurl forgery and the
dead G1, Hostinger wave 1, Deriv wave 1, AiSOC E-01, Vercel H7,
Kyverno, Vikunja, Craft CMS, GPUStack, LobeChat, OpenMausBot,
thinbus-srp. Where a file says "grounded example", the hunt folder
or MEMORY.md is the source.
