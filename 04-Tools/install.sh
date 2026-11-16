#!/usr/bin/env bash
# install.sh — install the recommended HackerOne toolchain.
# Checks whether each tool is already installed and skips it if present.
# Safe to re-run. Requires Go (>= 1.21) for the ProjectDiscovery tools,
# and a package manager (apt) or pip3 for the rest.
set -u

have() { command -v "$1" >/dev/null 2>&1; }

go_install() { # $1 = binary name, $2 = module@version
  if have "$1"; then echo "[skip] $1 already installed"; return 0; fi
  echo "[install] $1 ..."
  GOFLAGS=-mod=mod go install "$2" 2>/dev/null || echo "[warn] $1 install failed — install it manually (see 04-Tools/README.md)"
}

echo "== Go tools (ProjectDiscovery + friends) =="
go_install subfinder github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go_install httpx github.com/projectdiscovery/httpx/cmd/httpx@latest
go_install nuclei github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
go_install naabu github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
go_install katana github.com/projectdiscovery/katana/cmd/katana@latest
go_install dnsx github.com/projectdiscovery/dnsx/cmd/dnsx@latest
go_install gau github.com/lc/gau/v2/cmd/gau@latest
go_install ffuf github.com/ffuf/ffuf/v2@latest
go_install gobuster github.com/OJ/gobuster/v3@latest

echo "== Other tools =="
if have assetfinder; then echo "[skip] assetfinder already installed"; else
  echo "[install] assetfinder ..."
  go install github.com/tomnomnom/assetfinder@latest 2>/dev/null || echo "[warn] assetfinder install failed"
fi

if have arjun; then echo "[skip] arjun already installed"; else
  echo "[install] arjun ..."
  pip3 install --user arjun 2>/dev/null || echo "[warn] arjun install failed (pip3 missing?)"
fi

if have nmap; then echo "[skip] nmap already installed"; else
  echo "[install] nmap ..."
  (sudo apt-get install -y nmap 2>/dev/null || apt-get install -y nmap 2>/dev/null) || echo "[warn] nmap install failed — install it with your package manager"
fi

if have jq; then echo "[skip] jq already installed"; else
  echo "[install] jq ..."
  (sudo apt-get install -y jq 2>/dev/null || apt-get install -y jq 2>/dev/null) || echo "[warn] jq install failed"
fi

echo ""
echo "Done. Make sure ~/go/bin is on your PATH:"
echo "  export PATH=\"\$PATH:\$HOME/go/bin\""
echo "Then verify: subfinder -h && httpx -h && nuclei -h"
