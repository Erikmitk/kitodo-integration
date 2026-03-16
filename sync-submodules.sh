#!/usr/bin/env bash
set -euo pipefail
# Install the pre-commit hook
cp "$(dirname "$0")/hooks/pre-commit" "$(dirname "$0")/.git/hooks/pre-commit"
echo "Pre-commit hook installed."
# Update submodules to pinned commits (normal day-to-day)
git submodule update --init --recursive
# To bump to latest remote main branches instead, run:
# git submodule update --init --remote --recursive
