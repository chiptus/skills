Quickstart:

```bash
npx skills add chiptus/skills --skill=pr-review-fixer
```

```bash
npx skills update pr-review-fixer
```

[Source](https://github.com/chiptus/skills/tree/main/skills/chiptus/pr-review-fixer)

## What it does

`pr-review-fixer` fetches every unresolved review thread and top-level review comment on the current PR, analyzes what each reviewer actually means, gives each actionable comment a verdict, proposes a concrete fix, and then implements only the ones you approve in free text.

It never resolves a thread it hasn't actually addressed, and it never guesses which comments you want fixed. You always get a numbered list and a chance to say "fix 1, 2, 4" or "skip 3" before anything changes.

## Verdicts

Each action-required, suggestion, or revert comment is judged on evidence, not on the reviewer's tone:

- **Needed**: the skill can name the concrete failure (input, state, or event) and it can happen in this repo's real usage.
- **Optional**: correct, but the failure is rare, cosmetic, or cheaper to accept.
- **False positive**: the claim is wrong, proven by reading the code or running the command on a scratch repo.
- **Pre-existing**: the commented lines are identical on the PR's base branch, so they are skipped here, with a follow-up named if the failure is Needed.

The skill recommends fixing the Needed ones and skipping the rest, and leaves skipped threads unresolved until you say otherwise. It also prefers the fix that deletes the thing a comment is about over one that adds machinery around it, since every added line invites the next review comment.

## Unattended mode

Invoke it with `unattended` (a long-running agent, no human to answer) and it skips the approval question and acts on its own verdicts. Needed fixes that are `small` or `medium` are made and their threads resolved. Needed `large` items and Needed pre-existing bugs get a ticket. Everything else is skipped. Questions get an answer and are resolved. Every other thread that isn't fixed gets a reply with the decision and a short explanation (plus the ticket link if needed), and stays unresolved so a human can overrule it. The run ends with one summary of what was fixed, ticketed, and skipped.

## When to reach for it

Type `/pr-review-fixer`, or the agent reaches for it automatically when you ask to review PR comments, address review feedback, or respond to code review.

Reach for it once a PR has feedback waiting. For opening a new PR in the first place, use [create-pr](https://aihero.dev/skills-create-pr) instead.

## Cascades and sizing

Before presenting anything, the skill looks for **cascades** — comments that all stem from one root change, like an API refactor and its call-site follow-ons — and groups them under a single number so you can approve the whole chain as one decision instead of five. Each item also gets sized (`small`, `medium`, `large`): small and medium fixes are implemented on approval, but large ones are flagged as needing a dedicated follow-up session rather than attempted inline.

## It's working if

- Every proposed fix quotes the exact comment it's addressing and carries a verdict naming the failure and how likely it is here.
- In unattended mode, every skipped or ticketed thread carries a reply with the decision and why.
- It recommends skipping the Optional, False positive, and Pre-existing comments instead of fixing all of them.
- Related follow-on comments show up as one grouped cascade, not five separate numbered items.
- Threads only get resolved after their fix is actually applied — never resolved speculatively.
- Large items are called out as deferred, not silently attempted.

## Where it fits

`pr-review-fixer` is a reach-for-it-anytime standalone you drop into whenever a PR has open feedback. See [ask-matt](https://aihero.dev/skills-ask-matt) for how it sits alongside the rest of the flow.
