---
name: test-feature
description: The independent verification gate after /build-feature, for one work item. Orchestrates the reviewers that apply (qa-reviewer, product-reviewer and, for user-facing work, ux-reviewer), checks the already implemented behaviour against the approved requirements and returns PASS, FAIL or BLOCKED — NO VERDICT. Implementation is read-only here, so it never fixes code, tests or snapshots and never accepts "tests passed" from the builder as evidence. Works for substantial spec-driven work and for a real microchange. After PASS the next step is /review-code; after FAIL it is /build-feature.
---

# test-feature

## Purpose

`/test-feature` is the independent verification gate between implementation and code review. It verifies **one** already implemented work item of a target project: the implemented behaviour against the approved intent, and the relevant regression surface. The verification is done by the independent reviewers that apply, which this skill orchestrates: `qa-reviewer`, `product-reviewer` and, for user-facing work, `ux-reviewer`. It returns one final result, `PASS`, `FAIL` or `BLOCKED — NO VERDICT` (step 9).

It is **not** a builder. It does not write or fix production code, tests, fixtures or snapshots, change requirements, architecture, the Tech Spec or the UI, or update documentation, and it is not a code review, a security or infrastructure audit or a deployment readiness review. The build report is context, never evidence: "tests passed" from the builder is a claim, and green developer checks never become a PASS on their own. A defect goes back to where it was made:

`/test-feature` → FAIL → `/build-feature` → `/test-feature` again.

After a PASS the next step is `/review-code`. Nothing is launched automatically.

**Reviewers.** They stay separate, never merged into one universal reviewer. `qa-reviewer` asks whether it was built correctly, `product-reviewer` whether the right thing was built (the approved product or feature intent), `ux-reviewer` whether the user-facing experience matches the approved UX expectations. Each takes its detailed professional criteria from its own agent definition. This skill owns applicability, workflow, gate invariants, safety, aggregation and routing.

**Source of truth.** The expected behaviour comes from the approved sources of step 3. Code and existing tests are the implementation under test, not the expected behaviour just because they exist.

**A PASS is version-specific.** It proves that the implementation, as it was actually tested, meets the approved expectations it was tested against. An old PASS is no longer sufficient, and a new `/test-feature` is needed, after a substantive change to:

- the production implementation, including migrations;
- the required automated tests and their required fixtures and snapshots (required by the current tests or the project conventions);
- verification-relevant implementation or test configuration;
- an applicable source of truth, where the change materially affects the approved expectations or the verification scope of this work item: the Product Spec or Feature Spec requirements, the current Tech Spec, the relevant agreed architecture contracts and boundaries, the approved UX/UI direction.

Normal transient test outputs (coverage files, reports, caches, screenshots and videos created only as runtime artifacts), unrelated files and source changes not relevant to this work item or its verification scope do not invalidate a PASS. A PASS is never carried over to new expectations, even if the implementation did not change: "the requirement became weaker, so the old PASS still counts" is not valid without new verification. When a relevant source changed, step 3 applies. Nothing is recorded: no hashes, approval registry, QA status file or PASS metadata. A later stage may treat a PASS as reliably established only if the current conversation or workflow contains it for this very implementation and the sources it was tested against, with no relevant substantive change since, or the user explicitly confirms the same. Otherwise it does not count, and the safe move is a new run.

**One work item per run.** The work item under test and the regression surface are kept apart (step 2).

## When to use

- After `/build-feature` for substantial work: reviewed requirements → architecture as applicable → reviewed Tech Spec → `/build-feature` → `/test-feature`.
- For a real microchange that the user explicitly wants verified, in proportion.
- After a FAIL was fixed by `/build-feature`, after a BLOCKED cause was resolved, or after a reliably known change that voids an earlier PASS (see "Purpose"). A changed source completes its own upstream gates first.

## When not to use

- The current directory is the **ai-dev-framework repository itself**. That repo is the source of the framework, not a target. If the root contains the framework's own `skills/` folder, stop and ask which project the user actually means.
- The framework structure created by `/init-project` is missing (step 1).
- Nothing of the work item is implemented. That is `/build-feature`. A partly implemented item is tested as it stands (step 2).
- The work is substantial and has no requirements or no Tech Spec (step 3), or a "microchange" turns out to be substantial (step 2).
- The request covers several work items.
- The user wants bugs fixed, tests written, snapshots updated or a feature added (`/build-feature`), code reviewed (`/review-code`), documentation updated (`/update-docs`), deployment readiness checked (`/deploy-check`), or a security or infrastructure audit.

