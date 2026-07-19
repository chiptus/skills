---
name: what-to-do
description: >
  Show today's planned tasks and this week's goals from the personal work log at
  ~/chiptus-repos/notes/dailies/. Use this skill whenever the user asks /what-to-do,
  "what should I work on today", "what are my tasks", "what's on my plate",
  "what do I have to do today", "show my tasks", "what's planned for today",
  or anything about checking their current work priorities or weekly goals.
  Trigger even for short questions like "what's next?" or "what am I doing today?".
---

# What To Do

Read the current weekly log, show the user their weekly goals and today's planned tasks, then ask if they want to add anything to today's list.

## Step 1: Find the current week file

Calculate today's date and the Sunday that started this week. The file is at:
`/Users/work/chiptus-repos/notes/dailies/YYYY/YYYY-MM-DD_DD.md`

where `YYYY-MM-DD` is this week's Sunday and `DD` is Saturday's day number.

```bash
python3 /Users/work/.claude/skills/what-to-do/scripts/get-week-file.py
```

The script prints two lines:
1. The relative path (e.g. `2026/2026-04-26_02.md`)
2. Today's heading (e.g. `Tuesday, April 28`)

Read the file from `/Users/work/chiptus-repos/notes/dailies/<relative-path>`.

## Step 2: Extract and display the two sections

### Weekly tasks

Find the `## Tasks for the week` section and show all items with their current status. Checked items (`[x]`) show what's done; unchecked (`[ ]`) show what's still pending.

### Today's tasks

Find the heading that matches today's date (e.g., `## Tuesday, April 28th`). Show:
- Unchecked items (`- [ ]`) as the active to-do list
- Checked items (`- [x]`) as already done today
- Plain bullet points (`- text`) as completed work logged today

If today's section has no entries yet, say so — it means the daily hasn't been written yet.

## Output format

Present it cleanly in the conversation. Something like:

```
## This week's goals
- [ ] Release (mainly workflows, other bugs)
- [ ] Start React migration

## Today — Tuesday, April 28th
- [ ] Continue LDAP settings refactor (admin groups section)
- [ ] Continue BE-12885 workflow status
```

If today has a mix of done and to-do items, group them: pending first, then done. If today has only completed work and no pending tasks, show the completed work and note there's nothing explicitly queued for the rest of the day.

Keep the output tight — this is a quick glance at priorities, not a full report.

## Step 3: Ask if anything should be added

After displaying the tasks, ask: **"Anything else you'd like to add to today?"**

Use AskUserQuestion as a free-text input (not multiSelect). If the user provides tasks:

1. Append them as unchecked items under today's heading in the week file:
   ```markdown
   - [ ] New task from user
   ```
   If today's section doesn't exist yet, create it with the correct heading format (e.g., `## Tuesday, April 28th`) before adding the tasks.

2. Confirm to the user what was added.

If the user says nothing / leaves it blank / says no, skip the file write entirely.

## Edge cases

- **File doesn't exist yet** (new week, no Sunday entry written): note the file is missing and suggest running `/write-daily` to start the week.
- **No section for today**: show the weekly tasks and note today hasn't been planned yet.
- **Weekend (Friday evening / Saturday / Sunday before writing)**: still show the weekly tasks; note it's the weekend if no today section exists.
