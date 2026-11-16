# Program: [Program Name]

| Field | Value |
| ----- | ----- |
| Platform | HackerOne |
| Program URL | https://hackerone.com/[program-handle] |
| Status | Active / Paused / Private / VDP |
| Policy last updated | [YYYY-MM-DD — copy from the HackerOne policy page] |
| Scope last verified | [YYYY-MM-DD — the date you last checked the live policy] |
| Researcher | [HackerOne username] |

**Verify this scope against the live HackerOne policy before testing.
Scope changes. This file is a snapshot, not the policy.**

## Bounty ranges

| Severity | Range |
| -------- | ----- |
| Critical | $ |
| High | $ |
| Medium | $ |
| Low | $ |
| Informative | $ |

Average payouts (if published by the program): Critical $ / High $ /
Medium $ / Low $.

## In-scope assets

Copy the asset list exactly from the HackerOne policy. Keep `assets.txt`
in sync with this table — the scope-check script reads `assets.txt`.

| Asset | Type | Notes |
| ----- | ---- | ----- |
| example.com | Domain | Main web app |
| *.example.com | Wildcard | All subdomains unless listed out of scope |
| api.example.com | Domain | API |
| 192.0.2.0/24 | IP range | |
| Example app (iOS / Android) | Mobile app | Version under test: |

## Out-of-scope assets

List every exclusion, even ones that look in scope. If it is here, do not
test it.

- [asset] — [reason, e.g. third-party provider, out of policy]
- [asset] — [reason]

## Excluded vulnerability types

Copy this list from the program policy. Common entries: self-XSS,
clickjacking without impact, missing security headers, CSV injection,
user enumeration, rate limiting, TOCTOU permission bugs, issues requiring
a victim to install a malicious app without further impact. If a class is
listed here, do not spend time on it.

- [excluded class 1]
- [excluded class 2]

## Rules

- Test accounts only. Create dedicated accounts for testing; never use
  real users' accounts or data.
- Cross-account testing only with your own test accounts (A and B).
- No denial of service, no spam, no phishing, no brute force of
  credentials, tokens, OTPs, or passwords.
- No social engineering.
- No automated scanning without rate limits. Stop on HTTP 429.
- No destructive testing (no deleting, transferring, or purchasing with
  real money or real data).
- A theoretical vulnerability without a working proof of concept is out
  of scope for reporting — a live PoC is required.
- One report per distinct root cause. Group same-root-cause endpoints
  into one report.
- Check duplicates in HackerOne Hacktivity and the program's disclosed
  reports before filing.

## Required headers / research identifiers

Some programs ask for a research header on every testing request. If the
policy requires one, record it here (the header NAME only — never a secret
value).

- Header: [e.g. X-HackerOne-Research: <username>]

## Submitted reports

| Date | Title | Severity | Status | HackerOne report ID |
| ---- | ----- | -------- | ------ | ------------------- |
| | | | | |

## Notes

- [Any program-specific facts: response time, triage behaviour, known
  duplicates, program contacts]
