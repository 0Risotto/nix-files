#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
STOW_DIR="$REPO_DIR/stow"
TARGET_DIR="$HOME"

for pkg in "$STOW_DIR"/*/; do
  name=$(basename "$pkg")

  # Nuke existing config dir so stow can link fresh
  rm -rf "$TARGET_DIR/.config/$name"

  echo "→ stowing $name..."
  stow -d "$STOW_DIR" -t "$TARGET_DIR" "$name"
done

echo "✔ Done."
