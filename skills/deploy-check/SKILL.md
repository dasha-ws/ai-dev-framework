---
name: deploy-check
description: The final independent readiness gate before deployment or release, for one work item and one deployment target. Hands the accepted work to the independent security-reviewer and infrastructure-reviewer, aggregates their results and returns PASS, FAIL or BLOCKED — NO VERDICT. It checks readiness and never deploys, publishes or releases anything. It needs a reliably established current /update-docs PASS, and both reviewers are mandatory whenever it is run, microchanges included. Read-only, so it never fixes findings. After PASS, `/deploy` can deliver the checked version to the checked target, as a separate step.
---

# deploy-check

## Purpose

`/deploy-check` is the final independent readiness gate before deployment or release. It checks **one** accepted work item against **one** intended deployment or release target and answers one question:

"Is this accepted work item ready to be deployed or released safely through the project's established delivery mechanism to the intended target?"

It checks readiness and does not deliver. PASS means ready, not deployed. Nothing is deployed, published or released, and nothing is launched automatically.

The review is done by the independent `security-reviewer` and `infrastructure-reviewer`. This skill owns the prerequisites, the target, the scope, the sources, the project-defined checks, safety, baseline and integrity, the aggregation of the two results, the gate semantics and the routing. It is not a builder, a code or documentation review, an architecture redesign, a penetration test or a full DevOps audit. It fixes nothing.

**Roles.** `security-reviewer` owns the detailed security criteria and `infrastructure-reviewer` the detailed infrastructure and deployment criteria. Each is independent and read-only. **Both** are mandatory whenever `/deploy-check` is actually run, for substantial work and for a microchange alike (proportional scope for a microchange). The skill never imitates either of them, and never substitutes another reviewer or a self-review.

**Relation to earlier gates.** Every actual run needs a current `/update-docs` PASS, microchanges included. `/update-docs` already handles microchanges and `no documentation changes required`, so this gate makes no exception. Earlier PASSes are not repeated here and are not evidence of readiness. As a defensive rule only, a gate that was actually invoked earlier (for a microchange, `/test-feature` or `/review-code`) and is reliably known to be a FAIL, BLOCKED, unresolved or invalidated is not ignored merely because an `/update-docs` PASS exists (step 4). A gate that was never invoked creates no prerequisite.

**Source of truth.**

- The accepted implementation, configuration and artifacts that would actually be delivered.
- Product and Feature requirements: the intended behaviour and relevant operational constraints. The Tech Spec: the approved design, dependencies, integrations, persistence, contracts and constraints.
- `architecture.md`: the agreed architecture and service boundaries. `development.md`: the established build and test commands and conventions.
- `infrastructure.md`: the descriptive runtime and deployment facts and the established delivery mechanism. It is not permission to invent infrastructure.
- Current documentation relevant to delivery (setup, operator, runbook, configuration). `ux-guide.md` only where a release has user-facing configuration or assets.
- Deployment and release artifacts, where present and relevant: Dockerfile or Compose, build and package configuration, service configuration, deployment scripts, existing infrastructure configuration, environment schema or example files, manifests, lockfiles, migrations, release configuration, existing CI/CD. Nothing is created because it is absent.
- Test and check results: evidence, not a replacement for the upstream gates.
- A material conflict between the accepted implementation and the approved sources is not normalized here: `BLOCKED — NO VERDICT` (or FAIL, if a concrete readiness defect is independently established), routed upstream. Architecture, the Tech Spec and infrastructure design are not redesigned here.

**The three results.** The final result belongs to the skill, not to either reviewer (step 12).

- **`PASS`.** Both reviewers completed valid independent reviews and passed, and the mandatory checks completed: ready to deploy or release through the established mechanism to the checked target. It does not mean deployed, that deployment will run automatically, that historical security or infrastructure debt is solved, that another target is covered, or that the product is ready for public launch unless that scope was assessed (step 6).
- **`FAIL`.** At least one reviewer validly established a concrete, evidence-based, actionable blocking readiness defect, relevant to this work item and target. For an applicable public launch, an unresolved declared `[before public launch]` open question, or a declared requirement that is not ready for that launch under step 6, that the skill itself establishes from the approved sources counts the same way.
- **`BLOCKED — NO VERDICT`.** Readiness cannot be determined and no concrete blocking defect is established. A broken process is not a FAIL.

