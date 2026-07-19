---
name: write-daily
description: >
  Add a daily work entry to the personal weekly log in ~/chiptus-repos/notes/dailies/.
  Prompts for today's work (pre-populated from git activity), hours, and tomorrow's plans.
  Use this skill whenever the user says /write-daily, "write my daily", "log today's work",
  "update daily log", "add daily entry", or "fill in my daily". Trigger even if they just
  say "daily log" or "add today to my log".
---

# Write Daily Entry

Add a new daily entry to the weekly log file at `/Users/work/chiptus-repos/notes/dailies/`.

## Notes Repo

All file paths are absolute. The notes repo root is:
`/Users/work/chiptus-repos/notes`

Daily files live at: `/Users/work/chiptus-repos/notes/dailies/YYYY/`

## Date and File Calculation

1. **Determine today's information:**
   - Get current date, day of week, and formatted day name (e.g., "Wednesday, April 27th")
   - Calculate which week file this belongs to (weeks start Sunday, end Saturday)
   - Week file format: `YYYY-MM-DD_DD.md` (Sunday's full date, underscore, Saturday's day number only)
   - Example: `2026-04-19_25.md` = week of April 19 (Sun) through April 25 (Sat)

2. **Work week is Sunday to Thursday** (Friday and Saturday are weekend days)
   - Check if today is Thursday — it is the last work day and requires a weekly summary

## Workflow

### Step 0: Review Daily Work

Run the git activity script bundled with this skill to pre-populate today's work:

```bash
/Users/work/.claude/skills/write-daily/scripts/fetch-daily-commits.sh
```

Parse the output to generate suggested tasks per project. Use these suggestions when asking the user what they worked on — don't make them start from scratch.

### Step 1: Prompt for Today's Work

Ask the user: **"What did you work on today?"**

Use AskUserQuestion with multiSelect enabled and these options:

- Portainer
- Other (always available for custom input)

After getting project selection, for each project ask:

1. **"What did you work on for [ProjectName] today?"** — pre-fill with suggestions from Step 0, multiSelect
2. **"How many hours did you work on [ProjectName] today?"** - free text
3. **"Any additional notes for [ProjectName]?"** (free text, optional)

### Step 2: Preview and Confirm Entry

Before writing to the file, show the user the full entry that will be added and ask for confirmation. Only proceed after confirmation.

### Step 3: Add Today's Entry

Read the current week file and add a new section. Include hours per project:

```markdown
## DayName, Month DDth

- ProjectName (X hours)
  - task 1
  - task 2
- AnotherProject (Y hours)
  - task 1
```

### Step 4: Prompt for Tomorrow's Plans

Ask the user: **"What are you planning to work on tomorrow?"**

Get a list of tasks (simple text or structured by project).

Add tomorrow's section with unchecked tasks:

```markdown
## TomorrowDayName, Month DDth

- [ ] Task 1
- [ ] Task 2
```

**Important:** If tomorrow is Sunday (new week), create the next week's file instead of adding to the current file.

### Step 5: Thursday Special Handling

If today is Thursday:

1. Ask: **"Provide a brief summary of what was accomplished this week:"**
   - Add a `## Week Summary` section to the current week file

2. Ask: **"What are your main goals for next week?"**
   - Create next week's file (Sunday–Saturday range)
   - Add goals as tasks under `## Tasks for the week`

### Step 6: Update Weekly Tasks

Review the `## Tasks for the week` section:

- Mark any completed tasks as `[x]`
- Add any new tasks discovered from today's work

### Step 7: Commit

After writing the file, commit the changes:

```bash
cd /Users/work/chiptus-repos/notes && git add dailies/ && git commit -m "daily" && git push
```


## File Format Reference

```markdown
# DD-DD/MM

## Tasks for the week

- [x] Completed task
- [ ] Pending task

## Sunday, April 19th

- Portainer (4 hours)
  - task 1
  - task 2

## Monday, April 20th

- Portainer (3 hours)
  - task 1

## Week Summary

Brief summary of the week's accomplishments (only on Thursday).
```

## Important Notes

- Week starts Sunday (day 1), ends Saturday (day 7)
- Thursday is end of work week for summary purposes
- Always read existing file before modifying to preserve all existing content
- Use proper date formatting matching existing entries
- Create the year directory if it doesn't exist
- When calculating the week file name, Sunday's full date is the prefix, Saturday's day number only is the suffix