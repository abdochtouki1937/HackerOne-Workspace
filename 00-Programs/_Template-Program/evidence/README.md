# Evidence

This folder holds the proof for every confirmed finding in this program:
screenshots, screen recordings, and saved request/response pairs.

## What goes here

- Screenshots of the vulnerable behaviour in the browser or app.
- Saved request/response pairs (curl output, Burp history exports, HAR
  files) that reproduce the finding.
- Short screen recordings (mp4/webm) for findings that need a visual flow.
- Nothing else. Recon output goes in `recon/`, not here.

## Naming convention

`YYYY-MM-DD-short-name.ext`

Examples:

- `2026-11-16-unfurl-forge-title-link.png`
- `2026-11-16-idor-account-b-response.txt`
- `2026-11-16-auth-bypass-flow.mp4`

Use lowercase, hyphens, no spaces. One finding can have several files;
give them the same short name and a suffix (`-01`, `-02`) when needed.

## Rules

- Every file must be referenced from its finding file in `findings/`.
- Never store credentials, tokens, cookies, or session data here. Redact
  secrets from request/response pairs before saving them.
- Never include real users' data. Test accounts only (A vs B).
