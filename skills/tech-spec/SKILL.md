---
name: tech-spec
description: Create or substantially update the Technical Specification for one implementation work item: how exactly the agreed, reviewed requirements are implemented inside the agreed architecture. Writes .claude/work/<work-item-name>/tech-spec.md from the installed template. Covers initial product implementation and feature implementation. Not a requirements or architecture document. The next mandatory step is /review-spec, and only after its PASS /build-feature.
---

# tech-spec

## Purpose

`/tech-spec` creates, or substantially updates, the Technical Specification for **one** implementation work item of a target project. The artifact is:

`.claude/work/<work-item-name>/tech-spec.md`

A Tech Spec answers one question: **how exactly should this approved work be implemented in this project?** It turns reviewed requirements, the applicable agreed architecture and the current project constraints and facts into a technical design concrete enough that `/build-feature` does not have to redesign the work.

It does not decide again what the product or the feature must do or what the scope is. It takes no substantive architecture decision (that is `/architecture`), writes no production code and does not review itself. A Tech Spec is not reviewed or approved just because it was written: `/review-spec` is the mandatory gate after every creation or substantive update, and a PASS belongs only to the version that was reviewed.

## When to use

Both scenarios take exactly one implementation work item per run, where the work needs technical design first: a substantial feature, several related code changes, an API, data model or integration change, significant workflow logic, a migration, a change across several modules, technical work with significant failure, security or data implications, or the initial implementation of a new product.

- **Initial product implementation** (a new product). The upstream is the current Product Spec. A separate Feature Spec is not required and must not be created artificially.
- **Feature implementation** (an existing product). The upstream is the Feature Spec of the work item.

Both need the prerequisites of step 4. The Tech Spec lives in `.claude/work/<work-item-name>/`.

## When not to use

- The current directory is the **ai-dev-framework repository itself**. It is the source of the framework, not a target. If the root contains the framework's own `skills/` folder, stop and ask which project the user means.
- The framework structure created by `/init-project` is missing. Stop, say what is missing and suggest `/init-project` (step 1).
- The work is a real microchange. A separate Tech Spec would be decoration (step 2).
- A substantial feature has no Feature Spec, or its requirements have not passed `/review-spec`: `/new-feature-spec` and `/review-spec` first. A Tech Spec never replaces requirements.
- The requirements themselves have to change: `/product-spec` or `/new-feature-spec`, then a mandatory `/review-spec`.
- The design needs a substantive architecture decision that is not agreed yet, or `architecture.md` is too empty to design against: `/architecture`.
- The user wants code, tests, a migration run, dependencies installed, infrastructure changed or a deployment.

## Inputs

- **Target project root.** Default: the current working directory. Confirm it if there is any doubt.
- **The user:** the description of the work, the implementation scope where it is open, and answers to clarifying questions.
- **The project itself:** codebase, configuration, existing documentation and infrastructure.
- **The framework structure in the target project**, created by `/init-project`: root `CLAUDE.md`, `.claude/skills/project-context/SKILL.md`, in `.claude/skills/project-context/context/` the files `product.md`, `architecture.md`, `development.md` and `infrastructure.md`, plus `.claude/product/product-spec.md` and `.claude/work/`. All are required. `ux-guide.md` is used only if it exists and the router marks it as relevant.
- **The reviewed upstream requirements spec:** the current Product Spec for initial product implementation, the Feature Spec of the work item for feature implementation.
- **Architecture context:** the current `architecture.md`, plus the architecture prerequisite of step 4.
- **The installed Tech Specification template.** It lives at `%USERPROFILE%\.claude\ai-dev-framework\templates\work\tech-spec.md`. Do not look for another template or recreate it from memory.

## Files to read

Read before writing anything. All reads are read-only.

Always: the root `CLAUDE.md`, the project-context router, the applicable upstream requirements spec, `product.md`, `architecture.md`, `development.md`, `infrastructure.md`, the target Tech Spec if it already exists, and the installed template. When relevant: `ux-guide.md`, the Product Spec, related current and completed specs, the README, API documentation and other technical documentation.

