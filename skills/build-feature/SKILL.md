---
name: build-feature
description: Implement one work item in code: production code, its automated tests, and developer-level checks along the way. For substantial work it needs a current Tech Spec with an established /review-spec PASS; a real microchange may go without one. Not an independent quality gate: it never grants a /test-feature PASS, never reviews its own code and never calls a reviewer. Can be re-run to correct a concrete implementation-side finding of /test-feature, /review-code, /update-docs or /deploy-check. The next mandatory step is /test-feature.
---

# build-feature

## Purpose

`/build-feature` implements **one** work item of a target project in code: the production code, the automated tests that belong to it, and the implementation-side configuration, migrations and artifacts that the approved scope requires. It works from the actual repository state and hands the result to verification.

- **Substantial work** implements the current reviewed Tech Spec, `.claude/work/<work-item-name>/tech-spec.md`. A **real microchange** is work where a separate Tech Spec would be decoration. The user's request is then the work instruction.
- It is an implementation skill, not an independent verification or review gate. It calls no reviewer.
- It can be entered again when a downstream gate returns a concrete finding whose root cause is implementation-side (step 2).
- Done means ready for the applicable verification. It does not mean tested, reviewed, documented or deploy-ready. Nothing is launched automatically.

## When to use

- Substantial work whose current Tech Spec has passed `/review-spec`.
- A real microchange: a typo, a small obvious text edit, an obvious one-line fix, a very small isolated bugfix, or another truly microscopic change with no new product, architecture or substantial technical decision.
- Continuing a partially implemented work item.
- Correcting a concrete implementation-side finding returned by `/test-feature`, `/review-code`, `/update-docs` or `/deploy-check`.

## When not to use

- The current directory is the **ai-dev-framework repository itself**. It is the source of the framework, not a target. If the root contains the framework's own `skills/` folder, stop and ask which project the user means.
- The framework structure created by `/init-project` is missing. Stop and suggest `/init-project`.
- Substantial work has no Tech Spec, or its current version has no established `/review-spec` PASS: `/tech-spec` or `/review-spec` first.
- The work needs a change of requirements, a substantive redesign of the Tech Spec or a substantive architecture decision: route upstream (step 3).
- The user wants independent testing (`/test-feature`), a code review (`/review-code`), documentation updated (`/update-docs`) or deployment readiness checked (`/deploy-check`).
- The request covers several work items. One per run.

## Inputs

- **Target project root.** Default: the current working directory. Confirm it if there is any doubt.
- **The reviewed Tech Spec** (substantial work), or the user's request (microchange).
- **The applicable upstream requirements spec:** the Feature Spec of the work item, or the Product Spec for an initial product implementation.
- **The framework structure created by `/init-project`.** For substantial work: root `CLAUDE.md`, `.claude/skills/project-context/SKILL.md`, in `.claude/skills/project-context/context/` the files `product.md`, `architecture.md`, `development.md` and `infrastructure.md`, plus `.claude/product/product-spec.md` and `.claude/work/`. For a microchange: root `CLAUDE.md` and the router.
- **The codebase**, its tests and its configuration.
- **The concrete downstream finding and its evidence**, on a return after a downstream gate.
- **The user,** for the few questions only they can settle (step 5).

## Files to read

Read before writing any code. All reads are read-only.

- **Substantial work:** the root `CLAUDE.md`; the router; the current reviewed Tech Spec; the applicable upstream requirements spec; the current `architecture.md`; the relevant parts of `development.md` and `infrastructure.md`; `ux-guide.md` if the work item is user-facing and the router marks it as relevant; the relevant code, tests and configuration. The Product Spec only where it is needed to understand a requirement.
- **Microchange:** the root `CLAUDE.md`, the router, the minimum relevant context, and the affected code, tests and configuration.

Do not load the whole repository without a reason. Never read real `.env` files, credentials, tokens or passwords, and never expose secrets.

## Execution steps

### 1. Confirm the target and the project rules

