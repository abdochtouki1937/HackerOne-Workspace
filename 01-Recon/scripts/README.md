# Recon scripts

Small helpers for recon. Keep them short, keep them in scope.

## scope-check.sh

Prints the in-scope assets from a program's `assets.txt` and checks
whether a target matches. Refuses to proceed when the target is not
listed — the same idea as the scope guard in
[DevCop95/bugbounty-lab101](https://github.com/DevCop95/bugbounty-lab101),
which blocks any scan when no scope file exists for the target.

Matching rules:

- Exact match: the target equals an asset line (case-insensitive,
  e.g. `API.Deriv.COM` matches `api.deriv.com`).
- Wildcard: an asset written as `*.deriv.com` matches any subdomain
  of that domain.
- A plain domain asset does **not** cover its subdomains: a bare
  `deriv.com` asset matches only `deriv.com` itself, never
  `api.deriv.com`, unless the file also lists it or a wildcard.
- Asset lines ignore surrounding whitespace, skip `#` comments and
  blank lines, and tolerate CRLF line endings.

Usage:

```bash
./scope-check.sh ../../00-Programs/Slack slack.com
./scope-check.sh ../../00-Programs/Hostinger hpanel.hostinger.com
./scope-check.sh -v ../../00-Programs/Deriv api.deriv.com
./scope-check.sh --quiet ../../00-Programs/Deriv example.com
```

Flags:

| Flag | Effect |
| --- | --- |
| `-v`, `--verbose` | Print each asset as it is checked. |
| `--quiet` | Print only the final verdict line. |
| `-h`, `--help` | Print usage and exit 0. |

On DENIED, the script also prints a hint listing the closest assets
(those sharing the target's base domain), so you can see what *is*
in scope.

Exit codes:

| Code | Meaning |
| --- | --- |
| 0 | Scope OK — the target is in scope. |
| 1 | Scope DENIED, or bad input: missing/invalid program folder, missing/empty target, target contains whitespace or a URL scheme (`https://`), or no usable `assets.txt`. |

Examples:

```bash
# Accepted — api.deriv.com is listed in Deriv/assets.txt
./scope-check.sh ../../00-Programs/Deriv api.deriv.com   # exit 0

# Refused — example.com is not in scope for Deriv
./scope-check.sh ../../00-Programs/Deriv example.com     # exit 1

# Refused — a URL is not a target
./scope-check.sh ../../00-Programs/Deriv https://api.deriv.com   # exit 1
```

## recon-run.sh

Ordered, scope-checked, rate-limited recon runner. Pipeline order:
passive subdomains (subfinder, assetfinder) -> live hosts (httpx)
-> endpoints/JS (katana) -> nuclei. Scope is enforced first — the
run refuses to start unless `scope-check.sh` says the target is in
scope. Tools that are not installed are skipped with a warning, never
faked. A failing tool step never aborts the run; its failure and exit
code are recorded in `RUN-LOG.md`.

Usage:

```bash
./recon-run.sh ../../00-Programs/Slack slack.com
./recon-run.sh --fast ../../00-Programs/Deriv api.deriv.com
./recon-run.sh --slow ../../00-Programs/Deriv api.deriv.com
./recon-run.sh --dry-run ../../00-Programs/Deriv api.deriv.com
```

Flags:

| Flag | Effect |
| --- | --- |
| `--fast` | Double the rate limits (defaults become httpx 100/s, katana/nuclei 40/s). |
| `--slow` | Halve the rate limits (minimum 5/s). |
| `--dry-run` | Print the plan (scope verdict, tool availability, output path, effective limits) and exit 0 without running any tool or creating the output folder. |
| `-h`, `--help` | Print usage and exit 0. |

`--fast` and `--slow` cannot be combined.

Environment variables (rate limits, requests/second):

| Variable | Default | Notes |
| --- | --- | --- |
| `RATE_LIMIT` | — | Overrides all three limits at once. |
| `HTTPX_RATE_LIMIT` | 50 | Beats `RATE_LIMIT` for httpx. |
| `KATANA_RATE_LIMIT` | 20 | Beats `RATE_LIMIT` for katana. |
| `NUCLEI_RATE_LIMIT` | 20 | Beats `RATE_LIMIT` for nuclei. |

The effective limits are printed at the start of every run. Example:

```bash
RATE_LIMIT=10 ./recon-run.sh ../../00-Programs/Deriv api.deriv.com
HTTPX_RATE_LIMIT=100 ./recon-run.sh --slow ../../00-Programs/Deriv api.deriv.com
```

Output goes to `<program-folder>/recon/<YYYY-MM-DD>-recon-run/` and
contains the result files, an `INDEX.md` (one line per file) and a
`RUN-LOG.md` (start/end timestamps, the command line used, the scope
verdict, per-step status — ok/skipped/failed with exit code — and the
counts).

Exit codes:

| Code | Meaning |
| --- | --- |
| 0 | Run finished (some steps may have been skipped/failed — see `RUN-LOG.md`), or `--dry-run` plan printed. |
| 1 | Scope denied, missing/invalid arguments, or the output folder could not be created. |

## release-watch.sh

Reports when a GitHub repo ships a new release. See its header for
usage. (House style reference — do not change it without a reason.)

## Adding a script

- One job per script. Print what it does, fail loudly on bad input.
- Never hardcode a target, a token, or a password. Take them as
  arguments.
- Rate-limit every request the script makes.