From the codebase, read only what a realistic implementation design needs: the relevant source tree and entry points, affected modules and interfaces, API and schema definitions, package and dependency files, configuration, the test structure, storage and model definitions, integration code, and relevant infrastructure and deploy configuration. No full code audit. Never read real `.env` files, credentials or secrets.

## Execution steps

### 1. Confirm the target, the structure and the template

Verify that the working directory is a target project, not the framework repo, and that the required framework structure from "Inputs" exists. If any of it is missing: **stop**, say what is missing and suggest `/init-project`. Do not create the structure yourself and do not rebuild it from memory.

The installed Tech Specification template is required. If it is missing, unavailable or empty: **stop** and report a framework installation or template problem. Do not recreate it from memory and do not invent your own structure. If the template cannot express the design the work needs: do not improvise a section. **Stop**, say that the framework template needs to change, and do not change it here.

### 2. Decide whether a Tech Spec is needed

Not every micro-edit goes through a Tech Spec. A real microchange is a typo, a trivial text change, an obvious one-line fix, a very small isolated bugfix, or another truly microscopic change where the implementation is obvious and needs no technical decision. For it: explain why a separate Tech Spec is not needed, create no decorative spec, propose the lightweight path `/build-feature` → relevant testing or verification → `/review-code` where applicable, and launch nothing. Do not stretch a substantial feature into a microchange for the sake of speed. If the scope proves substantive, use the proper workflow.

For a substantial feature or the initial implementation of a product, continue.

### 3. Determine the work item

Exactly one implementation work item per run.

**Feature work.** Use the `.claude/work/<feature-name>/` folder that holds the matching `feature-spec.md`. The Tech Spec is `.claude/work/<feature-name>/tech-spec.md`. Never create a second folder for the same feature.

**Initial product implementation.** There may be no Feature Spec, and none is created, not even to pick a scope. Determine one concrete implementation scope first:

- If the Product Spec and the request unambiguously define one work item, use it.
- If the Product Spec describes several independently implementable parts and the user has not said which one is implemented now: do not choose the scope yourself and do not merge the whole product or MVP into one huge Tech Spec. Show reasonable decomposition options briefly, if that helps, ask which scope to take now, and create no Tech Spec until they answer.
- Choose a concise work-item name from that scope and the project's naming convention. If it is ambiguous, propose one and wait for confirmation. Do not invent several work items unasked.

Before creating a new work item, look through `.claude/work/`, including `.claude/work/completed/`, to avoid a duplicate. If a suitable one exists, use it when the request clearly means continuing or updating it, otherwise ask. Never create a duplicate under another name, and modify nothing in `.claude/work/completed/` unless the user explicitly asks.

**Existing `tech-spec.md`.**

- The request clearly means continuing or substantially updating it: work with it.
- The intent is unclear: ask, and never overwrite it automatically as a new document.
- It is empty, damaged, or so far from the template that continuing safely is impossible: **stop** and describe the problem. Do not invent an alternative structure.
- The user changed it before the run: read its current content first, do not overwrite the changes blindly and keep unrelated valid content. If the new request conflicts with what is there, show the substantive conflict and ask for a decision.

### 4. Check the prerequisites

**Reliably established.** A PASS or another result named below counts as reliably established in exactly two cases:

1. the current conversation or workflow contains it for this very version, and there has been no substantive change since;
2. the user explicitly confirms that this very version already has that result and has not changed in substance since.

In every other case it is not established. Never infer it from a file existing, git history, commits, timestamps, hashes, metadata, naming or comments, and do not guess. If the conversation already establishes it, or nothing reliably shows a relevant change, do not ask for a ritual confirmation. No persistent approval status, hashes, registry, approval fields or review report files.

