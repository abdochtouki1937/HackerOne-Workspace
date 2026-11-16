# Research notes — Slack

## What the target is

- Team messaging platform: workspaces, channels, DMs, apps, unfurls
  (link previews), files, canvases, lists, scheduled messages.
- Main roles: workspace owner, admin, member, guest, bot/app.

## Confirmed finding

- **App-unfurl forgery phishing primitive — Medium, CWE-451.**
  Any app can claim ANY domain as an unfurl domain with zero ownership
  verification, then attach a forged preview via `chat.unfurl` to any
  message containing a link to that domain, with an arbitrary title and
  a `title_link` to ANY URL. The web client renders the forged title as
  bright blue bold clickable link text with no domain header, no favicon,
  no app label, and no hover destination warning. Escalation: it also
  works on ANOTHER author's message and is indistinguishable from a
  genuine preview.
  - Evidence left in place in the victim test workspace #social:
    YY1 forged message and ZZ1 forged attachment on the human owner's
    message.
  - Draft: `~/workspace/bug-bounty-hunt/daily/2026-11-15/slack/HACKERONE-DRAFT-unfurl-forge.md`
    (cross-user-first, with a prior-art section on HackerOne #481472 and
    Push Security's preview-spoofing research).
  - Status: user chose to file on 2026-11-16; submission not yet
    confirmed. Do NOT delete the evidence messages until filed.

## Closed / dead findings

- **G1 scheduled-message delete — DEAD, do NOT file.** `chat.deleteScheduledMessage`
  returning ok while the message still delivers is a known public
  pre-fetch quirk (Slack docs: cannot delete within 60s of post_at;
  public test confirms deletes at 63–300s before send still post).
  Confirmed by a 10-minute API test and a 10-minute browser UI test.
  Draft is marked DO NOT FILE.

## Hunt status

- Waves 1–48 done (2026-11-15). All other surfaces clean or CLOSED:
  Slack Code (feature_disabled), usergroup writes (permission_denied),
  MCP/RTS from bot tokens (user-token gated), video blocks, metadata
  edges, unfurl dedup/opt-outs.
- Still untested (need user token / paid plan / out of scope): search
  with a user token, session survival after deactivation/password/2FA
  change, session fixation retest, Slack AI API (Business+), Agent
  Sessions as a declared agent app, Slack Connect / Enterprise Grid /
  SCIM / SAML, RTS action_token flow, private-IP SSRF via the unfurl
  fetcher (deliberately NOT tested).
- Method quirk: `pins.list`, `bookmarks.list`, `conversations.members`,
  `files.*`, `users.*` reads need form-encoded bodies (JSON gives
  errors or false denials). `chat.*` accepts JSON.
- Metadata validation map is COMPLETE and CLOSED — do not re-test.
  Whole object <= 4,000 bytes; event_type 1–100 chars.
- chat.unfurl forge matrix is CLOSED — do not re-test forge shapes.

## Ranked leads

1. RTS action_token flow (remaining open test surface).
2. Search with a user token (needs the user's sign-in; asked twice —
   do not re-ask unprompted).

## Test setup

- Attacker and victim test workspaces exist (see the full setup in
  `~/workspace/bug-bounty-hunt/daily/2026-11-15/slack/SETUP.md`).
  No tokens or passwords are stored in this workspace.
- Victim app scopes: 43. Attacker app: 17 scopes.
- Never touch the pre-existing workspaces "ppu team" and "ABDO".
