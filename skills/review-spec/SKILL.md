---
name: review-spec
description: The mandatory PASS/FAIL quality gate for one specification: a Product Spec, a Feature Spec or a Tech Spec. Identifies the target, checks prerequisites, hands the spec to the matching independent reviewer-agent, validates its output and returns an unambiguous PASS or FAIL with concrete blocking findings. Read-only: it never writes, fixes or approves anything on its own. Run it after /product-spec, /new-feature-spec or /tech-spec, and again after every substantive change.
---

# review-spec

## Purpose

`/review-spec` is the mandatory independent quality gate for specifications. Nothing moves on to the next significant stage until the spec feeding that stage has passed here.

It reviews **exactly one** spec per run:

- Product Specification: `.claude/product/product-spec.md`
- Feature Specification: `.claude/work/<feature-name>/feature-spec.md`
- Tech Specification: `.claude/work/<feature-name>/tech-spec.md`

It identifies the target and its type, checks the prerequisites, hands the spec to the matching independent reviewer-agent, validates the reviewer's output and integrity, returns the outcome and stops. It never creates, rewrites, fixes or approves a spec itself. The reviewer is independent of whoever wrote the spec: "I wrote it, I fixed it, I gave myself a PASS" is the loop this gate exists to break.

The outcome is `PASS`, `FAIL`, or no verdict when the review could not validly take place (step 7 defines all three). A PASS belongs only to the version that was reviewed. Nothing is launched automatically.

## When to use

- After `/product-spec`, `/new-feature-spec` or `/tech-spec` created or substantially updated a spec.
- After the findings of a previous FAIL were fixed, before moving on.
- When a spec changed after its PASS, or when it cannot be established whether the current version ever passed.

## When not to use

- The current directory is the **ai-dev-framework repository itself**. It is the source of the framework, not a target. If the root contains the framework's own `skills/` folder, stop and ask which project the user means.
- The framework structure created by `/init-project` is missing. Stop without a verdict, say what is missing and suggest `/init-project` (step 2).
- The user wants a spec written, changed or fixed: `/product-spec`, `/new-feature-spec` or `/tech-spec`. This skill only judges.
- The user wants several specs reviewed at once. One spec per run: ask which goes first.
- The target lives in `.claude/work/completed/`. A finished work item is not an active gate, unless the user explicitly asks to review it.
- The user wants a finished implementation checked against the product goal (`/review-spec` never calls `product-reviewer`), code reviewed (`/review-code`) or a finished feature tested (`/test-feature`).

## Inputs

- **Target project root.** Default: the current working directory. Confirm it if there is any doubt.
- **The target spec.** Named by the user, or unambiguously determined from the current work item or context. Never guessed.
- **The framework structure in the target project**, created by `/init-project`: root `CLAUDE.md`, `.claude/skills/project-context/SKILL.md`, `.claude/skills/project-context/context/product.md`, `.claude/product/product-spec.md` and `.claude/work/`. All are required.
- **The installed specification template** for the target's type. It lives under `%USERPROFILE%\.claude\ai-dev-framework\templates\`: `product-spec.md` for a Product Spec, `work\feature-spec.md` for a Feature Spec, `work\tech-spec.md` for a Tech Spec. Do not look for it by other means.
- **The reviewer-agent** for the target's type, as provided by the current installation.

The mapping is fixed:

| Target | Location | Reviewer-agent | Template needed |
|--------|----------|----------------|-----------------|
| Product Spec | `.claude/product/product-spec.md` | `requirements-reviewer` | Product Specification template |
| Feature Spec | `.claude/work/<feature-name>/feature-spec.md` | `requirements-reviewer` | Feature Specification template |
| Tech Spec | `.claude/work/<feature-name>/tech-spec.md` | `tech-spec-reviewer` | Tech Specification template |

One reviewer-agent per spec. Several on the same spec only under a separate framework rule.

## Files to read

Read before calling the reviewer. All reads are read-only. The reviewer gets the same context, not more. The one exception is an explicitly defined post-PASS routing-only read, below: it happens only after a valid PASS and is never handed to the reviewer. Follow the router and do not load everything.

Always: the root `CLAUDE.md`, `.claude/skills/project-context/SKILL.md` (the router), the target spec and the installed template for its type. Then, per type:

- **Product Spec:** `product.md`. Other product-level material (README, product documentation, the observable behaviour of an existing product) only where the review really needs it, in the smallest amount. No technical audit.
- **Feature Spec:** `.claude/product/product-spec.md` and `product.md`. Relevant documentation, current observable behaviour and related current or completed specs only when needed. A Feature Spec review is not a code review. After a PASS, only to route (see "Next skills"), the current `architecture.md`, read-only. It is not handed to the reviewer.
- **Tech Spec:** the applicable upstream requirements spec (step 3); the Product Spec and `product.md` as far as the requirements need them; the CURRENT `architecture.md`, always; the relevant parts of `development.md` and `infrastructure.md`; `ux-guide.md` only if the UI or UX of the work item is relevant. Existing code, configuration, package, build and test files and API or schema definitions only as far as needed to judge whether the Tech Spec fits the existing project. This is not a code audit.

Never read real `.env` files, credentials or secrets.

## Execution steps

### 1. Identify the target and its type

The target is named by the user or unambiguously determined from the current work item or context. Do not guess. If several specs are possible: show the candidates in a few lines, ask which one to review and do not start until the user answers. Never review several in one go. A target in `.claude/work/completed/` is not used as an active gate without the user's explicit request.

Determine the type from purpose and location, as in the mapping table. If the location is unexpected or the type ambiguous, ask the user or stop and explain. Do not invent a new specification type.

### 2. Check that the review can take place

**Process problem.** If a prerequisite fails, the template or the reviewer is unavailable, or the reviewer's output cannot be validly accepted (step 6), the review did not validly take place. There is **no verdict**: no PASS and no FAIL. A problem found before the reviewer is called means the reviewer is not called. Stop, report the blocker and the required next action, and do not count the review as done. A broken process is never a content FAIL. The one exception is a reviewer mutation together with an independently established FAIL (step 6). Everywhere in this skill, "no verdict" means this rule.

Verify that the working directory is a target project, not the framework repo, and that the base framework structure from "Inputs" exists. If any of it is missing: no verdict, say what is missing and suggest `/init-project`. Do not create the structure yourself and do not rebuild it from memory. Then verify that:

- the target spec exists, is not empty and is not a not-started or template-only stub, and its type is supported. If not, there is nothing to review: suggest the matching skill (`/product-spec`, `/new-feature-spec` or `/tech-spec`) and do not launch it;
- the installed template for the type is available and not empty, and the right reviewer-agent is available. If not, say that the framework installation needs fixing and what exactly is missing. Do not recreate the template from memory, do not invent your own review structure, do not imitate the reviewer or substitute another agent, do not create an agent and do not invent a verdict.

For a Feature Spec, the product context must be clear enough to review it: a substantive Product Spec or, if it is a not-started stub, existing project context that already defines the product clearly enough (the same rule as in `/new-feature-spec`). Do not fill the gaps with assumptions. If it is not clear enough: no verdict, suggest `/product-spec`. A FAIL is legitimate only when the review did take place and the reviewer concluded that the Feature Spec itself is insufficient.

### 3. Check the Tech Spec prerequisites (Tech Spec only)

None of this is added to a Product Spec or Feature Spec review. Everything here is checked **before** the `tech-spec-reviewer` is called. `/review-spec` only establishes what was already completed. It designs no architecture and takes no architecture decision.

**Reliably established.** A fact or PASS named in this step, except the feature-implementation workflow (which follows from the work-item folder, see below), counts as reliably established in exactly two cases:

1. the current conversation or workflow contains it for this very version, and there has been no substantive change since;
2. the user explicitly confirms it for this very version, and that there has been no substantive change since.

In every other case it is not established. Never infer it from a file existing, from a non-empty or hand-filled file, from the content of the Tech Spec, from git history, commits, timestamps, hashes, metadata, naming or comments, or from your own fresh analysis, and do not guess. If the conversation already establishes it, or nothing reliably shows a relevant substantive change, do not ask for a ritual confirmation. No status file, registry, hash, version tracking, approval field or report file.

**Workflow.** Establish which workflow the work item belongs to. Do not guess.

