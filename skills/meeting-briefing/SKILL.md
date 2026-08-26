---
name: meeting-briefing
description: Give the user a concise, decision-oriented meeting brief from the current project when they say a meeting is starting or ask what to load into context.
---

# Meeting briefing

Use this skill for requests such as "meeting starts now", "daily start", "brief me for this meeting", or "what should I load?".

## Goal

Give the user enough current context to enter the meeting in ten seconds. Optimize for decisions and the desired outcome, not background.

## Read only what matters

1. Identify the meeting or workstream from the user's message, the current directory, recent context, or the most recent clearly related note or task.
2. Read project-local instructions first when they exist (for example, `AGENTS.md`, `CONTRIBUTING.md`, or a project README). Follow their source-of-truth rules.
3. Read the smallest relevant set of current files. Prefer a meeting-prep file, current brief, decision log, issue, task list, or recent activity record.
4. Check dates, status, and wording before relying on a source. Treat old notes, snapshots, generated files, and pages explicitly marked historical as background only.
5. Read blocked, waiting, or in-progress states only when they affect this meeting.
6. Skip unrelated projects, broad documentation, and source material that does not change today's decisions.

If no reliable current source exists, say so briefly and ask the user for the meeting topic or current source. Do not fill the gap with stale project context.

## Output

Use this exact shape:

```markdown
### [Meeting name]

Goal: [one sentence]

Decide:
- [decision]
- [decision]
- [decision]

Leave with: [one sentence describing the concrete result]

Load: [at most three linked files]
```

Use three to five decision bullets. Add an `Ask:` section only when a question must be answered in the meeting. Keep the whole brief below 100 words when possible. Link files using paths valid in the current project.

## Rules

- Put the meeting goal first.
- Name decisions as actions: "Choose five hospitals", not "Hospital selection".
- State one concrete completion condition: owners, a date, an approved draft, or a selected batch.
- Mention a blocker in one short line only if it changes the meeting plan.
- Keep the user's role clear. Put external conversations, approvals, and commitments with the user.
- Link only files the user may need to load now.
- Do not include a history section, generic advice, or a long explanation.
- Ask for clarification only when the meeting cannot be identified from the repo and the user's message.
- Never imply that a project is current merely because a matching page or directory exists.
- Do not modify project files while preparing the brief.