## Inputs

- **Target project root.** Default: the current working directory. Confirm it if there is any doubt.
- **The work item.** Substantial work: `.claude/work/<work-item-name>/tech-spec.md`. Microchange: the user's request.
- **The applicable approved requirements.** The Feature Spec of the work item, or the Product Spec for an initial product implementation.
- **The framework structure created by `/init-project`.** Substantial work: root `CLAUDE.md`, `.claude/skills/project-context/SKILL.md`, in `.claude/skills/project-context/context/` the files `product.md`, `architecture.md`, `development.md` and `infrastructure.md`, plus `.claude/product/product-spec.md` and `.claude/work/`. Microchange: root `CLAUDE.md` and the router.
- **The implementation**, its automated tests and its test and application configuration.
- **The reviewers** `qa-reviewer`, `product-reviewer` and `ux-reviewer`, as provided by the current installation. Agents are built after the skills, so a reviewer may not be installed yet (step 4).
- **A safe verification environment.**
- **The `/build-feature` report**, if any. Context only.
- **The user**, for the few questions only they can settle (step 2).

## Files to read

All reads are read-only. Never read or expose real `.env` files, passwords, tokens, credentials or secret keys. Use the existing safe test configuration. Do not load the whole repository without a reason.

- **Substantial work:** the root `CLAUDE.md`; the router; the current Tech Spec; the applicable reviewed requirements (the Product Spec directly for an initial product implementation, for feature work only where needed to understand the product intent); `architecture.md` only where it bears on observable boundaries and contracts; the relevant parts of `development.md` and `infrastructure.md`; `ux-guide.md` when the work is user-facing and the router marks it relevant; the relevant production code, automated tests, test configuration and application configuration that affects test behaviour.
- **Microchange:** the root `CLAUDE.md`, the router, the minimum relevant context, and the affected code, tests and configuration.

## Execution steps

### 1. Confirm the target and the framework structure

Verify that the working directory is a target project, not the framework repo, and that the structure required for the mode exists (see "Inputs"). If it is missing: **stop with `BLOCKED — NO VERDICT`**, say what is missing and suggest `/init-project`. Do not create or rebuild it.

Follow the target's root `CLAUDE.md` and conventions. They may refine how the verification is done and cannot silently override a mandatory framework gate. If a project instruction directly conflicts with a mandatory framework rule and both cannot be satisfied, **stop**, report the conflict and ask for a decision.

### 2. Decide the mode and the work item

**Spec-driven substantial work.** The work item has a Tech Spec and approved requirements, and the implementation exists. It usually arrives straight after `/build-feature`. Do not ritually repeat `/review-spec`. **Real microchange.** Work where a separate Tech Spec would be decoration. The basis is the user's request, the affected implementation, the relevant existing behaviour and the applicable project instructions. No artificial specs, proportional verification, and not every reviewer forced on it (step 4).

Do not shrink substantial work into a microchange to save time. If the work turns out to be substantial (new product behaviour, a new contract, a schema change, a non-obvious technical decision), **stop** and route to the normal workflow: `/new-feature-spec` or `/product-spec`, `/tech-spec`, `/review-spec`, `/build-feature`, then back here.

Exactly one work item. If the Tech Spec or the request covers several, take the one the sources and the user point to, and ask if that is unclear. For substantial work, establish which requirements apply (the `feature-spec.md` in the same work folder, or the Product Spec for an initial product implementation). If the workflow cannot be determined, do not guess. Ask.

The implementation must exist. If nothing of the work item is in the code, there is nothing to verify: **stop with `BLOCKED — NO VERDICT`** and route to `/build-feature`. A partly implemented item is tested as it stands, and what is missing against the approved behaviour is a defect, not an excuse.

Keep two scopes apart: the **work item under test** (what the approved sources say it must do) and the **regression surface** (neighbouring behaviour, shared components, touched contracts and integrations it could realistically have broken, picked from the actual impact and not from habit).

Ask the user only what the sources cannot answer: unresolved product behaviour, permission for a real side effect, a missing safe environment or test account, a business or security policy, an inaccessible required system, an ambiguous source conflict, or a decision the framework cannot safely infer. No QA interview.

### 3. Establish the sources and the workflow state