- **Feature implementation** on an existing product. The upstream requirements spec is `.claude/work/<feature-name>/feature-spec.md`. If the matching `feature-spec.md` exists in the same work-item folder as the target `tech-spec.md`, that is a sufficient structural basis, normally with no confirmation needed, and the absence of a confirmation is not a conflict. A missing Feature Spec is not a fallback to the Product Spec. If substantial existing-product work has no Feature Spec: no verdict, route to `/new-feature-spec` → `/review-spec` → `/tech-spec`.
- **Initial product implementation.** The upstream is `.claude/product/product-spec.md`, and a separate Feature Spec is not required. This is the only case where the Product Spec is the direct upstream of a Tech Spec. Without a matching Feature Spec it is reliably established only if the conversation or workflow explicitly shows that this Tech Spec was created as an initial product implementation, or the user explicitly confirms it. It is not evidenced by a missing Feature Spec, the name of the work item or its folder, the content of the Product Spec, or the Tech Spec merely existing. If it cannot be established, do not fall back to the Product Spec and do not guess. Ask the user if a short clarification is enough, otherwise stop with the prerequisite ambiguity and no verdict.
- **Workflow conflict.** The matching `feature-spec.md` exists, but the conversation or an explicit user statement directly says that this same work item is the initial product implementation. Neither side wins automatically: the structure does not override the statement, and the statement does not override the structure. Do not call the reviewer, give no verdict, show the contradiction briefly and ask which workflow is right, then continue with the matching upstream. A clarification that it is an initial product implementation counts as the explicit confirmation required above. Only an explicit statement to the opposite makes a conflict.

**Upstream requirements PASS.** The current version of the upstream requirements spec (the Feature Spec, or for an initial product the Product Spec) must have a `/review-spec` PASS, reliably established. If it is not: the reviewer is not called, no verdict, and the route is `/review-spec` on that upstream spec first. After it passes, the Tech Spec review can run again.

**Architecture path.** The current `architecture.md` must exist, because `/init-project` creates it. If it does not, the framework structure is incomplete: no verdict, `/init-project`. Establish which path applies. Do not classify it by a guess, and do not take an architecture decision to do it.

- **Initial product implementation.** The chain is always `/product-spec` → `/review-spec` PASS → `/architecture` → `architecture-reviewer` PASS → `/tech-spec` → `/review-spec`. All three must be established: the current Product Spec has a `/review-spec` PASS, the current agreed architecture went through `/architecture`, and the current substantive version of `architecture.md` has an `architecture-reviewer` PASS. A non-empty or hand-filled `architecture.md` proves none of it.
- **Feature Case A: no architecture change was clearly required.** The reviewed Feature Spec went straight to `/tech-spec`. Established only if the conversation or workflow shows that routing for the current reviewed Feature Spec, or the user explicitly confirms that for its current version the impact was determined as clearly not required and `/architecture` was not run. `/review-spec` does not decide again whether the change is "probably not needed". Real doubt means it is not Case A. No fresh `architecture-reviewer` PASS is needed for this feature.
- **Feature Case B: the impact was unclear, and `/architecture` found no substantial architecture change was required.** `/architecture` ran for the current reviewed Feature Spec and established "no substantial architecture change required". `architecture.md` was either left unchanged or received only a narrow factual sync with no new architecture decision, and the `architecture-reviewer` was not called. A changed `architecture.md` is not by itself evidence of Case C. Established only if the conversation or workflow contains that result for the current version of the Feature Spec, with no substantive change of it since, or the user explicitly confirms the same. An unchanged `architecture.md` or a missing architecture commit proves nothing. No fresh `architecture-reviewer` PASS is needed for this feature.
- **Feature Case C: `/architecture` created or substantively changed the architecture.** The current substantive version of `architecture.md` must have an `architecture-reviewer` PASS, established for this very version.

If the path or a required PASS is not established, including feature implementation where none of A, B or C can be established: do not pick a scenario, do not re-analyse the Feature Spec to make an architecture decision, do not call the reviewer. No verdict, explain the ambiguity, and route to `/architecture` (for an initial product, in the initial-architecture mode).

**Architecture changed after Case A or B.** Cases A and B exempt the feature from a fresh `architecture-reviewer` PASS only while the review relies on the existing agreed architecture. If the conversation, the workflow or an explicit user confirmation establishes that the current `architecture.md` was substantively changed after a valid Case A or B, the old case no longer suffices. The current substantive version then needs an `architecture-reviewer` PASS, established as above. If it is not: the reviewer is not called, no verdict, `/architecture`.

