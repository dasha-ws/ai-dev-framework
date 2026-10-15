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

## Safe test environment

These rules hold for every skill and agent, and during autonomous continuation. Reading and inspecting is always allowed.

- Before any operation that can change or destroy data (tests that write, migrations, seeding, cleanup or reset, schema changes, bulk deletes and the like), find out what it would really hit and whether that is isolated from working data. First read what the project defines: `development.md`, the test configuration, environment files (never print secret values), scripts and container or service definitions. Then look at what actually exists, stopped or unused resources included, not only what is running. Then resolve the real target (host, port, database or schema, container, path) from the effective configuration. A name such as `test` or `dev` proves nothing.
- Isolation is confirmed only when the project's own test infrastructure provides a resource that the project designates for tests and that is verifiably not a working one: a separate instance, store or path, not shared with working data.
- Use the test infrastructure the project defines. Preparing it with the project's own configured command is part of using it: start a stopped resource, create it from the project's own definition (a compose profile, a setup script, a documented test-setup or migration command) and apply the project's own test setup. The isolation check above must pass for what that command actually targets. Never create a substitute (a database, schema, container, file store or other resource) that the project does not define, inside or next to a working resource, or on an assumption.
- If isolation is confirmed, carry on without asking. If it cannot be confirmed, the project defines no test infrastructure, or the target is a working resource, stop before the operation, say what you found and what is missing, and ask the user for the missing verifiable information or for a fix of the configuration. Checks that touch no data (read-only checks, mocks) may continue.
- The user's word does not replace the check. Never offer "please confirm that it is isolated" as the way forward, and do not accept it as proof. Where the evidence shows the target is a working resource, or contradicts itself (a name that says `test` on a port that serves working data), a destructive operation on it is not allowed even with the user's approval, and this overrides any rule elsewhere that allows an explicit authorization for real side effects. The way forward is a corrected configuration that points at the project's test resource, or new verifiable facts (recorded in `development.md` or in the resource definitions), and then the check is done again.

## Finding files and heavy operations

These rules hold for every skill and agent, and for commands in the foreground or the background.

- Use what already tells you where things are, before any file search. Skills are listed in the session: invoke them through the Skill tool, and never look for a `SKILL.md` on disk to find out whether a skill exists. Project context goes through the router, the installed framework templates and scripts live under `%USERPROFILE%\.claude\ai-dev-framework\`, and a path a skill or the project already names is the path. Prefer the dedicated tools (Read, Glob, Grep) to shell search commands.
- Search the smallest scope that can hold the answer: a named file, then the project directory, then a known install directory. Widen only when the narrower scope came up empty, and know why the wider one is the next place to look.
- No recursive search from a filesystem root, a drive root or the home directory (`/`, `C:\`, `~`, `%USERPROFILE%`), whatever the command (`find`, `grep -r`, `rg`, `dir /s`, `Get-ChildItem -Recurse`, a `**` glob and the like), unless the user has agreed to it. When a broader search really is needed, say what you are looking for, where, and why the narrow scope was not enough, and ask. If a search is killed or runs out of memory, do not retry it wider: report it and rethink the scope.
- Before starting an expensive operation, and above all in the background, check that it is needed, what it covers and what it can cost. Keep it scoped and bounded (a narrow path, a timeout). Ordinary development work (tests, builds, a dev server, a search inside the project) needs none of this ceremony.

## Workflow continuation

- Once the user has started a work item, carry it through the framework chain yourself. When a skill finishes (a gate PASS, or success for a skill that is not a gate), run the next step that its "Next skills" section names, through the Skill tool, without asking for permission. Routine steps (verification, code review, documentation updates, repeating a gate) need no extra go-ahead. A microchange continues only through the gates its own rules make applicable.
- The chain ends with the work item. Do not start another independent work item or task on your own. If "Next skills" leaves the next step open or depends on the task, settle it from the task already under way; if that does not settle it, ask.
- On a FAIL, hand the findings to the owner skill that "Next skills" names, let it fix them, then repeat every gate the fix made stale. Keep going while there is a justified fix and each round makes progress (the blocking findings shrink or change). Never repeat a fix that already failed. If a round leaves the same finding in place, take a different approach and say why. Stop and report when no new justified approach exists, or the rules do not allow the fix.
- Stop and ask the user only for: an approval or decision that only they can give; a product decision or a substantial architecture decision; a change of scope or requirements; any route that says to ask or resolve something with the user; a FAIL that cannot be fixed within the approved scope; a risk to data, infrastructure, security, privacy or spend; a `BLOCKED` result that only they can resolve. A `BLOCKED` caused by an earlier PASS that is not established is not one of these: run that gate.
- Never continue on your own into `/deploy` (the deployment itself), and never commit, push or release. `/deploy-check` only checks readiness: it is an ordinary gate and the chain continues into it, then stops after its PASS.
- Record what the user decides: when the user explicitly confirms a gate state, or gives an approval that the framework needs again later, the skill that received it records it in `.claude/work/status.md` as `templates/work/status.md` says, so it is not asked twice.
- After `/clear`, compaction or a restart, do not rely on memory: read `.claude/work/status.md` and run its `check` command (see that file). The current stage is the first step of the normal chain for the work item without a `FRESH` result, or whose artifact does not exist yet. Run again only the gates whose rows are `STALE` or missing. A recorded user approval is not asked again while it is `FRESH`. Never invent an approval or a PASS, and never let one stand in for the other. A decision is also settled where its effect is visible in the project (an agreed requirement in a spec, an agreed decision in `architecture.md`). A deployment confirmation is never recorded and is always asked afresh.
