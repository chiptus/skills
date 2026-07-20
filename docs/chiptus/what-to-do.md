Quickstart:

```bash
npx skills add chiptus/skills --skill=what-to-do
```

```bash
npx skills update what-to-do
```

[Source](https://github.com/chiptus/skills/tree/main/skills/chiptus/what-to-do)

## What it does

`what-to-do` reads the current weekly log and shows this week's goals alongside today's planned tasks, then offers to add anything new to today's list. It's a quick glance at priorities, not a report — the output stays tight even when the week file has a long history of completed work.

The defining constraint is that it reads before it asks: the weekly-goals and today's-tasks sections are pulled from the log file itself, never invented or summarized from memory.

## When to reach for it

Type `/what-to-do`, or the agent reaches for it automatically when you ask what you should work on, what's on your plate, or what's planned for today.

Reach for it any time you want a quick priorities check. If today's section doesn't exist yet, it says so and points you at [write-daily](https://aihero.dev/skills-write-daily) to start the day's entry.

## Prerequisites

Reads from a personal weekly log at `~/chiptus-repos/notes/dailies/YYYY/YYYY-MM-DD_DD.md` (Sunday-to-Saturday week files). This path is hardcoded to one person's setup — the skill won't be useful without that log already in place, populated by [write-daily](https://aihero.dev/skills-write-daily).

## Where it fits

`what-to-do` is a reach-for-it-anytime standalone, the read side of the daily-log pair completed by [write-daily](https://aihero.dev/skills-write-daily). See [ask-matt](https://aihero.dev/skills-ask-matt) for how it sits alongside the rest of the flow.