Findings are of two kinds only: blocking findings and non-blocking observations. No scores.

**A PASS is version-specific and target-specific.** It applies to this work item, this target, the accepted implementation, the deployment and release artifacts actually checked, the approved sources and documentation used, and the target-environment conditions actually relied on. An old PASS is no longer sufficient after a reliably known substantive relevant change to the production implementation, deployment or release scripts or configuration, manifests or lockfiles that affect the delivered artifact, migrations, environment or configuration schema, build or package configuration, deployment documentation or runbooks, relevant architecture or infrastructure constraints, security-relevant configuration or policy, the intended target, or a target condition that was material evidence. Unrelated changes and normal transient build or check outputs do not invalidate it. Chronology is never inferred from git timestamps, hashes or metadata, and nothing is recorded: no hashes, approval registry, deployment status file or PASS metadata. A PASS covers public-launch prerequisites only if its report says they were assessed. A PASS that did not assess them does not cover a later public launch.

**One work item and one target per run.** A target is a production or staging environment, a particular server, a package or release channel, an artifact delivery target, or another established delivery target. Targets whose readiness materially differs are not merged into one gate.

## When to use

- After a `/update-docs` PASS for substantial work: reviewed requirements → architecture as applicable → reviewed Tech Spec → `/build-feature` → `/test-feature` PASS → `/review-code` PASS → `/update-docs` PASS → `/deploy-check`.
- For a real microchange that has a current `/update-docs` PASS. Scope is proportional.
- After a FAIL was fixed and the upstream gates rerun, after a BLOCKED cause was resolved, or after a reliably known change that voids an earlier PASS or moves to another target.

## When not to use

- The current directory is the **ai-dev-framework repository itself**. That repo is the source of the framework, not a target. If the root contains the framework's own `skills/` folder, stop and ask which project the user actually means.
- The framework structure created by `/init-project` is missing (step 1).
- There is no reliably established current `/update-docs` PASS, or the workflow reliably shows an earlier actually invoked gate that is a FAIL, BLOCKED, unresolved or invalidated (step 4).
- The user wants the deployment or release itself performed (that is `/deploy`), findings fixed, or infrastructure or CI/CD created or changed.
- The request covers several work items or several materially different targets.

## Inputs

- **Target project root.** Default: the current working directory. Confirm it if there is any doubt.
- **The work item.** Substantial work: `.claude/work/<work-item-name>/tech-spec.md` and its requirements. Microchange: the user's request and the actual accepted change.
- **The intended deployment or release target** (step 3).
- **The framework structure created by `/init-project`.** Substantial work: root `CLAUDE.md`, `.claude/skills/project-context/SKILL.md`, the files in `.claude/skills/project-context/context/`, `.claude/product/product-spec.md` and `.claude/work/`. Microchange: root `CLAUDE.md` and the router.
- **The accepted implementation** with its delivery artifacts, configuration and documentation.
- **The current `/update-docs` PASS**, established by the current conversation or workflow (step 4).
- **`security-reviewer` and `infrastructure-reviewer`**, as provided by the current installation. Agents are built after the skills, so they may not be installed yet (step 5).
- **A safe verification environment**, and the user for the few decisions only they can settle.

## Files to read

All reads are read-only. Never read real `.env` files, private keys or secret files to perform the gate. Read selectively, not the whole repository:

- **Substantial work:** the root `CLAUDE.md`; the router; `architecture.md`, `development.md` and `infrastructure.md` (`ux-guide.md` only if relevant); the applicable requirements where operational or security intent matters; the current Tech Spec; the accepted implementation relevant to delivery and security; the deployment and release artifacts, manifests, lockfiles and migrations; environment schema or example files; the deployment, operator, runbook and setup documentation; the `/update-docs` result, and the `/review-code` and `/test-feature` results where useful as context.
- **Microchange:** the root `CLAUDE.md`, the router, and the minimum relevant subset.
- **Public-launch prerequisites, in either mode:** the Product Specification and, if the work item has one, its Feature Specification, read only as step 6 describes.

