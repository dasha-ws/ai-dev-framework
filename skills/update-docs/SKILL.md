---
name: update-docs
description: The documentation synchronization gate after /review-code, for one work item. Works out what documentation or durable project context must change because of the implementation that was actually accepted, updates only that, then has the independent docs-reviewer confirm it, including when the answer is that no documentation changes are required. For substantial work, and for a microchange that went through /review-code, it needs a reliably established current /review-code PASS, and a microchange never bypasses an earlier gate it actually went through. Once it is run at all, docs-reviewer is mandatory, microchanges included. It never edits code, tests, specs, product context or architecture decisions and never imitates the reviewer. Returns PASS, FAIL or BLOCKED — NO VERDICT. After PASS the next step is /deploy-check.
---

# update-docs

## Purpose

`/update-docs` synchronizes the durable project documentation with a work item that has already been implemented and accepted. It works on **one** work item and answers one question:

"What documentation or durable project context must change because of the implementation that was actually accepted?"

Impact is judged against the ACTUAL accepted implementation and its approved sources, not against what an old plan promised. The skill:

1. determines the documentation impact and the exact scope;
2. updates only the documentation that is really affected;
3. has the independent `docs-reviewer` review the result;
4. fixes documentation defects inside the allowed scope and reruns the review;
5. returns PASS, FAIL or BLOCKED.

`No documentation changes required.` is a complete, valid result of the impact analysis, not a skip and not an error. The `docs-reviewer` still has to confirm independently that the impact was handled correctly.

It is not a builder, a code or spec reviewer, or a deployment or security review. It does not decide product, architecture, UX, development-convention or infrastructure policy after the fact, and it does not rewrite specs to match the code.

**Roles.** The skill analyses the impact, writes the documentation and owns prerequisites, scope, source-of-truth boundaries, baseline, integrity, gate semantics and routing. `docs-reviewer` owns the detailed professional documentation-review criteria and the independent, read-only review. It is mandatory whenever `/update-docs` is actually run, for substantial work and for a microchange alike (proportional scope for a microchange). The skill never imitates it. No documentation is changed before its availability is established.

**Relation to `/review-code`.** For substantial work, and for a microchange that went through `/review-code`, a current `/review-code` PASS is a prerequisite. It says the accepted implementation has passed the earlier gates, which are not repeated here. It is not evidence that the documentation is current. For a microchange, a gate that was never invoked creates no prerequisite, and any earlier gate (`/test-feature` or `/review-code`) that was actually invoked must have a current PASS.

**Source of truth.**

- The actual accepted implementation: what really exists. Documentation describes accepted reality.
- Product and Feature requirements: the intended behaviour and product intent.
- The Tech Spec: the approved technical decisions, contracts, integrations, constraints.
- `architecture.md`: the agreed architecture. Its decisions are never adjusted to fit the code. The one exception is the status-only synchronization of step 7.
- Project context (`product.md`, `development.md`, `infrastructure.md`, `ux-guide.md`), used selectively and under the write rules of step 7.
- Existing documentation the project actually uses: README, API and integration docs, user, admin and operator docs, setup, development and deployment docs, runbooks, examples.
- Tests help to understand verified behaviour. They are not requirements merely because they exist.

**The three results.**

- **`PASS`.** The documentation impact was handled correctly: either the required documentation and context were updated and `docs-reviewer` passed, or `docs-reviewer` confirmed that no documentation changes were required. It does not mean that all repository docs are perfect, or that the work is deployment-ready or security-approved.
- **`FAIL`.** Independent review established concrete blocking documentation defects in this work item's documentation scope, and they remain unresolved. Not for a broken process or a missing prerequisite.
- **`BLOCKED — NO VERDICT`.** Valid synchronization or review cannot be completed. A broken process is not a FAIL.

**A PASS is version-specific.** It applies to the accepted implementation, the applicable approved sources and the documentation and context artifacts actually reviewed. An old PASS is no longer sufficient after a reliably known substantive change to the accepted implementation or an applicable source, where the documentation impact changes, or to a documentation or permitted context artifact that was in the reviewed scope. Unrelated documentation changes and normal transient tool output do not invalidate it. If the implementation or a source changes, the upstream gates come first, then `/update-docs` again. Chronology is never inferred from git timestamps, hashes or metadata, and nothing is recorded: no status file, hash or PASS registry.

