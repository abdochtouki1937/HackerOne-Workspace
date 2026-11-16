# Recon

Shared recon tooling and results for the bug bounty workspace.

## Layout

```
01-Recon/
├── scripts/          Recon scripts (scope-check.sh, recon-run.sh, release-watch.sh)
├── shared-results/   Results that span programs (cross-program summaries)
└── wordlists/        Pointer to the shared wordlists in 05-Wordlists/
```

Per-program recon output does **not** live here — it lives in the
program's own folder, at `00-Programs/<Name>/recon/`.

## The scope-first rule

**No scope file, no scan.** Every recon run starts by checking the
target against the program's `assets.txt`
(`00-Programs/<Name>/assets.txt`) with `scripts/scope-check.sh`.
If the target is not listed there (exactly, or covered by a `*.domain`
wildcard), the run refuses to start. A plain domain asset does not
cover its subdomains — scope is only what the file says.

## Scripts

See [scripts/README.md](scripts/README.md) for full documentation.

- `scope-check.sh` — check one target against a program's scope.
  Exit 0 = in scope, exit 1 = denied or bad input.
- `recon-run.sh` — the standard recon pipeline (subfinder ->
  httpx -> katana -> nuclei), scope-checked and rate-limited.
  Supports `--dry-run`, `--fast` / `--slow`, and `RATE_LIMIT`
  overrides. Writes `INDEX.md` and `RUN-LOG.md` in the output folder.
- `release-watch.sh` — report when a GitHub repo ships a new release.

## Shared results

`shared-results/` holds results that span programs — for example a
list of interesting hosts found across several targets. See
[shared-results/README.md](shared-results/README.md). Per-program
results stay in the program folder.