## Execution steps

### 1. Confirm the target project and the framework structure

Verify that the working directory is a target project, not the framework repo, and that the structure required for the mode exists (see "Inputs"). If it is missing: **stop with `BLOCKED — NO VERDICT`**, say what is missing and suggest `/init-project`. Do not create or rebuild it. Follow the target's root `CLAUDE.md` and delivery conventions. They cannot silently override a mandatory framework gate. If a project instruction directly conflicts with one, **stop**, report it and ask for a decision.

### 2. Decide the mode

**Spec-driven substantial work.** The work item has a Tech Spec and approved requirements and has passed `/test-feature`, `/review-code` and `/update-docs`. **Real microchange.** No artificial specs. The basis is the user's request, the actual accepted change and the project conventions. Scope and review are proportional, but the `/update-docs` PASS and both reviewers are still required, and an earlier gate that the microchange actually went through is not bypassed (step 4). If a "microchange" turns out to be substantial, **stop** and route to the normal workflow.

### 3. Determine the work item and the deployment target

Exactly one work item. Exactly one target. If the project has one obvious target and the current workflow establishes it unambiguously, do not ask for a ritual confirmation. If several materially different targets are possible and the intended one cannot be reliably determined, ask the user. Never invent a target.

### 4. Check the `/update-docs` PASS

**How gate state is established.** Whenever this skill depends on a previous gate state, above all a `/update-docs` PASS, it counts as reliably established only through the current conversation or workflow, or an explicit user confirmation. Never infer it from git history, commit existence, timestamps, hashes, metadata, comments or file existence. If it cannot be established, it does not count. If the conversation already establishes it, do not ask for a ritual confirmation.

A current `/update-docs` PASS must be reliably established for every actual run. It is not rerun here. If it is absent, was a FAIL or BLOCKED, is not established or was invalidated: `BLOCKED — NO VERDICT` → `/update-docs` → `/deploy-check`.

**A known change after the PASS.** If it is reliably known that a relevant change invalidated an upstream gate or the documentation PASS, do not check a stale state: `BLOCKED — NO VERDICT` → the earliest applicable upstream workflow → the downstream gates → `/update-docs` → `/deploy-check`. The upstream skills' own version-specific rules decide what counts. Unrelated files and normal transient outputs do not invalidate the state.

**A contradictory chain.** A gate that was never invoked creates no prerequisite, and none is invented, a microchange included. But if the current workflow reliably shows that an earlier gate that was actually invoked (for a microchange, whichever of `/test-feature` and `/review-code` it went through) is currently a FAIL, BLOCKED, unresolved or invalidated, do not accept the chain merely because an `/update-docs` PASS exists: `BLOCKED — NO VERDICT` → the earliest such gate → the downstream gates → `/update-docs` → `/deploy-check`. A valid current `/update-docs` PASS normally already implies that started gates were respected, so this only guards a reliably known contradiction. It is not a workflow-history audit, and prior gates are not reconstructed.

### 5. Check that both reviewers are available

Do this before any expensive check. A reviewer is available only if it is installed and can actually be invoked in this session. If either `security-reviewer` or `infrastructure-reviewer` is not: do not imitate it, substitute another reviewer or review it yourself. **Stop with `BLOCKED — NO VERDICT`**, name the missing reviewer and say it has to be provided before the gate can run.

### 6. Establish the sources, the delivery mechanism and the project type

Read what "Files to read" lists. Establish the intended target, the existing delivery mechanism, what artifact or process would actually be delivered, and the environment constraints. Follow the existing project infrastructure and do not design a delivery system here.

Infrastructure minimalism applies: existing infrastructure → scripts and local automation → self-hosted automation → external managed service. Nothing like GitHub Actions, Vercel, Supabase, AWS, a managed database or third-party CI/CD is added merely to make delivery easier. An existing, approved use of such a service may be reviewed. An unapproved substantive infrastructure dependency found here is not silently accepted: route to the upstream design workflow.

