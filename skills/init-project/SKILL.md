---
name: init-project
description: Prepare a target project for work with ai-dev-framework. Inspects the project's current state, then creates only the missing local project context, work folders and a short root CLAUDE.md, without inventing facts or overwriting anything. Entry point for new and existing projects; run it before /product-spec.
---

# init-project

## Purpose

`/init-project` is the bootstrap entry point for a **target project**: a new one, an existing one that is adopting ai-dev-framework, or a partially initialised one. It creates only the missing local framework structure: a project context that later skills can read, working folders for specs, and a short root `CLAUDE.md` that points Claude Code to all of it. It records what is already true and what the user has said, and everything else stays an honest `TODO`. It does not build the product, author requirements or design architecture.

## When to use

- A new project has no framework structure yet.
- An existing project is adopting ai-dev-framework.
- A project is partially initialised and some framework files are missing (re-running is safe: it only fills gaps).

## When not to use

- The current directory is the **ai-dev-framework repository itself**. It is the source of the framework, not a target. If the root contains the framework's own `skills/` folder with skills such as `init-project`, stop and ask which project the user means.
- The project is fully initialised and nothing is missing. Report that and suggest the next skill.
- The user wants requirements, architecture or an implementation plan: `/product-spec`, `/architecture`, `/tech-spec`.
- The user wants git setup, dependencies, Docker, CI/CD, hosting or deployment (see "Hard limits").

## Inputs

- **Target project root.** Default: the current working directory. Confirm it if there is any doubt.
- **The project itself** (existing projects): its files, configuration and code are the source of facts.
- **Starter answers** (new projects, or existing ones where facts are missing). At most three questions: the project name, a short statement of what it is for, and whether it has a user interface, user-facing scenarios or user-facing content. The communication language (step 1) is a working preference, not a project fact: it is asked separately and does not count toward these three.
- **Installed framework templates**, under `%USERPROFILE%\.claude\ai-dev-framework\templates\`: the root `CLAUDE.md` template (`CLAUDE.md`), the `project-context` templates (router and context files, in `project-context\`) and the product-spec template (`product-spec.md`).

## Files to read

Read before writing anything. All reads are read-only. Read the target project selectively:

- the top-level directory listing and the first level of subdirectories;
- `CLAUDE.md`, `.claude/` (settings, existing skills, existing specs) and `README*`;
- project configuration: package manifests, build files, `Makefile`, tool, test and lint configs;
- infrastructure files, as facts only: `Dockerfile`, compose files, CI configs, deploy scripts, `.env.example`. Never read real `.env` files, keys or credentials;
- documentation folders (`docs/`, ADRs) and any existing spec convention;
- entry points and the top-level source layout: skim, do not audit;
- git state, read-only, only to know what exists: the baseline commands of step 2 and the current branch.

The installed framework templates are read in step 4.

## Execution steps

### 1. Confirm the target and the communication language

Verify that the working directory is a target project, not the framework repo (see "When not to use").

Then settle the communication language before asking the user anything else, so that every later question, explanation and report is already in it. Read the root `CLAUDE.md`, if there is one, for a `Communication language` rule:

- **A clear preference is there:** use that language from now on. Do not ask again and do not rewrite it.
- **None is there** (including no `CLAUDE.md`, or a `TODO`): ask, in a short message of its own, which language the user wants Claude Code to use when communicating with them in this project. The message asks nothing else. Switch to the answer at once. It is recorded in step 8. If the user declines, the rule stays a `TODO`.
- **It is ambiguous or contradictory:** do not guess. Ask which language applies, the same way.

This applies to new and existing projects alike. Never infer the language from the code, the README, the OS locale or any single project file. Only the conversation switches language: everything written to files stays in English, and the language itself is stored by its English name. Store nothing else about the conversation: no messages, replies or transcripts.

Then confirm the project root with the user if it is unclear (if that changes the target, check the new root's `CLAUDE.md` the same way).

### 2. Inspect and classify the state

Read the files listed above. Classify the project: **new** (empty, or little beyond a stub), **existing** (has code, configuration or documentation) or **partially initialised** (some framework files already exist). Note which required framework files and folders already exist. Existing files are never candidates for overwriting.

In a git repository, take a read-only baseline before the first write with `git status --short -uall`, `git diff` and `git diff --cached`. A clean tree is not required, and existing user changes are preserved. If the project is not a git repository, do not invent a substitute.

### 3. Collect facts, ask only what is missing

For an existing project, facts come from the repository. Ask the user only what the repository cannot answer. For a new project, or when name, purpose or UI presence cannot be determined, ask the starter questions (at most three, in one message; the language question of step 1 is not one of them) and nothing more. No product interview: users, goals, scope, metrics and constraints are `/product-spec` territory. If the user does not want to answer, proceed with `TODO` markers. Use only facts confirmed by existing project files or explicit user answers. An unconfirmed fact stays a `TODO` or gets asked about.

Decide whether `ux-guide.md` is needed. It is needed only if the project has a user interface, user interaction scenarios or user-facing content. With evidence in the repo or a clear user answer: needed. Clearly none (for example a library or a headless service with no user-facing text): not needed, do not create it and say so in the report. Unclear: ask the user before deciding.

### 4. Check the templates

Check only the templates this initialisation will actually need: those for the files that will be created (`ux-guide.md` only if it is needed). They live under the template root named in "Inputs", so do not look elsewhere. If a required template is missing or empty, **stop**: tell the user which one is unavailable and that the ai-dev-framework installation needs fixing. Do not recreate it from memory, do not build an alternative structure and do not continue until the problem is resolved.

### 5. Resolve conflicts and show the plan

Ask the user first when the existing structure clashes with the framework structure: `.claude/skills/project-context/` exists with a different layout; `.claude/product` or `.claude/work` exists as a file or with another convention; `CLAUDE.md` exists and is long, or already routes Claude Code elsewhere; the project keeps specs or context in another place (`docs/`, `specs/`, a wiki) and the framework would duplicate it. Present the conflict, the options (adapt to what exists, add alongside, skip) and your recommendation. Do not reorganise the codebase: the framework adapts to the project, not the other way round.

Then list what will be created, what already exists and will be left alone, and any proposed change to an existing file (as the exact text to be added). If the plan has no modifications to existing files and no open conflicts, proceed after showing it. Otherwise wait for approval.

### 6. Create the missing structure

Create only what does not exist. The target layout:

```
CLAUDE.md
.claude/
  skills/
    project-context/
      SKILL.md
      context/
        product.md
        architecture.md
        development.md
        infrastructure.md
        ux-guide.md        (conditional, see step 3)
  product/
    product-spec.md
  work/
    completed/
