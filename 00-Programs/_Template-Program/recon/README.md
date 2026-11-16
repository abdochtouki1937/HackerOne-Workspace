# Recon

This folder holds all recon output for this program: subdomain lists, live
hosts, historical URLs, JS endpoints, port scans, nuclei results, and
crawl output.

## What goes here

- Subdomain enumeration output (`subdomains-YYYY-MM-DD.txt`)
- Live host probing (`live-YYYY-MM-DD.txt`)
- Historical URLs (`urls-YYYY-MM-DD.txt`)
- JavaScript endpoint extraction (`js-endpoints-YYYY-MM-DD.txt`)
- Content discovery / fuzzing output (`ffuf-YYYY-MM-DD.json`)
- Vulnerability scan output (`nuclei-YYYY-MM-DD.txt`)
- Notes on what was tried and what came back empty (empty results are
  still results — record them so nobody repeats the work).

## Naming convention

`<tool-or-step>-YYYY-MM-DD.<ext>`

Examples:

- `subdomains-2026-11-16.txt`
- `live-2026-11-16.txt`
- `nuclei-2026-11-16.txt`

Keep the raw tool output and, next to it, a short summary of what it
means (one or two lines at the top of `notes.md` or in a
`summary-YYYY-MM-DD.md` file).

## Rules

- Recon output is leads, not findings. Nothing in this folder is a bug
  until a manual proof exists in `evidence/` and a finding file in
  `findings/`.
- All recon runs must be in scope and rate-limited. See
  `../../02-Methodology/recon-checklist.md`.
- Dedupe every list with `sort -u` before testing.
