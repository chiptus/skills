#!/usr/bin/env bash
# Resolves a single PR review thread by ID.
# Usage: resolve-thread.sh <thread-id>
set -euo pipefail

thread_id="$1"

gh api graphql -f query='
  mutation($threadId: ID!) {
    resolveReviewThread(input: {threadId: $threadId}) { thread { id } }
  }' -F threadId="$thread_id" >/dev/null