```

- Create each file from its installed framework template. Never improvise a template's structure or content.
- Existing files are skipped and reported, never replaced, so re-running stays safe.
- `.claude/work/` holds current specs and `.claude/work/completed/` holds finished ones. Create the folder, and add no placeholder files to it unless the user asks (mention that git will not track an empty folder).
- `.claude/product/product-spec.md` is created from its template as a not-started stub. It is not a draft of the specification.

### 7. Fill the context files and write the router

**Context files: facts only.** Write only facts confirmed by existing project files or explicit user answers. Everything else gets `TODO(<owner>): <what is needed>`, where the owner is the skill or person expected to supply it. No source labels are needed. A file that ends up mostly `TODO` is a correct result for a young project. Padding it with plausible-sounding text is not.

| File | What may go in at init | Everything else |
|------|------------------------|-----------------|
| `product.md` | Name, purpose, UI presence, as stated by the user or found in the README. | `TODO(product-spec)`. No invented users, goals or constraints. |
| `architecture.md` | For existing projects: observed top-level layout, entry points, obvious components. Descriptions, not judgments. | `TODO(architecture)`. No assumed design intent. |
| `development.md` | Language, framework, package manager, and build, test, lint and run commands found in configuration. | `TODO(confirm)`. No guessed stack, including for new projects. |
| `infrastructure.md` | Infrastructure that already exists in the repo (Dockerfile, CI config, deploy scripts), stated as found. | `TODO(infrastructure)`. No suggested services. |
| `ux-guide.md` | See step 3. | `TODO(ux)`. |

**The router**, `.claude/skills/project-context/SKILL.md`, is a router for the project's context, not a summary of it. It has valid skill frontmatter (`name`, and a `description` that says when the router applies) and tells Claude Code:

- which context files exist (only the ones actually created) and what each is responsible for;
- which file to read for which kind of task: product intent and terminology (`product.md`), structure and boundaries (`architecture.md`), stack, commands and conventions (`development.md`), environments and deployment (`infrastructure.md`), interface and tone of text (`ux-guide.md`);
- to **read only what the current task needs** and not load the whole context by default;
- to treat a `TODO` as a gap to ask about, never as permission to guess.

It may note that requirements live in `.claude/product/product-spec.md` and current specs in `.claude/work/`, but it does not duplicate them.

### 8. Root `CLAUDE.md`

Keep it a short entry point. It contains only: a brief description of the project (from the README or the user, otherwise `TODO`); where the project context lives (`.claude/skills/project-context/`); where current specs live (`.claude/work/`); the basic working rules for Claude Code in this project (read the router first and load only relevant context; treat specs in `.claude/work/` as the source for current work; do not invent facts; ask when something is ambiguous; do not touch files unrelated to the task); the communication language from step 1, as `Communication language: <language>`, with the rule that framework-managed files stay in English; and a note that the project uses ai-dev-framework. No requirements, architecture, infrastructure or other documentation goes into it.

The project description is a summary of confirmed facts, so it must not change them. Write it from the same confirmed facts as `product.md` and check it against them. It may be short and it may be general, but it must not change who initiates an action, whether an action is automatic or user-triggered, timing, cause and effect, or any other material behavioural distinction (a step the user triggers is not one that happens on its own). If the confirmed behaviour does not fit in a short description, state it more generally, not more falsely. It stays a short orientation, not a second product description: the detail lives in `product.md`.

If `CLAUDE.md` already exists, do not replace or restructure it. Show the short section you propose to add, including the communication-language rule unless the file already has a clear one, and apply it only after the user agrees. The language rule gets no separate overwrite or approval path.

### 9. Check your work, report and stop

Before reporting, verify that:

- every required file and folder exists (except a deliberately skipped `ux-guide.md`);
- nothing existing was overwritten and only the files of this skill changed: repeat `git status --short -uall`, `git diff` and `git diff --cached` (read-only) and compare them, contents included and not only paths, with the baseline and the state you observed in step 2;
- every statement in the context files is confirmed by an existing project file or an explicit user answer, and everything else is a `TODO`;
- the project description in `CLAUDE.md` changes no confirmed fact it summarises;
- the router still only routes, and `CLAUDE.md` contains nothing beyond step 8.

Fix any failure before reporting. Then report briefly: what was created, what already existed and was left alone, what was skipped and why, the `TODO`s that remain and any decision you are waiting on. Suggest `/product-spec` as the next step, with a clause on why: it turns the user's idea into agreed product requirements. Then **stop**. Do not start it.

## Hard limits

**Whatever the user asks,** `/init-project` does not author product or feature requirements, take substantive architecture decisions, create Tech Spec design, implement production functionality, or redesign infrastructure or tooling. An explicit request does not make such work a responsibility of this skill: it belongs to `/product-spec`, `/new-feature-spec`, `/architecture`, `/tech-spec` and the implementation skills. It also never runs `git stash`, `git reset`, `git checkout`, `git restore` or any other command that changes git state, except the narrow `git init`, staging and commit exception below. Git is otherwise for inspection only: the baseline and the final comparison are read-only.

Unless the user asks for it explicitly and separately, `/init-project` does not:

- run `git init`, stage anything or commit (this exception covers nothing else in git);
- install dependencies, create Docker configuration, set up CI/CD, add external services, deploy anything or change existing infrastructure;
- reorganise or refactor the codebase.

It writes only the layout of step 6 and the root `CLAUDE.md` of step 8, and creates no skills, agents, templates, scripts, folders or document types beyond them.

## Outputs

In the target project, only what was actually missing and created: `.claude/skills/project-context/SKILL.md` (the router) and `context/` with `product.md`, `architecture.md`, `development.md`, `infrastructure.md` and, when applicable, `ux-guide.md`; `.claude/product/product-spec.md` (a stub, not started); `.claude/work/completed/`; a short root `CLAUDE.md`, or a proposed addition to the existing one awaiting approval. In the conversation: the report of step 9.

## Completion criteria

`/init-project` is done when all of these are true:

- the target project's state was inspected and classified before any write;
- all missing structure of step 6 exists, and nothing existing was overwritten or reorganised;
- every file was created from an installed framework template, and the context files hold only confirmed facts with every gap a `TODO`;
- `ux-guide.md` exists if and only if the project has a user-facing interface, scenarios or content (or the user decided otherwise), the router routes selectively, and the root `CLAUDE.md` is short and records the communication language, or its proposed change is waiting for approval;
- only the files owned by this skill changed, checked against the baseline, and no hard-limit action was taken;
- the report was given, and `/product-spec` was suggested, not run.

## Next skills

- `/product-spec`: the usual next step. It turns the user's intent into a real specification and fills the product-level gaps left as `TODO(product-spec)`.
- `/architecture`: reasonable next for an existing project whose structure needs documenting before any change.
- `/new-feature-spec`: usable without a prior `/product-spec` only if the product context is already clear enough from the existing project and its `project-context` (the check is in that skill). A missing product spec is never a licence to invent product context.