Verify that the working directory is a target project, not the framework repo, and that the framework structure required for the mode exists (see "Inputs"). If any of it is missing: **stop**, say what is missing and suggest `/init-project`. Do not create the structure yourself and do not rebuild it from memory.

Follow the target project's root `CLAUDE.md` and conventions: commands, style, testing, file layout, local workflow. They may refine how the work is done. They cannot silently override a mandatory ai-dev-framework gate or allow requirements or architecture drift. If a project instruction directly conflicts with a mandatory framework rule and both cannot be satisfied: do not pick the convenient one. **Stop**, report the conflict and ask for a decision.

### 2. Decide the mode, the work item and the entry

**Mode.** Substantial work or a real microchange. Never relabel substantial work as a microchange for speed: new product behaviour, an architecture question, a new dependency, a schema or contract, or any technical decision that is not obvious makes it substantial and needs a reviewed Tech Spec. If a microchange turns out to be substantive, **stop** and route upstream (step 3). No "just this once". For a real microchange the request is the work instruction. No Tech Spec is created, the Tech Spec prerequisite of step 3 is skipped, and everything else applies in proportion: a minimally sufficient change, a test only if the behaviour change really needs one, proportional developer verification, and no new dependency.

**Work item.** Exactly one, from the current Tech Spec. If the Tech Spec describes several or the request mixes several, do not merge them: take the one the Tech Spec and the user point to, and ask if that is unclear. No neighbouring feature "while we are here". If the work item depends on unfinished work: when the Tech Spec already provides for it and it only affects the order, keep the order. If it blocks a safe implementation, **stop** and report the blocker. Never implement someone else's work item quietly.

**Entry.** One of three:

- **First implementation.** Nothing of the work exists in the code yet.
- **Partial implementation.** Inspect the current implementation and continue from its real state. Do not assume a clean start and do not recreate finished work blindly. Uncommitted changes that are visibly the earlier partial implementation of this same work item are the state to continue from. They remain part of the baseline and are never overwritten blindly. If it is unclear which changes belong to that work and which are unrelated user work, the recovery boundary of step 4 applies.
- **Return after a downstream finding.** The finding comes from `/test-feature`, `/review-code`, `/update-docs` or `/deploy-check`. The root cause decides the route, not the gate that found the problem. `/build-feature` takes only an implementation-side finding: an implementation defect, a test-code defect that belongs to the implementation work, a concrete code or configuration defect (a security one included), or an implementation defect found while documenting. Not build work: a requirement, Tech Spec, design or architecture problem goes upstream (step 3), a documentation-only problem goes to `/update-docs`, and a deployment environment, access or tooling prerequisite goes to its owner. Read the finding and its evidence and work from the current implementation. A defect in the implementation of an already approved design does not need a new Tech Spec. A finding never widens the approved scope. For a microchange the request and the finding are the basis.

### 3. Check the prerequisite and the current sources

**Sources.** The Product Spec and the reviewed Feature Spec define the requirements. The reviewed Tech Spec defines the design of substantial work. `architecture.md` defines the agreed durable architecture. Project context holds durable constraints. Code shows the current implementation, which is not intended behaviour just because it exists. `/build-feature` does not re-review any of them. It only notices a known mismatch or change and routes it.

**The prerequisite (substantial work).** The current version of the Tech Spec must have a `/review-spec` PASS. That PASS already covers the upstream prerequisites that `/review-spec` checks. It counts as **reliably established** in exactly two cases:

1. the current conversation or workflow contains a `/review-spec` PASS for this very version, and the Tech Spec has had no substantive change since;
2. the user explicitly confirms that the current version already got a PASS and has not changed in substance since.

In every other case it is not established. Never infer it from the Tech Spec existing, git history, commits, timestamps, hashes, metadata, comments, naming or status fields. If it is not established: do not implement. **Stop** and suggest `/review-spec`. If the conversation already establishes it, or nothing reliably shows a relevant change, do not ask for a ritual confirmation. No persistent approval tracking.

**Sources that changed after the PASS.** The same rule of reliable establishment applies. If it is reliably shown that after the PASS the applicable upstream requirements or the agreed `architecture.md` changed substantively, the old PASS is not a sufficient basis. Do not run a re-review here. **Stop** and route upstream by root cause:

- it is not known whether the Tech Spec is still correct against the current sources: `/review-spec`;
- the Tech Spec obviously needs substantive design changes: `/tech-spec` → `/review-spec`;
- the requirements change has not passed the workflow and gate it needs: the matching requirements workflow first (`/product-spec` or `/new-feature-spec`);
- the architecture needs an unfinished architecture workflow or review: `/architecture` first.

"Route upstream" anywhere in this skill means this mapping. Never fix a source of truth silently.

### 4. Read the current state, take the baseline and set the recovery boundary

Read what "Files to read" lists for the mode. Before the first change, find out the real state: the affected files, modules and components, the existing interfaces and contracts, the existing tests, the dependencies in use, the conventions, and what exists now as against what the Tech Spec plans to create. Do not invent filenames, classes, modules, tables, APIs, queues, services, dependencies, commands, a test framework or a deployment setup. A planned artifact that does not exist yet is created only if this work item is the one that must create it. An artifact that another unfinished work item must create does not exist yet (see step 2).

**Baseline.** In a git repository, before the first substantive write, take a read-only baseline: `git status --short -uall`, `git diff` and `git diff --cached`. A clean tree is not required. Existing user changes are not changes of this run: they are never wiped out and stay untouched unless they belong to the work item. `git diff` does not keep the original content of untracked files, so record the untracked paths listed before the first write. A pre-existing untracked file is never treated as created by this run: read its current content before changing it, preserve the unrelated content, and do not delete, replace wholesale or rename it unless the work requires it and the content can be preserved safely. The new untracked files of this run are the paths in the final status that were not in that initial list, and a new file inside an already existing untracked directory counts as new. Git is a baseline only and never approval metadata. Create no hashes, snapshot files, backup registries, recovery metadata or checkpoint commits. If the project is not a git repository, do not invent a substitute.

**Recovery boundary.** `HEAD` plus the initial baseline must be enough to tell which changes this run made. This applies to a microchange as well. Look at every file you expect to change:

- it holds unrelated uncommitted user changes: never overwrite them. If they can be kept safely and you can work beside them with no ambiguity, go on;
- the planned implementation cannot be reliably separated from existing user changes (in a modified file or in a pre-existing untracked one), or a safe boundary cannot be established for the affected files: **stop** before changing anything and ask the user to create a safe boundary or resolve the conflict.

**Recovery rule.** If a regression or an unexpected change appears: first try a safe local correction inside the work item and rerun the relevant checks. If a safe fix needs a change of requirements, design or architecture: route upstream (step 3). If a safe correction cannot be established without risking user or unrelated work: **stop**, report, and propose a recovery option back to the initial baseline. Never roll back destructively and never wipe out the user's changes.

### 5. Implement within the approved scope

Implement the minimally sufficient solution. Follow the reviewed Tech Spec, the agreed architecture, the existing conventions, `development.md`, the relevant infrastructure constraints and, where it applies, `ux-guide.md`. Prefer changing existing code to adding a new abstraction. No speculative extensibility, unrelated refactoring, framework migration, service split, new architectural pattern or "improvements for the future". A small local refactor is allowed when it is really necessary to implement the work safely: keep it minimal, keep unrelated behaviour unchanged, and mention it in the report. If it becomes substantial work of its own: **stop**, and do not hide it inside the feature.

**Design mismatch.** Ordinary internal details that the Tech Spec does not prescribe are resolved professionally, inside the agreed requirements and architecture. Implementation never silently changes a requirement, the substantive design or the architecture. If the code and the approved design materially conflict, or the work needs such a decision: **stop** and route upstream. `/build-feature` is not a second spec reviewer.