**Reviewed requirements.** A Tech Spec is not written on unreviewed requirements. Feature work needs a `/review-spec` PASS of the current `feature-spec.md`, initial product implementation one of the current `product-spec.md`. A substantial feature without a Feature Spec: do not write a Tech Spec instead of requirements, **stop** and suggest `/new-feature-spec`. If the upstream PASS is not established: **stop** and suggest `/review-spec` for the upstream spec first.

**Architecture path.** A Tech Spec always takes the current `architecture.md` into account. `/tech-spec` consumes the architecture state and does not decide it: the determination of the architecture impact belongs to `/architecture`. Only one question is answered here: is the architecture prerequisite resolved, so that technical design may begin? A fresh `architecture-reviewer` PASS is mandatory for every initial product implementation and for Case C, and not for Cases A and B.

- **Initial product implementation.** The chain is always `/product-spec` → `/review-spec` PASS → `/architecture` → `architecture-reviewer` PASS → `/tech-spec`. It must be reliably established that the current agreed architecture went through `/architecture` and that the last substantive version of `architecture.md` has an `architecture-reviewer` PASS for this very version. A non-empty or hand-filled `architecture.md` replaces neither `/architecture` nor its review. If it cannot be established: **stop** and suggest `/architecture`, in the initial-architecture mode.
- **Feature Case A: the change was clearly unnecessary.** The reviewed Feature Spec clearly does not require an architecture change, and `/architecture` was not run for it. Real doubt means it is not "clearly": treat the impact as unclear. The existing `architecture.md` is used.
- **Feature Case B: the impact was unclear, and `/architecture` found no substantial architecture change was required.** `/architecture` ran for the current reviewed Feature Spec and established that no substantial architecture change is required. `architecture.md` was either left unchanged or received only a narrow factual sync with no new architecture decision, and the `architecture-reviewer` was not called. A changed `architecture.md` is not by itself evidence of Case C. The current `architecture.md` is used. It must be established that this `/architecture` result exists for this Feature Spec, and that the Feature Spec has not changed in substance since.
- **Feature Case C: `/architecture` created or substantively changed `architecture.md`.** A PASS of the last substantive version from the `architecture-reviewer` must be reliably established for this very version. If it is not: do not design on top of unconfirmed new architecture. **Stop** and suggest `/architecture`.
- **No path established, or the impact is unclear.** Do not guess, do not classify the impact yourself and do not settle it inside the Tech Spec. **Stop** and route to `/architecture`.

**Architecture context.** The file existing does not make the architecture context sufficient for a substantial Tech Spec. If `architecture.md` is a not-started or template-only stub, practically empty, too outdated to determine the relevant boundaries safely, or lacks the context a substantial design needs: do not reconstruct the architecture here and do not let a codebase analysis grow into a hidden `/architecture`. **Stop** and suggest `/architecture`. The exception: the work item is local, its relevant architectural boundaries and constraints are already unambiguous from the existing context, and the missing parts of `architecture.md` do not concern it. Then do not demand a fully filled `architecture.md` as a ritual.

### 5. Read the project, take the baseline and establish the facts

Read what "Files to read" lists.

Before the first write, in a git repository, record a read-only baseline with `git status --short -uall`, `git diff` and `git diff --cached`. Do not require a clean working tree. Changes the user already has are part of the baseline: leave them untouched, they are not changes made by `/tech-spec`. Never stage, commit, reset, checkout, stash, revert or run any other command that changes git state. If the project is not a git repository, do not invent a filesystem snapshot, hashes or any other baseline mechanism.

Each source keeps its role. The Product Spec and the reviewed Feature Spec define the requirements. `architecture.md` defines the agreed durable architecture. Code is the current implementation and the main source of facts about the codebase, not of intended requirements. Project context holds durable constraints and is not a competing work specification.

Establish the facts about the current codebase before any design. Do not invent files, modules, APIs, tables, services, queues, integrations, dependencies, infrastructure, a test framework or a deployment mechanism. Current implementation is not agreed architecture: `architecture.md` may describe components that do not exist in the code yet, and an element is never assumed to exist because `architecture.md` mentions it. For every relevant artifact, tell apart:

- **existing now**, described as existing;
- **agreed or planned, but not implemented**, described as planned;
- **to be created by this work item**;
- **dependent on another unfinished work item**, recorded as a dependency and never presented as existing.

If the work item depends on unfinished work, state the dependency explicitly. If it only affects the order, record the order. If the work item cannot be designed or implemented safely until the other one is done: **stop** and report the blocker. No dependency-tracking mechanism or registry.

### 6. Clarify only what the sources cannot answer

No technical interview about questions you can settle professionally. Read the requirements, the architecture, the development context, the infrastructure and the relevant code first, and make the minimally sufficient implementation decisions yourself inside the agreed architecture. Do not ask what to call an internal class, which helper to create or which pattern to use when it is an ordinary engineering decision with no product or business impact.

Ask the user only when a decision or constraint cannot be derived from the sources: a requirement on external behaviour, a product or business rule, a compatibility requirement, a security or permission policy, a data-retention requirement, an operational constraint, an explicit cost or hosting constraint, or a trade-off that materially changes user-visible behaviour or a business outcome.

If requirements, architecture, context and code contradict each other: do not pick the convenient version and do not fix a source silently. Stop or put the question to the user, depending on the kind of contradiction. A question about requirements is not decided inside the Tech Spec: send it to `/product-spec` or `/new-feature-spec`, followed by `/review-spec`. A question that needs a substantive architecture decision goes to `/architecture`.

### 7. Design

Pin down the exact scope from the reviewed requirements, map it onto the agreed architecture and the real code, and plan new components, files or interfaces only where really needed. Check the result for simplicity and overengineering.

The design has to be concrete enough that `/build-feature` knows what to change, how the parts connect, which artifacts exist and which are planned, and which dependencies and order matter, without inventing key technical decisions, changing requirements or changing architecture on the way. It must not become a copy of the future code.

**Content, only where it applies and never as an empty ritual:** affected components, modules and files, and planned new ones; responsibilities, interfaces, contracts and API changes; data model and schema changes; control and data flow and integration details; validation, error and failure handling; permissions, auth and security implications; configuration; dependency changes; migrations and backward compatibility; infrastructure impact; deployment and rollback considerations; the implementation sequence if the order really matters; dependencies on unfinished planned work. The testing approach is always defined, in proportion to the work item.

**Level of detail.** Useful: concrete files and modules, conceptual interface signatures, request and response contracts, schema changes, algorithms and flows, validation rules, migration order, the test strategy. Not without a reason: production-ready implementation, large code blocks, obvious line-by-line edits, internal detail that can safely stay with `/build-feature`. A short pseudocode or example is fine only if it removes a real ambiguity, the template allows it and it stays short.

**Traceability.** Every significant technical decision ties back to a real requirement or constraint, without a separate ledger, without `source:` labels and without copying the Product or Feature Spec. The Tech Spec covers all significant requirements of the work item and never silently narrows or widens the scope. If a requirement needs no technical work, do not invent some for symmetry. If a significant requirement cannot be implemented in the proposed design, do not ignore or change it: **stop** and report the contradiction.

**Architecture boundary.** The Tech Spec owns ordinary implementation-design decisions inside the approved architecture: internal module structure, file layout, local interfaces, implementation mechanics, migrations inside the agreed storage architecture, and API details inside the agreed boundaries. It must not introduce on its own a new major service or system boundary, a new architectural pattern, a new core storage approach, a substantial new integration architecture, a major change of a key data flow, or any other substantive architectural decision that was not agreed through `/architecture`. If such a decision turns out to be necessary: **stop**, explain the architecture impact, route to `/architecture` and do not write it into the Tech Spec as an accomplished fact.

**Infrastructure minimalism.** The order of choice is: existing infrastructure → scripts and local automation → self-hosted automation → external managed service. Add no external or infrastructure dependency by default. It is acceptable only if it solves a specific requirement, the existing infrastructure and a simpler local or self-hosted option are not enough, its cost and operational complexity are justified, and its portability and lock-in impact are understood. Do not design for imaginary scale. If a new infrastructure dependency is itself a substantive architecture change, `/tech-spec` does not approve it: **stop** and route to `/architecture`.

