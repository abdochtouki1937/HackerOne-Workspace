# DEF CON Talks — Bug Bounty Workflow, Recon, and Triage

Talks that shaped this workspace. Each entry has the talk, the speaker,
the year, a working link, and the concrete takeaways that changed how
this workspace is organized. Links verified 2026-11-16. Watch the newest
ones first; the older ones are the foundation the new ones build on.

## 1. Eating Our Own Dogfood: Running a Bug Bounty Program on a Bug Bounty Platform

- **Speakers:** Shrimant Subhash More and Martzen Haagsma
- **Event:** DEF CON 34, Bug Bounty Village, 2026
- **Link (slides, PDF):** https://media.defcon.org/DEF%20CON%2034/DEF%20CON%2034%20villages%20and%20creators/DEF%20CON%2034%20-%20Bug%20Bounty%20Village%20-%20Eating%20Our%20Own%20Dogfood%20-%20Running%20a%20Bug%20Bounty%20Program%20on%20a%20Bug%20Bounty%20Platform%20-%20Shrimant%20Subhash%20More%20and%20Martzen%20Haagsma.pdf
- **What it is:** the team that runs a bug bounty platform ran a bug bounty
  program on their own product, and turned the program into a live lab.

**Takeaways for hunters:**

- **Collapse the triage-engineering gap.** Their loop (submission ->
  triage -> engineering -> fix -> retest -> disclosure) runs in hours
  instead of weeks because the triager and the engineer share one thread
  of context. For a hunter this means: write the report so the triager
  can reproduce it without asking you a question. A report that needs a
  clarifying question loses days.
- **Severity is argued from two sides.** Triage asks for CVSS vectors,
  attack complexity, and exploitability. Engineering asks for business
  impact and blast radius. A report that gives both — the vector AND the
  business impact — gets a fairer severity. This is why the templates in
  `03-Templates/` ask for per-metric CVSS justification plus a plain
  impact paragraph.
- **Let a confidence score decide what gets automated.** Their AI routing
  sends a report to a human or an engineer automatically only when
  confidence is high (64% of reports). Low confidence goes to a human.
  Apply the same rule to your own automation: let scripts do the
  repetitive recon, but never let a script decide a finding is real.
- **Disclosure forces root-cause fixes.** You cannot publish a band-aid,
  so you find the root and pull it out everywhere. Same for a report:
  file the root cause, not the symptom, and group same-root-cause
  endpoints into one report.
- **Proof it works:** a $7,000 report went from submission to full
  remediation in 7 days on their tight loop.

## 2. Hackbots / Building Hackbots

- **Speakers:** Jason Haddix and Ryan Bonner
- **Event:** DEF CON 34, Bug Bounty Village, 2026
- **Link (write-up of the session):** https://medium.com/@gilberto.deleon18/def-con-34-where-appsec-ai-and-bug-bounty-are-colliding-5f930c15fc72
- **Agenda reference:** https://blog.criticalthinkingpodcast.io/p/hackernotes-ep-185-bug-bounty-village-at-def-con-34-with-harley-kimball-ariel-garcia
- **What it is:** the practical side of building AI-powered
  penetration-testing bots: single-purpose and multi-stage bots, tool
  integration, output parsing, hallucination control, cost, and
  auditability.

**Takeaways for hunters:**

- **Hackbots need evidence, not confidence.** Every candidate finding
  goes through reproduction before it counts. An AI claim without a
  reproducible request/response pair is noise — the same standard this
  workspace applies to scanner output.
- **Context engineering is the job.** Decide exactly what the agent
  knows: program scope, authentication state, discovered endpoints,
  prior requests, tool output, and the rules. A bot (or a subagent)
  with the wrong context tests the wrong thing.
- **Keep humans on business logic.** Let machines chew through
  repetitive recon. Save human attention for business logic,
  exploitability, impact, and disclosure — the parts no automation
  does well.
- **The noise problem is real.** The Bug Bounty Village agenda
  addressed AI-assisted submissions and triage bottlenecks directly:
  floods of low-quality automated reports make triage slower for
  everyone. A short, proven report stands out precisely because of
  the flood.

## 3. Efficient Bug Bounty Automation Techniques

- **Speaker:** Gunnar Andrews (Gunnar Andrews / Gunner Andrews)
- **Event:** DEF CON 32, Bug Bounty Village, 2024
- **Link (transcript):** https://media.defcon.org/DEF%20CON%2032/DEF%20CON%2032%20villages/DEF%20CON%2032%20villages%20captions/DEF%20CON%2032%20-%20Bug%20Bounty%20Village%20-%20Efficient%20Bug%20Bounty%20Automation%20Techniques%20-%20Gunnar%20Andrews.eng.srt
- **What it is:** how to automate bug bounty recon so it produces
  findings instead of just data.

**Takeaways for hunters:**

- **Resources vs findings.** Automation can collect a huge amount of
  data very fast and produce zero findings, which means zero dollars.
  Judge a pipeline by findings per hour, not by gigabytes collected.