Readiness adapts to the actual product and delivery model, and does not assume a web app:

- a web service, API or bot: runtime, process or container, configuration, service dependencies, startup and health, persistence and migrations as applicable;
- a static frontend: the build artifact, hosting configuration and release mechanism;
- a library or package: the package artifact and existing publishing mechanism;
- a CLI, desktop or local tool: its established distribution mechanism.

**No delivery action.** If the work item has no deployment or release action, do not invent one. `No deployment/release action required for this work item` is a valid PASS, but only if both reviewers independently confirm that no delivery action or readiness work applies. Nothing else is launched.

**Public-launch prerequisites (an additional layer, only where declared).** Deployment readiness does not by itself mean public-launch readiness, and a `[before public launch]` line never blocks a run that is not an applicable public launch. What blocks a deployment under the rules above still does, with or without the marker.

- **Sources.** Read the Product Specification and, if the work item has one, its Feature Specification, only for lines marked `[before public launch]` and for an unambiguous legacy statement with the same meaning, such as "must be closed before public launch". The section decides what a marked line is: under `Constraints and dependencies` it is a known requirement, under `Open questions` an unresolved question. Product-wide truth comes from the Product Specification and feature-specific truth from the Feature Specification. Do not copy between them, do not scan other or completed Feature Specifications, do not search texts for "launch", "release" or "production", and do not rewrite or re-audit a spec. Nothing is added that no canonical source declares: no generic checklist, no privacy or compliance prerequisite because one is usually needed, and an untagged TODO, placeholder or open question is not a public-launch blocker. If no such line exists, this layer does not apply, no question is asked, and the report says none are declared.
- **Applicability.** An applicable public launch is a run that makes the product, or this work item's feature, available to its public users. Decide it from the user's explicit statement or an unambiguous project or release context, `infrastructure.md` included, never from the environment name, `production`, a VPS, a first deployment or internet accessibility. A line that itself limits its scope to something this run does not cover does not apply. If a declared line exists and the applicability that decides the result is unclear, ask the user and give no final result before the answer. Without an answer: `BLOCKED — NO VERDICT`. If the run is not an applicable public launch, the lines do not affect the result, and the report says they were not applicable or not assessed, never that the product is ready for public launch.
- **Marked open question, applicable public launch.** A blocker. Name the line. Do not answer it, rewrite the spec, invent the underlying requirement or draw a legal conclusion: for "it is not yet known whether X is required", the blocker is the unresolved question itself.
- **Marked requirement, applicable public launch.** It must be ready for that launch, in one of two ways. Either it is already satisfied independently of this delivery, or the checked accepted deliverable and the established delivery mechanism reliably establish that this delivery will satisfy it before the product or feature becomes available to public users, for example a document or asset contained in the checked release, or configuration or credential setup that the established `/deploy` procedure applies before public exposure. In the second case this skill checks the readiness of the deliverable and the mechanism only: it does not claim that the requirement is already live, it deploys nothing, and it never assumes that `/deploy` will fix a missing prerequisite. A prerequisite that has to exist independently before delivery and that the checked mechanism does not create, for example an external account or registration, must be established as existing before PASS. For a credential that the established `/deploy` onboarding handles before public exposure, the absence of the secret value in this check is not a blocker by itself, provided the need is known, the mechanism handles it before public exposure and no secret value is read or shown. If the mechanism does not handle a credential or setup that is really needed before public launch, it stays unresolved. Check only as far as the approved sources, the existing read-only inspection of the project and target state, and the checks the project already defines allow, and ask for no more evidence than that prerequisite needs. A user's word does not replace an observable check that the requirement or the project calls for: if it cannot run, the prerequisite is unresolved. A declarative fact that nothing here can check, for example that an external account exists, may be established by the user's explicit confirmation for this run, and the report says it is user-confirmed. Ready either way: not blocking. Explicitly not satisfied and not going to be satisfied by the checked delivery before public exposure: a blocker. Not establishable: ask the user if they can settle it, otherwise report it as an unresolved public-launch prerequisite. Unknown is never assumed ready. No evidence record is kept.
- **Boundaries.** This is a readiness check of declared requirements, not a legal or privacy audit. It decides nothing about whether a policy, consent, registration or any other obligation applies. The secret rules of this skill are unchanged: for credentials or external service setup only the safe inspection already allowed, such as the presence of a configuration name, never a value or a key.

