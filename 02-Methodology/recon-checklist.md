# Recon Checklist

Recon comes BEFORE any vulnerability testing — never skip it, and never
test a host you have not first mapped. Recon is roughly 80% of bug
bounty: good recon finds the attack surface, bad recon wastes the whole
hunt. Save every output file in the program's `recon/` folder, named
`<step>-YYYY-MM-DD.<ext>`.

## Before you start

- [ ] Scope is documented in `scope.md` and `assets.txt`.
- [ ] Scope check passed:
      `01-Recon/scripts/scope-check.sh 00-Programs/<Name> <target>`.
- [ ] Program folder exists; `recon/` is empty and ready.
- [ ] Tools installed (`04-Tools/install.sh`).

## Step 1 — Subdomain enumeration (passive first)

```bash
subfinder -d TARGET.COM -all -o subs1.txt
assetfinder --subs-only TARGET.COM > subs2.txt
curl -s "https://crt.sh/?q=%25.TARGET.COM&output=json" | jq -r '.[].name_value' | sort -u > subs3.txt
cat subs1.txt subs2.txt subs3.txt | sort -u > subs-all.txt
wc -l subs-all.txt
```

- [ ] Passive sources combined and deduped.
- [ ] Active brute force only after passive, slow, from the workspace
      wordlist (`05-Wordlists/common-subdomains.txt`).
- [ ] Wildcard DNS filtered out (or every name looks "live").
- [ ] Look for `dev`, `staging`, `test`, `api`, `admin`, `internal`,
      `beta`, `old`, `legacy` — forgotten subdomains are the
      highest-yield recon finding.
- [ ] Check enumerated subdomains for takeover (dangling DNS /
      unclaimed services).

## Step 2 — Live host detection

```bash
httpx -l subs-all.txt -o live.txt -title -tech-detect -status-code -follow-redirects
httpx -l subs-all.txt -ports 80,443,8080,8443,3000,5000,8000,9000 -o live-ports.txt
```

- [ ] Review `live.txt` by hand. Sort by technology.
- [ ] Note every title that looks like an admin panel, login, API doc,
      or error page.
- [ ] An unusual stack (old framework, debug page, default landing
      page) is worth manual time.

## Step 3 — Historical URLs

```bash
gau TARGET.COM > urls-gau.txt
waybackurls TARGET.COM > urls-wayback.txt
cat urls-gau.txt urls-wayback.txt | sort -u > urls-all.txt
grep -i -E "api|admin|config|debug|test|backup|old" urls-all.txt > urls-interesting.txt
grep -E "\?" urls-all.txt | sort -u > urls-with-params.txt
```

- [ ] Old URLs reveal retired endpoints, old API versions, forgotten
      parameters, and files that still exist.
- [ ] Keep the parameter list — it feeds the enumeration phase.
- [ ] Stale URLs are re-requested live before they are believed.

## Step 4 — JS file analysis

```bash
katana -u https://TARGET.COM -jc -o js-files.txt
grep -E "\.js$" urls-all.txt > js-urls.txt
grep -rhoE '"/api/[^"]+"' js-files/ | sort -u > js-api-endpoints.txt
grep -r -i -E "api_key|secret|token|password|aws_|sk-|ghp_|AKIA" js-files/ || true
```

- [ ] JS files are where hidden API routes, internal hosts, debug
      flags, and hardcoded keys live.
- [ ] Every `/api/...` string in JS is a candidate endpoint.
- [ ] A secret in JS is a lead — verify it live, do not use it.

## Step 5 — Port scanning (scope permitting)

```bash
naabu -host TARGET.COM -top-ports 1000 -o ports.txt
nmap -sV -sC TARGET.COM -oN nmap.txt   # only on hosts explicitly in scope
```

- [ ] Interesting ports: 22, 3306, 5432, 6379, 27017, 9200, 8080/8443.
- [ ] An exposed database with no auth is a critical finding — verify
      scope first, and never read real user data beyond proving access.

## Step 6 — Content discovery

```bash
ffuf -w 05-Wordlists/common-directories.txt -u https://TARGET.COM/FUZZ \
  -mc 200,301,302,403 -rate 20 -o ffuf.json
ffuf -w 05-Wordlists/common-api-endpoints.txt -u https://TARGET.COM/FUZZ \
  -mc 200,401,403 -rate 20 -o api-ffuf.json
```

- [ ] Check for `/robots.txt`, `/sitemap.xml`, `/.well-known/`, `/.git/`,
      `/.env`, `/backup/`, `/swagger`, `/api/docs`, `/graphql`, `/debug`.
- [ ] A 403 on `/admin` is interesting (it exists). A 200 on `/.env`
      is a finding.
- [ ] Filter by response size (`-fs`) — custom 404 pages returning 200
      flag the whole wordlist otherwise.

## Step 7 — Technology fingerprinting

```bash
curl -s -I https://TARGET.COM
# Framework fingerprints: Next.js (_next/static), React (__NEXT_DATA__),
# Django (csrfmiddlewaretoken), Laravel (XSRF-TOKEN)
```

- [ ] Record the exact stack and version (e.g. "Next.js 16.3.8,
      sharp 0.34.5").
- [ ] Version numbers decide whether a known CVE applies. Never guess
      a version — read it from headers, JS bundles, or lockfiles.
- [ ] Follow the actual code path, not the top-level version number:
      a nested dependency can be fixed while the root one is
      vulnerable (or the reverse).

## Step 8 — Vulnerability scanning (automated, then manual)

```bash
nuclei -update-templates
nuclei -l live.txt -o nuclei-results.txt
nuclei -t http/technologies/ -u https://TARGET.COM
nuclei -t http/exposures/ -u https://TARGET.COM
nuclei -t http/cves/ -u https://TARGET.COM
```

- [ ] Nuclei hits are leads. Reproduce each one with a manual request
      and capture it.
- [ ] Informational findings (missing headers, verbose banners) are
      not vulnerabilities on most programs.

## Step 9 — Prioritise and hand off

Rank what you found before any manual testing:

1. Forgotten/staging subdomains and old API versions.
2. Exposed files (`.env`, `.git`, backups, Swagger docs).
3. Interesting technologies with known CVEs at the exact version found.
4. Endpoints with parameters.
5. Everything else, by feature.

- [ ] Ranked lead list written into `notes.md`.
- [ ] All output files saved in `recon/`, named by date and step.
- [ ] Empty results recorded too (so nobody repeats the work).
