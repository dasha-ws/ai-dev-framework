# CLAUDE.md

## Project

TODO: a one-line description of what this project is.

This project uses ai-dev-framework.

## Context and specs

- Project context lives in `.claude/skills/project-context/`. Read its `SKILL.md` (the router) first, and load only the context the current task needs.
- Current specs live in `.claude/work/`. Treat them as the source for current work.

## Working rules

- Communication language: TODO (the language Claude Code uses when talking to the user in this project).
- Framework-managed files (project context, specs) are written in English, whatever the communication language.
- Do not invent facts.
- Ask when something is ambiguous instead of guessing.
- Do not touch files unrelated to the task.