**Dependencies.** Use the existing ones where reasonable, and check whether the existing stack can do the job and what maintenance, security and lock-in a new one brings. The Tech Spec may plan a dependency change. It never installs anything.

**Security and secrets.** If the work item touches auth, permissions, personal or sensitive data, external input, file upload, tokens, secrets, an external API or privileged operations, design for the relevant security implications. Never put real secrets, tokens or credentials into the Tech Spec and never read a real `.env`: refer only to variable names or configuration concepts. This is not a security audit.

**Testing.** Define how the implementation will be verified, tied to the requirements and the failure scenarios, in as much detail as `/build-feature` needs. Do not push one test type on every project. Running the checks is the job of `/test-feature`.

**Deployment and rollback.** Only where the implementation really affects them (migration order, backward compatibility, a feature flag that is really needed, config or environment changes, a rollback limitation). It is not a deploy runbook. Deployment readiness belongs to `/deploy-check`.

**UX.** If the work item touches user-facing UI, bot interaction or text, and `ux-guide.md` exists, follow its conventions and do not change agreed UX requirements. If the implementation needs a UX or product decision that does not exist, do not invent it: ask the user or route to the requirements workflow. A Tech Spec is not a UX specification.

### 8. Write `tech-spec.md` and check your own work

Write only when steps 1 to 6 leave no open blocker. Use only the structure of the installed template, with no permanent sections or status fields of your own. Write the confirmed design: existing artifacts as existing, planned ones as planned, unfinished dependencies as dependencies. Record assumptions and unresolved items only where and how the template provides for them, with no placeholder syntax or markers of your own. For a new work item, create the missing work-item folder (in practice only for an initial product implementation).

Then reread the whole Tech Spec and verify that:

- it is one work item, and an initial-product scope did not swallow several independently implementable ones without a user decision;
- it implements the reviewed requirements without changing them silently, and the design respects the agreed architecture with no hidden substantive architecture decision;
- existing, planned, to-create and dependent artifacts are not mixed up, and dependencies on unfinished work are stated where they matter;
- the design is implementation-ready: concrete enough for `/build-feature`, covering failure handling, security, migration and tests where they apply, with justified infrastructure and no imaginary-scale design or obvious overengineering;
- the document has not turned into production code, contains no secret, and matches the template;
- only the allowed Tech Spec file changed. In a git repository, repeat `git status --short -uall`, `git diff` and `git diff --cached` and compare the actual contents, not only the paths, with the baseline of step 5. Changes the user already had are not counted, and a clean tree is not required.

This is a self-check, not a spec review or an architecture review. If it shows that new requirements are needed: do not fix them here, **stop** and route to the matching requirements skill. If a substantive architecture change is required: **stop** and route to `/architecture`. If a blocking dependency on unfinished work exists: do not present the Tech Spec as ready for build, and report the blocker and the required order.

### 9. Report and stop

The report exists only in the conversation. After a successful create or update, report briefly:

- the work item and the Tech Spec path;
- the architecture path that step 4 reliably established, named exactly as `Initial product implementation`, `Feature Case A — architecture change clearly not required`, `Feature Case B — /architecture found no substantial architecture change required` or `Feature Case C — /architecture created or substantively changed architecture`. Never a guessed one. It is not written into `tech-spec.md` or any other file, and no status, registry, approval field, hash or metadata is created for it;
- the main technical decisions, the unresolved non-blocking items if the template allows them, and the dependencies on unfinished work;
- other artifacts that may need syncing later, named but not touched;
- that the next mandatory step is `/review-spec`, the independent check of whether the design is safe to build from.

