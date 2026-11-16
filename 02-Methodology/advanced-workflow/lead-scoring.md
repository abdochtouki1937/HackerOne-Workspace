# Lead Scoring — Freshness × Attack Surface × Duplicate Pressure × Potential Impact

A second, complementary scoring model for triaging leads. It is
multiplicative, not additive: a lead that is dead on any one factor
scores low overall, even if it shines on the others. That is the
point — a lead with no attack surface, or no impact, or a certain
duplicate, is not saved by being fresh.

Score each factor 1–5. Multiply the four factors. Maximum 5 × 5 × 5 × 5
= **625**.

| Band | Score | Action |
|---|---|---|
| Test now | ≥ 200 | Top of the queue. Test in the next wave. |
| Test next | 80–199 | Worth a block after the top band is cleared. |
| Park | < 80 | Park it. Revisit only if nothing better exists, or if new information changes a factor. |

## The four factors

### F — Freshness (1–5)

How new / unhunted is the surface? Fresh code has had less time to
be reviewed by other hunters and by the vendor's own security work.

| Score | Meaning | Anchor |
|---|---|---|
| 5 | Brand-new surface | New feature, new endpoint, or new release < 3 months old; no public hunting writeups yet |
| 4 | Recently changed | Feature or endpoint changed in the last few months; new scope just added to the program |
| 3 | Active but established | Core flow in regular use, changed in the last year, moderately hunted |
| 2 | Mature | Stable for years; heavily hunted; many disclosed reports on neighbouring endpoints |
| 1 | Ancient / exhausted | Long-public surface with a long Hacktivity history and no new change |

### A — Attack Surface (1–5)

How much attacker-reachable surface does the lead actually expose?
A single caller-controlled parameter on a money-moving endpoint is
more surface than a read-only field on an admin page.

| Score | Meaning | Anchor |
|---|---|---|
| 5 | Wide, caller-controlled | Many endpoints share the pattern (convergent surface); parameters are free-form and caller-supplied; one token reaches all of them |
| 4 | Broad, one pattern | Several sibling endpoints share the same handler / parameter pattern; a single PoC pattern tests all of them |
| 3 | One clear endpoint | A single endpoint with a caller-supplied identifier or parameter that reaches another user's object or action |
| 2 | Narrow | One endpoint, one parameter, limited effect; needs a specific value or a specific state to matter |
| 1 | Almost no surface | Self-only effect, or an endpoint that only reflects the caller's own data back |

### D — Duplicate Pressure (1–5, higher = less pressure)

How likely is this lead to already be disclosed? This is the
inverted duplicate-risk factor: a high score means the field is
clear. Run the Duplicate Radar (`09-triage-and-scoring.md`,
section 9.2) before scoring this factor — do not guess it.

| Score | Meaning | Anchor |
|---|---|---|
| 5 | Clear field | No prior art found for this endpoint + class, after searching Hacktivity, advisories, and public writeups with the distinctive field name |
| 4 | Mostly clear | Same class exists on the program, different endpoint; no prior art for this endpoint |
| 3 | Neighbouring prior art | Same class on a sibling endpoint, or a close neighbour advisory; the report must lead with what is new |
| 2 | Known class, crowded | Same endpoint + class discussed publicly or disclosed on a similar program; a filing would need a genuinely new angle |
| 1 | Almost certainly a duplicate | Same endpoint + class already disclosed on this program, or the behaviour is a documented / stock-library quirk |

### I — Potential Impact (1–5)

What does the attacker gain if the lead confirms? Score the impact
of the lead as written — not the impact of a chain you have not
proved. A lead that "could lead to" a bigger bug scores for what it
is, not for what it could become.

| Score | Meaning | Anchor |
|---|---|---|
| 5 | Total compromise | Unauthenticated RCE, full account takeover of any user, complete exposure of sensitive data, draining another user's money |
| 4 | Serious cross-user impact | Cross-tenant data access, moving another user's money, privilege escalation, reading another tenant's credentials or login links |
| 3 | Bounded cross-user impact | Phishing primitive, limited data exposure, a privilege issue that needs an extra step (victim click, install, second bug) |
| 2 | Limited disclosure | Information disclosure that enables a further attack (existence oracle, verbose errors with internal detail) but gives no access on its own |
| 1 | Cosmetic / self-only | Cosmetic issue, self-only effect, or a hardening note with no real-world effect |

## Worked example 1 — Deriv B-L1: `transfer_between_accounts` `account_from` IDOR