- **Automate collection first, then scale.** Start with what you
  personally collect and how you collect it efficiently; only then
  scale up. Do not buy scale before the pipeline works on one target.
- **Move off flat text files.** The talk pushes hunters toward real
  data engineering: structured, queryable recon data instead of piles
  of `.txt` files. This is why the workspace keeps a `recon/` folder
  per program plus a ranked lead list in `notes.md` — the next step
  up is a single recon index per program (see `checklist-master.md`).
- **Start from apex domains.** For a program, find all root domains
  first, then the IP space they own (ASN data, reverse DNS, TLS
  certificate scraping). His own tool for this is Caduceus: it does
  half a TLS handshake, pulls domain names from the certificate's
  common name and SAN fields, and records which IP served them.
- **No brute forcing until you have to.** Passive sources first
  (certificate transparency, ASN, reverse DNS), active second.

## 4. Leveraging AI for Smarter Bug Bounties

- **Speakers:** Diego Jurado and Joel Niemand Sec Noguera (Expo)
- **Event:** DEF CON 32, Bug Bounty Village, 2024
- **Link (transcript):** https://media.defcon.org/DEF%20CON%2032/DEF%20CON%2032%20villages/DEF%20CON%2032%20villages%20captions/DEF%20CON%2032%20-%20Bug%20Bounty%20Village%20-%20Leveraging%20AI%20for%20Smarter%20Bug%20Bounties%20-%20Diego%20Jurado%20%26%20Joel%20Niemand%20Sec%20Noguera.eng.txt
- **What it is:** how AI agents can mimic a human bounty hunter, and
  how a team scaled that up.

**Takeaways for hunters:**

- **An agent that hunts like a human.** Their demo agent does basic
  recon, finds the register endpoint, registers a user, logs in,
  saves cookies to a jar, then searches the internet for public
  information and proof-of-concept exploits for what it found. That
  sequence — recon, authenticate, persist state, then research — is
  the same shape as a good manual hunt.
- **Scale comes from benchmarks.** They collected thousands of
  benchmarks from CTF competitions and partner companies, then built
  a fully autonomous agent on an attack machine loaded with
  pentesting tools. Lesson: measure your pipeline against known
  targets before trusting it on a live program.
- **AI is a force multiplier, not a replacement.** The talk is from
  researchers who have hunted for years; the agent extends their
  workflow, it does not replace judgment about what is worth
  reporting.

## 5. How I Built Recon to Scale with Serverless Architecture

- **Speaker:** Gunnar Andrews
- **Event:** DEF CON 31, Recon Village, 2023
- **Link (transcript):** https://media.defcon.org/DEF%20CON%2031/DEF%20CON%2031%20villages/DEF%20CON%2031%20villages%20captions/DEF%20CON%2031%20-%20Recon%20Village%20-%20Gunnar%20Andrews%20-%20How%20I%20Built%20Recon%20to%20Scale%20with%20Serverless%20Architecture.eng.txt
- **What it is:** scaling recon across many targets with AWS Lambda,
  DynamoDB, Step Functions, and the Serverless Framework (SAM /
  Terraform), with all code in the slides.

**Takeaways for hunters:**

- **Recon is a workload problem.** Spreading the work across many
  small functions beats running one big scan: each target gets its
  own cheap, parallel job. Tools that do this for you: Axiom and
  ShadowClone.
- **It costs money.** Serverless scale is not free — budget for it,
  and start small. For one hunter on one program at a time, the
  local `recon-run.sh` in `01-Recon/scripts/` is the right scale;
  serverless is for watching many programs at once.
- **Keep the pipeline boring.** Lambda + a queue + a database is the
  whole architecture. The value is in the ordering of the steps, not
  in clever infrastructure.

## 6. Easy EASM: The Zero-Dollar Attack Surface Management Tool

- **Speakers:** Jason Haddix and team (with Gunnar Andrews and Oliver Gulushi)
- **Event:** DEF CON 31, Recon Village, 2023
- **Link (transcript):** https://media.defcon.org/DEF%20CON%2031/DEF%20CON%2031%20villages/DEF%20CON%2031%20villages%20captions/DEF%20CON%2031%20-%20Recon%20Village%20-%20Jason%20Haddix%20-%20Easy%20EASM%20The%20Zero-Dollar%20Attack%20Surface%20Management%20Tool.eng.srt
- **What it is:** building an external attack surface management tool
  from free parts, and the history of subdomain enumeration.

**Takeaways for hunters:**

- **Free EASM is real.** Amass + subfinder + ProjectDiscovery tools,
  chained together, give you the same asset inventory a paid EASM
  product sells. The workspace's `recon-checklist.md` is this idea
  in checklist form.
- **Know the history.** Subdomain enumeration went Fierce (brute
  force) -> Sublist3r (2015) -> Amass and subfinder (2017-2018).
  Every generation kept the previous one's sources and added new
  ones. Use more than one tool: no single source finds everything.