### 7. Take the baseline

In a git repository, before the reviewers run, take a read-only baseline: `git status --short -uall`, `git diff` and `git diff --cached`. It serves to preserve user changes, identify what would be delivered and detect unexpected mutations. A clean tree and a commit are not required, and an already committed implementation with an empty diff is normal. If the project's own delivery rules require a clean, committed or tagged state that is not met, the reviewers report that as a concrete readiness problem. Commit history is never approval. Create no hashes, baseline files or metadata. If the project is not a git repository, do not invent a substitute.

A dirty tree does not block by itself. Changes of the work item may be the very artifact checked. Clearly unrelated user changes are preserved. If unrelated or pre-existing changes materially contaminate the artifact, so that it is unclear what would actually be delivered: `BLOCKED — NO VERDICT`. Never stash, reset, checkout, restore, clean, commit or otherwise discard or modify the user's changes.

### 8. Prepare the readiness checks and the safety boundaries

**Project-defined checks.** Determine from `CLAUDE.md`, `development.md`, `infrastructure.md`, the project configuration and its scripts which readiness checks already exist and which are mandatory, where applicable: a production or package build, a Docker build, Compose or configuration validation, release-relevant type or compile validation, a local or test startup or smoke check, package validation, a local or test migration validation or dry-run, environment or configuration schema validation, existing security scanning and dependency checks. Do not invent or install tooling. The reviewers run the applicable safe checks. The skill verifies that the mandatory ones actually completed. An unavailable optional check is a reported limitation. A mandatory check that cannot run: `BLOCKED — NO VERDICT`. A current result produced in this run may be shared as evidence to avoid ritual reruns, and the judgments stay independent.

**Bootstrap.** Installing dependencies the project **already declares** is allowed only if an established check needs it, through the project's own mechanism in locked or frozen form, with no package added or upgraded, no manifest, lockfile or source file intentionally changed, and no global install (unless the project requires it and it is safe). Never install scanners, deployment CLIs, cloud tooling, package managers or CI agents for this gate. An unexpected change of tracked files is an integrity problem (step 11).

**Transient artifacts.** Established checks may create normal transient local artifacts (build or dist output, a compiled package, a local image or cache, validation reports, local temporary runtime files, safe local container or process state) when the project mechanism expects them. They are not durable framework output. Stop the local processes and containers that a check started, where practical.

**Live systems.** Default to local, test, sandbox or read-only evidence. Never mutate a production environment, a shared production database, live queues, customer data, live third-party integrations or real accounts. No active security testing against live or external targets by default. A read-only external check is allowed only if the project already defines it, it is genuinely needed and safe, and the required authorization is established. If a mandatory readiness fact cannot be established safely without live access or authorization: `BLOCKED — NO VERDICT`. Do not bypass the check.

**Secrets.** Never ask the user to paste secret values, and never print, log or expose tokens, passwords, private keys, connection strings with credentials, API secrets or secret values. Reasoning about required secret or configuration names, and a safe project-defined presence check, is fine. A required secret or configuration that is concretely known to be missing may be a blocking finding. If its state cannot be established safely: `BLOCKED — NO VERDICT`.

**Migrations and data.** Inspect the migrations and use safe local or test validation or a dry-run where the project supports it. Never apply a migration to a production or shared database, mutate customer data, or roll back destructively on shared data. A migration that cannot be shown safe enough for the target is a blocking readiness issue, or `BLOCKED — NO VERDICT` if the evidence cannot be obtained.

### 9. Scope and boundaries of the reviews

The reviewers own the detailed criteria. The skill hands them the scope and these boundaries. This is not a penetration test, a product-wide threat model or an audit of historical debt.

**Security concerns, where relevant:** secret handling and exposure; auth and access boundaries relevant to the change; unsafe configuration and defaults; obvious injection, execution or exposure risks; dependency and security checks the project already established; transport, storage and security configuration; dangerous deployment permissions or capabilities; release-artifact exposure; direct security regressions in the reviewed scope.

