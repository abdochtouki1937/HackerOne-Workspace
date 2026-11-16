# Program: Slack

| Field | Value |
| ----- | ----- |
| Platform | HackerOne |
| Program URL | https://hackerone.com/slack |
| Status | Active |
| Policy last updated | [check the live policy page] |
| Scope last verified | 2026-11-16 |
| Researcher | e1gle |

**Verify this scope against the live HackerOne policy before testing.
Scope changes. This file is a snapshot, not the policy.**

## Bounty ranges

| Severity | Average payout |
| -------- | -------------- |
| Critical | $16,333 |
| High | $4,000 |
| Medium | $1,490 |
| Low | $516 |

Response efficiency: 99%. Disclosure is **PAUSED since 15 August 2025**,
which raises duplicate risk — file fast once a finding is confirmed.

## In-scope assets

| Asset | Type | Notes |
| ----- | ---- | ----- |
| slack.com | Domain | Main site |
| app.slack.com | Domain | Web client |
| api.slack.com | Domain | API |
| edgeapi.slack.com | Domain | Edge API |
| slack-imgs.com | Domain | Image hosting |
| slack-redir.net | Domain | Redirect service |
| slack-status.com | Domain | Status pages |
| slackatwork.com | Domain | |
| slackb.com | Domain | |
| spaces.pm | Domain | |
| Quip | Product | Critical severity only |
| Nebula source | Source | Critical severity only |
| Slack mobile / desktop apps | Apps | |

No Signal requirement — program is "Open to submit". ID verification is
required to submit to bounty programs.

## Out-of-scope assets

- Slack Connect, guests, SSO/SAML/SCIM, Enterprise Grid (not covered by
  the free test workspaces).
- Slack support channels are out of scope unless the policy names them.
- Any asset not listed above.

## Excluded vulnerability types

Copy the current list from the policy. Known non-qualifying classes:
self-XSS, clickjacking, CSRF with no impact, missing security headers,
user enumeration, CSV injection, TOCTOU permission bugs ("WAD").
Already burned (do not re-report): stored XSS in message text,
files.slack.com XSS, emoji-name XSS, gist XSS, window.opener XSS, open
redirect, rate-limit bypass, SSRF via slash commands / Event
Subscriptions / Office thumbnails, 2019 request smuggling on slackb.com,
TURN/STUN abuse, DTLS key.

## Rules

- Test accounts only. Cross-org testing ONLY with your own dedicated
  test workspaces.
- First reporter only — duplicates are closed.
- No spam, phishing, brute force, or DDoS.
- No attacking live third-party workspaces. Testing is limited to your
  own test workspaces.
- A theoretical vulnerability without a working proof of concept is out
  of scope for reporting.

## Submitted reports

| Date | Title | Severity | Status | HackerOne report ID |
| ---- | ----- | -------- | ------ | ------------------- |
| | App can attach a forged link preview to another user's message (app-unfurl forgery) | Medium | Draft ready, not yet submitted | |

## Notes

- Free workspace does not cover Slack Connect, guests, SSO/SAML/SCIM,
  or Enterprise Grid.
- Only 3 trial reports are shared across ALL HackerOne programs — spend
  them only on strong, proven findings. Trial reports spent so far: 0.