- **Defenders lose track of assets; hunters find them.** The talk is
  framed defensively, but the mechanism is identical for hunting:
  forgotten subdomains run old code with old bugs.

## Classics (watch after the six above)

### Domain Discovery: Expanding Your Scope Like A Boss — Jason Haddix, DEF CON 25, Recon Village, 2017

- **Link (transcript):** https://media.defcon.org/DEF%20CON%2025/DEF%20CON%2025%20villages/DEF%20CON%2025%20villages%20captions/DEF%20CON%2025%20-%20Recon%20Village%20-%20Jason%20Haddix%20-%20Domain%20Discovery%20-%20Expanding%20Your%20Scope%20Like%20A%20Boss.eng.srt
- **Takeaways:** the discovery methodology in one talk — domain
  scraping, brute forcing, BGP/Hurricane Electric data, Crunchbase
  org discovery. Undiscovered assets are less secured than the main
  site, and in bug bounty that means they pay. The foundation of the
  Bug Hunters Methodology.

### Bug Bounty Hunting on Steroids — Anshuman Bh and team, DEF CON 26, Recon Village, 2018

- **Link (transcript):** https://media.defcon.org/DEF%20CON%2026/DEF%20CON%2026%20villages/DEF%20CON%2026%20villages%20captions/DEF%20CON%2026%20-%20RECON%20VILLAGE%20-%20anshuman%20bh%20-%20Bug%20Bounty%20Hunting%20on%20Steroids.eng.srt
- **Takeaways:** automate the boring manual parts of recon and
  enumeration ("all things is code"), and build one project (their
  Bounty Machine) instead of running ten tools that repeat each other.
  The warning still holds: many tools do the same thing, some work,
  some are broken — pick a small set and learn it deeply.

### Bugs, Bounties & Breaches: Insider Tales from the Trenches (panel) — Jason Haddix (moderator), Olivia, Ariane, Ben, DEF CON 31, Recon Village, 2023

- **Link (transcript):** https://media.defcon.org/DEF%20CON%2031/DEF%20CON%2031%20villages/DEF%20CON%2031%20villages%20captions/DEF%20CON%2031%20-%20Recon%20Village%20-%20Panel%20Discussion%20-%20Bugs%2C%20Bounties%20%26%20Breaches%20Insider%20Tales%20from%20Trenches.eng.srt
- **Takeaways:** war stories with a method inside them. Recon on a
  prospect found an S3 bucket with source code and 13 hard-coded AWS
  keys before the test even started. On a wide-scope bug bounty, an
  acquired CRM's login page led to the company that made it — an
  asset nobody had mapped. Lesson: acquisitions, subsidiaries, and
  cloud storage are where the forgotten assets live.

### Bug Bounty Recon: Bypassing Geographic DNS with Ensemble — Anthony Russell, DEF CON 31, Recon Village, 2023

- **Link (transcript):** https://media.defcon.org/DEF%20CON%2031/DEF%20CON%2031%20villages/DEF%20CON%2031%20villages%20captions/DEF%20CON%2031%20-%20Recon%20Village%20-%20Anthony%20Russell%20-%20Bug%20Bounty%20Recon%20Bypassing%20Geographic%20DNS%20with%20Ensemble.eng.srt
- **Takeaways:** geographic DNS hides assets from a single vantage
  point — run recon from several locations. His open-source tool
  Ensemble does geo-distributed recon. If a subdomain resolves
  differently from your network than from the target's region, you
  are missing assets.

### Inside a Large Self-Hosted VRP — Sam Erb (Google), DEF CON 33, Bug Bounty Village, 2025

- **Link (listing):** https://appsec.fyi/bugbounty/page/2
- **Takeaways:** how Google builds and operates a large self-hosted
  Vulnerability Research Program. Useful for understanding the other
  side of the table: what a mature program's triage and operations
  look like, and what kind of report their engineers can act on.

### How to Shot Web: Web and Mobile Hacking in 2015 — Jason Haddix, DEF CON 23, 2015

- **Link (slides, PDF):** https://www.peterbassill.com/files/Mirrors/defcon/DEF%20CON%2023/DEF%20CON%2023%20presentations/DEF%20CON%2023%20-%20Jason-Haddix-How-Do-I-shot-Web.pdf
- **Takeaways:** the original Bug Hunters Methodology talk. The 80/20
  rule: bug bounty testing is not a full application assessment —
  tailor the method to finding bugs in 20% of the effort, not covering
  100% of the app. The GitBook project that grew out of this talk is
  still the best single methodology reference.

## How to use this file

- New to hunting: watch 6 (Easy EASM) and 3 (Automation Techniques)
  first — they set up the pipeline. Then 1 (Dogfood) before you write
  your first report.
- Stuck on recon: watch 5 (Serverless Recon) and the DEF CON 25
  Domain Discovery classic.
- Before filing: re-read the takeaways of 1 (Dogfood) — write the
  report so triage can reproduce it without asking you anything.
