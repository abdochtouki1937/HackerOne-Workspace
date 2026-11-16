#!/usr/bin/env bash
# download-seclists.sh — fetch SecLists (shallow clone) into 05-Wordlists/.
# SecLists is large; this script clones with --depth 1 to keep it small.
# Only run it when you need the big lists. Never use password lists
# against a live program — credential brute-forcing is forbidden.
set -u

DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="$DIR/SecLists"

if [ -d "$TARGET" ]; then
  echo "[skip] SecLists already present at $TARGET"
  echo "To update: cd $TARGET && git pull"
  exit 0
fi

echo "[install] Cloning SecLists (depth 1) into $TARGET ..."
git clone --depth 1 https://github.com/danielmiessler/SecLists.git "$TARGET" \
  || { echo "[!] Clone failed — check your network and try again." >&2; exit 1; }

echo "[done] SecLists ready."
echo "Useful subfolders:"
echo "  $TARGET/Discovery/Web-Content/   (directory and file lists)"
echo "  $TARGET/Discovery/DNS/           (subdomain lists)"
echo "  $TARGET/Fuzzing/                 (XSS, SQLi, LFI payloads)"
echo "  $TARGET/Discovery/Web-Content/api/ (API endpoints)"
