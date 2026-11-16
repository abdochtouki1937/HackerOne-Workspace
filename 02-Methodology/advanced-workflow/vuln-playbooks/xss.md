# XSS — Stored, Reflected, DOM

CWE-79. ~18% of NahamSec's 2025 bounties.

Part of the Stage 3 Deepening playbooks — see the index in
`../07-vuln-playbooks.md`. The testing rules in `../03-testing-playbook.md`
still apply: baseline first, one variable at a time, test accounts A vs B
only, rate-limit, stop on 429, log everything.

**Trigger conditions.** Any field that is stored and later rendered
(stored), any parameter reflected in a response (reflected), or any
client-side code that writes attacker-controlled data into the DOM
with `innerHTML`, `document.write`, or a framework's unsafe binding
(DOM).

**The exact test.**

1. **Stored:** submit a marker payload as A in a field (name, bio,
   comment, title, file name), then view it as B in every context
   where it renders: the web UI, the mobile app, email, exports,
   notifications. Record where it executes and where it is escaped.
2. **Reflected:** put a marker in each parameter, header, and path
   segment; check whether it is reflected unescaped, and in which
   context (HTML body, attribute, script, URL).
3. **DOM:** read the client JS for sinks (`innerHTML`, `eval`,
   `location.hash` flows). Feed the sink a marker and watch whether
   it executes.
4. **Client-rendering gap (the Slack case):** when the API stores a
   label or a flag (e.g. `is_app_unfurl: true`) but the client does
   not show it, prove the gap with a browser rendering check —
   genuine control side by side with the forged one. The finding is
   the gap, not the API object.
5. Use a harmless marker first (`<script>` is not needed to prove
   reflection — a unique string in the response proves the sink; only
   use an executing payload when the program allows it and the impact
   needs it).

**Common false positives.**

- A payload that is stored but always escaped on render (check every
  render context — one escaped context does not prove all are).
- A reflected value inside a JSON response with the right content
  type (`application/json` is not HTML execution).
- A `javascript:` or `data:` link that the web client renders as
  plain text / `about:blank` / broken image (Slack waves 2 and 21 —
  dead in the client, however interesting it looks API-side).
- Self-XSS: a payload that only executes for the user who entered it.
  Most programs exclude it. The finding needs another victim.

**What proof looks like.** A screenshot or browser check showing the
payload executing (or the forged content rendering indistinguishably
from genuine content) in a victim's view — account B viewing
account A's content — plus the stored API object that produced it.

**Grounded example (this workspace).** Slack app-unfurl forgery
(Medium, CWE-451): any app claims any domain with zero ownership
verification, then attaches a forged preview via `chat.unfurl` with
an arbitrary title and a `title_link` to any URL. The web client
rendered the forged title as bright blue bold clickable text with no
domain line, no favicon, no app label, and no hover warning. The
escalation was cross-user: the forge attached to the human owner's
message was indistinguishable from a genuine preview.
