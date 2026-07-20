#!/usr/bin/env bash
set -euo pipefail

# Rebase this fork's main branch onto Matt Pocock's upstream main.
#
# Usage: scripts/rebase-upstream.sh [--push]
#   --push   after a clean rebase, force-push (--force-with-lease) to origin.
#            Without this flag the script stops after rebasing so you can
#            review the result first.
#
# Requires a git remote named "upstream" pointing at mattpocock/skills:
#   git remote add upstream git@github.com:mattpocock/skills.git

REPO="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO"

PUSH=0
for arg in "$@"; do
  case "$arg" in
    --push) PUSH=1 ;;
    *)
      echo "unknown argument: $arg" >&2
      exit 1
      ;;
  esac
done

if ! git remote get-url upstream >/dev/null 2>&1; then
  echo "error: no 'upstream' remote configured." >&2
  echo "Run: git remote add upstream git@github.com:mattpocock/skills.git" >&2
  exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
  echo "error: working tree not clean. Commit or stash your changes first." >&2
  git status --short
  exit 1
fi

BRANCH="$(git branch --show-current)"
if [ -z "$BRANCH" ]; then
  echo "error: not on a branch (detached HEAD)." >&2
  exit 1
fi

echo "==> fetching upstream"
git fetch upstream

echo "==> rebasing $BRANCH onto upstream/main"
if ! git rebase upstream/main; then
  cat >&2 <<'EOF'

Rebase stopped with conflicts.

Resolve them (the /resolving-merge-conflicts skill can help — invoke it in
Claude Code), then run:

  git rebase --continue

... repeating until the rebase finishes. Once it's done, re-run this script
to run validation and re-linking, or run the tail steps by hand:

  bash scripts/link-skills.sh
  claude plugin validate . --strict
EOF
  exit 1
fi

echo "==> re-linking skills"
bash "$REPO/scripts/link-skills.sh"

echo "==> validating plugin manifests"
claude plugin validate . --strict

if [ "$PUSH" -eq 1 ]; then
  echo "==> pushing to origin/$BRANCH (--force-with-lease)"
  git push --force-with-lease origin "$BRANCH"
else
  echo
  echo "Rebase complete. Review the result, then push with:"
  echo "  git push --force-with-lease origin $BRANCH"
  echo "(or re-run this script with --push)"
fi
