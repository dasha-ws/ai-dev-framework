---
name: architecture
description: Work with the durable architecture of a target project in exactly one of three modes: document the current architecture of an existing project, design the initial architecture of a new product from a reviewed Product Spec, or, from a reviewed Feature Spec, design a substantial architecture change (first deciding whether one is needed, when the impact is unclear). Writes only .claude/skills/project-context/context/architecture.md. Substantive architecture work needs a PASS from the independent architecture-reviewer; a Case B no-op or narrow factual sync does not. Not a Tech Spec. Run it after /init-project; the next step is usually /tech-spec.
---

# architecture

## Purpose

`/architecture` is the sole owner of substantive architecture decisions of a **target project**. It works with the durable architecture context:

`.claude/skills/project-context/context/architecture.md`

That file is durable architecture, not a Tech Spec and not an implementation plan. `/tech-spec` later describes how to implement one piece of work inside the agreed architecture.

It works in exactly one of three modes (step 2): documenting the current architecture of an existing project, defining the initial target architecture of a new product, or resolving the architecture impact of a reviewed Feature Spec, and changing the architecture when a substantial change is needed. A PASS of the independent `architecture-reviewer` belongs to the current reviewed version of `architecture.md`. Nothing is launched automatically.

## When to use

- **Mode 1.** An existing project where the architecture lives in code and configuration, but `architecture.md` is missing in substance, incomplete or outdated.
- **Mode 2.** A new product: `/product-spec` → `/review-spec` → PASS → `/architecture`.
- **Mode 3.** An existing product: `/new-feature-spec` → `/review-spec` → PASS → `/architecture`, when the reviewed Feature Spec either clearly requires a substantial change of architecture, or has an architectural impact that cannot be safely determined before `/tech-spec` without separate architecture analysis.

Architecture work is for durable structural decisions with cross-feature or system consequences: major component or service boundaries, core storage, major integrations, key data flows, a substantial architectural pattern, or a change that needs one shared structural decision. It is also for an architecture that is insufficient or undefined for a safe technical design, and for recording the actual architecture of an existing project. Ordinary local implementation design stays with `/tech-spec`.

A feature whose reviewed Feature Spec clearly has no architectural impact (Case A) is not an `/architecture` case. `/architecture` is not run for it, and the workflow goes straight to `/tech-spec`.

## When not to use

- The current directory is the **ai-dev-framework repository itself**. It is the source of the framework, not a target. If the root contains the framework's own `skills/` folder, stop and ask which project the user means.
- The framework structure created by `/init-project` is missing. Stop, say what is missing and suggest `/init-project` (step 1).
- The work is only a new function, endpoint, table, screen, bot command, a local change inside one module, or an ordinary bugfix, and it clearly does not change the durable architecture. Do not invent architecture work: go straight to `/tech-spec`. If the impact of a reviewed Feature Spec is unclear, that is mode 3, and step 5 decides.
- The upstream requirements have not passed `/review-spec` (modes 2 and 3). Stop and suggest `/review-spec` first (step 3).
- The requirements themselves have to change: `/product-spec` or `/new-feature-spec`, then a mandatory `/review-spec`.
- The user wants a Tech Spec or an implementation plan (`/tech-spec`), code, tests, infrastructure changes or deployment.

## Inputs

- **Target project root.** Default: the current working directory. Confirm it if there is any doubt.
- **The user:** the task, answers to clarifying questions and decisions on significant architectural choices.
- **The project itself:** code, configuration, existing documentation, existing infrastructure.
- **The framework structure in the target project**, created by `/init-project`: root `CLAUDE.md`, `.claude/skills/project-context/SKILL.md`, and in `.claude/skills/project-context/context/` the files `architecture.md`, `product.md`, `development.md` and `infrastructure.md`, plus `.claude/product/product-spec.md` and `.claude/work/`. All are required.
- **Reviewed upstream requirements** (modes 2 and 3 only): the Product Spec for the initial architecture, the Feature Spec of the work item (`.claude/work/<feature-name>/feature-spec.md`) for mode 3.
- **The installed architecture template.** `architecture.md` was created from it by `/init-project`. It lives at `%USERPROFILE%\.claude\ai-dev-framework\templates\project-context\context\architecture.md`. Do not look for it by other means.
- **The `architecture-reviewer`**, as provided by the current installation.

## Files to read

