#!/usr/bin/env python3
"""
Categorize local git branches by their GitHub PR state.

Cross-references every local branch against `gh pr list` so the caller can tell
which branches are safe to delete (PR merged, remote gone) versus which are
abandoned-but-unconfirmed, closed-without-merging, still active, checked out in
another worktree, or a long-lived release branch.

Usage:
    python3 analyze_branches.py [--fetch] [--json OUT.json]

Requires: git, gh (authenticated: `gh auth status`)
"""
import argparse
import json
import re
import subprocess
import sys

RELEASE_RE = re.compile(r"^(release|develop|main|master)(/|$)")


def run(cmd):
    return subprocess.run(cmd, capture_output=True, text=True, check=True).stdout


def git_branches():
    """Return list of (name, is_current, worktree_path, track) for local branches."""
    out = run(
        [
            "git",
            "branch",
            "--format=%(refname:short)|%(HEAD)|%(worktreepath)|%(upstream:track)",
        ]
    )
    branches = []
    for line in out.splitlines():
        if not line.strip():
            continue
        name, is_head, wt, track = line.split("|")
        branches.append((name, is_head == "*", wt, track))
    return branches


def gh_my_prs():
    """One bulk call: every PR authored by the current user, any state."""
    out = run(
        [
            "gh",
            "pr",
            "list",
            "--state",
            "all",
            "--author",
            "@me",
            "--json",
            "headRefName,state,number,title",
            "--limit",
            "1000",
        ]
    )
    return json.loads(out)


def gh_pr_for_branch(branch):
    """Fallback lookup for branches not covered by the bulk author query
    (e.g. PR authored by a teammate, or opened from a differently-named fork ref)."""
    try:
        out = run(
            ["gh", "pr", "list", "--search", f"head:{branch}", "--state", "all",
             "--json", "state,number,title", "--limit", "5"]
        )
        return json.loads(out)
    except subprocess.CalledProcessError:
        return []


def categorize(branches, my_prs, probe_unmatched=True):
    merged = {p["headRefName"] for p in my_prs if p["state"] == "MERGED"}
    closed = {p["headRefName"] for p in my_prs if p["state"] == "CLOSED"}
    opened = {p["headRefName"] for p in my_prs if p["state"] == "OPEN"}

    result = {
        "current": None,
        "release_or_trunk": [],
        "worktree_checked_out": [],
        "safe_to_delete_merged": [],
        "closed_unmerged": [],
        "unconfirmed_abandoned": [],
        "active": [],
    }

    for name, is_current, wt, track in branches:
        if is_current:
            result["current"] = name
            continue
        if RELEASE_RE.match(name):
            result["release_or_trunk"].append(name)
            continue
        if wt:
            result["worktree_checked_out"].append({"branch": name, "worktree": wt})
            continue

        gone = track == "[gone]"

        if name in merged:
            (result["safe_to_delete_merged"] if gone else result["active"]).append(name)
        elif name in closed:
            result["closed_unmerged"].append(name)
        elif name in opened:
            result["active"].append(name)
        elif gone and probe_unmatched:
            prs = gh_pr_for_branch(name)
            states = {p["state"] for p in prs}
            if "MERGED" in states:
                result["safe_to_delete_merged"].append(name)
            elif prs:
                result["closed_unmerged"].append(name)
            else:
                result["unconfirmed_abandoned"].append(name)
        elif gone:
            result["unconfirmed_abandoned"].append(name)
        else:
            result["active"].append(name)

    return result


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--fetch", action="store_true", help="run `git fetch --prune` first")
    ap.add_argument("--json", help="write full categorized result to this path")
    ap.add_argument("--no-probe", action="store_true",
                     help="skip per-branch gh lookups for unmatched 'gone' branches (faster, less accurate)")
    args = ap.parse_args()

    if args.fetch:
        subprocess.run(["git", "fetch", "--prune"], check=True)

    branches = git_branches()
    my_prs = gh_my_prs()
    result = categorize(branches, my_prs, probe_unmatched=not args.no_probe)

    def show(title, items, fmt=lambda x: x):
        print(f"\n{title} ({len(items)})")
        for item in items:
            print(f"  {fmt(item)}")

    print(f"Current branch: {result['current']}")
    show("Release/trunk branches (kept)", result["release_or_trunk"])
    show("Checked out in another worktree (kept)", result["worktree_checked_out"],
         fmt=lambda x: f"{x['branch']}  ->  {x['worktree']}")
    show("SAFE TO DELETE (merged PR + remote gone)", result["safe_to_delete_merged"])
    show("Closed WITHOUT merging (abandoned)", result["closed_unmerged"])
    show("Unconfirmed (remote gone, no PR record)", result["unconfirmed_abandoned"])
    show("Active (open PR or live remote tracking)", result["active"])

    if args.json:
        with open(args.json, "w") as f:
            json.dump(result, f, indent=2)
        print(f"\nFull result written to {args.json}")


if __name__ == "__main__":
    main()
