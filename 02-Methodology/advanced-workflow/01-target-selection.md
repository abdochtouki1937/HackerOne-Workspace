# Stage 1 — Target Selection

Picking the target is the highest-leverage decision in the hunt. A bad
target wastes the whole week; a good one makes every later stage easier.
Spend real time here. Do not start recon on a target that has not passed
this stage.

## 1.1 The selection rule

Choose by **"can we find a REAL, verifiable bug here?"** — not by money, not
by CVE prestige. A real, verifiable bug brings both money and credit; a
high-paying program with mature, heavily hunted code brings neither.

Score each candidate on four things:

1. **Freshness.** Fresh code (under ~3 months old), new features, and recent
   releases score highest. Mature code that has been hunted for years scores
   lowest. The user learned this on 2026-11-08: do not pick big, mature
   companies whose code has already been heavily tested.
2. **Attack surface size.** More endpoints, more roles, more state, more
   integrations — more places for a check to be missing. An OpenAPI spec
   with hundreds of paths is a strong signal (see the Hostinger case below).
3. **Testability.** Can you get two test accounts? Is there a demo/sandbox
   mode? Can you test from your own network, or does the target need a live
   browser or a paid plan? A target you cannot test is not a target.
4. **Program health.** Open, responsive, and paying — see 1.2.

## 1.2 Program health checks (read live, save the evidence)

Before choosing a program, verify all of these on its live HackerOne page
and record the date and the values in the program folder's `scope.md`:

- **Open to submit.** No pause notice, working submit button.
- **Signal requirement.** If the program requires a Signal score the user
  does not have, it is not a target — unless the user already holds the
  required Signal. Never plan around a gate you cannot pass.
- **Response and triage speed.** First-response time, triage time, time to
  bounty. A program that answers in days beats one that answers in months.
- **Bounty ranges by severity.** Record the maxima and the averages if
  published (Critical / High / Medium / Low). Note any rule that changes
  the payout, e.g. "Low is paid only on Important-business assets"
  (Deriv, 2026-11-16).
- **Report volume and duplicate pressure.** Reports received in the last 90
  days. High volume means only novel, PoC-proven vectors win — factor that
  into the freshness score.
- **Disclosure status.** If disclosure is paused, duplicate risk is higher
  and you cannot see what others already filed — file fast, and expect more
  duplicate closures.

### The trial-report budget (hard rule)

The user has **only 3 trial reports, shared across ALL HackerOne programs**.
A trial report is spent when a report is submitted on a program where the
user has no reputation yet. Rules:

- Spend a trial report **only on a strong, proven bug** — one that passed
  the verification gate in `04-verification-gate.md` in full.
- Never spend one on a code-only lead, an unverified candidate, or a
  timing quirk.
- Never spend one on a finding whose duplicate check is uncertain.
- Track the count in the workspace README / program folder. As of
  2026-11-16, **0 of 3 spent**.

## 1.3 Reading the scope (the step most hunters skip)

Read the whole policy, not just the asset list. Save the exact in-scope and
out-of-scope text in the program folder's `scope.md`, with the date you read
it. Check:

- **Asset list.** Domains, wildcards, IPs, mobile apps, repos. Copy it
  exactly into `assets.txt` — the scope-check script
  (`01-Recon/scripts/scope-check.sh`) reads that file.
- **Exclusions.** Named out-of-scope classes (self-XSS, missing headers,
  enumeration alone, theoretical vulns without a PoC, CSRF with no impact).
  A finding in an excluded class is closed as N/A no matter how real it is.
- **Testing rules.** Test accounts only, no DoS, no spam, no brute force,
  no social engineering, no testing other customers. Note any header the
  program requires on every request (Deriv: `X-HackerOne-Research: e1gle`).
- **Bounty rules.** Which severities pay, on which assets, and any
  business-tier split (Deriv Important vs General vs Edge).

### Out-of-scope traps (real cases)

