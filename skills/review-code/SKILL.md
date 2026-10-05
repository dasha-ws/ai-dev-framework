---
name: review-code
description: The independent code-quality gate after a successful /test-feature, for one work item. Hands the already working implementation to the independent code-reviewer and returns PASS, FAIL or BLOCKED — NO VERDICT. It asks whether the code is technically sound, maintainable, appropriately simple and consistent with the approved technical design and project conventions. Read-only, so it never fixes code, and it is neither a second QA gate nor a security, architecture or deployment review. For substantial work, and for a microchange that went through /test-feature, it needs a reliably established current /test-feature PASS. Once it is run at all, code-reviewer is mandatory, microchanges included. After PASS the next step is /update-docs; after FAIL it is /build-feature, then /test-feature, then /review-code again.
---

# review-code

## Purpose

`/review-code` is the independent code-quality gate that follows successful verification. It reviews **one** already working work item of a target project and answers one question:

"Is the implementation technically sound, maintainable, appropriately simple, and consistent with the approved technical design and project conventions?"

The review itself is done by the independent `code-reviewer`. This skill owns the process around it: prerequisites, scope, sources, baseline, gate semantics, integrity and routing. It is not a second `/test-feature`, a builder, a requirements, architecture, product, UX, security or deployment review, or a documentation stage. It fixes nothing. A defect goes back to where it was made. For substantial work:

`/review-code` → FAIL → `/build-feature` → `/test-feature` → `/review-code` again.

The detour through `/test-feature` is mandatory there. After a substantive fix, `/review-code` can rely on a `/test-feature` PASS only if that PASS is still current under `/test-feature`'s own version-specific rules, so "fix the code, then `/review-code`" is not allowed. For a microchange the proportional re-verification rule of step 12 applies instead: a clearly non-behaviour-affecting fix does not need a full `/test-feature` solely because code changed, and a behaviour-affecting or uncertain one needs the appropriate functional re-verification.

**Relation to `/test-feature`.** `/test-feature` asks whether the behaviour works. `/review-code` asks whether the code that implements it is good enough to accept. Functional QA is not repeated. For substantial work, and for a microchange that went through `/test-feature`, a current `/test-feature` PASS is a prerequisite, but it is not evidence of code quality: the code is read and judged independently, and a concrete bug visible in it is a valid FAIL even if the tests are green.

**Roles.** The skill is the orchestrator and the gate. `code-reviewer` owns the detailed code-review criteria and the independent, read-only inspection. It is mandatory whenever `/review-code` is actually run, for substantial work and for a microchange alike. The skill never imitates it. There is no fallback where the skill "does the review" itself.

**Source of truth.**

- Product and Feature requirements: the expected behaviour, as far as it sets technical intent.
- The reviewed Tech Spec: the approved technical decisions, contracts, dependencies, persistence and integration design, constraints.
- `architecture.md`: the durable architectural boundaries.
- `development.md`: the conventions, commands and development rules. `infrastructure.md` only where it materially affects the implementation.
- Code is the implementation under review. Tests are implementation artifacts, not a source of requirements.
- For a microchange: the user's request, the affected implementation and existing behaviour, the project conventions.
- A material conflict between sources is never resolved by picking the convenient one: `BLOCKED — NO VERDICT`, routed upstream (step 5).

**Tech Spec conformance is semantic, not literal.** The implementation is reviewed against the material approved decisions of the Tech Spec: contracts, constraints, boundaries, dependencies, data and persistence design, the integration approach, lifecycle behaviour. It need not match the Tech Spec structurally. Helpers, private methods, file splits, internal names and small refactors are not prescribed unless a detail is an explicit required decision. A reasonable choice inside the approved design is not a FAIL because the reviewer would have done it differently.

**The three results.**

- **`PASS`.** No unresolved substantive code-quality defect must be fixed before the work goes on. It may carry non-blocking observations. It does not mean perfect code, security approval, deployment readiness or an architecture re-approval.
- **`FAIL`.** Independent review established a concrete, evidence-based, actionable, substantive defect in the current work item or in code it materially depends on. Never for a stylistic preference.
- **`BLOCKED — NO VERDICT`.** Valid independent review cannot be completed and no valid blocking defect is established. A broken review process is not a FAIL.

