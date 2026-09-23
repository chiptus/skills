---
"mattpocock-skills": minor
---

Add setup-chiptus-env: configures a repo end to end for the autonomic issue pipeline — checks setup-matt-pocock-skills is installed (asking the dev to install it themselves if missing, rather than installing it on their behalf), runs it for the issue tracker/triage labels/domain docs, optionally relocates docs/agents/ to a separate repo via AGENTS_DOCS_REPO, then scaffolds autonomic-issues.md wired to whichever tracker (GitHub or Linear) was chosen. Tracker-specific mechanics live in references/github.md and references/linear.md. Repo-specific customization lives in a separate docs/agents/autonomic-issues-local.md that refreshes never touch; step 7 diffs before overwriting an existing autonomic-issues.md.