Read before writing anything. All reads are read-only.

Always: the root `CLAUDE.md`, the project-context router (`.claude/skills/project-context/SKILL.md`), `architecture.md`, `product.md`, `development.md`, `infrastructure.md` and the installed architecture template. `ux-guide.md` only if the router and the task show that UI or interaction architecture is relevant. Then, per mode:

- **Mode 2:** the reviewed Product Spec, the README and relevant product documentation if needed, and the existing constraints.
- **Mode 3:** the reviewed Feature Spec, the substantive Product Spec, related current specs if needed, the existing architecture, and the relevant parts of code and configuration, so that the change fits the real project.
- **Mode 1:** only what is needed: the top-level source layout and entry points, package and build configuration, major modules and components, APIs and interfaces between major parts, data and storage configuration, integrations, infrastructure and configuration where they show system boundaries, and existing documentation and ADRs.

No full code audit. Never read real `.env` files, credentials or secrets.

## Execution steps

### 1. Confirm the target, the structure and the template

Verify that the working directory is a target project, not the framework repo, and that the required framework structure from "Inputs" exists. If any of it is missing: **stop**, say what is missing and suggest `/init-project`. Do not create the structure yourself and do not rebuild it from memory.

Check the installed architecture template. If it is missing, unavailable or empty: **stop** and say that the framework installation or template needs fixing. Do not invent your own structure. If the existing `architecture.md` is empty, damaged, or so far from the template that continuing safely is impossible: **stop** and describe the problem.

### 2. Determine the mode

Choose exactly one mode, from the user's request, the current workflow and the project state. If it cannot be determined unambiguously: do not guess. Show the possible modes in a few lines, ask the user and do not change `architecture.md` until they answer.

| Mode | Used for | Upstream PASS | Architecture work needed? | `architecture-reviewer` |
|------|----------|---------------|---------------------------|--------------------------|
| 1. Document current architecture | An existing system: document or correct the durable architecture context | None | Only if `architecture.md` does not already describe the observed structure accurately | Required for a substantive change |
| 2. Initial architecture | A new product | Current Product Spec | Always | Always |
| 3. Feature architecture impact | A reviewed Feature Spec | Current Feature Spec | Only if a substantial change is required | Required for a substantive change (Case C), not for Case B (no-op or narrow factual sync) |

- **Mode 1** observes the real code, configuration and project facts. It records what exists, takes no new architectural decision, invents no intent, does not silently replace an existing decision and does not redesign the system unless the user asks for that.
- **Mode 2** creates the minimally sufficient target architecture for the approved product, not speculative enterprise design.
- **Mode 3** is the resolution of the architecture impact, not simply a change. It first determines whether a substantive change is required (step 5). If not, that is Case B: no substantial architecture change, with at most a narrow factual sync of `architecture.md` (step 5). If it is, `/architecture` designs and writes the change (Case C).

### 3. Check the reviewed upstream requirements (modes 2 and 3)

Modes 2 and 3 need the current version of the reviewed requirements: `.claude/product/product-spec.md` for mode 2, `.claude/work/<feature-name>/feature-spec.md` for mode 3. A `/review-spec` PASS of the current version counts as **reliably established** in exactly two cases:

- the current conversation or workflow contains that PASS for this very version, and the spec has had no substantive change since;
- the user explicitly confirms that the current version already passed `/review-spec` and has not changed in substance since.

In every other case it is not established. Never infer it from the file existing, git history, commits, timestamps, hashes, naming, comments or metadata. If the conversation already establishes it, do not ask for a ritual confirmation. If it cannot be established: do not design the architecture, **stop** and suggest `/review-spec` for the upstream spec. No persistent approval status, registry, hashes or review report files.

Mode 1 needs no requirements PASS, and none is invented for it.

### 4. Read the project and take the initial baseline

Read what "Files to read" lists for the mode. The sources keep their roles: the Product and Feature Specs hold the approved intent, code and configuration are factual evidence of the current implementation (not proof of a desired architecture), `architecture.md` holds the agreed durable architecture, project context holds durable facts and constraints (`infrastructure.md` describes the actual infrastructure: take it into account, do not silently rewrite it and do not design infrastructure implementation here), and a Tech Spec is implementation design, never architecture authority. An architecture decision is not inferred from a planned Tech Spec.

