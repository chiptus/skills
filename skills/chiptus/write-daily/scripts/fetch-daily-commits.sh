#!/bin/bash

# Fetch today's git activity across all configured repositories
# Usage: ./fetch-daily-commits.sh [date]
# Date format: YYYY-MM-DD (defaults to today)

# Configuration - directories to scan for git repos
PORTAINER_ORG_DIR="$HOME/portainer-org"
PERSONAL_REPOS_DIR="$HOME/chiptus-repos"
CHIPTUS_REPOS_DIR="/Users/chiptus/repos"

# Get date parameter or use today
TARGET_DATE="${1:-$(date +%Y-%m-%d)}"
DATE_START="${TARGET_DATE} 00:00"
DATE_END="${TARGET_DATE} 23:59"

echo "==================================="
echo "Git Activity Report: $TARGET_DATE"
echo "==================================="
echo ""

# Function to check a repository or worktree
check_repo() {
    local repo_path="$1"
    local repo_name="$2"
    local is_worktree="$3"

    if [ ! -d "$repo_path" ]; then
        return
    fi

    cd "$repo_path" || return

    # Check if it's a git repo or worktree
    if [ ! -d .git ] && [ ! -f .git ]; then
        return
    fi

    # Get author name
    author=$(git config user.name 2>/dev/null)
    if [ -z "$author" ]; then
        return
    fi

    # Check for commits (only check commits in main repo, not individual worktrees)
    commits=""
    commit_count=0
    reflog_activity=""
    if [ "$is_worktree" != "true" ]; then
        # Use reflog to find commits across ALL branches (not just current HEAD)
        reflog_activity=$(git reflog --since="$DATE_START" --until="$DATE_END" \
            --pretty=format:"%H|%gs|%cr" 2>/dev/null)

        while IFS='|' read -r full_hash gs_subject _cr_time; do
            [ -z "$full_hash" ] && continue
            echo "$gs_subject" | grep -qE "^commit" || continue
            commit_author=$(git show --no-patch --format="%an" "$full_hash" 2>/dev/null)
            [ "$commit_author" != "$author" ] && continue
            commit_line=$(git show --no-patch --format="%h|%s|%ar" "$full_hash" 2>/dev/null)
            [ -z "$commit_line" ] && continue
            short_hash=$(echo "$commit_line" | cut -d'|' -f1)
            echo "$commits" | grep -q "^$short_hash|" && continue
            if [ -z "$commits" ]; then
                commits="$commit_line"
            else
                commits="${commits}"$'\n'"${commit_line}"
            fi
        done <<< "$reflog_activity"

        commit_count=$(echo "$commits" | grep -c '^' 2>/dev/null || echo "0")
        if [ -z "$commits" ]; then
            commit_count=0
        fi
    fi

    # Check for uncommitted changes modified today
    uncommitted=0
    uncommitted_today=""
    diff_stat=""

    if [ -d .git ] || [ -f .git ]; then
        # Get all uncommitted files
        all_uncommitted=$(git status -s 2>/dev/null)

        if [ ! -z "$all_uncommitted" ]; then
            # Filter files modified today
            while read -r status_line; do
                [ -z "$status_line" ] && continue

                # Extract filename (handle both staged and unstaged)
                filename=$(echo "$status_line" | awk '{print $NF}')

                # Check if file exists and was modified today
                if [ -f "$filename" ]; then
                    # Get file modification date (macOS compatible)
                    file_date=$(stat -f "%Sm" -t "%Y-%m-%d" "$filename" 2>/dev/null || stat -c "%y" "$filename" 2>/dev/null | cut -d' ' -f1)

                    if [ "$file_date" = "$TARGET_DATE" ]; then
                        uncommitted=$((uncommitted + 1))
                        uncommitted_today="${uncommitted_today}${status_line}\n"
                    fi
                fi
            done <<< "$all_uncommitted"

            # Get diff stat if there are uncommitted changes from today
            if [ "$uncommitted" -gt 0 ]; then
                diff_stat=$(git diff --stat HEAD 2>/dev/null | tail -1)
            fi
        fi
    fi

    # Get current branch
    branch=$(git branch --show-current 2>/dev/null)

    # Extract branches worked on today from reflog (already fetched above)
    branches_worked_on=""
    if [ "$is_worktree" != "true" ]; then
        if [ ! -z "$reflog_activity" ]; then
            branches_worked_on=$(echo "$reflog_activity" | \
                cut -d'|' -f2 | \
                grep -E "checkout: moving from|commit:" | \
                sed -E 's/.*checkout: moving from (.*) to (.*)/\1\n\2/; s/.*commit: .*//' | \
                grep -v "^$" | sort -u | tr '\n' ', ' | sed 's/,$//')
        fi
    fi

    # Print results only if there's activity
    if [ "$commit_count" -gt 0 ] || [ "$uncommitted" -gt 0 ]; then
        if [ "$is_worktree" = "true" ]; then
            echo "   🌿 Worktree: $repo_name"
            echo "      Path: $repo_path"
            echo "      Branch: $branch"
        else
            echo "📦 $repo_name"
            echo "   Path: $repo_path"
        fi
        echo ""

        if [ "$commit_count" -gt 0 ]; then
            echo "   ✅ Commits today: $commit_count"
            echo ""
            while IFS='|' read -r hash subject time; do
                [ -z "$hash" ] && continue
                echo "   $hash - $subject ($time)"

                # Get file stats for this commit
                stats=$(git show --stat --pretty="" "$hash" 2>/dev/null | tail -1)
                if [ ! -z "$stats" ]; then
                    echo "      $stats"
                fi
            done <<< "$commits"
            echo ""
        fi

        # Show branch activity from reflog
        if [ ! -z "$branches_worked_on" ] && [ "$is_worktree" != "true" ]; then
            echo "   🔀 Branches worked on today:"
            echo "      $branches_worked_on"
            echo ""

        fi

        if [ "$uncommitted" -gt 0 ]; then
            if [ "$is_worktree" = "true" ]; then
                echo "      🔄 Uncommitted changes today: $uncommitted files"
            else
                echo "   🔄 Uncommitted changes today: $uncommitted files"
            fi
            if [ ! -z "$diff_stat" ]; then
                echo "         $diff_stat"
            fi
            echo ""
            if [ "$is_worktree" = "true" ]; then
                echo "      Modified files (today):"
                echo -e "$uncommitted_today" | head -10 | while read -r line; do
                    [ -z "$line" ] && continue
                    echo "         $line"
                done
            else
                echo "   Modified files (today):"
                echo -e "$uncommitted_today" | head -15 | while read -r line; do
                    [ -z "$line" ] && continue
                    echo "      $line"
                done
            fi
            echo ""
        fi

        if [ "$is_worktree" != "true" ]; then
            echo "-----------------------------------"
        fi
        echo ""
    fi
}