**Infrastructure concerns, where relevant:** build, package and container readiness; startup and runtime configuration; environment and configuration requirements; service and integration dependencies; migration and data-safety readiness; target compatibility; consistency with the deployment mechanism; health and readiness checks where the project uses them; observability and operational requirements where actually established; a proportionate recovery path.

**Proportionality.** No enterprise infrastructure rituals for a simple project. A recovery path is required in proportion to the deployment risk: restoring the previous artifact, container or version can be enough for a simple stateless service. Do not invent blue/green deployment, Kubernetes, multi-region failover, feature flags or complex backup systems without an approved need. If project policy or the work item's risk requires recovery and none exists, that may be a blocking infrastructure finding. Do not FAIL a simple bot for lacking heavyweight rollback machinery.

**Pre-existing issues.** An issue introduced or materially worsened by the work item may be blocking. An issue in shared or existing code or infrastructure that the current deployment materially depends on, so that it cannot be safely accepted, may be blocking, with evidence. A clearly pre-existing, unrelated issue is a non-blocking observation. If the relationship cannot be established and that prevents a valid decision: `BLOCKED — NO VERDICT`. No repository or infrastructure cleanup here.

**Findings** are concrete, evidence-based, relevant to the work item and target, and actionable. A reviewer's preference for another hosting, cloud or security stack is not a finding.

**Questions to the user** only when necessary: an ambiguous target, an authorization for an external read-only check, a real business or operational constraint, an infrastructure or security decision that needs an owner, a delivery policy or window that the project makes part of readiness, whether the run is an applicable public launch when a declared public-launch prerequisite exists and the answer decides the result, or an inaccessible required environment. Not questions the reviewers can resolve from the sources, and not about which cloud, CI/CD, Docker or Kubernetes to use unless that is an actual unresolved upstream decision.

### 10. Run both reviewers

After the prerequisites, target, sources, baseline and applicable checks are established, invoke **both** reviewers. Each receives:

- the work item and the target;
- the accepted implementation and the delivery scope;
- the approved technical sources and the architecture, infrastructure and development context;
- the existing delivery mechanism, the relevant documentation and runbooks, and the deployment and release artifacts, configuration, manifests and migrations as relevant;
- the applicable project-defined checks, with the mandatory ones marked, and any current evidence from this run;
- the known constraints and the read-only and safety boundaries.

Neither is told which verdict to return, or that the other passed. Each is read-only: it edits no code, configuration, documentation or specs, fixes nothing, installs no tools, provisions nothing, does not deploy or release, does not stage or commit, and does not redesign architecture or requirements or widen the scope.

Each returns, with no numeric score: the work item and target reviewed; the scope and artifacts inspected; the checks run; the blocking findings and the non-blocking observations, with evidence and locations; the blockers and limitations; and a recommended `PASS`, `FAIL` or `BLOCKED`.

### 11. Check the reviewer results and the integrity

The skill does not relay labels blindly and does not run a second review. Verify for each result: the right work item and target, the reviewer's own domain, a relevant scope, evidence for every blocking finding, the mandatory checks completed, and read-only behaviour. Then:

- A missing mandatory check: `BLOCKED — NO VERDICT`. An unavailable optional check is a limitation, not a FAIL.
- A subjective preference for another hosting, cloud or security stack is not a FAIL.
- A concrete unsafe secret exposure, a broken deployment artifact or an unsafe required migration may be a FAIL. An obvious security defect of this work item may FAIL.
- An unrelated legacy issue is an observation, unless it makes this deployment unsafe.
- Malformed or wrong-scope output: `BLOCKED — NO VERDICT` for that reviewer, unless the other reviewer already established a valid concrete FAIL.
- The same underlying issue reported by both reviewers is one defect. Merge the reports and keep who identified it. Security judgement stays with `security-reviewer`, infrastructure and deployment judgement with `infrastructure-reviewer`.