**User-facing text.** The agreed `User-facing text` of the applicable Product Spec or Feature Spec is part of the requirements and is implemented as such. Where the spec records an exact wording, use it as written: do not replace, paraphrase or shorten it on your own. A technical transformation that changes neither the text the user sees nor its meaning (escaping, encoding, localization plumbing and the like) is not a change of copy. Where the spec records only the meaning, choose a concrete wording that keeps that meaning, following `ux-guide.md` if it exists and applies. Where the text that this work needs is explicitly left unresolved (an open question) and the work cannot be implemented correctly without it, do not invent it: **stop**, tell the user which product or feature decision is missing and name the matching requirements step (`/product-spec` or `/new-feature-spec`) without launching it. A spec that has no `User-facing text` section is not an error and blocks nothing: go on with the existing requirements and `ux-guide.md`.

**Write scope.** Change only what the approved work item requires:

- production source;
- automated tests, and the fixtures, mocks and test artifacts that genuinely belong to the implementation;
- the migration files that the approved work requires;
- the package manifest and the lockfile, where a dependency change is allowed;
- application, build and test configuration required by the implementation, and repository-level runtime or infrastructure configuration only when it is explicitly part of the approved implementation;
- generated implementation artifacts (API or schema artifacts included) that the project's workflow requires;
- code comments and docstrings that are part of a correct implementation.

The README, user documentation, API prose docs, release notes, durable project context, the Product Spec, Feature Specs, the Tech Spec and `architecture.md` are never build outputs. Post-implementation documentation and context synchronization belongs to `/update-docs`. That includes only a narrow status-only sync of an architecture decision already approved upstream. A substantive architecture change belongs to `/architecture`.

**Dependencies.** Prefer the existing ones. A new dependency is allowed only if it belongs to the approved implementation and adds no substantive decision of its own: the reviewed Tech Spec provides for it (then implement it), or it is a purely local, small implementation detail with no substantial maintenance, security or lock-in impact. If it substantially changes the design, the operational complexity, the security surface, the infrastructure or the lock-in: **stop** and route to `/tech-spec`, and to `/architecture` if the consequence is architectural. A real microchange adds none. Use the project's own package manager and versioning conventions, no unrelated upgrades, and no global install unless the project explicitly requires it and it is safe. Manifest and lockfile changes are inspected under the write-tool rule (step 6). Credentials, privileged machine changes, production access or external service setup are never improvised: **stop** and report what is required.

**Migrations.** A schema or data migration is part of the implementation when the approved work requires it. Follow the project's migration conventions, inspect what a generator produced (write-tool rule, step 6), and validate only in a safe local or test database where the setup allows. Never apply a migration to a production or shared environment and never perform a destructive operation on real data. A substantive migration that the Tech Spec does not provide for: **stop** and route to `/tech-spec`.

**Configuration, infrastructure, deleting and renaming.** Configuration and infrastructure files change only as part of the approved implementation. Do not deploy, release, provision, change production secrets, or add a managed or external service, CI/CD or a platform for convenience. An infrastructure decision that the approved design lacks: **stop** and route to `/tech-spec`, or to `/architecture` if the decision is architectural. Delete or rename only when the work item requires it, after checking that the file belongs to the scope and checking its references, imports and usages. Not because something looks unused, and no clean-up outside the work item. Unrelated user work is preserved.

**Questions.** Do not interview the user about internal technical choices that the Tech Spec, the architecture, the project context or the code conventions settle. Ask only when correctness depends on an unresolved product or feature decision, scope, a compatibility choice, a security or business policy, an architecture decision, a real operational constraint, or a conflict with user changes that cannot be resolved safely.

### 6. Write the tests and run the developer checks

**Automated tests are part of the implementation.** Create or update them where the changed behaviour reasonably should be covered, and add a regression test where a returned finding calls for it. Use the project's existing test strategy and conventions. Cover substantive behaviour, meaningful failure scenarios and regression where it applies, not a coverage number. Test artifacts that the conventions require (fixtures, mocks, test-only configuration, snapshots if the project already uses them) belong here. Do not change production behaviour for the convenience of testing if that changes a requirement. No new testing framework or snapshot strategy without an approved reason. If suitable test infrastructure is missing, use proportional verification and report the limitation. If the missing infrastructure is itself a substantial technical decision: **stop** and route to `/tech-spec`.