**Sources.** The Product Spec and the reviewed Feature Spec define the intended behaviour and intent. The reviewed Tech Spec defines the design, including the technical contracts that are externally observable or required. `architecture.md` matters only for observable boundaries and contracts. `ux-guide.md` holds the approved UX and UI conventions, where it exists. Project context holds durable constraints and the project's own commands. For a real microchange, the user's request, the affected existing behaviour and the applicable project instructions stand in for formal specs.

For substantial work, the applicable approved requirements and the current Tech Spec must exist and hold real content. If one is missing, empty or a not-started stub, the expected behaviour is not established: **stop with `BLOCKED — NO VERDICT`** and route to the matching workflow (see "Next skills").

**How workflow state is established.** Whenever this skill depends on a previous gate or PASS state, it counts as reliably established only through the current conversation or workflow, or an explicit user confirmation. Never infer it from file contents, git history, commits, timestamps, hashes, metadata, comments or file existence. If it cannot be established, it does not count. If the conversation already establishes it, or nothing reliably shows a relevant substantive change of a source or after a PASS, do not ask for a ritual confirmation. This gate does not re-prove earlier gates: if the workflow is plainly the normal one and no conflict is known, take the sources as approved. Nothing is recorded for this.

**Sources that changed after the build.** If it is reliably shown that after the implementation the applicable requirements, the relevant agreed architecture, the current Tech Spec or the approved UX direction changed substantively, in a way relevant to this work item or its verification scope, do not test the old implementation blindly, and do not apply the general "take the sources as approved" rule to that source:

- it has not completed every upstream gate it requires, or completion is not reliably established: it is not an approved basis. `BLOCKED — NO VERDICT` → complete or confirm the source workflow and its gates → `/test-feature`. `/test-feature` itself never declares a changed source approved;
- gates complete, the implementation stays applicable and needs no update: continue against the current approved sources. `/build-feature` is not needed just because a source changed;
- the implementation now needs an update: the source workflow → `/build-feature` → `/test-feature`;
- the Tech Spec only needs independent revalidation: `BLOCKED — NO VERDICT` → `/review-spec` → after a valid PASS, back to `/test-feature`. This is a prerequisite problem, not an implementation FAIL.

**Ambiguity and conflicts, at any point.** If the acceptance behaviour is ambiguous, or the Feature Spec, the Product Spec, the Tech Spec, an architecture or contract source, the approved UX direction or a user expectation contradict each other in a relevant area: do not pick a convenient reading and do not FAIL the implementation against an unresolved expectation. `BLOCKED — NO VERDICT`, routed to the source that needs fixing.

Then read what "Files to read" lists for the mode.

### 4. Determine the applicable reviewers and their availability

Decide this **before** any testing, from the sources, not from convenience.

- **Substantial product or feature work:** `qa-reviewer` and `product-reviewer` are mandatory. `ux-reviewer` is mandatory if user-facing interaction exists.
- **Purely technical work** with no product or feature intent: `qa-reviewer` is mandatory. `product-reviewer` may be not applicable only if there really is no product-level behaviour to review, and the reason is stated. "It would save time" is not a reason.
- **`ux-reviewer`:** applies wherever there is user-facing interaction. Ordinary interaction UX counts, non-visual products such as a normal Telegram bot included. Visual review applies only where there is an actual custom visual UI (a website, web application, dashboard, admin panel, mobile app, a WebApp part of a bot) and an approved visual direction, either the applicable rules in `ux-guide.md` or an explicitly approved design direction or reference that the workflow actually supplies. A plain bot gets no visual-design review. With no user-facing interaction (an API, a backend service, a library, a CLI without user-facing interaction under approved UX expectations) it is skipped, with the reason stated. It gets the approved UX sources and is not asked to invent a design. A visual preference outside the approved direction never creates a FAIL, and an explicit approved visual or UX requirement that is violated can. `ui-designer` is never invoked here.
- **Microchange:** only the reviewers whose question the change genuinely raises (`qa-reviewer` for a behaviour change, `product-reviewer` only if product intent really needs review, `ux-reviewer` only if the user-facing experience is affected). Those that apply are mandatory for this run.

If there is real doubt whether a reviewer applies, it applies. A mandatory reviewer is never skipped silently, and every skip is stated with its reason in the report. A reviewer that is not applicable does not block. An applicable one that is unavailable does.