Findings are of two kinds only: blocking findings and non-blocking observations. No severity scores. FAIL needs at least one blocking finding.

**A PASS is version-specific.** It applies only to the implementation as reviewed, against the sources and conventions used for that review. An old PASS is no longer sufficient after a reliably known substantive change to the production implementation (migrations included), the required tests and their required fixtures and snapshots, implementation or review-relevant configuration, dependency manifests and lockfiles, any other implementation artifact in the review scope, or an applicable source (requirements, Tech Spec, architecture contracts and boundaries, development conventions) that materially changes the review expectations or scope. Unrelated changes, documentation outside code and normal transient outputs (build output, coverage, reports, caches, screenshots) do not invalidate it. A PASS is never carried over to changed expectations by assumption (steps 4 and 5). Nothing is recorded: no hashes, approval registry, review status file or PASS metadata.

**One work item per run.** Three scopes are kept apart: the work item; the review scope needed to assess it (the code it changed, shared code it changed or materially depends on, and the tests, configuration, dependencies and migrations needed to judge it); and unrelated repository code, which is not part of this gate.

## When to use

- After a `/test-feature` PASS for substantial work: reviewed requirements → architecture as applicable → reviewed Tech Spec → `/build-feature` → `/test-feature` PASS → `/review-code`.
- For a real microchange that the user explicitly sends here. The scope is proportional. `code-reviewer` is still mandatory.
- After a FAIL was fixed and re-verified, after a BLOCKED cause was resolved, or after a reliably known change that voids an earlier PASS.

## When not to use

- The current directory is the **ai-dev-framework repository itself**. That repo is the source of the framework, not a target. If the root contains the framework's own `skills/` folder, stop and ask which project the user actually means.
- The framework structure created by `/init-project` is missing (step 1).
- Nothing is implemented, or substantial work, or a microchange that went through `/test-feature`, has no current `/test-feature` PASS (steps 3 and 4).
- Substantial work has no requirements or no Tech Spec (step 5), or a "microchange" turns out to be substantial (step 2).
- The request covers several work items.
- The user wants findings fixed, code written, functional verification, documentation updated, deployment readiness checked, a security audit, or a review of requirements or architecture.
- A true microchange that the framework or project rules let go without code review may skip this skill. Once it is sent here, the skill applies in full, `code-reviewer` included.

## Inputs

- **Target project root.** Default: the current working directory. Confirm it if there is any doubt.
- **The work item.** Substantial work: `.claude/work/<work-item-name>/tech-spec.md`. Microchange: the user's request.
- **The applicable approved requirements.** The Feature Spec of the work item, or the Product Spec for an initial product implementation.
- **The framework structure created by `/init-project`.** Substantial work: root `CLAUDE.md`, `.claude/skills/project-context/SKILL.md`, in `.claude/skills/project-context/context/` the files `product.md`, `architecture.md`, `development.md` and `infrastructure.md`, plus `.claude/product/product-spec.md` and `.claude/work/`. Microchange: root `CLAUDE.md` and the router.
- **The implementation** with its tests, fixtures, configuration, manifests and migrations.
- **The current `/test-feature` PASS** (substantial work, and a microchange that went through `/test-feature`), established by the current conversation or workflow (step 4).
- **`code-reviewer`**, as provided by the current installation. Agents are built after the skills, so it may not be installed yet (step 6).
- **The `/build-feature` and `/test-feature` reports**, if any. Context only.
- **The user**, for the few questions only they can settle.

## Files to read

All reads are read-only. Never read or expose real `.env` files, credentials, tokens or secrets. Read selectively, not the whole repository:

- **Substantial work:** the root `CLAUDE.md`; the router; the current Tech Spec; the relevant architecture context and `development.md` (`infrastructure.md` only where it bears on the implementation); the requirements only where needed for technical intent; the relevant code, tests, fixtures and snapshots, configuration, manifests and lockfiles, migrations and generated-code inputs; the `/build-feature` report and the `/test-feature` result, as context only.
- **Microchange:** the root `CLAUDE.md`, the router, and the minimum relevant subset of code, tests, configuration and context.

## Execution steps

### 1. Confirm the target and the framework structure

Verify that the working directory is a target project, not the framework repo, and that the structure required for the mode exists (see "Inputs"). If it is missing: **stop with `BLOCKED — NO VERDICT`**, say what is missing and suggest `/init-project`. Do not create or rebuild the structure.

