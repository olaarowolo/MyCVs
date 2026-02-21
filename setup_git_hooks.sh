#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$repo_root"

mkdir -p .githooks
chmod +x .githooks/pre-push

# Use repository-managed hooks
git config core.hooksPath .githooks

echo "Git hooks configured."
echo "- core.hooksPath set to .githooks"
echo "- pre-push hook will run clean_latex_aux.sh before every push"
