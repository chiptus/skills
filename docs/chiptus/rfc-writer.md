Quickstart:

```bash
npx skills add mattpocock/skills --skill=rfc-writer
```

```bash
npx skills update rfc-writer
```

[Source](https://github.com/mattpocock/skills/tree/main/skills/chiptus/rfc-writer)

## What it does

`rfc-writer` produces a complete RFC document for a proposed change, in the Portainer RFC format. It gathers what it can from the environment first — git log, diff stat, commit messages, a linked Linear ticket — and only interviews you about what's left unclear, rather than starting from a blank-page interview.

The defining constraint is that context-gathering comes before questions: the author shouldn't have to repeat anything already sitting in the code, commits, or ticket.

## When to reach for it

Type `/rfc-writer`, or the agent reaches for it automatically when you ask to write, draft, or RFC a proposed change.

Reach for it once you have a branch with real commits to reason about — it reads `git log main..HEAD` and the diff stat to build context, so it's most useful after the work (or at least a design direction) already exists. For turning a conversation into a spec for the issue tracker instead, use [to-spec](https://aihero.dev/skills-to-spec).

## Prerequisites

Works best on a branch with commits ahead of `main` or `develop`, so it has git history and a diff stat to read. A Linear ticket ID in the branch name or commit messages (e.g. `BE-12345`) lets it pull full ticket context automatically via the Linear MCP — without one, it just asks you directly.

## Quality bar, not just a template

The skill holds itself to a checklist beyond filling in section headings: a non-author has to get the "so what" from the Overview alone, the Problem section has to explain *why* the status quo was insufficient, and an RFC that lists no trade-offs is treated as suspect, not complete. It also actively resists writing like an AI — no padding, no restating what was just said.

## Where it fits

`rfc-writer` is a reach-for-it-anytime standalone, typically used once a change is built or well-scoped and needs to be documented for review. See [ask-matt](https://aihero.dev/skills-ask-matt) for how it sits alongside the rest of the flow.