These hosts looked in scope but were not, or needed a ruling first. Check
for the same pattern on every new program:

- **Hostinger (2026-11-16):** `auth.hostinger.com`,
  `access.hostinger.com`, and `cart.hostinger.com` host the login flow and
  the cart — but are in **neither** the policy domain list **nor** the
  34-asset HackerOne list. Findings there need program clarification
  before filing or testing.
- **Deriv (2026-11-16):** `*.home.deriv.com` is out of scope but hosts the
  login UI. API testing on `auth.deriv.com` is in scope; UI flows on
  `home.deriv.com` need a scope ruling first. One live listing disagreed
  with the policy mirror — treat as out of scope until a browser check
  confirms.
- **Rule:** when a host is missing from the asset list but hosts a core
  flow, record it as a scope flag in `scope.md` and clarify before testing
  there. Never assume a host is in scope because it looks like part of the
  product.

## 1.4 Fresh-code scoring (the version rule)

**Always audit and verify against the LATEST release.** A bug found on an
older version is dead if the latest version fixed it; maintainers only
support the latest release. This rule was set on 2026-11-12 after the ha-mcp
case: the bug only worked on a 9.1.2-or-older component and 9.2.0 fixed it.

- Record the exact version under test (release tag, build, or "live web
  app as of <date>").
- Re-check the version again on filing day (`04-verification-gate.md`).
- For open-source targets, check the fix history on the exact code path
  before investing test time (`git log` on the handler, not just the repo).

## 1.5 The stop rule

Stop target selection and do not start recon when:

- The program is paused, or the submit button does not work.
- The scope is unclear on the hosts you would need to test, and the
  program has not answered a clarification.
- You cannot get two test accounts, and the target has no demo/sandbox
  mode.
- The target needs a paid plan you cannot get for free (see the Hostinger
  case: the free coupon is the only route to a plan — if it is refused, test
  free surfaces only or move on).

A stopped target is not a failure. Record why in the program folder, move
it to `07-Archive/`, and pick the next one. The user's queue as of
2026-11-16: Slack (done — one confirmed finding), Hostinger, Deriv.

## 1.6 Worked examples (from real hunts)

- **Slack (2026-11-15):** chosen first from the ranked list. No Signal
  gate, "Open to submit", 99% response efficiency, averages Critical
  $16,333 / High $4,000 / Medium $1,490 / Low $516, disclosure paused
  since Aug 2025. In scope: slack.com, app.slack.com, api.slack.com,
  edgeapi.slack.com, slack-imgs.com, and more. Free workspace does not
  cover Slack Connect, guests, SSO/SAML/SCIM, or Enterprise Grid — those
  were excluded from testing from the start.
- **Hostinger (2026-11-16):** chosen second. Open, no Signal gate, no
  pause. Bounty $100–$25,000, averages Critical $10,440 / High $2,671 /
  Medium $740 / Low $200, 1,014 resolved reports, response efficiency
  100%. Decisive rule: **only cross-tenant issues qualify** — own-account
  issues are N/A. The public OpenAPI spec (353 paths, 85% taking
  caller-supplied object IDs) made the attack surface large and testable.
- **Deriv (2026-11-16):** chosen third. Open, no Signal gate, working
  submit button, last report resolved 15 hours before the check, 324
  reports in 90 days, $2,700 paid in 90 days. Bounties (Important-business
  maxima): Critical up to $5,000 / High $2,500 / Medium $500 / Low $100.
  High duplicate pressure — only novel, PoC-proven vectors win.

## 1.7 Deliverable

A program folder in `00-Programs/<Program>/` with:

- `scope.md` — policy copied, bounty ranges, in/out-of-scope tables,
  scope flags, rules, date read.
- `assets.txt` — machine-readable asset list for the scope-check script.
- `notes.md` — why this target was chosen, freshness score, testability
  notes, open questions.
- `findings/`, `evidence/`, `recon/` — empty, ready for the next stages.