**Architecture context sufficiency.** The file existing does not make the architecture context sufficient. If `architecture.md` is a not-started or template-only stub, practically empty, so outdated that the relevant system boundaries cannot be determined safely, or lacks what a substantive review of this Tech Spec needs: do not reconstruct the architecture and do not let the spec review become a hidden `/architecture`. It is a prerequisite problem: the reviewer is not called, no verdict, `/architecture`. The exception: the work item is local, its relevant architectural boundaries and constraints are already unambiguous from the existing context, and the unfilled parts of `architecture.md` do not concern it. Then do not demand a fully filled `architecture.md` as a formality. This check takes no architecture decision.

### 4. Collect the context and take the baseline

Read what "Files to read" lists for this type of spec. For a Tech Spec, the current `architecture.md` is always part of that context.

Before calling the reviewer, in a git repository, record a read-only baseline with `git status --short -uall`, `git diff` and `git diff --cached`. All three, because a file that was already modified or staged before the review can still be changed by the reviewer. Do not require a clean working tree, and leave any changes the user already has untouched: they are not changes made by the review. Never stage, commit, reset, checkout, stash, revert or run any other command that changes git state. If the project is not a git repository, do not invent a filesystem snapshot, hashes or any other baseline mechanism.

### 5. Hand the spec to the reviewer

The detailed professional review criteria belong to the reviewer-agents: `requirements-reviewer` for Product and Feature Specs, `tech-spec-reviewer` for Tech Specs. Each takes them from its own agent definition. This skill carries no checklist of theirs. It owns the invariants of the gate:

- the spec is the right target of the right type, and its structure conforms to the installed template;
- source-of-truth boundaries hold. The Product Spec defines product-level behaviour, scope and requirements. The reviewed Feature Spec defines the requirements of one change and cannot quietly rewrite the Product Spec. The Tech Spec defines how the agreed requirements are implemented and cannot change them for the convenience of implementation. Code shows the current implementation, not automatically the intended behaviour. Project context is short durable context and must not become a competing requirements document. A contradiction between sources is a finding, not something to resolve quietly, and if resolving it needs the user, the finding says so. No source ledger and no `source:` tag;
- unresolved and open questions are explicit. Those that block the next stage are blocking findings, those that do not are acceptable for a PASS.

Type-specific invariants:

- **Product Spec.** It stays product-level and does not turn into technical design or an architecture document. A substantive contradiction with `product.md` is a finding and is not fixed here.
- **Feature Spec.** It describes one change and does not rewrite or hide a change of product-level truth. If the requested feature in fact needs one, the verdict is FAIL, the finding names the affected product-level decision, and the way to fix it is `/product-spec`.
- **Tech Spec.** It implements the upstream requirements and does not change them, and it introduces no undeclared substantial architecture change. It is reviewed against the CURRENT sources: the current reviewed upstream requirements, the current agreed architecture and the relevant current project facts. It is not assumed correct because it was once written under a valid prerequisite. If `architecture.md` changed substantively after the Tech Spec was written, the current architecture first has to satisfy step 3, and the reviewer then judges whether the Tech Spec still fits the CURRENT `architecture.md`. If it no longer does, that is a blocking finding and may be a FAIL. A changed architecture is not an automatic FAIL. `/review-spec` does not rewrite the Tech Spec.

Call the one reviewer-agent that the mapping assigns. Hand it:

- the target spec and its type, and the installed template;
- the context from step 4. For a Tech Spec that is the current Tech Spec, the current applicable upstream requirements, the current `architecture.md`, and the relevant durable project context and current project facts. The established workflow path (initial product, or Case A, B or C) may be passed as context. It is never passed as an instruction to give a PASS, and a scenario that was not reliably established is not passed at all and not chosen on the reviewer's behalf;
- the gate invariants above;
- the rules of its role: independent and read-only, no edits, no fixes, no replacement text, no new requirements, no design, product or architecture decisions, no widening of the scope, no staging or committing;
- the response contract.

Do not hand it your own opinion of the spec or a verdict to confirm.