**One work item per run.** The documentation scope may span several files if one work item really touches them. This is not a repository-wide documentation cleanup.

## When to use

- After a `/review-code` PASS for substantial work: reviewed requirements → architecture as applicable → reviewed Tech Spec → `/build-feature` → `/test-feature` PASS → `/review-code` PASS → `/update-docs`.
- For a real microchange, including one that was sent through `/review-code`. Its documentation impact may well be none.
- After a FAIL or BLOCKED cause was resolved, or after a reliably known change that voids an earlier PASS.

## When not to use

- The current directory is the **ai-dev-framework repository itself**. That repo is the source of the framework, not a target. If the root contains the framework's own `skills/` folder, stop and ask which project the user actually means.
- The framework structure created by `/init-project` is missing (step 1).
- Substantial work, or a microchange that went through `/review-code`, has no reliably established current `/review-code` PASS (step 3).
- A microchange for which `/test-feature` was actually invoked has no reliably established current `/test-feature` PASS (step 3).
- The user wants code, tests, specs or architecture changed, a product or convention decision made, implementation defects fixed, or a review of code, deployment or security.
- The request covers several unrelated work items.

## Inputs

- **Target project root.** Default: the current working directory. Confirm it if there is any doubt.
- **The work item.** Substantial work: `.claude/work/<work-item-name>/tech-spec.md` and its requirements (the Feature Spec, or the Product Spec for an initial product implementation). Microchange: the user's request and the actual accepted change.
- **The framework structure created by `/init-project`.** Substantial work: root `CLAUDE.md`, `.claude/skills/project-context/SKILL.md`, the files in `.claude/skills/project-context/context/`, `.claude/product/product-spec.md` and `.claude/work/`. Microchange: root `CLAUDE.md` and the router.
- **The accepted implementation** and the documentation and context the project actually has.
- **The current `/review-code` PASS** (substantial work, and a microchange that went through `/review-code`), and the current `/test-feature` PASS of a microchange for which `/test-feature` was actually invoked, established by the current conversation or workflow (step 3).
- **`docs-reviewer`**, as provided by the current installation. Agents are built after the skills, so it may not be installed yet (step 4).
- **The user**, for the few decisions only they can settle.

## Files to read

All reads are read-only. Never read real secret files merely for documentation. Read selectively, not the whole repository:

- **Substantial work:** the root `CLAUDE.md`; the router; the applicable requirements; the current Tech Spec; the relevant architecture and project context; the implementation files needed to understand the actual accepted behaviour; relevant tests where useful; the existing documentation that may be affected; the `/review-code` result, if the workflow has it.
- **Microchange:** the root `CLAUDE.md`, the router, and the minimum relevant subset of the change, its documentation and context.

## Execution steps

### 1. Confirm the target and the framework structure

Verify that the working directory is a target project, not the framework repo, and that the structure required for the mode exists (see "Inputs"). If it is missing: **stop with `BLOCKED — NO VERDICT`**, say what is missing and suggest `/init-project`. Do not create or rebuild it. Follow the target's root `CLAUDE.md` and documentation conventions. They cannot silently override a mandatory framework gate. If a project instruction directly conflicts with one, **stop**, report it and ask for a decision.

### 2. Decide the mode

**Spec-driven substantial work.** The accepted implementation has a Tech Spec and approved requirements and a `/review-code` PASS.

**Real microchange.** No artificial specs. The basis is the user's request, the actual accepted change, the current project docs and context and the project conventions. Scope and review are proportional. A gate that was never invoked for a microchange creates no prerequisite, and none is invented for it. If the current workflow actually invoked `/test-feature` or `/review-code` for it, each of them must have a current reliably established PASS (step 3).

If a "microchange" turns out to be substantial, **stop** and route to the normal workflow.

### 3. Check the `/review-code` PASS and the accepted implementation

**How gate state is established.** Whenever this skill depends on a previous gate state, above all a `/review-code` PASS, it counts as reliably established only through the current conversation or workflow, or an explicit user confirmation. Never infer it from git history, commits, timestamps, hashes, metadata, comments or file existence. If it cannot be established, it does not count. If the conversation already establishes it, do not ask for a ritual confirmation.

