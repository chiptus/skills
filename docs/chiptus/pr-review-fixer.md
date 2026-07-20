Quickstart:

```bash
npx skills add mattpocock/skills --skill=pr-review-fixer
```

```bash
npx skills update pr-review-fixer
```

[Source](https://github.com/mattpocock/skills/tree/main/skills/chiptus/pr-review-fixer)

## What it does

`pr-review-fixer` fetches every unresolved review thread and top-level review comment on the current PR, analyzes what each reviewer actually means, proposes a concrete fix for each, and then implements only the ones you approve in free text.

It never resolves a thread it hasn't actually addressed, and it never guesses which comments you want fixed — you always get a numbered list and a chance to say "fix 1, 2, 4" or "skip 3" before anything changes.

## When to reach for it

Type `/pr-review-fixer`, or the agent reaches for it automatically when you ask to review PR comments, address review feedback, or respond to code review.

Reach for it once a PR has feedback waiting. For opening a new PR in the first place, use [create-pr](https://aihero.dev/skills-create-pr) instead.

## Cascades and sizing

Before presenting anything, the skill looks for **cascades** — comments that all stem from one root change, like an API refactor and its call-site follow-ons — and groups them under a single number so you can approve the whole chain as one decision instead of five. Each item also gets sized (`small`, `medium`, `large`): small and medium fixes are implemented on approval, but large ones are flagged as needing a dedicated follow-up session rather than attempted inline.

## It's working if

- Every proposed fix quotes the exact comment it's addressing.
- Related follow-on comments show up as one grouped cascade, not five separate numbered items.
- Threads only get resolved after their fix is actually applied — never resolved speculatively.
- Large items are called out as deferred, not silently attempted.

## Where it fits

`pr-review-fixer` is a reach-for-it-anytime standalone you drop into whenever a PR has open feedback. See [ask-matt](https://aihero.dev/skills-ask-matt) for how it sits alongside the rest of the flow.