**Availability.** A reviewer is available only if it is installed and can actually be invoked in this session. If an applicable mandatory reviewer is not available:

- do not imitate it, do not substitute another agent, do not perform its review yourself as if independent, and do not read its absence as a pass;
- **stop with `BLOCKED — NO VERDICT`**, name the missing reviewer and say it has to be provided before the gate can run. Nothing has been verified, so no defect is established;
- if the user explicitly asks to run the available reviewers anyway, do so. A concrete defect found that way is a valid FAIL, with the missing review reported as incomplete. Such a run never yields a PASS, and without such a FAIL the result stays `BLOCKED — NO VERDICT`.

### 5. Take the baseline and prepare a safe environment

**Baseline.** In a git repository, before any independent verification, take a read-only baseline: `git status --short -uall`, `git diff` and `git diff --cached`, and record the untracked paths listed. A clean tree is not required. The baseline tells pre-existing changes from mutations caused by the test process, and shows whether existing dirty changes can invalidate the results. Git is never approval metadata. Create no hashes, snapshots, baseline files or backup registries. If the project is not a git repository, do not invent a substitute.

**Dirty tree.** Unrelated dirty changes do not block testing by themselves, but judge whether pre-existing uncommitted or untracked changes could materially affect the tested behaviour, runtime configuration, a contract, an integration or a test result. Clearly unrelated: go on. Uncommitted changes of an earlier partial implementation of this same work item are the state under test. If their influence cannot be reliably separated: `BLOCKED — NO VERDICT`, because neither PASS nor FAIL is honest. Never stash, reset, checkout, restore, clean, commit or otherwise modify the user's changes to get a cleaner environment.

**Safe verification.** Verification defaults to local, test, sandbox, mock or read-only execution: an existing automated test environment, an isolated test database, fixtures, test services or accounts, dry-run modes. Use the commands that `CLAUDE.md`, `development.md` and the project configuration define, and do not invent commands. Established safe local processes may be started, are not exposed publicly, and are stopped afterwards where practical. Without explicit authorization there is never a real external side effect: real messages or notifications to users, payments or orders, mutation of production or shared data (databases, queues, live integrations, customer data, accounts), publishing, deployment, release, provisioning or credential rotation. Never apply a production or shared migration. If a mandatory verification really needs one of these, do not do it silently: `BLOCKED — NO VERDICT` until the user gives explicit permission or a safe alternative exists. The same applies when a mandatory verification has no available environment, a required tool is missing or safe test data cannot be established, unless a concrete FAIL is already established.

**Dependency bootstrap.** This gate never adds, upgrades or selects dependencies. Installing dependencies the project **already declares** is allowed, through the project's own established mechanism in its locked or frozen form where one exists, with versions governed by the existing manifest or lockfile, without intentionally changing the manifest, lockfile or source, and with no global install unless the project explicitly requires it and it is safe. Afterwards compare the repository state with the baseline. An unexpected change of a tracked manifest, lockfile or source file is an integrity issue (step 8). Do not accept it silently and do not revert it. A dependency that the implementation needs but the project does not declare is an implementation defect, not something to install here.

### 6. Verification rules at gate level

The reviewers carry out the independent verification. This skill sets the rules below and hands them over. It does not run the reviewers' checks in their place, and the detailed QA methodology belongs to `qa-reviewer`.

**Scope and adequacy.** The verification scope comes from the approved requirements and acceptance criteria, the Tech Spec, the changed components, the affected contracts and integrations, the realistic regression surface and the project's testing conventions. No full suite as a ritual, but where the project requires it, it runs when it is safe and available. Every substantive approved acceptance behaviour needs a safe method of verification and observed evidence. No acceptance criteria are invented, an internal Tech Spec step is not one, and a technical contract is verified when it is externally observable or required. Verification is not only the happy path: relevant failure behaviour is covered. An obvious high-risk regression surface cannot be ignored, and PASS is impossible while it is unchecked. Verification adapts to the actual project type and runtime model. No browser or UI is assumed. A migration is verified only in a safe local or test database, and a rollback only where the project has a safe established mechanism and the requirement or Tech Spec calls for it. Production rollback readiness belongs to `/deploy-check`.