**Substantial work, and a microchange that went through `/review-code`.** A current `/review-code` PASS must be reliably established for the accepted implementation. It is not rerun here. If it is absent, was a FAIL or BLOCKED, is not established, or was invalidated by a relevant later change: `BLOCKED — NO VERDICT` → `/review-code` (or the appropriate upstream correction) → `/update-docs`. A microchange that never went through `/review-code` is not held to this, and `/review-code` is not required merely because `/test-feature` ran.

**A microchange and `/test-feature`.** If `/test-feature` was never invoked for the microchange, there is no prerequisite. If it was, a current reliably established `/test-feature` PASS is required, whether or not `/review-code` ran. If it was a FAIL or BLOCKED, is not reliably established, or was invalidated by a relevant later change: `BLOCKED — NO VERDICT` → the appropriate correction or re-verification → `/update-docs`. For example, a microchange with `/test-feature` PASS and no `/review-code` may go straight to `/update-docs`.

**A known change after the PASS.** If it is reliably known that the implementation, or an applicable source, changed substantively so that the PASS no longer relates to the current implementation (by the version-specific rules of `/review-code`), do not document the changed implementation as accepted: `BLOCKED — NO VERDICT` → the source workflow if a source changed → `/test-feature` where its PASS was invalidated → `/review-code` → `/update-docs` (for a microchange, only the gates that were actually invoked). Unrelated files and normal transient outputs do not invalidate it.

### 4. Check that `docs-reviewer` is available

Do this before any write. It is available only if it is installed and can actually be invoked in this session. If it is not: do not imitate it, do not substitute another agent, do not review the documentation yourself as if independent, and do not change any documentation. **Stop with `BLOCKED — NO VERDICT`**, name the missing reviewer and say it has to be provided before the gate can run. This holds for a microchange too.

### 5. Analyze the documentation impact and the scope

**Accepted implementation against the sources.** If the accepted implementation materially differs from the approved requirements, the Tech Spec or the architecture, do not document the deviation as new truth, and never use documentation to bypass an upstream gate: `BLOCKED — NO VERDICT`, routed upstream. Minor implementation details that the specs never fixed may be documented from the actual implementation. A stale target or planned status of an architecture that the accepted implementation now implements is a status-only synchronization (step 7). Any other divergence between the implementation and `architecture.md` is not a documentation task.

**Impact.** Decide whether something changed that existing or required documentation must reflect, for this work item, for example: user-visible behaviour; a public API or integration contract; setup or installation; configuration and environment variables (by name and purpose only); commands and development workflow; runtime or deployment operation; persistence or migration operational notes; permissions and roles; relevant error behaviour; examples; README usage; durable descriptive project-context facts. This is not an exhaustive checklist.

**Scope.** Derive it from the work item, the accepted implementation, the approved sources and the existing documentation and context. Git status and diff help to see the working state, but they are not approval metadata, and the accepted implementation may already be committed, so do not assume only the files in the diff matter. Resolve an ambiguous scope before writing. No broad search-and-replace without a bounded need.

**No impact.** `No documentation changes required` is valid when the implementation creates no user, developer, operator, integration or context impact, the existing docs remain correct and no durable descriptive context needs syncing. No token edit just to show activity. `docs-reviewer` is still invoked.

**New files.** Create a documentation file only if the project conventions call for a separate document, or the work item really needs documentation and no suitable existing location exists. If the location or naming is genuinely ambiguous, ask. Do not invent a documentation taxonomy.

**Pre-existing documentation.** Stale documentation introduced by this work item is in scope. A section materially affected by it is updated, with a minimal adjacent correction if needed to keep it coherent. Clearly unrelated stale documentation is a non-blocking observation: not fixed, and not a reason to FAIL. If the relevance cannot be separated and that prevents a valid update: `BLOCKED — NO VERDICT`.

### 6. Take the baseline and protect user changes

In a git repository, before any write, take a read-only baseline: `git status --short -uall`, `git diff` and `git diff --cached`, and record the untracked paths. It serves to tell pre-existing user changes from updates made by this skill. This is the initial skill baseline. It guards the write scope and the user's changes, and the reviewer baseline of step 9 is separate. A clean tree and a commit are not required, and an already committed implementation with an empty diff is normal. Create no hashes, baseline files or metadata. If the project is not a git repository, do not invent a substitute.

