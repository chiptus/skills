---
name: rfc-writer
description: Write a Request for Comments (RFC) document for a pull request, feature, or significant change. Use this skill whenever the user asks to write an RFC, draft an RFC, or document a proposal. Also trigger when the user says things like "let's RFC this", "I need to write up a proposal for", "document this change for review", or "create a design doc for this PR". The skill gathers context from the current branch (git history, code changes, Linear tickets) and interviews the author to fill gaps, then produces a complete RFC in the Portainer RFC format.
---

# RFC Writer

Your job is to produce a complete, well-reasoned RFC document for a proposed change. The primary audience is engineers, but the RFC may also be read by non-engineers — so prefer clear, direct writing over dense jargon, but never replace a precise technical term with a vague plain-language substitute.

Write concisely and conversationally — direct, not formal. Every sentence should carry information. Don't add text just to fill a section — a short, honest section is better than a padded one. Avoid constructions that sound AI-generated: don't restate the obvious, don't summarize what you just said, don't use filler phrases like "it's worth noting that" or "this ensures that".

## Process

### 1. Gather context automatically

Before asking the author anything, collect what you can from the environment:

- **Author and date**: get the author name from `git config user.name` and today's date from the system — fill these in automatically, no need to ask
- **Git log**: `git log main..HEAD --oneline` (or `develop..HEAD`) — understand what commits are on this branch
- **Git diff summary**: `git diff main..HEAD --stat` — understand the scope and files changed
- **Commit messages**: read them for goals, motivations, ticket references
- **Linear ticket**: if a ticket ID appears in commits or branch name (e.g. `BE-12345`), fetch it via the Linear MCP to get the full context — title, description, acceptance criteria.
- **Key changed files**: read the most important files to understand what actually changed. For large diffs, prioritize config files, entry points, and key services — skip lock files, generated files, and test files.

### 2. Interview the author

Once you've read the available context, identify what's still unclear and ask in one focused batch. Don't ask for things you can already infer. Common gaps:

- Is there a related Linear ticket? (if none was found automatically)
- What problem does this solve? (if not clear from the ticket/commits)
- What alternatives were considered and why were they rejected?
- What are the known trade-offs or risks?
- Any constraints or requirements that drove key decisions?

Keep it to the minimum questions needed — the author shouldn't have to repeat what's already in the code or tickets.

### 3. Write the RFC

Produce the RFC as a markdown document. Use this structure:

---

```
# <title>

---
Created: <date>
Status: DRAFT
---

## Authors
- <author name>

## Reviewers
| Name | Reaction | Comment |
|------|----------|---------|
|      |          |         |

## Overview

<2–3 paragraph summary of what this RFC proposes and why. Should be readable by anyone in the company, not just engineers. Focus on the "so what" — why does this matter?>

## Problem

<What is the current situation, and what pain point or opportunity is this addressing? Be concrete. If there's a ticket, summarize the key context here — don't just say "see Linear ticket".>

## Proposed Solution

<Describe what was built or is being proposed. Explain the approach clearly. Include key architectural or design decisions and the reasoning behind them. Use subheadings if the solution has multiple distinct parts.>

## Alternatives Considered

<What other approaches were evaluated? For each alternative, briefly describe it and explain why it was rejected. "We didn't think about it" is not an alternative — only include real ones that were weighed.>

## Trade-offs & Risks

<What are the downsides, limitations, or open questions? Be honest. An RFC that acknowledges no trade-offs is usually missing something.>

## Implementation Notes

<Optional. Any important details about rollout, migration, backward compatibility, or follow-up work needed.>
```

---

## Quality bar

A good RFC passes these tests:
- A non-author reads the Overview and immediately understands the "so what"
- The Problem section explains *why* the status quo was insufficient
- Design decisions are traceable — you can understand *why* a choice was made, not just *what* was chosen
- Trade-offs are honest, not marketing
- It doesn't read like it was written by an AI — no padding, no obvious restatements, no filler

## Output

Write the RFC to `RFC.md` in the current working directory. Then ask the author what needs refining — invite them to point at specific lines or sections and suggest changes.