**Mandatory and optional.** Mandatory verification is whatever the gate needs: substantive acceptance, the applicable product and UX review, a project-required command, realistic regression, a mandatory integration or contract check. If one of them cannot be done and no concrete FAIL exists: `BLOCKED — NO VERDICT`. An unavailable optional check is a reported limitation and does not block a PASS if the mandatory evidence is complete. A mandatory check is never demoted to optional because it is inconvenient.

**Classification of outcomes.**

- Caused by the current implementation: FAIL. That includes an incomplete implementation: what is missing against the approved behaviour.
- A required test, fixture or snapshot artifact (required by the Tech Spec or the project conventions) that is missing, stale or wrong: FAIL → `/build-feature`. `/test-feature` never edits it and never updates a snapshot to turn a run green, and uses the project's non-updating mode where the tooling has one. A mismatch is read against the approved behaviour. If the test itself contradicts an unresolved requirement, it is a source ambiguity (step 3).
- A test that is not required, with behaviour safely verifiable another established way: proportional verification is fine. Behaviour that cannot be verified reliably at all, or absent evidence that makes verification impossible: `BLOCKED — NO VERDICT`.
- An environment or tooling inability that prevents determining correctness: `BLOCKED — NO VERDICT`.
- Clearly pre-existing and unrelated, with the mandatory verification still valid: reported separately, not fixed, not a FAIL. Relevance is never declared unrelated without evidence. Ambiguous relevance that affects mandatory verification: `BLOCKED — NO VERDICT`.

**Flaky results.** No "fail, rerun until green, PASS". One diagnostic rerun is allowed when it is needed to establish nondeterminism, and no more. Flakiness caused by the current implementation is a FAIL. Flakiness caused by the environment or tooling, so that correctness cannot be determined, is `BLOCKED — NO VERDICT`. A known pre-existing, clearly unrelated flake with the mandatory verification still valid is reported separately. Unexplained flakiness in mandatory verification is incompatible with PASS.

**Coverage.** No arbitrary percentage. A threshold counts only if the project, an approved requirement or the existing tooling gate sets one, and a gap is a finding only where it matters for the expectations of the current implementation.

**Non-functional requirements** (performance, accessibility, compatibility, latency, resource limits and the like) are verified only if an approved requirement or the project conventions require them, or the work item touches a documented constraint. No automatic audit. A mandatory one that cannot be reliably verified is `BLOCKED — NO VERDICT`, a non-mandatory one is a reported limitation. Accessibility can fall under `ux-reviewer` if it is an approved UX requirement.

### 7. Run the reviewers

Each applicable reviewer receives:

- the exact work item and the current verification scope, with the regression surface;
- the applicable approved sources, the implementation and the relevant tests, test configuration, conventions and commands;
- the safe environment boundaries, the known limitations and the rules of step 6;
- the response contract below.

In addition, `qa-reviewer` gets the relevant architecture and context. `product-reviewer` gets the Product or Feature intent, the current implemented result, the relevant observable behaviour and product context, and judges only against the APPROVED intent: it may not extend the requirements. `ux-reviewer` (only when applicable) gets the approved user-facing requirements, the relevant Feature or Product Spec, `ux-guide.md`, the current user-facing flow or UI and states, and the approved design direction if there is one.

Every reviewer is independent and read-only. It does not edit the implementation, tests, fixtures, snapshots, specs, project context, requirements, architecture, manifests, lockfiles or implementation configuration, does not fix findings, stage or commit, does not redesign or silently widen the scope, and gives no verdict outside its domain. Do not hand it a verdict to confirm or your own opinion. The build report is context, never evidence.

**Order.** The default is `qa-reviewer`, then `product-reviewer` and `ux-reviewer` where applicable. It is not rigid. If an earlier reviewer establishes a concrete blocking FAIL, the remaining expensive verification may be stopped: report what was completed, which reviewers did and did not run, and that the remaining verification is incomplete.

**Response contract.** No numeric score. Each reviewer returns: the scope reviewed; the checks performed; the findings, each concrete (scenario, expected, observed, evidence, impact); the blockers and limitations; other-domain and non-blocking observations, listed separately and not findings against this gate; and a recommended `PASS`, `FAIL` or `BLOCKED`.

### 8. Validate the results and the integrity

**Results.** The skill does not vote on top of the reviewers and does not run a second review. It verifies that each result concerns the right work item, comes from the right reviewer, is one unambiguous result, stays in the reviewer's domain and shows the evidence its label needs. Then:

