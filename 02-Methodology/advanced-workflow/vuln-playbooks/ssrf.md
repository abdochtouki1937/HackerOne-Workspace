# SSRF (Server-Side Request Forgery)

CWE-918. NahamSec's top earner (~25% of his 2025 bounties).

Part of the Stage 3 Deepening playbooks — see the index in
`../07-vuln-playbooks.md`. The testing rules in `../03-testing-playbook.md`
still apply: baseline first, one variable at a time, test accounts A vs B
only, rate-limit, stop on 429, log everything.

**Trigger conditions.** Anywhere the server fetches a caller-supplied
URL: webhook URLs, avatar/image URLs, link unfurl/preview fetchers,
file import from URL, PDF generation from URL, "check this link"
features. Also: any parameter that looks like a URL, a host, or a path
the server will resolve.

**The exact test.**

1. Point the fetcher at your own collaborator/interactsh URL (or a
   URL you control) and confirm the server actually fetches it
   (out-of-band callback = the fetcher is real).
2. Point it at a private address: `http://169.254.169.254/` (cloud
   metadata), `http://127.0.0.1/`, `http://localhost:PORT/`, and an
   internal hostname from the inventory. Use your own test instance
   for the internal target where possible; never fetch a real
   internal service you do not own.
3. Test the bypasses one at a time: redirect (does the fetcher follow
   a 302 from your server to a private address?), DNS rebinding
   (does it resolve the hostname once or twice?), URL parsing gaps
   (`http://127.0.0.1%09@public/`, `http://0x7f.0.0.1/`, decimal
   and octal IP forms), protocol confusion (`gopher://`, `file://`).
4. Record exactly what the server returns for each: status, body,
   timing, and whether the fetch happened at all.

**Common false positives.**

- The server fetches the URL but returns only a generic error and no
  response body — the fetch happened, but nothing is exfiltrated.
  That is a lead for a blind-SSRF chain, not a finding on its own.
- The fetcher strips credentials on cross-host redirect and forwards
  them only to the same host (standard, correct behaviour — the Slack
  fetcher did exactly this; it is not a finding).
- A fetch that only reaches public internet hosts (the fetcher has a
  private-IP blocklist that works). Test the blocklist, do not assume
  it fails.

**What proof looks like.** An out-of-band callback from the target's
server to your collaborator URL, plus a second request showing a
private address was reached (metadata body, internal response, or a
timing difference that only a private service explains). For blind
SSRF, the callback alone proves the fetch; the impact needs the
second step.
