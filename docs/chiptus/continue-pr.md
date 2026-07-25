Quickstart:

```bash
npx skills add chiptus/skills --skill=continue-pr
```

```bash
npx skills update continue-pr
```

[Source](https://github.com/chiptus/skills/tree/main/skills/chiptus/continue-pr)

## What it does

`continue-pr` picks up work on a branch that already has an open PR, instead of starting a fresh branch or re-deriving the plan from scratch. It checks out the named branch — never creates a new one — then grounds the rest of the work in the PR itself: the PR body says what's already done, and unresolved review comments are the real remaining work list, not a suggestion to skim.

## When to reach for it

Type `/continue-pr`, or the agent reaches for it automatically when you give it a branch and PR and say to continue, keep working, or work on the PR.

Reach for it when an issue is already in progress with an open PR. For opening a brand-new PR, use [create-pr](https://aihero.dev/skills-create-pr) instead; for just working through review feedback on a PR you're not otherwise resuming, use [pr-review-fixer](https://aihero.dev/skills-pr-review-fixer).

## Verify before assuming undone

Before doing any new work, the skill diffs the issue's acceptance criteria against what's already on the branch — some may already be met by existing commits, so it checks the actual code rather than assuming an unchecked box means undone work.

## It's working if

- The existing branch is checked out, not a new one created.
- Unresolved review comments are each treated as a task, not skimmed.
- Comments already satisfied by existing code get a reply and thread resolution instead of redundant rework.
- Work lands as a push to the same branch, not a new PR.

## Where it fits

`continue-pr` is a reach-for-it-anytime standalone for resuming in-progress work. See [ask-matt](https://aihero.dev/skills-ask-matt) for how it sits alongside the rest of the flow.