A dirty documentation file is not an automatic block. Preserve pre-existing user changes, and apply the required update if it can be done without overwriting or semantically undoing them. For a pre-existing untracked file, read it first and preserve its content. If the same section has conflicting pre-existing changes that cannot be safely separated: `BLOCKED — NO VERDICT`. Never overwrite the user's version, restore or discard it, or use `git checkout`, `reset` or `restore` to get a clean copy.

### 7. Update the documentation

Only after the prerequisites, the impact, the scope, the reviewer availability and the baseline are established.

**Writing rules.** Preserve the existing documentation style. Prefer minimal targeted edits, and do not rewrite whole documents for stylistic consistency. Do not invent features, commands, options, URLs, environment variables, API fields or behaviour. Verify facts against the accepted implementation and the current sources. Do not present future behaviour as current, and keep the project's own distinction between current and planned behaviour where it exists. Never include real secrets or credential values. Do not browse the web to fill project documentation. If genuinely needed external facts are missing, report that need instead of inventing them.

**Project-context write boundaries.** Context is not a way to change design decisions after the fact.

- `product.md`: not modified here. A change of product truth goes through `/product-spec`.
- `architecture.md`: read-only for architectural content and decisions. `/architecture` remains the only skill that creates or changes them: components, service boundaries, responsibilities, integrations, data flows, storage architecture, service or API relationships, architecture-level infrastructure topology, constraints and the target architecture itself. There is one narrow exception, a **status-only descriptive synchronization**: an architecture already approved through `/architecture` and described in the file as target, planned or not yet implemented may be re-described as implemented and current, using the file's existing wording and structure and adding no section or marker. It applies only if all of these hold: the architecture was already approved through the architecture workflow; the accepted implementation now implements that same architecture; no architectural decision needs to change; the change is only descriptive status; and the new wording is directly supported by the accepted implementation and the approved architecture. For example, `Target: service X uses PostgreSQL; not yet implemented` becomes `Current: service X uses PostgreSQL`, but only if that was already the approved architecture and the implementation really does it. Never allowed: changing a decision (PostgreSQL to Redis because the code uses Redis), adding a component the architecture never approved, changing responsibilities, boundaries, integration direction, topology or contracts, removing an approved component, inferring a new design from the code, or rewriting the target to rationalize drift. If the implementation differs materially from the approved architecture, or anything beyond status wording is needed, the exception does not apply: `BLOCKED — NO VERDICT` → `/architecture` → the downstream workflow as applicable → `/update-docs`. The implementation is evidence of what was built and never becomes approved architecture by itself. If the file already describes the implemented state correctly, it is not edited. `docs-reviewer` checks that such an edit is status-only, matches the accepted implementation and leaves the approved architecture unchanged.
- The target's root `CLAUDE.md` and the router `.claude/skills/project-context/SKILL.md`: a governing instruction file and the context router, not documentation output. They may be read and are never modified here. Descriptive commands, setup and runtime facts go into the appropriate permitted file, primarily `development.md` or `infrastructure.md`, within the boundaries below. If either is known to need a structural or governing change, report it as a project or framework maintenance issue instead of editing it.
- `ux-guide.md`: not rewritten to fit the implementation. Only a documentation-only clarification of an already approved direction that creates or changes no UX decision.
- `development.md`: only descriptive durable facts established by the accepted implementation or workflow (actual commands, local setup, the testing command, a tool or stack fact). No new or silently changed convention or policy.
- `infrastructure.md`: only descriptive durable runtime and infrastructure facts that are already approved or implemented (the actual runtime, the existing deployment mechanism, environment and configuration facts, the approved service topology). No new infrastructure decision. A design change goes upstream. The actual deployed state of a target after a real deployment (the paths, service identifiers, runtime and procedures confirmed on that target) belongs to `/deploy` and is not written here.
- The Product Spec, Feature Specs and Tech Specs are never modified. If a spec is materially wrong or stale, route to the matching upstream workflow.

**Generated documentation.** Follow the established mechanism. Do not hand-edit outputs that the project conventions mark as generated. Update the proper source if it is inside the documentation scope, and run the established generator only when it is safe and expected. Do not install a documentation generator, add a documentation platform or CI/CD, or change tooling. If a generator unexpectedly modifies production source, dependency files, specs or unrelated files, that is an integrity problem (step 11).

**Examples.** They must match the accepted behaviour. No real external side effect to produce an example. Prefer existing verified examples, local, test or sandbox evidence, or static examples derived from approved contracts. Never real credentials, customer data or production tokens.

