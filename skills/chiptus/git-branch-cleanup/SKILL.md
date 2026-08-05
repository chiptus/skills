---
name: git-branch-cleanup
description: >
  Analyze local git branches and categorize which are safe to delete by
  cross-referencing them against GitHub PR state (merged, closed-unmerged,
  still open, checked out in another worktree, or a release/trunk branch).
  Use whenever the user wants to clean up, organize, or prune local branches
  — "clean up my branches", "delete branches that were merged", "which
  branches can I remove", "I have too many local branches", or anything
  combining git branch management with a request to tidy up. Always trigger
  this before running any bulk `git branch -D` so deletions are based on real
  GitHub state rather than guesswork.
---

# Git Branch Cleanup

Local branches pile up over months of work. A branch's remote-tracking ref showing
`[gone]` in `git branch -vv` is a hint it was deleted on GitHub, but that alone
doesn't tell you *why* — it could have been squash-merged, or just abandoned and
manually deleted. Deleting based on `[gone]` alone risks losing unmerged work.
This skill cross-references every local branch against the actual PR state on
GitHub so deletion decisions are based on fact, not a heuristic.

## Why a script instead of ad-hoc commands

Doing this by hand (loop over branches, call `gh pr list` per branch) is slow and
easy to get subtly wrong — e.g. running `git branch` through a shell hook or proxy
tool that silently reformats output (some setups rewrite `git` commands
transparently) can inflate or corrupt what you think the branch list contains.
`scripts/analyze_branches.py` calls `git` and `gh` directly as subprocesses,
bypassing any such rewriting, so the counts and categorization are trustworthy.

## Steps

1. **Run the analysis script** from inside the target repo:

   ```bash
   python3 <skill_dir>/scripts/analyze_branches.py --json /tmp/branch_analysis.json
   ```

   Add `--fetch` first if the user hasn't fetched recently (`git fetch --prune`
   updates which remote branches are actually gone). Add `--no-probe` only if the
   repo has hundreds of branches and the per-branch `gh` fallback lookups are
   taking too long — this trades accuracy for speed.

   The script does one bulk query (`gh pr list --author @me --state all`) to
   cover most branches cheaply, then falls back to a per-branch `gh pr list
   --search head:<branch>` lookup only for branches whose remote is gone but
   weren't matched — this catches PRs authored by teammates or under a
   differently-named head ref.

2. **Read the categorized output.** The script buckets every branch into:
   - `release_or_trunk` — release/develop/main branches, always kept
   - `worktree_checked_out` — checked out elsewhere, can't be deleted from here
   - `safe_to_delete_merged` — confirmed MERGED PR + remote gone
   - `closed_unmerged` — PR was closed without merging (abandoned work, not "merged")
   - `unconfirmed_abandoned` — remote gone but no PR record at all (rebased away,
     or deleted without ever opening a PR — can't confirm it landed)
   - `active` — open PR, or upstream still tracking normally

3. **Present the categorized lists to the user before deleting anything.** Show
   counts and branch names per bucket. Only `safe_to_delete_merged` is a
   confident default recommendation — call out `unconfirmed_abandoned` and
   `closed_unmerged` as separate, lower-confidence groups the user should
   decide on explicitly rather than bundling them into the same delete command.

4. **Get explicit confirmation, then delete.** `git branch -D` is locally
   reversible for a while via `git reflog` (deleted branches' commits stay
   reachable until they're garbage-collected), but that's a safety net, not a
   substitute for asking — never delete without the user greenlighting which
   bucket(s).

   ```bash
   git branch -D <branch1> <branch2> ...
   ```

5. **Never touch**: the current branch, branches in `release_or_trunk`, or
   branches in `worktree_checked_out` (deleting those requires removing the
   worktree first — that's a separate, more destructive decision the user
   should make deliberately).