- PASS while a mandatory verification was not run: not a PASS, `BLOCKED — NO VERDICT`.
- FAIL caused by an unavailable environment, a missing tool or broken tooling: `BLOCKED`, not an implementation FAIL.
- FAIL against an unresolved expectation: `BLOCKED`, routed to the source (step 3).
- FAIL for a code-quality, security or deployment concern: an observation for the later gate. It is a FAIL here only if it directly makes approved behaviour fail.
- A reviewer that is unavailable at the moment of the call or fails to run produces no result: `BLOCKED` as in step 4, and the other results are still aggregated.
- Malformed output, output about another work item, or a reviewer that stepped out of its role: no valid result for that reviewer. `BLOCKED` for it. Never invent one, fix its output or substitute your own verdict.

**Integrity.** After the reviewers, repeat `git status --short -uall`, `git diff` and `git diff --cached` and compare with the baseline of step 5, comparing the actual contents of `git diff` and not only the paths. Untracked files listed before count as pre-existing, and a content change of such a file is invisible to this comparison, so the reviewers' read-only rule guards it. Normal transient artifacts (coverage files, test reports, browser screenshots and videos, Playwright or Cypress results, caches, temporary local test data) are fine if they are normal for the project's tooling, change no implementation source, tracked test, spec, context or configuration, are not used to hide a failure, and are allowed by the project conventions.

If a reviewer or the bootstrap changed source code, tracked tests, fixtures, snapshots, a manifest, a lockfile, a migration, implementation configuration, specs or project context, integrity is broken. A reviewer mutation can never yield a PASS. Do not silently revert anything and do not repair the mutation automatically: report what changed. A concrete implementation FAIL that had already been independently established, with evidence that does not rest on the mutated state, may still be reported, together with the integrity issue and the incomplete remaining verification. Otherwise: `BLOCKED — NO VERDICT`.

### 9. Aggregate and give the result

The final result aggregates the applicable mandatory reviewers and the mandatory verification. Do not accept a favourable result the evidence does not support.

- **`FAIL`.** At least one applicable reviewer validly established a concrete defect of the current implementation against the approved behaviour, intent or UX requirement. FAIL is about the implementation, and only about it. It stands even if another reviewer was BLOCKED or never ran. Report the incomplete verification too. After the fix, the whole applicable `/test-feature` runs again.
- **`BLOCKED — NO VERDICT`.** No concrete implementation defect is established, but a mandatory reviewer or mandatory verification could not be validly completed: an unavailable reviewer, environment or tool; ambiguity in the sources; dirty changes that make test validity ambiguous; a required unsafe side effect; unexplained mandatory flakiness; broken integrity. A broken process, a broken environment, a missing reviewer or an unsettled requirement is never a FAIL.
- **`PASS`.** Only if: the target and one work item are established and the approved expected behaviour is clear; the implementation exists and the safe environment was available; the applicable reviewers were determined correctly, were all available and completed valid independent reviews; `qa-reviewer` passed, and `product-reviewer` and `ux-reviewer` passed where they apply; the mandatory acceptance behaviour, failure behaviour and regression, and the applicable mandatory non-functional requirements, are verified; no defect of the current implementation is unresolved; dirty-tree ambiguity did not invalidate the evidence and there is no unexplained flaky mandatory verification; no unsafe side effect happened and the integrity is preserved; the evidence is sufficient.

A PASS does not claim that the work is code-reviewed, security-approved, deployment-ready or production-ready. Those gates have not happened. Whether the skill ran correctly and whether the gate passed are two different questions.

### 10. Report and stop

The result exists only in the conversation. Report the work item and the applicable reviewers, with any skipped reviewer and its reason, and:

- **PASS:** the verification summary (acceptance scenarios, failure paths, regression scope), the product-intent and UX summaries where they apply, the checks actually run and the evidence, non-blocking limitations and observations, `PASS` as applying to the implementation as tested against the current approved sources, and the next step `/review-code`, which judges the code quality of the now verified implementation.
- **FAIL:** the concrete findings with reviewer or domain, scenario, expected, observed, evidence and impact, the verification that stayed incomplete, `FAIL`, the route by root cause (see "Next skills") and that the whole applicable run reruns after the fix.
- **BLOCKED:** the reviewers and checks completed and not completed, the blocker and the unverified areas, `BLOCKED — NO VERDICT` and the required next action.