Follow the target's root `CLAUDE.md` and conventions. They may refine how the review is done and cannot silently override a mandatory framework gate. If a project instruction directly conflicts with a mandatory framework rule, **stop**, report the conflict and ask for a decision.

### 2. Decide the mode

**Spec-driven substantial work.** The work item has a Tech Spec and approved requirements, and the implementation has been through `/test-feature`. Do not rerun `/test-feature` or `/review-spec` here.

**Real microchange.** No artificial specs. The basis is the user's request, the affected implementation, existing behaviour, project conventions and minimum technical context. The scope is proportional. A microchange that never went through `/test-feature` has no `/test-feature` PASS prerequisite, and none is invented for it. If the current workflow actually invoked `/test-feature` for it, a current reliably established `/test-feature` PASS is required, exactly as for substantial work (step 4).

Do not shrink substantial work into a microchange. If it turns out to be substantial, **stop** and route to the normal workflow: `/new-feature-spec` or `/product-spec`, `/tech-spec`, `/review-spec`, `/build-feature`, `/test-feature`, then back here.

### 3. Determine the work item and the review scope

Exactly one work item. If the request or Tech Spec covers several, take the one the sources and the user point to, and ask if that is unclear. For substantial work, establish the applicable requirements (the `feature-spec.md` in the same work folder, or the Product Spec for an initial product implementation) and ask if the workflow cannot be determined.

If nothing of the work item is in the code: **stop with `BLOCKED — NO VERDICT`** and route to `/build-feature`.

**Do not rely on `git diff` alone to find the scope.** The implementation may already be committed and the diff empty. Identify the scope from the work item, the Tech Spec, the conversation or workflow, the build report, code references and the project structure. Git status and diff serve state inspection and safety. They are not the source of the work item's identity, of approvals or of workflow completion. History may be read to understand how the code evolved, never as approval metadata. If the scope cannot be identified: `BLOCKED — NO VERDICT`.

### 4. Check the `/test-feature` PASS

**How gate state is established.** Whenever this skill depends on a previous gate or review state (a `/test-feature` PASS, a reviewed Tech Spec, a required architecture review, the upstream review of a changed source), it counts as reliably established only through the current conversation or workflow, or an explicit user confirmation. Never infer it from file contents, git history, commits, timestamps, hashes, metadata, comments or file existence. If it cannot be established, it does not count. If the conversation already establishes it, do not ask for a ritual confirmation. Earlier gates are not re-proved when the conversation clearly establishes them and no conflict is known.

**Substantial work, and a microchange that went through `/test-feature`.** A current `/test-feature` PASS must be reliably established for the current implementation against the current approved sources. It is not rerun here. If it is absent, was a FAIL or BLOCKED, is not established, or was invalidated by a relevant later change: `BLOCKED — NO VERDICT` → the appropriate correction (`/build-feature` where the result was an implementation defect) → `/test-feature` → `/review-code`. A microchange that never went through `/test-feature` is not held to this.

**A known change after the PASS.** Whether that `/test-feature` PASS is still current is decided by `/test-feature`'s own version-specific rules. `/review-code` neither copies nor redefines them, and never issues or renews that PASS. If it is reliably known that a change after the PASS invalidates it under those rules, do not review the changed implementation as if it were still verified: `BLOCKED — NO VERDICT` → `/test-feature` → `/review-code`. If the change came from an upstream source, the source workflow comes first (step 5). If it cannot be reliably established that the PASS exists and applies to the current implementation, it does not count and none is assumed. Chronology is never inferred from git timestamps, hashes or metadata, and without reliable evidence of a change no confirmation is asked.

### 5. Check the sources of the technical expectations

For substantial work the Tech Spec must exist and hold real content, and the relevant architecture and development context must be available. Otherwise: **stop with `BLOCKED — NO VERDICT`** and route to the matching workflow.

**Changed sources.** If it is reliably shown (conversation, workflow or explicit user confirmation) that the requirements, the Tech Spec, the relevant architecture contracts or the approved technical constraints changed substantively after the implementation and test gate, in a way that materially affects this work item or the review expectations, do not review against stale expectations:

- **The source has not completed every upstream gate it requires, or completion is not reliably established** (step 4): it is not an approved basis. `BLOCKED — NO VERDICT` → complete or confirm the gates → `/test-feature` where its PASS was invalidated → `/review-code`. `/review-code` never declares a changed source approved.
- **Gates reliably complete, implementation stays applicable and needs no change:** continue against the current approved sources, once `/test-feature` has been rerun where its PASS was invalidated. No `/build-feature` merely because a source changed.
- **Gates complete, implementation needs an update:** the source workflow → `/build-feature` → `/test-feature` → `/review-code`.
- **The Tech Spec, the architecture or the requirements themselves must change:** the matching upstream chain (see "Next skills").

**Development conventions.** `development.md` is project context and the current source of truth for the conventions. It is not a gated artifact, and no gate or approval mechanism is created for it. Review against the current applicable conventions, unless a conflict or an unresolved decision about a convention is known. If a convention materially changed and so changed the review expectations, an earlier `/review-code` PASS may be invalidated and the review runs again against the current conventions. A convention known to be unresolved or conflicting: `BLOCKED — NO VERDICT`.

**Conflicts and ambiguity, at any point.** If sources conflict materially or the expected technical standard is unresolved: `BLOCKED — NO VERDICT`, routed upstream. The one exception is a concrete code defect that the review independently established and that stays valid whichever way the source question is resolved: it may still be reported as a FAIL. If the review reveals that the Tech Spec is wrong, the architecture must change or the requirements must change, do not force the code to match an obsolete design and do not redesign upstream here.

Then read what "Files to read" lists.

### 6. Check that `code-reviewer` is available

Do this before any expensive work. It is available only if it is installed and can actually be invoked in this session. If it is not: do not imitate it, do not substitute another agent, do not review the code yourself as if independent, and do not read its absence as a pass. **Stop with `BLOCKED — NO VERDICT`**, name the missing reviewer and say it has to be provided before the gate can run.

### 7. Take the baseline and prepare the checks

**Baseline.** In a git repository, before the review, take a read-only baseline: `git status --short -uall`, `git diff` and `git diff --cached`, and record the untracked paths listed. It serves to understand the reviewed state, preserve user work and detect mutations. A clean tree and a prior commit are not required, and an already committed implementation with an empty diff is normal. Create no hashes, baseline files, snapshots or review metadata. If the project is not a git repository, do not invent a substitute.

**Dirty tree.** Changes belonging to the work item are part of the review target. Clearly unrelated changes are preserved and do not block. If pre-existing or unrelated changes materially affect the reviewed implementation and cannot be separated: `BLOCKED — NO VERDICT`. Never stash, reset, checkout, restore, clean, commit or otherwise discard or modify the user's changes.

**Project checks.** Find out from `CLAUDE.md`, `development.md` and the project configuration which quality checks exist and which are mandatory. `code-reviewer` runs the applicable ones, non-mutating only: lint or formatter in check mode, a type checker, compiler validation, existing static analysis, a project-defined quality command. The skill does not run them itself. Never `lint --fix`, formatter write mode, import auto-fixers, regeneration of generated source, new lint or compiler configuration, manifest or lockfile updates, or new review tools. An unavailable optional tool is a reported limitation. A mandatory check that cannot run: `BLOCKED — NO VERDICT`.

**Bootstrap.** Installing dependencies the project **already declares** is allowed only if an established check command needs it, through the project's own mechanism in locked or frozen form, with no upgrade, addition, manifest, lockfile or source change and no global install (unless the project requires it and it is safe). If it unexpectedly changes tracked files, that is an integrity problem (step 11). Do not silently revert it.

### 8. Scope and boundaries of the review

`code-reviewer` owns the detailed criteria. The skill hands it the scope and these boundaries.

**Concerns, where relevant to the work item:** correctness visible from the code; maintainability; simplicity and minimal sufficiency; project conventions; tests as code; error and resource handling; dependencies and configuration; comments as code artifacts; material duplicate or dead code; performance only when relevant.

**Rules that carry framework semantics.**