**Integrity.** Repeat `git status --short -uall`, `git diff` and `git diff --cached` and compare with the baseline of step 7, comparing the contents of `git diff` and not only the paths. Allowed: expected transient build and check outputs, safe local runtime or container artifacts, expected caches and reports. If a reviewer, check or tool changed production source, tests, fixtures, manifests, lockfiles, migrations, deployment configuration, specs, context, docs or framework files, or git state, integrity is broken. Do not silently revert anything. A content change of a pre-existing untracked file is invisible to this comparison, so the reviewers' read-only rule guards it. With no concrete blocking defect independently established: `BLOCKED — NO VERDICT`. A concrete blocking defect already independently established and valid regardless of the mutation: FAIL may still be reported, with the integrity failure and the incomplete review.

### 12. Aggregate and give the result

- **`PASS`.** Only if: one work item and one target; a current `/update-docs` PASS reliably established and not known to be invalidated, and no earlier actually invoked gate known to be a FAIL, BLOCKED, unresolved or invalidated; the delivery mechanism established; both reviewers available and passed after valid independent reviews; the mandatory checks completed; no unresolved blocking finding; the delivery artifacts and configuration consistent with the approved sources; unrelated legacy issues did not affect the verdict; the repository integrity preserved; no prohibited external side effect; for an applicable public launch, no unresolved marked open question and every applicable marked requirement established as ready for the launch, either already satisfied or reliably satisfied by the checked delivery before public exposure (step 6).
- **`FAIL`.** At least one reviewer validly established a concrete blocking defect, or the skill itself established, from the approved sources, an unresolved marked open question, or a marked requirement of an applicable public launch that is explicitly unsatisfied and that the checked delivery will not satisfy before public exposure (step 6). If the other reviewer passed, the result is FAIL. If the other reviewer is BLOCKED or incomplete, the result is still FAIL, because a known defect is not hidden behind BLOCKED: report the defect, the incomplete review, and that the whole applicable `/deploy-check` reruns after the defect and the blocker are resolved.
- **`BLOCKED — NO VERDICT`.** No concrete blocking defect is validly established, but one or both reviewers or mandatory checks cannot complete: an absent `/update-docs` PASS, a reliably known contradictory chain, an unresolved target, an unavailable reviewer, a mandatory check, required evidence or authorization that is unavailable, conflicting sources, an ambiguous deployable artifact, invalid reviewer output, an unexpected mutation, an unresolved upstream decision, a declared public-launch prerequisite or the applicability of the launch that cannot be established. One PASS and one BLOCKED is BLOCKED.

### 13. Report and stop

The result exists only in the conversation. Report the work item, the target, the delivery mechanism, the checks run, the result of each reviewer, and:

- **PASS:** the non-blocking observations, `PASS`, and the readiness statement `Ready to deploy/release through the project's established mechanism to the checked target`. State explicitly that **no deployment or release was performed**. The next step is `/deploy`, which delivers the checked version to the checked target and is run separately by the user. Never launched automatically. State the public-launch scope: that no public-launch prerequisites are declared, or that the declared ones were not applicable and not assessed for this run (never "ready for public launch"), or, for an applicable public launch, that the declared prerequisites in the canonical specs do not block it, naming any that this delivery is to satisfy as such and not as already live. That is no claim of legal or compliance readiness.
- **FAIL:** the blocking findings with evidence, for a public-launch blocker the canonical line and what remains unresolved or unsatisfied, the affected artifacts and who identified them, the non-blocking observations, any incomplete review, `FAIL` and the recovery route.
- **BLOCKED:** the blocker (a public-launch prerequisite or applicability that could not be established included), the completed checks and reviews, the unchecked scope, `BLOCKED — NO VERDICT` and the required next action.

Then **stop**. Launch nothing.

## Hard limits

`/deploy-check`, `security-reviewer` and `infrastructure-reviewer` do not:

- fix findings, or modify production code, tests, fixtures, snapshots, manifests, lockfiles, migrations, application, deployment or infrastructure configuration, specs, project context, documentation or framework files;
- deploy, publish, release, upload artifacts, push images to a registry, create tags or releases, provision infrastructure, change DNS or cloud or server resources, restart production services, apply production configuration, rotate credentials, send production traffic or promote staging to production;
- apply production or shared migrations, or touch customer data unnecessarily;
- create CI/CD or infrastructure, or install or add tooling or dependencies;
- run active security attacks or scans against live targets without an explicitly authorized process;
- expose secrets;
- imitate an unavailable reviewer, or perform the independent reviews themselves;
- launch any skill automatically;
- create tracking, status or PASS artifacts, or hashes;
- run `git add`, commit, stash, reset, checkout, restore, revert, clean or any other command that changes git state. Git is for inspection only.

## Outputs

Conversation only. No durable project artifact is intentionally created or modified. Only normal transient local check, build and runtime outputs may appear. The report content is defined in step 13.

- **PASS:** the readiness statement for the checked target, the reviewer results, and the explicit statement that nothing was deployed.
- **FAIL:** the blocking findings and the recovery route.
- **BLOCKED:** the blocker, the completed and unchecked scope and the required next action.

## Completion criteria

**Correct PASS completion:** one work item and one target; a current `/update-docs` PASS reliably established; the sources and state established; both mandatory reviewers available and their valid independent reviews completed; the mandatory checks completed; no unresolved blocking finding; the repository integrity preserved; no prohibited deployment or external mutation; for an applicable public launch, the declared public-launch prerequisites checked and none blocking; `PASS` reported with the readiness statement, the public-launch scope stated, and without performing any deployment.

**Correct FAIL completion:** at least one evidence-backed blocking readiness finding, relevant to the work item and target; no self-fix; any incomplete second review reported; the recovery route given; no deployment performed.

**Correct BLOCKED completion:** no unsupported PASS or FAIL invented; the blocker identified; the completed and remaining scope reported; the recovery route given; no deployment performed.

In every case no git state was changed and no framework entity or tracking artifact appeared. A correctly executed run is not the same as a PASS of the readiness gate.

## Next skills

Delivery itself belongs to `/deploy`, a separate step. Nothing here is executed automatically.

- `/deploy-check` PASS → `/deploy`, as a separate step. `No deployment/release action required` → PASS → stop.
- A declared `[before public launch]` open question remains unresolved, or a declared requirement is not ready for the launch under step 6 (neither already satisfied nor reliably satisfied by the checked delivery before public exposure) → resolve it at its owner (the matching requirements workflow for a question or requirement in a spec, the user for an external action) → `/deploy-check`.
- The `/update-docs` PASS is absent, not established or invalidated → `BLOCKED — NO VERDICT` → `/update-docs` → `/deploy-check`.
- An earlier actually invoked gate is reliably known to be a FAIL, BLOCKED, unresolved or invalidated behind an `/update-docs` PASS → `BLOCKED — NO VERDICT` → the earliest such gate → the downstream gates → `/update-docs` → `/deploy-check`.
- An implementation, configuration or security code defect → `/build-feature` → `/test-feature` → `/review-code` → `/update-docs` → `/deploy-check` (the upstream skills' proportional rules apply to a microchange). No fix inside this gate.
- A documentation or context defect only → `/update-docs` → `/deploy-check`.
- A Tech Spec problem → `/tech-spec` → `/review-spec` → `/build-feature` → `/test-feature` → `/review-code` → `/update-docs` → `/deploy-check`.
- An architecture or infrastructure design problem → `/architecture` → the required architecture review → `/tech-spec` → `/review-spec` → `/build-feature` → `/test-feature` → `/review-code` → `/update-docs` → `/deploy-check`. Infrastructure design is not changed here.
- A requirements problem → the matching requirements workflow → `/review-spec` → `/architecture` if needed → `/tech-spec` → `/review-spec` → `/build-feature` → `/test-feature` → `/review-code` → `/update-docs` → `/deploy-check`.
- A reviewer, mandatory check, required authorization or environment access unavailable → `BLOCKED — NO VERDICT` → resolve the prerequisite → `/deploy-check`.
- An unresolved target → ask the user → `/deploy-check`. Framework structure missing → `/init-project`.

After any fix or resolved blocker, the whole applicable `/deploy-check` run repeats. No next skill is ever launched automatically.