**Acceptance coverage.** Before completion, check that the substantive acceptance behaviour of the reviewed requirements is reflected in the implementation and its tests well enough to hand over. Do not invent acceptance criteria. If it is not implemented or cannot even be shown to exist at the developer level, work out where the problem sits (the implementation, the Tech Spec design or the requirements) and route accordingly. This is a developer self-check, not an independent acceptance gate.

**Developer checks.** Run the safe, relevant developer-level checks that the project has: targeted tests, relevant unit or integration tests, typecheck, lint, build, local static validation, local migration validation, and any command the project's instructions require. A full suite is not a ritual. Passing checks establish local coherence only. They are not a `/test-feature` PASS, a `/review-code` PASS, product or UX acceptance, or deploy readiness.

- A required check (required by the project's instructions, or needed to establish that the changed code builds and runs safely) cannot run because of an environment or tooling problem: do not claim successful completion. Report the blocker and do not edit unrelated code to make the environment pass.
- An optional check cannot run: report the limitation. That does not mean the implementation failed if the changed behaviour is otherwise verified in proportion.
- A targeted check of the changed behaviour fails: the implementation is not ready. Fix it and rerun inside the approved scope. A failure that clearly does not come from the implementation is reported separately and not fixed. A failure is never called unrelated without evidence. If that cannot be told, do not report success.
- A regression appears: the recovery rule of step 4.

**Tools that write files.** A command that can write files is a write operation even when it is invoked as validation or setup: formatters, lint auto-fix, code generators, package managers, schema and migration generators. Use it only where the work item or the project's conventions require it, and understand its expected write scope first. Prefer scoped commands, and never run a repository-wide formatter or auto-fixer just for tidiness. Afterwards inspect what it actually changed (manifests, lockfiles, generated migrations and artifacts included), keep the intended changes, and remove only accidental changes of this run, and only where that is safe and does not touch pre-existing user work. If it changed unrelated files and the changes cannot be separated safely: **stop** and report (recovery rule, step 4).

**External side effects.** Development and local verification must not cause unauthorized real-world or shared-environment actions. Prefer mocks, fixtures, local and test environments, sandbox or test APIs, dry-run modes and isolated test data. Without explicit authorization that the approved work requires, never send real user-facing messages or notifications, make payments or orders, mutate production or shared data, accounts or services, upload to live services, rotate or change credentials, provision infrastructure, or publish, deploy or release. Never run destructive commands. A read-only external request is fine only if it is safe, permitted by the project's instructions and really necessary. If a meaningful verification is only possible through a real side effect: do not do it silently. Report the limitation, leave that verification to a later stage, or ask for the authorization.

### 7. Check your own diff

In a git repository, repeat `git status --short -uall`, `git diff` and `git diff --cached`, compare the actual contents with the initial baseline, and determine exactly which changes this run made. A clean tree is not required. Check that:

- only the current work item was implemented, inside the write scope of step 5, with no accidental unrelated edit;
- the user's pre-existing changes are preserved, and pre-existing untracked files were not mistaken for files of this run;
- the changes of every write tool were inspected, and new files and dependencies are really needed;
- the implementation matches the approved design: no known violation of the architecture constraints it was given, and the failure and error behaviour and the security-sensitive behaviour that the design requires are implemented;
- no required check was skipped, no secret slipped in, and no real external side effect happened without authorization;
- specs, project context and documentation were not changed outside the allowed artifacts.

If you find an accidental unrelated change of your own, fix only that change, and only if it is safe. Do not reset or revert the user's changes. This is a scope and integrity check. Independent code-quality judgement is `/review-code`.

### 8. Report and stop

The report exists only in the conversation.

**Success:** the work item; what was implemented and the main files and components changed; the tests added or updated; the developer checks actually run and their results; the required checks that could not run; the dependencies, configuration or migrations changed, if any; limitations and relevant pre-existing failures; the documentation and context that will probably need syncing later; the next step, `/test-feature`, which independently verifies the implementation against the approved requirements. Do not call the work fully tested, QA-passed, code-reviewed, documentation-complete or deploy-ready.

**Blocked or stopped:** the blocker or root cause; the stage at which the run stopped; the changes already made; the checks already run; and the needed upstream route, prerequisite, user decision or recovery option. No false completion.

Then **stop**. Launch nothing.

## Hard limits

`/build-feature` does not:

- change requirements or architecture silently, modify a Product Spec, a Feature Spec or the Tech Spec, modify durable project context or the target's root `CLAUDE.md`, edit `architecture.md`, or touch framework templates, skills or agents;
- change anything outside the write scope of step 5, or add unrelated features, refactors or silent fixes of unrelated failures;
- overwrite or revert user work destructively, or run any command that changes git state (`git add`, commit, stash, reset, checkout, restore, revert and the like);
- create framework entities, or persistent tracking, status, hash, recovery or PASS metadata;
- install global or unrelated tooling or dependencies;
- perform an unauthorized real external side effect, mutate production or shared data, or deploy, release or provision;
- read or expose secrets;
- claim an independent QA, code-review or deployment verdict, or call a reviewer agent;
- launch `/test-feature`, `/review-code`, `/update-docs` or any other skill.

## Outputs

- **Successful implementation.** In the target project: the implementation artifacts of the current work item, with the automated tests where appropriate. In the conversation: the report of step 8. A microchange changes only the minimally necessary artifacts, gets proportional developer verification and no artificial Tech Spec.
- **Blocked run.** No false success. The blocker and the required previous step or user decision are reported.

## Completion criteria

A successful substantial run is complete when all of these are true:

- exactly one work item was implemented in the established target project;
- the current reviewed Tech Spec prerequisite was reliably established, with no known substantive upstream change unresolved;
- the required implementation scope was completed, and the automated tests and implementation artifacts were created or updated as applicable;
- the applicable developer checks were completed sufficiently, and every required check either passed or its inability to run blocks completion;
- there is no known unresolved implementation defect inside the scope. On a return after a downstream finding, the fix addresses that concrete finding inside the approved scope and design;
- there is no unresolved known mismatch with the requirements, the design or the architecture;
- the baseline and the user's changes were preserved, only allowed artifacts changed, and no unauthorized real external side effect happened;
- the user got the report, and `/test-feature` was suggested, not launched.

A microchange meets the proportional equivalent: no Tech Spec was needed, the change is minimal, and the verification is proportional. A correctly stopped or blocked run makes no success claim and reports the blocker and the route. A `/test-feature` PASS is not part of these criteria. That is the next stage.

## Next skills

- Substantial implementation completed: `/test-feature`.
- Microchange completed: the applicable `/test-feature` or proportional verification, then `/review-code` where applicable. No complicated bypass of the gates.
- An implementation-side defect returned by `/test-feature`, `/review-code`, `/update-docs` or `/deploy-check`: `/build-feature` → `/test-feature` → `/review-code` → `/update-docs` → `/deploy-check`, as far as applicable to the workflow. The fix does not jump straight back to the gate that found the defect, because the earlier verification has gone stale. Each downstream skill applies its own version-specific rules, and for a microchange its proportional rules.
- The requirements are wrong or must change: `/product-spec` or `/new-feature-spec` → `/review-spec` → `/architecture` if needed → `/tech-spec` if needed → `/review-spec` → `/build-feature`.
- The Tech Spec has to change in substance: `/tech-spec` → `/review-spec` → `/build-feature`.
- The Tech Spec only needs independent revalidation: `/review-spec` → `/build-feature` if it still applies.
- A substantive architecture change is needed: `/architecture` → the required architecture review → `/tech-spec` → `/review-spec` → `/build-feature`.
- A documentation-only problem: `/update-docs`.
- A deployment environment, access or tooling prerequisite: resolve the prerequisite with its owner, not through `/build-feature`.
- An unfinished dependency blocks the work: finish the prerequisite work first, then resume at the appropriate stage.
- A project instruction and a framework rule cannot both be satisfied: the user decides first.

No next skill is ever launched automatically.