Before the first write, in a git repository, record the **initial skill baseline** with `git status --short -uall`, `git diff` and `git diff --cached`. It checks the file boundaries of this skill. Do not require a clean working tree. Changes the user already has are part of the baseline: leave them untouched and never overwrite or revert them. If the update cannot be made without overwriting them, stop and report. Never stage, commit, reset, checkout, stash, revert or run any other command that changes git state. If the project is not a git repository, do not invent a filesystem snapshot, hashes or any other baseline mechanism.

Two baselines exist, with different jobs. This one guards the boundaries of `/architecture`. The reviewer baseline of step 9 is taken separately, right before every reviewer call, and guards only against changes made by the reviewer. Until the reviewer is called, this skill may change only `architecture.md`.

### 5. Decide whether architecture work is needed

Do not run architecture work for its own sake.

- **Mode 3.** Is the change possible inside the existing architecture? If the reviewed Feature Spec does not require a substantial architectural change, this is Case B, no substantial architecture change: do not create artificial architecture work and do not invent a decision. Before concluding, check whether the existing factual statements in `architecture.md` are still correct under the reviewed Feature Spec. Case B then has three outcomes:
  - **B1. Narrow factual sync.** An existing statement became false, stale or incomplete, and the correction follows unambiguously from the reviewed requirements without any new architecture decision: a corrected or removed statement, or a missing fact that the requirements and the existing architecture already settle (for example, an existing storage that the architecture already makes responsible for the data now also holds a state the requirements already require). Change only those statements, inside the existing structure. It is not Case C and does not call the reviewer. State explicitly in the conversation that no substantial architecture change was required, that a factual sync was made, and what it changed.
  - **B2. True no-op.** The existing factual statements remain correct. State explicitly that no substantial architecture change is required and the current architecture is sufficient, change nothing and do not call the reviewer.
  - **B3. Not a factual sync.** The correction needs a decision about how: where a new state lives, which component owns it, which storage mechanism, boundary or integration pattern applies. Do not write it as a sync. It is a substantive architecture decision: it takes the design path of step 6 and the reviewer is mandatory (Case C).

  In B1 and B2 suggest `/tech-spec`. Downstream `/review-spec` and `/tech-spec` may rely on the result.
- **Mode 1.** If `architecture.md` already describes the observed structure accurately, there is nothing to change. Say so, change nothing and do not call the reviewer.
- **Mode 2.** Architecture is needed by definition.

If the reviewed Feature Spec left the architectural impact unclear, decide it here from the Feature Spec and the existing architecture. If you cannot decide it without guessing, ask the user. A true no-op (B2) or a narrow factual sync (B1) is not counted as substantive architecture work: no reviewer is required, and a no-op writes nothing.

**The reviewer before the first write.** If `architecture.md` is going to be created or substantively changed, check **before the first substantive write** that the `architecture-reviewer` is installed and available. If it is not: do not start the change, do not imitate the reviewer, do not substitute another agent and do not give a PASS yourself. **Stop** and report that the framework installation needs fixing, so that no substantive architecture change is left in the project that the framework cannot verify.

### 6. Clarify and design

**Clarify only what the project cannot answer.** No architecture exam for the user. Study the requirements, the current architecture and the constraints first. Ask only what the project cannot reliably answer and what really affects an architectural decision, in small groups of related questions. Do not ask which database, framework or pattern to choose when you can justify it as a professional architectural decision. Do ask about a product, business or operational constraint you cannot know (a mandatory external system, a hard hosting, regulatory or cost constraint, required compatibility, a known load, a team or tooling constraint). Do not invent such constraints. In mode 1, do not invent an intent for observed facts: describe what is observable and, if needed, ask. If the uncertainty is in fact about requirements, do not settle it here: route to `/product-spec` or `/new-feature-spec` and then `/review-spec`.

**Design (modes 2 and 3).** Pin down the requirements and constraints, study the existing architecture and infrastructure, and find the minimally sufficient solution. Propose a structural change only if the task cannot be solved inside the existing architecture. Formulate the decisions with their trade-offs. Show the significant new decisions to the user **before** they are written. If several truly different options with real trade-offs exist, present them briefly with a recommendation, and wait for the user's decision where the choice depends on their product, business or operational priorities. Do not push low-level technical decisions on the user. Only after agreement, update `architecture.md`. In mode 1, describe the observed structure and redesign nothing.