For any result, list only as observations: the documentation impact (for `/update-docs`), pure code-quality observations (for `/review-code`) and security or deployment concerns (for the matching later gate). Then **stop**. Launch nothing.

## Hard limits

`/test-feature` and its reviewers do not:

- fix findings, not even one line. FAIL → `/build-feature` → `/test-feature`;
- modify source, automated tests, fixtures, snapshots, manifests, lockfiles, migrations, implementation or infrastructure configuration, or weaken an assertion, change a test expectation or update a snapshot to obtain a PASS;
- write new automated tests or create a test framework;
- change the Product Spec, a Feature Spec, the Tech Spec, architecture or project context, the target's root `CLAUDE.md`, documentation, framework templates, skills or agents, or silently change an approved requirement or UX expectation;
- add, upgrade or choose dependencies;
- perform a real external side effect without explicit authorization, mutate production or shared data, deploy or release;
- perform a code review, an architecture review, a security, infrastructure or deployment readiness review, claim their results, invent product strategy or a design, or call `ui-designer`;
- read or expose real secrets;
- imitate an unavailable reviewer;
- launch `/review-code`, `/build-feature`, `/update-docs` or any other skill;
- create framework entities, or hashes, approval registries, QA status files, persistent PASS metadata or persistent QA reports;
- run `git add`, commit, stash, reset, checkout, restore, revert, clean or any other command that changes git state. Git is for inspection only.

Allowed: the normal transient runtime and test artifacts of step 8, and nothing else.

## Outputs

Conversation only. `/test-feature` intentionally creates or modifies no implementation, source-of-truth or durable project artifact. The only files that may appear are the normal transient testing and runtime artifacts of the project's own tooling. The report content is defined in step 10.

## Completion criteria

**Correct PASS completion:** every PASS condition of step 9 holds, the required project checks were completed, the baseline was taken and the dirty state assessed (step 5), the integrity comparison was made (step 8), `PASS` was reported and `/review-code` suggested, not launched.

**Correct FAIL completion:** valid independent verification established a concrete defect of the implementation; the evidence is recorded and no self-fix occurred; the route by root cause and the rerun requirement were given. Not every remaining expensive reviewer must complete once a decisive FAIL is established, and the incomplete verification is reported.

**Correct BLOCKED completion:** a valid gate could not be completed and no unsupported PASS or FAIL was invented; the blocker was identified, the completed and unresolved verification reported, and a recovery action given.

In every case no git state was changed, the implementation and specs were not modified, and no framework entity or tracking artifact appeared. A correctly executed run is not the same as a PASS of the quality gate.

## Next skills

The root cause decides the route, not the reviewer that found the problem.

- `/test-feature` PASS → `/review-code`. Not launched automatically.
- An implementation defect, a missing, stale or wrong required test artifact, or an approved product intent or UX behaviour that is not implemented correctly → FAIL → `/build-feature` → `/test-feature`.
- The requirements are ambiguous or must change → `/product-spec` or `/new-feature-spec` → `/review-spec` → `/architecture` if needed → `/tech-spec` if needed → `/review-spec` → `/build-feature` → `/test-feature`.
- A substantive Tech Spec change → `/tech-spec` → `/review-spec` → `/build-feature` → `/test-feature`.
- An architecture change → `/architecture` → the required architecture review → `/tech-spec` → `/review-spec` → `/build-feature` → `/test-feature`.
- The Tech Spec only needs independent revalidation after a known source change → `/review-spec` → `/test-feature`.
- A relevant source changed, its gates reliably complete, the implementation applicable and needing no update → `/test-feature` again against the current approved sources. Not via `/build-feature`. If the change requires implementation changes, the routes above through `/build-feature` apply.
- The UX or design direction itself is missing, contradictory or must change → the appropriate source-of-truth or design decision outside this skill (no redesign here, no automatic `ui-designer`), then the implementation update if needed → `/test-feature`.
- An environment or tool blocker, an unavailable mandatory reviewer, or a required unsafe side effect → resolve the prerequisite (or an explicit user decision, or a safe alternative) → `/test-feature`.
- Nothing implemented → `/build-feature`. Framework structure missing → `/init-project`.
- Code-quality observations are reported for `/review-code`, documentation impact for `/update-docs`, security or deployment concerns for the matching later gate. They are not QA failures, unless they directly make approved behaviour fail.

After any fix or resolved blocker, the whole applicable `/test-feature` run repeats. No next skill is ever launched automatically.