Do not call the Tech Spec reviewed or approved, do not run `/review-spec`, and do not offer `/build-feature` before its PASS. After any substantive change, an earlier PASS of this spec no longer counts. If an unresolved dependency blocks, do not call the run fully ready and explain what has to happen first. If the workflow stopped, say what blocks it and which earlier step is needed, with no false success and no architecture path unless it was reliably established. Then **stop**.

## Hard limits

`/tech-spec` does not:

- invent or change product or feature requirements;
- make substantive architecture decisions, or change `architecture.md`;
- treat a target architecture as implemented without checking the code;
- write production code or tests, run migrations, or install dependencies;
- change infrastructure, create external services or accounts, or deploy;
- read or write real secrets;
- call the `tech-spec-reviewer`, run `/review-spec` or call the Tech Spec reviewed or approved;
- launch `/review-spec`, `/build-feature` or any other skill on its own;
- change framework templates, or create framework entities;
- run `git add`, commit, reset, checkout, stash, revert or any other command that changes git state;
- create tracking, status, hash or dependency mechanisms, or a separate implementation-plan document, design document, ADR, migration file, test file, review report, approval registry or dependency registry.

During a normal run it may only create or change `.claude/work/<work-item-name>/tech-spec.md`, and create the folder of a new work item. It reads other project files but never modifies them: the Product Spec, Feature Specs, `architecture.md`, `product.md`, `development.md`, `infrastructure.md`, `ux-guide.md`, the root `CLAUDE.md`, code, tests, documentation, dependency and package files, schema files, infrastructure and deploy configuration, templates and agents. If another artifact will later need syncing, say so in the report.

## Outputs

In the target project: `.claude/work/<work-item-name>/tech-spec.md`, and the work-item folder if it was new. In the conversation: the report of step 9. Nothing else, and no approval artifact.

A real microchange creates no spec file. A blocked run creates no false success: it names the blocker and the earlier step that is needed (`/init-project`, `/product-spec`, `/new-feature-spec`, `/review-spec`, `/architecture`, the completion of a prerequisite work item, a fix of the framework template or installation, or a user decision).

## Completion criteria

`/tech-spec` is done, as an authoring skill, when all of these are true:

- one valid substantial work item was determined. For an initial product implementation, the scope does not merge several independently implementable work items without a user decision;
- the upstream requirements are determined and their current PASS was reliably established;
- the architecture prerequisite is resolved (for an initial product implementation and Case C, an `architecture-reviewer` PASS of the current `architecture.md`), the architecture context is sufficient for the work item, and the path was reported in the conversation only;
- an implementation-ready design was written in the installed template's structure. It implements the requirements without rewriting them and respects the architecture;
- there are no blocking questions about requirements, architecture or dependencies;
- the self-check passed, and only the allowed artifact changed, checked against the baseline, with no git state changed;
- the user received the report, `/review-spec` was suggested and not launched, and the Tech Spec was not called approved.

The microchange exit and a correctly reported blocked run are valid non-success paths. Authoring completion does not mean the Tech Spec is approved: to move on to `/build-feature`, the current version needs a `/review-spec` PASS.

## Next skills

- After creating or substantively changing a Tech Spec: `/review-spec`. After its PASS: `/build-feature`. After its FAIL: `/tech-spec` to fix the findings, then `/review-spec` again.
- The upstream requirements have to change: `/product-spec` or `/new-feature-spec`, then a mandatory `/review-spec`, then `/architecture` if the change affects architecture, then `/tech-spec` again.
- A substantive architecture change is needed, an initial product implementation has no established `/architecture` run and `architecture-reviewer` PASS, or the architecture impact was unclear: `/architecture`. Then `/tech-spec` if it finds no substantial architecture change is required (a true no-op or a narrow factual sync), or, if it made a substantive architecture change, an `architecture-reviewer` PASS first and then `/tech-spec`. After writing, `/review-spec`.
- A blocking dependency on unfinished work: finish the prerequisite work first, then continue the current `/tech-spec` or the implementation flow, depending on the situation.
- A real microchange: the lightweight path of step 2.

No next skill is ever launched automatically.