**Infrastructure minimalism** is mandatory. The order of choice is: existing infrastructure → scripts and local automation → self-hosted automation → external managed service. An external service is not the default: a new external or infrastructure dependency needs a specific justification (the problem it solves, why the existing and a simpler option are not enough, the dependencies it adds, its operational complexity, cost and lock-in), and it is fine when the requirements really demand it. Do not design for imaginary scale and add no abstraction or infrastructure "just in case": ask whether fewer components would do. The architecture is minimally sufficient, not as sophisticated as possible.

### 7. Write `architecture.md`

Use the structure of the installed template. Do not add, remove or rename its sections. If the template cannot hold the durable context or cannot express which parts are agreed target and not yet implemented, do not improvise: **stop**, say that the framework template needs to change and do not change it here. Unresolved architectural questions are recorded only where and how the template provides, with no markers of your own. Gaps left by `/init-project` are filled with confirmed content or left as they are. No source ledger and no `source:` label next to every fact.

Write durable architecture context: the components and their responsibilities and boundaries, communication between major components, significant data flows, storage choices at the architectural level, external integrations, cross-cutting constraints, agreed patterns and significant agreed changes. Do not write implementation task lists, temporary feature details, line-level changes, architecturally insignificant functions or classes, or a deployment runbook, test plan or release checklist. That is the territory of `/tech-spec` and the later skills.

**Current vs target.** `architecture.md` is the source of truth for the **agreed** durable architecture, and agreed does not always mean implemented. Mode 1 describes the observed current architecture and never passes inferred intent off as fact. Modes 2 and 3 describe the agreed target, which the code may not yet realise or may still contradict. Never present a target state as implemented, do not declare the code compliant before implementation, and keep any difference visible instead of hiding it in wording or rewriting requirements. Mark which parts are agreed target and not yet implemented with the installed template's own structure: no new section, status mechanism, document type or separate current and target documents. Never leave two contradicting active versions of the architecture.

If `architecture.md` already has substantive content: do not rewrite it as a whole without a reason, keep the decisions that are still valid and change only what really changed. If a new decision cancels or substantially changes an existing one, show the change to the user before applying it. In mode 1, if the existing `architecture.md` contradicts the real project state, show the contradiction to the user before any substantive replacement.

