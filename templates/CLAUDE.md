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

## Workflow continuation

- Once the user has started a work item, carry it through the framework chain yourself. When a skill finishes (a gate PASS, or success for a skill that is not a gate), run the next step that its "Next skills" section names, through the Skill tool, without asking for permission. Routine steps (verification, code review, documentation updates, repeating a gate) need no extra go-ahead. A microchange continues only through the gates its own rules make applicable.
- The chain ends with the work item. Do not start another independent work item or task on your own. If "Next skills" leaves the next step open or depends on the task, settle it from the task already under way; if that does not settle it, ask.
- On a FAIL, hand the findings to the owner skill that "Next skills" names, let it fix them, then repeat every gate the fix made stale. Keep going while there is a justified fix and each round makes progress (the blocking findings shrink or change). Never repeat a fix that already failed. If a round leaves the same finding in place, take a different approach and say why. Stop and report when no new justified approach exists, or the rules do not allow the fix.
- Stop and ask the user only for: an approval or decision that only they can give; a product decision or a substantial architecture decision; a change of scope or requirements; any route that says to ask or resolve something with the user; a FAIL that cannot be fixed within the approved scope; a risk to data, infrastructure, security, privacy or spend; a `BLOCKED` result that only they can resolve. A `BLOCKED` caused by an earlier PASS that is not established is not one of these: run that gate.
- Never continue on your own into `/deploy` (the deployment itself), and never commit, push or release. `/deploy-check` only checks readiness: it is an ordinary gate and the chain continues into it, then stops after its PASS.
- Record what the user decides: when the user explicitly confirms a gate state, or gives an approval that the framework needs again later, the skill that received it records it in `.claude/work/status.md` as `templates/work/status.md` says, so it is not asked twice.
- After `/clear`, compaction or a restart, do not rely on memory: read `.claude/work/status.md` and run its `check` command (see that file). The current stage is the first step of the normal chain for the work item without a `FRESH` result, or whose artifact does not exist yet. Run again only the gates whose rows are `STALE` or missing. A recorded user approval is not asked again while it is `FRESH`. Never invent an approval or a PASS, and never let one stand in for the other. A decision is also settled where its effect is visible in the project (an agreed requirement in a spec, an agreed decision in `architecture.md`). A deployment confirmation is never recorded and is always asked afresh.
