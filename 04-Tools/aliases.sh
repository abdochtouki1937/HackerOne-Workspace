# aliases.sh — safe defaults for the hunting toolchain.
# Source it:  source 04-Tools/aliases.sh
# Every alias is rate-limited on purpose. Never run a scan without a
# rate limit on a live target.

# Workspace root (the folder that contains 00-Programs, 04-Tools, ...).
H1_WS="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"
export H1_WS

# ffuf: 20 requests/second, 5 threads, follow redirects off by default.
alias ffuf-safe='ffuf -rate 20 -t 5'

# nuclei: 50 requests/second, severity filter off (you choose the templates).
alias nuclei-safe='nuclei -rate-limit 50'

# httpx: 50 requests/second, tech detection on.
alias httpx-safe='httpx -rate-limit 50 -tech-detect -status-code -title'

# Scope check shortcut: scope-check <program-folder> <target>
alias scope-check="$H1_WS/01-Recon/scripts/scope-check.sh"

# Quick check: is a host alive and what does it run?
alias probe='httpx-safe -follow-redirects'