**Questions to the user** only when necessary: the intended audience or a documentation policy, an ambiguous location with no convention, business wording the sources cannot give, an unresolved public commitment, a documentation decision that needs an owner. Not routine wording or style questions that existing docs can answer.

### 8. Prepare the documentation checks

Determine which documentation-quality checks the project already defines (a docs build, Markdown or docs lint, link validation, API or schema documentation validation, example validation, another established check), and which of them are mandatory. Do not invent or install documentation tooling. `docs-reviewer` runs the applicable established, safe checks. The skill does not run them itself, but verifies that the mandatory ones actually ran. An unavailable optional check is a reported limitation. A mandatory check that cannot run: `BLOCKED — NO VERDICT`. Normal transient output of documentation tooling is fine.

### 9. Run `docs-reviewer`

**The reviewer baseline.** Immediately before **every** `docs-reviewer` call, including a rerun after a correction (step 10), take a fresh read-only baseline with `git status --short -uall`, `git diff` and `git diff --cached`. It already contains this skill's own intended documentation and context edits, so those are never mistaken for a reviewer mutation. It does not replace the initial baseline of step 6, which keeps guarding the write scope and the user's changes. Create no files, hashes or persistent baseline metadata. If the project is not a git repository, do not invent a substitute.

After the update (or after the no-change conclusion), invoke `docs-reviewer`. It receives:

- the work item and the accepted implementation scope;
- the applicable approved sources;
- the documentation-impact analysis;
- the changed documentation files, or an explicit `no documentation changes required`;
- the relevant existing documentation and context, and the documentation conventions;
- the applicable project documentation checks, with the mandatory ones marked;
- the read-only boundaries.

Do not tell it which verdict to return. The reviewer is read-only: it edits no documentation, code, tests, specs or context, fixes nothing, and does not stage or commit.

Where relevant it assesses: correctness against the accepted implementation and the approved sources; completeness for the actual impact; stale contradictions caused or left by the work item; internal consistency; the right audience and scope; commands, examples and contracts matching reality; no invented behaviour; no secret exposure; the established documentation conventions. The detailed criteria are its own.

It returns, with no numeric score: the scope reviewed; the impact checked; the checks run; the blocking findings and non-blocking observations, with evidence and locations; the blockers; and a recommended `PASS`, `FAIL` or `BLOCKED`.

### 10. Correct and rerun

If `docs-reviewer` establishes a concrete documentation defect inside the allowed scope (a stale command, a missing configuration explanation, a wrong API example, documentation that contradicts the accepted behaviour, or documentation that the reviewer found missing after a no-change conclusion), fix the documentation without touching the implementation or the specs, and rerun `docs-reviewer` with a fresh reviewer baseline (step 9). Do not ask the user to fix an ordinary documentation defect that can be fixed safely.

Continue only while there is a concrete blocking finding, a safe correction exists inside the allowed documentation scope, and the loop is making meaningful progress. There is no numeric cap, but no indefinite looping either. The loop ends in one of two ways:

- **`FAIL`.** A concrete blocking documentation defect that `docs-reviewer` validly established, inside this skill's documentation scope, still exists. If the corrections stop making progress while it does, the result stays FAIL: unsuccessful correction attempts do not turn a concrete defect into BLOCKED.
- **`BLOCKED — NO VERDICT`.** Valid continuation needs something outside an in-scope documentation correction: a user decision, an upstream problem, insufficient or ambiguous sources, a process, prerequisite or integrity failure, or a correction that cannot be made safely without crossing ownership (code, specs, architecture decisions or the user's conflicting edits). Broken tooling, process or prerequisite is BLOCKED, never a documentation FAIL.

If a finding points to an implementation, requirements, Tech Spec or architecture problem (an accepted implementation that is wrong, or has drifted from the approved architecture or spec, included), or to an unresolved project decision, do not patch the documentation around it and do not report it as a documentation defect. Route upstream with `BLOCKED — NO VERDICT`.

### 11. Check the reviewer result and the integrity

The skill owns the final gate semantics. It does not relay a label blindly and does not run a second review. Verify that the result concerns the right work item and scope, comes from the valid reviewer, is backed by evidence, stays in the reviewer's domain and covers the mandatory checks. Then:

- A PASS with a mandatory check not run: `BLOCKED — NO VERDICT`. A FAIL because an optional tool is missing is not a documentation defect.
- A FAIL resting on subjective wording preference, or on clearly unrelated legacy documentation, is a non-blocking observation.
- A no-change conclusion needs the reviewer's independent confirmation. Without it there is no PASS.
- Malformed output, output about another work item, an unavailable reviewer at the moment of the call, or a reviewer that changed files: no valid result. `BLOCKED — NO VERDICT`.

**Integrity.** After every `docs-reviewer` call, repeat `git status --short -uall`, `git diff` and `git diff --cached` and compare with the reviewer baseline taken right before that call (step 9), comparing the contents of `git diff` and not only the paths. Any difference other than normal transient tool output is a change made during the review, not an edit of this skill. Then check the overall write scope against the initial baseline of step 6. Allowed: the intended documentation edits, permitted descriptive context edits, expected generated documentation outputs and normal transient tool output. Verify that the intended update is present, that pre-existing user changes are preserved, and that no production, test, dependency, migration, spec or framework file changed. A content change of a pre-existing untracked file is invisible to this comparison, so read it back where this skill edited it.

If the reviewer, a check or a tool changed anything during the review, or changed a disallowed file, integrity is broken, and a documentation or context file changed by the reviewer counts as much as any other. Do not silently revert anything and do not issue a PASS on that run. With no independent concrete documentation FAIL established: `BLOCKED — NO VERDICT`. A concrete documentation defect independently established, whose evidence does not depend on the mutation: FAIL may still be reported, together with the integrity issue and the incomplete run. Do not continue the correction loop past a reviewer mutation, or the next reviewer baseline would absorb it.

### 12. Give the result

**`PASS`.** Only if: the target, one work item and the mode are right; where step 3 requires it, the current `/review-code` and `/test-feature` PASSes are reliably established and not known to be invalidated; the impact was analysed and the exact scope identified; pre-existing user changes were preserved; the required documentation and context were updated, or a no-change conclusion was reached; `docs-reviewer` was available and completed an independent review, with the mandatory checks; no blocking documentation finding remains; only allowed files changed; and the integrity is preserved.

**`FAIL`.** A concrete blocking documentation defect, validly established by `docs-reviewer` inside the work item's documentation scope, remains unresolved, including when the correction loop could not resolve it. `/deploy-check` is not ready.

**`BLOCKED — NO VERDICT`.** Valid synchronization or review cannot be completed: a required `/review-code` or `/test-feature` PASS that is absent, was a FAIL or BLOCKED, is not established or is invalidated; an accepted implementation that conflicts with the approved sources, or an implementation, spec or architecture problem found while documenting; a scope that cannot be determined safely; a needed correction that is not a safe in-scope documentation edit (it needs a user decision, an upstream fix or crossing ownership); an unreadable required source; an unavailable `docs-reviewer`; a mandatory documentation check that cannot run; a documentation decision that needs an owner; a pre-existing user edit that conflicts with a required write and cannot be merged safely; a reviewer or tool that changed disallowed files; correct documentation that depends on an unresolved upstream decision.

### 13. Report and stop

The result exists in the conversation. The changed documentation files are the durable output. Report:

- **PASS:** the work item, the documentation impact, the files changed or `no documentation changes required`, the checks run, the `docs-reviewer` result, the non-blocking observations, `PASS`, and the next step `/deploy-check`, which checks release readiness and deploys nothing.
- **FAIL:** the blocking findings, the affected files and scope, the checks and reviewer result, what stays unresolved and the recovery route.
- **BLOCKED:** the blocker, the analysis, update and review work completed, what remains unresolved, `BLOCKED — NO VERDICT` and the required next action.

Unrelated stale documentation is reported as an observation. Then **stop**. Launch nothing.

## Hard limits

`/update-docs` and `docs-reviewer` do not:

- modify production code, tests, fixtures, snapshots, dependency manifests, lockfiles or migrations;
- modify the Product Spec, a Feature Spec or the Tech Spec, rewrite architecture decisions, or silently change product, UX, development or infrastructure policy;
- modify `product.md`, change architecture decisions or edit `architecture.md` beyond the status-only synchronization of step 7, or change the target's root `CLAUDE.md` or the project-context router;
- fix implementation defects, rerun `/build-feature`, `/test-feature` or `/review-code`, deploy, or perform a security or infrastructure review;
- imitate an unavailable `docs-reviewer`, or perform the independent review themselves;
- install documentation tooling, add a documentation platform or CI/CD;
- expose real secrets;
- launch `/deploy-check` or any other skill;
- create framework entities, or hashes, status files, PASS registries or persistent approval metadata;
- run `git add`, commit, stash, reset, checkout, restore, revert, clean, merge, rebase, cherry-pick or any other command that changes git state. Git is for inspection only.

The skill may modify only documentation artifacts in the established scope, permitted descriptive context facts under the rules of step 7 (`development.md`, `infrastructure.md`, a documentation-only clarification in `ux-guide.md`, and the status-only synchronization of an already approved architecture in `architecture.md`), and established generated documentation outputs.

## Outputs

The durable output is the changed documentation and permitted context files, or an explicit `no documentation changes required`. The report is conversation-only (step 13). Only normal transient output of documentation tooling may otherwise appear.

- **PASS:** the impact, the changed files or the no-change conclusion, the reviewer result and the next step `/deploy-check`.
- **FAIL:** the unresolved documentation findings and the recovery route.
- **BLOCKED:** the blocker, the completed and remaining work and the required next action.

## Completion criteria

**Correct PASS completion:** one work item and the right mode; the accepted implementation and approved sources established; where step 3 requires it, the current `/review-code` and `/test-feature` PASSes reliably established; the impact analysed and the scope identified; pre-existing user changes preserved; the required documentation updated or a no-change conclusion reached; `docs-reviewer` available and its independent review completed, with the mandatory checks; no blocking finding remains; only allowed files changed; the repository integrity is preserved; `PASS` reported and `/deploy-check` suggested, not launched.

**Correct FAIL completion:** a concrete blocking documentation defect was independently established in the documentation scope; no unsupported implementation, spec or source change was made; the findings were reported and `/deploy-check` is not treated as ready.

**Correct BLOCKED completion:** valid update or review could not be completed, no unsupported PASS or FAIL was invented, the blocker and the completed and remaining scope were reported, and the recovery route was given.

In every case no git state was changed and no framework entity or tracking artifact appeared. A correctly executed run is not the same as a PASS of the documentation gate.

## Next skills

- `/update-docs` PASS → `/deploy-check`. A no-change conclusion confirmed by `docs-reviewer` is a PASS too. Not launched automatically.
- A documentation defect inside the allowed scope → fix the documentation → rerun `docs-reviewer`. An unresolved FAIL → correct the documentation → `/update-docs` again.
- The `/review-code` PASS is absent, not established or invalidated → `BLOCKED — NO VERDICT` → `/review-code` → `/update-docs`.
- A microchange's actually invoked `/test-feature` has no current PASS (FAIL, BLOCKED, not established or invalidated) → `BLOCKED — NO VERDICT` → the appropriate correction or re-verification → `/update-docs`.
- The implementation changed after `/review-code` PASS → `/test-feature` where its PASS was invalidated → `/review-code` → `/update-docs`.
- An implementation defect found while documenting → not fixed here → `/build-feature` → `/test-feature` → `/review-code` → `/update-docs`.
- The requirements are wrong → the matching requirements workflow → downstream implementation, verification and review as needed → `/update-docs`.
- The Tech Spec is wrong → `/tech-spec` → `/review-spec` → `/build-feature` → `/test-feature` → `/review-code` → `/update-docs`.
- The architecture must change → `/architecture` → the required architecture review → `/tech-spec` → `/review-spec` → `/build-feature` → `/test-feature` → `/review-code` → `/update-docs`.
- `docs-reviewer` unavailable → `BLOCKED — NO VERDICT` → provide `docs-reviewer` → `/update-docs`.
- A mandatory documentation check unavailable → `BLOCKED — NO VERDICT` → resolve the prerequisite → `/update-docs`.
- A conflicting pre-existing user edit in the target documentation → `BLOCKED — NO VERDICT` → resolve it with the user → `/update-docs`.
- A change of product truth or UX direction → `/product-spec` or the matching upstream workflow, not this skill.
- Framework structure missing → `/init-project`.

After a resolved blocker or an upstream fix, the whole applicable `/update-docs` run repeats. A documentation correction inside a run only reruns `docs-reviewer` (step 10). No next skill is ever launched automatically.