- Green tests do not hide an obvious code bug. Functional verification is not repeated.
- Only real conventions count (`CLAUDE.md`, `development.md`, configuration, established patterns). Reviewer taste is not a FAIL. A style point counts only if the project requires it or it materially affects maintainability or correctness.
- Complexity is a finding only with a concrete, material maintenance cost. Necessary complexity is valid. Duplicate or dead code blocks only when material.
- A substantive test-code defect is a FAIL. A finding that needs a change of the implementation or of its related verification artifacts is fixed through `/build-feature`. Whether that fix needs functional re-verification, and how much, is decided by `/test-feature`'s own rules, within the routing of step 12.
- Hardcoded real credentials or tokens are blocking defects.
- A dependency problem at implementation level is a FAIL. One that needs a design change is routed to `/tech-spec`, or to `/architecture`.
- Code the project establishes as generated is not reviewed as hand-written. Review its source or configuration and how it is integrated.
- Performance counts only if a current requirement or convention constrains it, the work item concerns it, or there is an obvious material inefficiency at a realistic current workload. No imaginary scale.

**Boundaries.**

- *QA, product, UX:* not repeated. If reading the code suggests earlier verification is no longer trustworthy, report it and route to `/test-feature`. Do not invent a QA verdict.
- *Security:* not an audit. Direct, obvious defects in the reviewed code (a hardcoded credential, secret logging, evident injection-prone construction, an explicit security coding rule violation) may FAIL. Broader concerns are observations for the later security review.
- *Infrastructure, architecture, requirements:* only conformance to what is agreed is checked. Deployment readiness belongs to `/deploy-check`. Nothing is redesigned here. Route upstream.
- *Documentation:* the README, API docs and release notes belong to `/update-docs`.

**Pre-existing and unrelated issues.** The reviewer explains each issue's relationship to the work item, with evidence. An issue introduced or materially worsened by the work item, or in shared code it materially depends on so that it cannot be safely accepted, may be blocking. A clearly pre-existing, unrelated issue is a non-blocking observation: not a FAIL, and not fixed here. If the relationship cannot be established and that prevents a valid review: `BLOCKED — NO VERDICT`. The review is not silently widened into the whole repository.

**Findings** are concrete and actionable: location, issue, evidence, the violated approved decision or convention, impact and a direction of correction, not rewritten code.

**Questions to the user** only when necessary: an unresolved business constraint, a real design decision that needs approval, an inaccessible source, a project policy. Never questions of taste.

### 9. Run `code-reviewer`

Once prerequisites, sources, scope and baseline are established, invoke `code-reviewer`. It receives:

- the work item and the review scope;
- the current technical sources and context (Tech Spec, relevant architecture, `development.md`, requirements where needed for intent);
- the implementation, tests, configuration, dependencies and migrations as relevant;
- the current `/test-feature` PASS, as prerequisite and context only;
- the applicable project checks, with the mandatory ones marked;
- the boundaries of step 8 and its read-only rule.

Do not tell it which verdict to return, and never say "QA passed, therefore the code should pass".

`code-reviewer` is read-only. It does not edit code, tests, fixtures, snapshots, generated source, manifests, lockfiles, migrations, configuration, specs, context or docs. It does not fix findings, stage or commit, redesign requirements or architecture, or widen the scope.

It returns, with no numeric score: the scope reviewed; the checks run; the blocking findings and the non-blocking observations, with evidence; the blockers; and a recommended `PASS`, `FAIL` or `BLOCKED`.

### 10. Check what the reviewer returned

The skill owns the final gate semantics. It does not relay a label blindly and does not run a second review. Verify that the result concerns the right work item and scope, comes from the valid reviewer, is backed by evidence, stays in the reviewer's domain, covers the mandatory checks, and left the project unchanged. Then:

- A PASS with a mandatory project check not run: `BLOCKED — NO VERDICT`. A FAIL merely because an optional tool is missing is not a code defect.
- A FAIL resting on subjective style or architecture preference is invalid, unless a current approved source requires it or a concrete material defect is established.
- An obvious code bug is a valid FAIL even though `/test-feature` was green.
- A complaint about clearly unrelated legacy code is a non-blocking observation.
- A finding outside the reviewer's domain (functional, product, UX, broad security, deployment) is an observation for the matching gate, not automatically blocking.
- Malformed output, output about another work item, an unavailable reviewer at the moment of the call, or a reviewer that changed files: no valid result. `BLOCKED — NO VERDICT`.

### 11. Check the integrity of the review process

