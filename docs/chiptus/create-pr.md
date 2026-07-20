Quickstart:

```bash
npx skills add chiptus/skills --skill=create-pr
```

```bash
npx skills update create-pr
```

[Source](https://github.com/chiptus/skills/tree/main/skills/chiptus/create-pr)

## What it does

`create-pr` opens a pull request for the current branch with three parts, each held to its own rule: a commitlint-compliant title (`<type>(<scope>): <subject>`), a one-or-two-line description, and a `## Verification` section of reviewer-testable bullets. It will not open the PR until all three meet their bar.

The defining constraint is the Verification section: each bullet must be a testable action a reviewer can perform ("Invite already-member; error shown"), not an assertion that the code works. It's only skipped when the diff has no runtime behavior to exercise, and even then the description says why.

## When to reach for it

Type `/create-pr`, or the agent reaches for it automatically when you ask to open, create, or raise a PR.

Reach for it once your branch is pushed and ready for review. For addressing feedback on a PR that already exists, use [pr-review-fixer](https://aihero.dev/skills-pr-review-fixer) instead.

## Three required parts

The title, description, and verification bullets aren't optional extras — the skill rejects a title without a valid type or scope, pads nothing into the description, and only omits verification for diffs with no runtime behavior. Each part has one job and stays terse: the description doesn't repeat the title, and the verification list leads with the golden path before edge cases.

## Where it fits

`create-pr` is a reach-for-it-anytime standalone, typically the last step before or right after `/implement` finishes a branch. See [ask-matt](https://aihero.dev/skills-ask-matt) for how it sits alongside the rest of the flow.