**Response contract.** No numeric score. The reviewer returns at minimum: one `Verdict: PASS` or `Verdict: FAIL`; on FAIL, the blocking findings, each with the location or context, the issue, why it blocks and the required resolution; the unresolved items it considers acceptable for a PASS, if any; a short summary.

### 6. Check the reviewer's output and integrity

The skill does not vote on top of the reviewer and does not run a second review. It makes sure the review was done properly. Verify that the output concerns the right target spec, comes from the right reviewer-agent, contains one unambiguous PASS or FAIL and stays within the reviewer's role. Verify also that the reviewer changed no project file and no git state: in a git repository, repeat `git status --short -uall`, `git diff` and `git diff --cached` and compare the actual diff contents, not only the paths, with the baseline from step 4. Any difference is a change made during the review, apart from normal transient output of a safe established check. Changes the user already had are part of the baseline, and a clean tree is not required.

If the output is unsound, there is no verdict (step 2): with no unambiguous verdict, do not interpret the answer and do not make one up. If the reviewer contradicts the facts of the project or steps out of its role, do not fix the spec, do not substitute your own verdict and report the problem with its output.

**A reviewer that changed a project file or git state** broke the read-only rule, so integrity is broken. Do not hide it, do not reset or revert anything, do not repair the spec, and tell the user which unexpected changes were found. Such a run can never yield a PASS. Then decide whether a concrete FAIL had already been independently established:

- a concrete blocking defect of the spec, with evidence that does not depend on the mutation and that the mutation did not create: the FAIL may stand. Report it together with the integrity violation and the fact that the run is not valid for a PASS. After the defect is fixed and the unexpected changes are dealt with, the review runs again;
- no such defect (a PASS recommendation, malformed output, a finding that depends on the changed state, or no independent concrete defect): no verdict;
- it cannot be established whether the finding existed independently of the mutation: no verdict. Do not keep a FAIL by assumption.

The mutation itself is a process problem. It does not prove a defect of the spec.

### 7. Give the verdict, report and stop

A valid reviewer result is the verdict: reviewer PASS is `PASS`, reviewer FAIL is `FAIL`. Never turn one into the other on the strength of your own review.

- **`PASS`:** the spec has no blocking findings that stop it from being a safe basis for the next stage. It is clear, consistent and complete enough for its role. Open questions that remain are explicitly recorded and do not block. A neat-looking document or "most sections are filled" is not a PASS.
- **`FAIL`:** at least one concrete blocking defect of the reviewed spec that must be fixed before the next mandatory stage. Real uncertainty that stops the reviewer from judging whether the requirements or the design are correct is a FAIL when it is a defect of the spec, not a reason to assume.
- **No verdict:** the review could not validly complete (step 2).

No scores, percentages, ratings or grades, no `PASS WITH CONDITIONS`, and no severity framework unless the framework defines one separately.

A PASS belongs only to the version that was reviewed. Any substantive change after it needs a new `/review-spec`, and an old PASS is never assumed to cover a changed spec. If it cannot be reliably established that the current version already passed, treat it as not reviewed and run the review again. There is no persistent approval status: no status file, review registry, hash, approval field in the spec or report file kept to store a PASS.

**On FAIL**, show `FAIL` and the blocking findings. Each is concrete and actionable: where the problem is, what exactly is wrong, why it blocks the next stage, and what has to be clarified or fixed. If a finding needs a decision from the user, say so plainly, and do not present one wording of a requirement as the only correct one when the choice is theirs. Name the skill that usually fixes it, and say that `/review-spec` has to run again. Until a new review gives PASS, no move to the next mandatory stage. Do not fix the spec and do not launch the fixing skill.

**On PASS**, show `PASS`, say which spec passed and that the PASS applies to the reviewed version, list the unresolved or non-blocking items the reviewer noted, and name the next stage for this type (see "Next skills"), with a clause on what that stage does and why it follows. Launch nothing.

**On no verdict**, explain what went wrong and what has to be done. The review is not counted as done. The one exception is a reviewer mutation together with an independently established FAIL: report the FAIL together with the integrity violation.

The result exists only in the conversation. No report file. Then **stop**.

## Hard limits

`/review-spec` does not:

- write, edit or fix the reviewed spec or any requirements, or rewrite a technical design;
- change any project file as part of the review, including project context, the root `CLAUDE.md`, code, tests, documentation, infrastructure, templates and agents;
- make product or architecture decisions: it does not design or decide an architecture change, does not establish Case B or Case C, does not reconstruct architecture from code and does not change `architecture.md`. After a Feature Spec PASS it only applies the routing threshold of "Next skills", which is routing and not an architecture decision;
- issue a PASS without a valid reviewer result, imitate or substitute an unavailable reviewer, or create or change reviewer-agents;
- turn a process failure into a content FAIL, or invent a verdict when the process is broken;
- silently revert or repair a reviewer mutation;
- run `git add`, commit, reset, checkout, stash, revert or any other command that changes git state;
- create new specs, review report files, framework entities, or any approval, status, registry or hash tracking;
- launch `/product-spec`, `/new-feature-spec`, `/tech-spec`, `/architecture`, `/build-feature` or any other skill on its own.

At runtime it is entirely read-only. Its only output is the review result in the conversation.

## Outputs

The only output is in the conversation, as defined in step 7: the target spec and its type, the reviewer-agent, the outcome, the blocking findings on FAIL or the non-blocking items on PASS, and the next permitted step. On no verdict: the explanation of the problem and the action needed. No project file is created or changed.

## Completion criteria

`/review-spec` is done, as a review process, when all of these are true:

- exactly one target spec was determined unambiguously and its type identified;
- the framework structure, the target, the template and the right reviewer-agent were valid and available, and for a Tech Spec the prerequisites of step 3 were reliably established;
- the reviewer was called with the necessary and not excessive context, and its output is valid, refers to the right spec and contains one unambiguous `PASS` or `FAIL`;
- integrity was checked against the baseline: the reviewer changed nothing, this skill changed no project file or git state, changes the user already had are not counted, and a clean tree is not required;
- the correct outcome was reported: `PASS`, or `FAIL` with concrete actionable findings, or no verdict with the blocker and the required action, and a PASS was stated as applying only to the reviewed version;
- the next permitted step was named, and no skill was launched.

A reviewer mutation never counts as a completed review. Only an independently established FAIL may still be reported, together with the integrity violation.

## Next skills

After a **Product Spec** PASS:

- For a new project, normally `/architecture`.
- For an existing project, do not push `/architecture` if the architecture already exists and the current work does not require revising it. Name the next stage that fits the current task.

After a **Feature Spec** PASS, `/review-spec` itself applies a routing threshold, after the reviewer's verdict and not by the reviewer. It is routing, not an architecture decision: it needs no new architecture analysis, designs nothing and never asks the user to choose the next skill.

- `/tech-spec`, only if the reviewed Feature Spec, the current `architecture.md` and the already established project context make it clear that no substantial architecture change is required (Case A).
- `/architecture`, in every other case: the reviewed Feature Spec clearly indicates a substantial architecture impact, or the impact is unclear, or there is any real doubt, or `architecture.md` is empty, template-only, materially stale or does not define the relevant boundaries well enough to establish Case A safely. Real doubt means not Case A. Say briefly that the architecture impact needs analysis, and do not reconstruct the architecture or settle Case B or C here. `/architecture` determines the actual impact. If it makes a substantive architecture change, that is Case C: `architecture-reviewer` PASS, then `/tech-spec`. If it finds no substantial architecture change is required, that is Case B: continue with `/tech-spec`.

After a **Tech Spec** PASS: `/build-feature`.

After a **FAIL**: the authoring skill of the reviewed layer (`/product-spec`, `/new-feature-spec` or `/tech-spec`), then `/review-spec` again, without exception. A Feature Spec whose defect is a change of product-level truth goes to `/product-spec`.

After **no verdict**, fix the problem first, at its owner:

- missing framework structure: `/init-project`;
- a missing or stub spec: the matching authoring skill;
- substantial feature work on an existing product without a Feature Spec: `/new-feature-spec` → `/review-spec` → `/tech-spec`;
- an upstream requirements spec without an established PASS: `/review-spec` on that spec;
- requirements that have to change: the matching authoring skill;
- insufficient architecture context, an unclear architecture impact or path, or an architecture workflow or PASS that is not established: `/architecture`;
- a missing template or reviewer-agent: a fix of the framework installation;
- a Tech Spec whose workflow cannot be determined, or is in conflict: ask the user.

No next skill is ever launched automatically.