The client sends `account_from` / `account_to` as free-form loginids
in the `transfer_between_accounts` call. If the server does not
enforce that both belong to the token owner, account A can drain
account B. The cashier is Important-business. One WebSocket call,
demo funds, no real money.

| Factor | Score | Reason |
|---|---|---|
| Freshness | 3 | Cashier is a core, established flow — not brand-new, but actively in scope and recently the focus of the hunt; not an exhausted surface. |
| Attack Surface | 3 | One clear endpoint with two caller-supplied loginids. Narrow in count (one call), but the parameters are free-form and directly select the source account. |
| Duplicate Pressure | 4 | Transfer IDOR is a known class, but no prior art was found for this endpoint after searching; the distinctive field name (`account_from`) returned nothing. Mostly clear. |
| Potential Impact | 5 | If confirmed, account A drains account B's funds — money movement across accounts, Critical if confirmed. |
| **Total** | **3 × 3 × 4 × 5 = 180** | **Test next (80–199)** — just below the "test now" band. |

Why it is not ≥ 200: the surface is a single endpoint and the flow
is established, not fresh. That is honest. In practice it was still
tested near-first, because the 0–10 model scored it 8/10 and the
disagreement rule below says to test a lead when either model puts
it in its top band. The multiplicative model is doing its job here:
it flags that this lead's strength is its impact and its clear
duplicate field, not its freshness or breadth — so if the impact
turns out to be capped (e.g. the server enforces ownership after
all), the lead dies fast and little time is lost.

## Worked example 2 — Hostinger convergent IDOR surface, `{username}`-keyed hosting endpoints

The official OpenAPI spec has 353 paths and 85% take
caller-supplied object IDs; a single global Bearer token has the
same rights as the hPanel user. The hosting endpoints are keyed by
`{username}`. Three agents independently ranked this surface #1.
PoC targets once accounts exist: WordPress jwt-token / auto-login
link for another account's site, phpMyAdmin sign-on link for another
account's database, database password change on another account's
database, file-content read on another account's files, and mailbox
password change.

| Factor | Score | Reason |
|---|---|---|
| Freshness | 3 | Hosting control-panel APIs are established, not new — but the OpenAPI spec itself is a fresh, complete inventory that had not been systematically worked through; the surface was unhunted as a whole. |
| Attack Surface | 5 | The widest possible: 353 paths, 85% caller-supplied IDs, one token reaching all of them, and the same `{username}`-key pattern repeated across WordPress, database, file, mailbox, and DNS endpoints. One pattern, dozens of siblings. |
| Duplicate Pressure | 4 | No prior art found for this endpoint family + class; IDOR is a known class, but nothing disclosed for these `{username}`-keyed hosting endpoints. Mostly clear. |
| Potential Impact | 4 | Cross-tenant: another tenant's WordPress auto-login link, phpMyAdmin sign-on, database password change, file read. Serious cross-user impact — short of total compromise only because it needs an authenticated tenant account and affects one tenant at a time. |
| **Total** | **3 × 5 × 4 × 4 = 240** | **Test now (≥ 200)** — top of the queue. |

Why it scores in the top band: the attack surface factor carries
it. A convergent surface is exactly what the multiplicative model
is built to reward — one pattern, many siblings, one PoC shape
(A-vs-B with a swapped `{username}`) testing all of them. The
sibling rule (`09-triage-and-scoring.md`, section 9.3) applies
directly: confirm one endpoint, then sweep the siblings in the
same block.

## How this relates to the 0–10 model

This model complements, and does not replace, the 0–10 five-factor
model in `09-triage-and-scoring.md`, section 9.1. That model is
additive: a lead can score well by being decent on everything, and
it separately weighs scope fit and ease of proof, which this model
does not score directly. This model is multiplicative: a lead that
is dead on any one factor — no surface, certain duplicate, no
impact — cannot be rescued by the other three. Use the 0–10 model
for a quick five-minute sort of a fresh inventory, and this model
when two leads tie on the 0–10 score, or when you need to decide
which of several good leads gets the next wave.

**Rule — when the two models disagree:** test the lead anyway if
either model scores it in its top band (≥ 8/10 on the 0–10 model,
or ≥ 200 here), and record why. Disagreement is information, not
an error: it usually means one model is seeing something the other
is not (for example, B-L1's ease of proof lifts it on the 0–10
model while its single-endpoint surface holds it back here). Write
the reason in `notes.md` next to the scores, so the next wave does
not re-litigate the decision.
