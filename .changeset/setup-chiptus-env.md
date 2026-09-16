---
"mattpocock-skills": minor
---

Add setup-chiptus-env: configures a repo end to end for the autonomic issue pipeline — installs setup-matt-pocock-skills if missing, runs it for the issue tracker/triage labels/domain docs, optionally relocates docs/agents/ to a separate repo via AGENTS_DOCS_REPO, then scaffolds autonomic-issues.md wired to whichever tracker (GitHub or Linear) was chosen. Tracker-specific mechanics live in references/github.md and references/linear.md.