**Status-only synchronization by `/update-docs`.** Decisions and the approved target architecture belong to `/architecture` alone. After accepted implementation, `/update-docs` may make one narrow status-only change: an already approved element described as target, planned or not yet implemented may be re-described as implemented and current, only if the accepted implementation exactly matches that approved architecture and no structural decision changes (the full conditions are `/update-docs`'s). `/architecture` is not rerun for that transition, and such an edit is not a substantive change: it does not void the `architecture-reviewer` PASS and needs no reviewer. If the implementation drifted from the approved architecture, `/update-docs` does not normalize it: the drift returns to `/architecture`.

If another artifact will later need syncing because of the decision, say so in the report and do not change it here.

### 8. Check your own work

The invariants of this gate, verified here and handed to the reviewer in step 9:

- the right mode was chosen, and the user was asked when it could not be determined unambiguously;
- the requirements PASS was established where it is mandatory, and the architecture matches the applicable reviewed requirements and hides no change of product requirements;
- `architecture.md` holds architecture-level durable context, and has not turned into a Tech Spec or taken over implementation detail;
- source-of-truth boundaries hold, and current implementation and agreed target architecture are not mixed up: target is not presented as implemented, observed facts are not passed off as invented intent, and there are no contradicting active versions;
- existing architecture and infrastructure are not ignored without a reason, and significant decisions were agreed with the user where that was required;
- the solution is minimally sufficient: infrastructure minimalism holds, new external dependencies are justified, there is no unnecessary complexity and no design for imaginary scale;
- the architecture is defined well enough that the next `/tech-spec` does not have to invent the key system structure itself.

In a git repository, repeat `git status --short -uall`, `git diff` and `git diff --cached` and compare the actual diff contents, not only the paths, with the initial skill baseline. The only file this skill may have changed is `architecture.md`. Changes the user already had do not count. Repeat this self-check after every fix that follows a reviewer FAIL.

### 9. Run the `architecture-reviewer`

**When it is required.** For mode 2, for a substantive architecture change in mode 3 (Case C), and for a substantive change in mode 1. It is not required for Case A (`/architecture` did not run), for a Case B result, whether a no-op or a narrow factual sync (B1, B2), or mode 1 with an accurate file, or for a status-only `/update-docs` synchronization.

**What each side owns.** The architecture gate is the independent `architecture-reviewer`, which this skill calls itself: `/review-spec` does not review `architecture.md`. The reviewer owns the detailed professional criteria, from its own agent definition. This skill owns the invariants of step 8, the reviewer baseline, the hand-off, the validation of the result and the handling of findings.

**The reviewer baseline.** Immediately before **every** reviewer call, record a separate read-only baseline with `git status --short -uall`, `git diff` and `git diff --cached`. It already contains this skill's own intended change of `architecture.md`, so that change is never mistaken for a reviewer mutation. Do not use the initial skill baseline for this. After a reviewer FAIL and a fix, take a new reviewer baseline before the next call. If the project is not a git repository, do not invent a filesystem snapshot or hashes.

**The call.** The `architecture-reviewer` is an independent reviewer-agent and works read-only. Hand it: the mode; the reviewed upstream requirements, where applicable; the current `architecture.md`; the relevant project context and current facts; the installed template; the invariants of step 8, including the infrastructure minimalism rules; and the response contract. Do not hand it your own verdict or a request to confirm your decision. If it became unavailable by the time of the call: do not imitate it, do not substitute another agent, do not give a PASS yourself. **Stop** and report a framework installation problem.

**The response contract.** No numeric scores. The reviewer returns at minimum: `Verdict: PASS` or `Verdict: FAIL`; on FAIL, the blocking findings, each with the location or context, the issue, why it blocks and the required resolution; on PASS, the acceptable unresolved or non-blocking items, if any; a short summary. If the output has no unambiguous PASS or FAIL, refers to another architecture, contradicts the facts of the project or steps out of the reviewer's role: do not make up a verdict. **Stop** and report the problematic output. A broken review process is not an architecture defect.

**The read-only check.** After every call, in a git repository, repeat the same three commands and compare the actual diff contents with the reviewer baseline taken right before this call. The reviewer may not change project files or git state. Normal transient output of a safe established check is not a mutation. If it did change something, integrity is broken: do not hide the changes, do not reset or revert anything, tell the user, and never give a PASS. Then decide whether a concrete FAIL had already been independently established:

- a concrete blocking architecture defect, with evidence that does not depend on the mutation and that the mutation did not create: the FAIL may stand. Report it together with the integrity violation and the fact that the run is not valid for a PASS. The user has to deal with the unexpected changes before the correction loop and the next reviewer call, because a new reviewer baseline would otherwise absorb them;
- no such defect (a PASS recommendation, malformed output, a finding that depends on the changed state, or no independent concrete defect): no verdict, neither PASS nor FAIL. **Stop**;
- it cannot be established whether the finding existed independently of the mutation: no verdict. Do not keep a FAIL by assumption.

The mutation itself is a process problem. It does not prove a defect of the architecture.

**On FAIL.** Do not move on to `/tech-spec`. List the blocking findings. The reviewer fixes nothing, and this workflow handles them:

- a finding that can be fixed in `architecture.md` inside the already agreed requirements and constraints, without a new significant decision from the user: fix it, repeat the self-check, take a new reviewer baseline and call the reviewer again;
- a finding that needs a new product, feature, business or operational decision: ask the user, apply the agreed change and repeat the review;
- a finding that shows the upstream requirements have to change: do not fix requirements inside `/architecture`. **Stop** and name the authoring skill (`/product-spec` or `/new-feature-spec`, then `/review-spec`).

Substantive architecture work is not finished as successful until the reviewer returns PASS.

**On PASS.** The architecture counts as reviewed for the current state of `architecture.md`. Say so briefly, list the acceptable non-blocking items, if any, and suggest `/tech-spec` where the work served a new product or feature. Launch nothing. A later substantive change of `architecture.md` needs a new review. No status file, hash, registry or approval field.

### 10. Report and stop

Report briefly, in the conversation:

- **Substantive architecture work:** the mode, what was changed in `architecture.md` and the significant decisions (or the documented current architecture), the `architecture-reviewer` verdict and the non-blocking items, other artifacts that will need syncing later (named, not touched), and the next permitted step with a clause on why it follows.
- **A no-op:** that no substantive architecture change was needed and why the existing architecture is sufficient, that no file was changed and the reviewer was not invoked because it does not apply, and the next step `/tech-spec`, which designs the implementation inside that architecture.
- **A narrow factual sync (B1):** that no substantial architecture change was needed, which existing statements were corrected, removed or added and why they follow from the reviewed requirements, that the reviewer was not invoked because it does not apply, and the next step `/tech-spec`.
- **A stopped run** (a prerequisite, a missing reviewer or template, a missing upstream PASS, a pending user decision or an integrity problem): the blocker, the stage, the changes already made, and the required upstream or recovery route. No false success.

Then **stop**. Do not launch the next skill.

## Hard limits

`/architecture` does not:

- change product or feature requirements, or silently replace an architecture decision the user approved;
- create a Tech Spec, write an implementation plan or take over detailed implementation design;
- write production code or tests, install dependencies, or refactor the project;
- create Docker or CI/CD configuration, change infrastructure, create external services or accounts, or deploy;
- update documentation outside `architecture.md`, or create a separate architecture spec, ADR, diagram file, new document type or decision registry, unless the framework provides for it separately or the user explicitly asks;
- hide a difference between target and implementation by rewriting current or target wording;
- imitate or substitute an unavailable `architecture-reviewer`;
- run `git add`, commit, reset, checkout, stash, revert or any other command that changes git state;
- create framework entities, or hashes, status files, PASS registries or approval metadata;
- launch `/tech-spec` or any other skill on its own.

During a normal run it changes only `.claude/skills/project-context/context/architecture.md`. It reads other project files but never modifies them: specs, other context files, the root `CLAUDE.md`, code, tests, documentation, infrastructure and deploy files, templates and agents.

## Outputs

In the conversation: the report of step 10. In the target project: the updated `architecture.md`, only when the work actually required a write, including a narrow factual sync. A valid no-op, and a stopped run, change no file, and no artifact is created to prove that the skill ran. No status or PASS file.

## Completion criteria

**Substantive architecture success:**

- the mode was determined unambiguously and the prerequisites and the template were checked;
- for modes 2 and 3, the PASS of the reviewed upstream requirements was reliably established, and the approved requirements were preserved;
- the `architecture-reviewer` was available before the first substantive write, and decisions were agreed with the user where their input was needed;
- `architecture.md` reflects the current durable agreed architecture with current and target told apart, hides no change of requirements, and the self-check passed;
- the `architecture-reviewer` returned PASS for the last substantive version of `architecture.md`, and every blocking finding was fixed with the review repeated;
- this skill changed no file other than `architecture.md`, and no git state, checked against the baselines, with the user's own changes not counted and a clean tree not required;
- the user received the report, and no next skill was launched.

**Valid no-op:** the architecture work was correctly determined unnecessary, nothing was written and no reviewer was called, the result was stated explicitly and `/tech-spec` was suggested. It is not counted as substantive architecture work, because none was required.

**Valid narrow factual sync (B1):** no substantial architecture change was required, only the factual statements that the reviewed requirements unambiguously changed were edited, no new architecture decision was taken, no reviewer was called, the result was stated explicitly and `/tech-spec` was suggested.

**Correct stopped or blocked run:** no false success, the blocker and the route were reported, and the user's and unrelated changes were preserved.

## Next skills

- After an initial architecture PASS, a Mode 3 change PASS (Case C) or a Case B result where no substantial architecture change is needed (a no-op or a narrow factual sync): `/tech-spec`.
- After a Mode 1 documentation PASS: the next skill depends on the current task. If the next stage is technical design of a feature, `/tech-spec`. Do not invent a work item if there is none.
- The requirements have to change: `/product-spec` for the Product Spec or `/new-feature-spec` for a Feature Spec, then a mandatory `/review-spec`, and only after a PASS return to `/architecture`, if it is still needed.
- A reviewer FAIL: correct in `/architecture` and call the reviewer again (step 9).
- After implementation, a status-only description of an already approved architecture as implemented: `/update-docs`. Do not rerun `/architecture` for that.
- The implementation drifted from the approved architecture: `/architecture`.
- A prerequisite, the template, the reviewer or the upstream PASS is missing: fix that first (`/init-project` for a missing framework structure, `/review-spec` for an upstream spec without an established PASS, a fix of the framework installation for a missing template or `architecture-reviewer`).

No next skill is ever launched automatically.