Repeat `git status --short -uall`, `git diff` and `git diff --cached` and compare with the baseline of step 7, comparing the contents of `git diff` and not only the paths. Untracked files listed before count as pre-existing. A content change of such a file is invisible to this comparison, so the reviewer's read-only rule is what guards it. Normal transient output of established read-only tooling is fine if the project conventions allow it and it touches no implementation or source-of-truth artifact.

If the review or a check changed source, tests, fixtures, snapshots, manifests, lockfiles, migrations, configuration, specs, context, docs or framework files, integrity is broken. Do not silently revert anything and do not issue a PASS on that run. No independent concrete FAIL established: `BLOCKED — NO VERDICT`. A concrete blocking defect already independently established, with evidence that does not depend on the mutated state: FAIL may still be reported, together with the integrity issue and the incomplete review.

### 12. Give the result

**`FAIL`.** At least one substantive blocking defect was validly established. Route by root cause:

- for substantial work, an implementation or test-code defect: `/build-feature` → `/test-feature` → `/review-code`. Never skip `/test-feature`;
- the Tech Spec, the architecture or the requirements must change: the matching upstream chain (see "Next skills"). If that leaves the expected technical standard unresolved, it is `BLOCKED — NO VERDICT`, unless a concrete code defect stays valid regardless.

**A microchange fix after a FAIL.** For substantial work nothing is weakened: `/build-feature` → `/test-feature` → `/review-code`. For a microchange, determine professionally whether the fix is behaviour-affecting, meaning it materially changes, where relevant, observable behaviour, a public or integration contract, state or persistence behaviour, error behaviour, integration behaviour, required tests or verification-relevant configuration. With genuine doubt, treat it as behaviour-affecting.

- A clearly non-behaviour-affecting internal fix (a local refactor, a naming or structure cleanup, an equivalent code-quality correction) needs the relevant established checks, not a full `/test-feature` solely because code changed.
- A behaviour-affecting or uncertain fix needs the appropriate functional verification before `/review-code` can PASS again: proportional verification for a genuine microchange, or `/test-feature` when the change or its scope requires it.
- If a `/test-feature` PASS already exists for the microchange, whether it remains current is decided by `/test-feature`'s own version-specific rules, not by `/review-code`.

Then `/review-code` runs again.

**`BLOCKED — NO VERDICT`.** Valid review cannot be completed and no valid blocking defect exists: an unavailable reviewer; an unidentifiable work item or scope; an ambiguous or conflicting source; a `/test-feature` PASS that step 4 requires and that is absent, was a FAIL or BLOCKED, is not established or is invalidated; a changed source with incomplete or unknown gates; an ambiguous dirty state; a mandatory check that cannot run; unreadable required files; a legacy-issue relationship that matters and cannot be established; a reviewer or tool that mutated the implementation.

**`PASS`.** Only if: the target, one work item and the mode are right; the scope and current technical sources are clear; where step 4 requires it, a current `/test-feature` PASS is reliably established and not known to be invalidated; `code-reviewer` completed an independent review; the mandatory checks were completed; the implementation materially conforms to the Tech Spec, the architecture boundaries and the material conventions; no blocking finding is unresolved and unrelated legacy issues did not affect the verdict; and the repository integrity is preserved. Do not claim more than the gate gave: not security-approved, deployment-ready, architecture-approved or documented.

### 13. Report and stop

The result exists only in the conversation. Report the work item, the review scope, the checks run, and:

- **PASS:** the non-blocking observations, `PASS` as applying to the implementation as reviewed against the current approved technical sources and conventions, and the next step `/update-docs`, which works out what documentation the accepted code affects, possibly none.
- **FAIL:** the blocking findings with evidence and locations, the non-blocking observations, `FAIL`, the route by root cause and the rerun sequence.
- **BLOCKED:** the blocker, the review work completed, the scope left unreviewed, `BLOCKED — NO VERDICT` and the required next action.

For any result, list as observations only: any documentation impact noticed in passing (`/update-docs` decides what needs updating), security or infrastructure concerns for the matching later gate, and clearly unrelated existing issues. Then **stop**. Launch nothing.

## Hard limits

`/review-code` and `code-reviewer` do not:

- fix findings, not even one line, and do not modify source, tests, fixtures, snapshots, generated source, manifests, lockfiles, migrations, configuration, specs, project context, the target's `CLAUDE.md`, documentation, or framework files;
- run auto-fixers, write-mode formatters or generators, add lint or compiler configuration or review tooling, or add, upgrade or choose dependencies;
- rerun `/test-feature`, play another reviewer role or claim its results, or redesign requirements, architecture or the Tech Spec;
- review the whole repository or fail the work item for clearly unrelated existing code;
- imitate an unavailable `code-reviewer` or perform the independent review themselves;
- read or expose real secrets;
- launch `/update-docs`, `/build-feature`, `/test-feature` or any other skill;
- create framework entities, or hashes, approval registries, status files, persistent PASS metadata or persistent review reports;
- run `git add`, commit, stash, reset, checkout, restore, revert, clean, cherry-pick, merge, rebase or any other command that changes git state. Git is for inspection only.

Allowed: normal transient output of established read-only check tooling, and nothing else.

## Outputs

Conversation only. No implementation, source-of-truth or durable project artifact is created or modified. The report content is defined in step 13.

- **PASS:** the result, its scope statement and the next step `/update-docs`.
- **FAIL:** the blocking findings and the route: `/build-feature` → `/test-feature` → `/review-code`, or the upstream route when a source must change first.
- **BLOCKED:** the blocker, the reviewed and unreviewed scope and the required next action.

## Completion criteria

**Correct PASS completion:** the target and one work item are established in the right mode; the sources were read and the scope established; where step 4 requires it, a current `/test-feature` PASS is reliably established; `code-reviewer` was available and completed an independent review, with the mandatory checks; there is no blocking finding; the repository integrity is preserved; `PASS` was reported and `/update-docs` suggested, not launched.

**Correct FAIL completion:** independent review validly established at least one evidence-backed blocking defect in the work item (or code it materially depends on); no self-fix occurred; the route by root cause and the rerun sequence were given.

**Correct BLOCKED completion:** valid review could not be completed, no unsupported PASS or FAIL was invented, the blocker and the reviewed and unreviewed scope were reported, and the recovery route was given.

In every case no git state was changed, the implementation and specs were not modified, and no framework entity or tracking artifact appeared. A correctly executed run is not the same as a PASS of the quality gate.

## Next skills

- `/review-code` PASS → `/update-docs`, for substantial work and for a microchange alike. `/review-code` does not decide whether documentation or context impact exists. `/update-docs` decides, and may conclude that nothing needs to change.
- An implementation, code-quality or test-code defect → FAIL → `/build-feature` → `/test-feature` → `/review-code`. For a microchange, the fix rule of step 12 decides how much functional re-verification precedes `/review-code`.
- A required `/test-feature` PASS (substantial work, or a microchange that went through `/test-feature`) is absent, was a FAIL or BLOCKED, is not established or is invalidated → `BLOCKED — NO VERDICT` → the appropriate correction → `/test-feature` → `/review-code`.
- A relevant source changed, its gates not reliably established → `BLOCKED — NO VERDICT` → complete or confirm the gates → `/test-feature` where its PASS was invalidated → `/review-code`.
- A relevant source changed, its gates reliably complete, the implementation applicable, `/test-feature` current where required → `/review-code`. No `/build-feature` merely because a source changed.
- A source change that needs an implementation update → the source workflow → `/build-feature` → `/test-feature` → `/review-code`.
- The Tech Spec must change → `/tech-spec` → `/review-spec` → `/build-feature` → `/test-feature` → `/review-code`.
- The architecture must change → `/architecture` → the required architecture review → `/tech-spec` → `/review-spec` → `/build-feature` → `/test-feature` → `/review-code`.
- The requirements must change → `/product-spec` or `/new-feature-spec` → `/review-spec` → `/architecture` if needed → `/tech-spec` → `/review-spec` → `/build-feature` → `/test-feature` → `/review-code`.
- `code-reviewer` unavailable, or a mandatory project check unavailable → `BLOCKED — NO VERDICT` → resolve the prerequisite → `/review-code`.
- An ambiguous dirty state or scope → resolve it with the user → `/review-code`.
- An unrelated existing code issue, documentation impact, or a security or infrastructure observation → reported only. No `/build-feature` for unrelated cleanup.
- Nothing implemented → `/build-feature`. Framework structure missing → `/init-project`.

After any fix or resolved blocker, the whole applicable `/review-code` run repeats. No next skill is ever launched automatically.
