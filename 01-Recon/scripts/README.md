# Recon scripts

Small helpers for recon. Keep them short, keep them in scope.

## scope-check.sh

Prints the in-scope assets from a program's `assets.txt` and checks
whether a target matches. Refuses to proceed when the target is not
listed — the same idea as the scope guard in
[DevCop95/bugbounty-lab101](https://github.com/DevCop95/bugbounty-lab101),
which blocks any scan when no scope file exists for the target.

Usage:

```bash
./scope-check.sh ../../00-Programs/Slack slack.com
./scope-check.sh ../../00-Programs/Hostinger hpanel.hostinger.com
```

Exit code 0 means "Scope OK". Exit code 1 means the target is not in
`assets.txt` — do not test it. A wildcard line such as `*.deriv.com`
matches any subdomain of that domain.

## Adding a script

- One job per script. Print what it does, fail loudly on bad input.
- Never hardcode a target, a token, or a password. Take them as
  arguments.
- Rate-limit every request the script makes.