# Function to check repo and its worktrees
check_repo_with_worktrees() {
    local repo_path="$1"
    local repo_name="$2"

    # Check main repo first
    check_repo "$repo_path" "$repo_name" "false"

    # Check for worktrees
    if [ -d "$repo_path/.git" ]; then
        cd "$repo_path" || return

        worktrees=$(git worktree list 2>/dev/null | tail -n +2 | awk '{print $1}')

        if [ ! -z "$worktrees" ]; then
            while read -r worktree_path; do
                [ -z "$worktree_path" ] && continue
                worktree_name="$(basename "$worktree_path")"
                check_repo "$worktree_path" "$worktree_name" "true"
            done <<< "$worktrees"
        fi
    fi
}

# Function to scan a directory for all git repos
scan_directory() {
    local dir="$1"
    local org_name="$2"

    if [ ! -d "$dir" ]; then
        return
    fi

    for repo in "$dir"/*; do
        if [ -d "$repo/.git" ]; then
            repo_name="$org_name: $(basename "$repo")"
            check_repo_with_worktrees "$repo" "$repo_name"
        fi
    done
}

# Scan all Portainer repos
echo "🔍 Checking Portainer Organization repos..."
echo ""
scan_directory "$PORTAINER_ORG_DIR" "Portainer"

# Check personal repositories
echo "🔍 Checking Personal repos..."
echo ""
scan_directory "$PERSONAL_REPOS_DIR" "Personal"
scan_directory "$CHIPTUS_REPOS_DIR" "Personal"

echo ""
echo "==================================="
echo "End of Report"
echo "==================================="
