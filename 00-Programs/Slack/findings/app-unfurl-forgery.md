# Finding: App can attach a forged link preview to another user's message

| Field | Value |
| ----- | ----- |
| Severity | Medium |
| CVSS | [to be set — Medium range; justify each metric in the report] |
| CWE | CWE-451: User Interface (UI) Misrepresentation of Critical Information |
| Asset | api.slack.com / app.slack.com |
| Status | Confirmed / Draft written / Not yet submitted |
| HackerOne report ID | — |
| Date found | 2026-11-15 |
| Date submitted | — |

## Summary

Any Slack app can claim any domain as an unfurl domain with zero
ownership verification, then attach a forged link preview via
`chat.unfurl` to any message containing a link to that domain — including
another user's message. The forged preview carries an arbitrary title
and a `title_link` to any URL. The web client renders the forged title
as bright blue bold clickable link text with no domain header, no
favicon, no app label, and no hover destination warning. A reader takes
it as a genuine preview for the human author's message while the title
points to the attacker's URL.

## Steps to Reproduce

1. Create a Slack app and add any domain (e.g. example.com) as an
   unfurl domain. No DNS check or confirmation is performed.
2. Have a human user post a message containing a link to that domain.
3. Call `chat.unfurl` with the app token, attaching an unfurl with an
   arbitrary title and a `title_link` pointing to an attacker URL.
4. Open the message in the web client: the forged preview appears under
   the human's message, indistinguishable from a genuine preview.

Expected result: an app cannot attach a preview to another user's
message, and a preview title never links to a URL unrelated to the
apparent domain without a warning.
Actual result: the forged preview attaches and renders with no warning.

## Proof of Concept

Evidence is left in place in the victim test workspace #social
(channel C0CJ07J496Y): the YY1 forged message and the ZZ1 forged
attachment on the human owner's message. Full request/response pairs
and browser rendering checks are in the draft report:

- `~/workspace/bug-bounty-hunt/daily/2026-11-15/slack/HACKERONE-DRAFT-unfurl-forge.md`

## Impact

Phishing primitive. A malicious app installed in a workspace can make
any user's message appear to link to a trusted domain while the title
actually points to an attacker URL, with no client-side warning. The
reader has no reliable visual cue: no favicon, no domain line, no app
attribution, no hover warning. Precondition: a malicious app installed
in the workspace. Honest severity is Medium (Low–Medium range): a
careful side-by-side reader can spot the missing favicon/domain lines,
and a forged title without `title_link` renders as plain black text.

## Root cause

Unfurl domains are claimed without ownership verification, and
`chat.unfurl` accepts an arbitrary `title_link` and attaches to any
message in the channel regardless of author. The API-side object is
labelled (`is_app_unfurl: true`) but the client renders none of that
information.

## Remediation

- Require domain ownership verification before an app can claim an
  unfurl domain.
- Only allow an app to attach an unfurl to messages authored by the app
  itself (or require the message author's consent).
- Render the true link target and the app's identity on every
  app-attached preview, and show the destination warning on hover.

## References

- Prior art: HackerOne report #481472 "URL link spoofing" ($250, 2020)
  — different mechanism (link-text spoof in the attacker's own message).
- Prior art: Push Security research on Slack link-preview spoofing via
  crawler user-agent trick — needs an attacker web server; this finding
  needs none (direct API injection) and adds cross-user attachment.
- Full draft: `~/workspace/bug-bounty-hunt/daily/2026-11-15/slack/HACKERONE-DRAFT-unfurl-forge.md`

## Duplicate check

- [x] Searched HackerOne Hacktivity for this program and issue class.
- [x] Checked #481472 and Push Security research — differentiators
  recorded above.
- [ ] Result: no duplicate found for the cross-user attachment claim.
