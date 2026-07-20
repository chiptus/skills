Quickstart:

```bash
npx skills add chiptus/skills --skill=write-daily
```

```bash
npx skills update write-daily
```

[Source](https://github.com/chiptus/skills/tree/main/skills/chiptus/write-daily)

## What it does

`write-daily` adds a new entry to the current weekly log: what you worked on per project, hours, and tomorrow's plan. It pre-populates the "what did you work on" prompt from actual git activity, so you're confirming and refining rather than reconstructing the day from memory.

The defining constraint is that it never overwrites — it reads the existing week file first and appends, preserving every prior entry, including the running `## Tasks for the week` checklist it updates in place.

## When to reach for it

Type `/write-daily`, or the agent reaches for it automatically when you say "log today's work" or "update daily log."

Reach for it at the end of a work day. On Thursdays (the last day of this work week) it also asks for a week summary and next week's goals, rolling straight into the next week's file.

## Prerequisites

Writes to a personal weekly log at `~/chiptus-repos/notes/dailies/YYYY/YYYY-MM-DD_DD.md` (Sunday-to-Saturday week files) and commits/pushes the notes repo after writing. This path and workflow are hardcoded to one person's setup.

## Where it fits

`write-daily` is a reach-for-it-anytime standalone, the write side of the daily-log pair completed by [what-to-do](https://aihero.dev/skills-what-to-do). See [ask-matt](https://aihero.dev/skills-ask-matt) for how it sits alongside the rest of the flow.
