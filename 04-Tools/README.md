# Tools

Recommended toolchain for HackerOne hunting. Install once with
`install.sh`, then source `aliases.sh` for safe defaults.

## Install

```bash
bash install.sh
```

The script checks whether each tool is already installed and skips it
if present. It installs Go-based tools with `go install` and the rest
with the system package manager or pip. Re-run it any time to fill gaps.

## Toolchain

| Tool | What it is for |
| ---- | -------------- |
| subfinder | Subdomain enumeration (passive) |
| assetfinder | Subdomain enumeration (passive) |
| dnsx | DNS probing, wildcard filtering |
| httpx | Live host probing, tech detection |
| naabu | Fast port scanning |
| nmap | Service detection (in-scope hosts only) |
| gau | Historical URLs (Wayback / Common Crawl) |
| waybackurls | Historical URLs |
| katana | Crawling and JS endpoint extraction |
| ffuf | Content discovery, parameter and value fuzzing |
| gobuster | Content discovery |
| nuclei | Vulnerability scanning (plus custom templates) |
| Arjun | HTTP parameter discovery |
| amass | In-depth attack surface mapping (optional, heavy) |
| Burp Suite / OWASP ZAP | Proxy, manual testing, request history |
| jq | JSON parsing in the shell |
| git, curl | The basics |

Full curated lists (use these when you need a tool that is not here):

- [vavkamil/awesome-bugbounty-tools](https://github.com/vavkamil/awesome-bugbounty-tools)
- [DevCop95/bugbounty-lab101](https://github.com/DevCop95/bugbounty-lab101)
  (auto-scanner tool matrix, by phase)

## Aliases

```bash
source aliases.sh
```

`aliases.sh` defines safe defaults: rate-limited `ffuf` and `nuclei`,
and a short `scope-check` alias that points at the workspace script.
It never overrides a tool with an unsafe default.

## Rules

- Never run a tool against a target that is not in scope.
- Rate-limit everything. The aliases exist so you do not forget.
- Keep the toolchain small. A tool you do not know how to read the
  output of is worse than no tool.
