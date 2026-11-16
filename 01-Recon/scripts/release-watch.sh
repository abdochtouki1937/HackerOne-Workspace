#!/usr/bin/env bash
# release-watch.sh — report when a GitHub repo ships a new release.
# Usage: release-watch.sh <owner>/<repo>
# State lives in 01-Recon/shared-results/release-watch/<owner>-<repo>.txt
# Exit 0 = up to date (or first run, state recorded).
# Exit 2 = NEW RELEASE (tag changed) — re-audit the changed code.
# Public GitHub API only (60 requests/hour unauthenticated), one request
# per run. No target interaction.
set -u
REPO="${1:-}"
[ -n "$REPO" ] || { echo "usage: release-watch.sh <owner>/<repo>" >&2; exit 1; }
STATE_DIR="$HOME/workspace/HackerOne-Workspace/01-Recon/shared-results/release-watch"
mkdir -p "$STATE_DIR"
SAFE="$(echo "$REPO" | tr '/' '-')"
STATE_FILE="$STATE_DIR/$SAFE.txt"
TAG="$(curl -s --max-time 20 "https://api.github.com/repos/$REPO/releases/latest" \
  | grep -m1 '"tag_name"' | sed 's/.*: *"//;s/".*//')"
[ -n "$TAG" ] || { echo "[warn] could not fetch latest release for $REPO" >&2; exit 1; }
if [ ! -f "$STATE_FILE" ]; then
  echo "$TAG" > "$STATE_FILE"
  echo "[new] $REPO: first check, recorded $TAG"
  exit 0
fi
OLD="$(cat "$STATE_FILE")"
if [ "$TAG" = "$OLD" ]; then
  echo "[ok] $REPO: up to date ($TAG)"
  exit 0
else
  echo "$TAG" > "$STATE_FILE"
  echo "[NEW RELEASE] $REPO: $OLD -> $TAG — re-audit the changed code"
  exit 2
fi
