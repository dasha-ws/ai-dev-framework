---
name: deploy
description: The actual deployment step, for one deployment target at a time. After an applicable /deploy-check PASS it delivers exactly the checked version to the target through the project's established deployment mechanism (systemd is a supported branch, not the only one), verifies the result, and records the confirmed actual deployed state of that target in infrastructure.md. Also does read-only status and logs, and rollback by a known safe procedure. It is an executor, not a reviewer: it gives no readiness PASS or FAIL, repeats no security or infrastructure review, and never chooses or changes the deployment mechanism. Never launched automatically.
---

# deploy

## Purpose

`/deploy` performs the actual delivery of one accepted work item to **one** real deployment target, after `/deploy-check` has passed for that work item, that target and that version. It answers one question:

"Is the checked version now delivered to this target and verified, and what exactly is the target's state?"

`/deploy-check` stays the readiness gate. `/deploy` is the executor: it works on the real environment, determines the target, the source being deployed and the deployment access, delivers or updates the application through the established mechanism, then verifies the result and records what it confirmed. It is not a reviewer, issues no readiness PASS or FAIL, repeats no security or infrastructure review and calls no reviewer-agent. It is not an architect: it does not choose or change the deployment mechanism, and it does not author repository code or deployment artifacts.

**Operations.**

- **Deliver:** a first deploy or an update of an existing deployment. Mutating. Needs an applicable `/deploy-check` PASS, with no bypass for small changes.
- **Status and logs:** fully read-only. They change no project file and nothing on the target, `infrastructure.md` included. If they show that reality differs from `infrastructure.md`, they only report that the context may be stale. No `/deploy-check` needed.
- **Rollback:** recovery of an existing deployment by an already known and applicable rollback procedure. No new `/deploy-check`, because it is not a new release. It is never a way around the pipeline for a new version.

**Source of truth.**

- The current `/deploy-check` PASS, as established in the conversation (step 3), and the work item and target it covers.
- `infrastructure.md`: the approved infrastructure facts (including the deployment mechanism) and, per target, the actual deployed state. It is the one canonical context. Nothing else is created.
- The approved sources for what is deployed: the Tech Spec, `architecture.md`, `development.md`, the repository's deployment artifacts and documentation. `/architecture` owns the choice of a deployment mechanism. The Tech Spec only describes how an already accepted mechanism is implemented.
- The real target, inspected read-only before any change.

**Gate state.** No registry, hash, approval file or deployment-status record exists. A `/deploy-check` PASS counts only if the current conversation establishes it or the user explicitly confirms it, never from git history, timestamps, hashes or file existence.

## When to use

- After `/deploy-check` PASS, to deliver the checked version to the checked target.
- To read the status or logs of an existing deployment.
- To roll an existing deployment back by a known procedure.

## When not to use

- The current directory is the **ai-dev-framework repository itself**. It is the source of the framework, not a target. If its root contains the framework's own `skills/` folder, stop and ask which project the user means.
- The framework structure created by `/init-project` is missing: stop and suggest `/init-project`.
- A deliver is requested without an applicable `/deploy-check` PASS: stop and route to `/deploy-check` (step 3).
- `/deploy-check` reported `No deployment/release action required`: there is nothing to deploy.
- The deployment mechanism is unknown, or must be chosen or changed: that is an infrastructure decision of `/architecture` (step 4).
- The request spans several targets or several work items.

## Inputs

- **Target project root.** Default: the current working directory. Confirm it if in doubt.
- **The operation, the work item and the one target** (steps 1 and 2).
- **For deliver:** the applicable `/deploy-check` PASS (step 3) and the source, ref or version it covers (step 5).
- **The framework structure created by `/init-project`**, including `infrastructure.md`.
- **Deployment access:** the user's own SSH setup, ssh-agent or ssh-config, or whatever access the mechanism uses. Never private key contents.
- **The user**, for the few decisions only they can settle, for the plan confirmation (step 8) and for entering secret values themselves (step 6).

## Files to read

Read selectively and read-only. Never read, print, log or store a secret value, and never read private key contents. A real `.env` or other secret-bearing configuration is not opened for its content or shown. Where a deployment step really needs it, only its configuration names or keys may be checked, in a way that exposes no value.

- the root `CLAUDE.md`, the project-context router, `infrastructure.md`, and `development.md` and `architecture.md` where they bear on delivery;
- the work item's Tech Spec, where there is one, and the deployment artifacts and documentation of the repository that the mechanism uses (service definitions, startup scripts, `.env.example`, runbooks);
- git state, read-only (`git status --short -uall`, the current ref), only to identify the source being deployed.

## Execution steps

### 1. Confirm the project and the operation

Check the working directory and the structure (see "When not to use"). Decide the operation: deliver, status and logs, or rollback. If a project instruction conflicts with a framework rule, stop and ask.

### 2. Determine the target

Exactly one target per run: production, staging, a particular VPS or another explicitly defined target. If it is not unambiguous, ask. Never choose one yourself, and never apply anything to another target. Everything is kept apart per target: host, project path, service, `.env`, runtime, credentials, persistent storage, database facts, procedures and deployed-state facts. `infrastructure.md` holds target-specific facts under the target's name. No target registry is created.

### 3. Establish the gate (deliver only)

A current `/deploy-check` PASS must be established for this work item, this target and the version that will be deployed. If it is absent, not established, a FAIL or BLOCKED, or for another work item or target: **stop** → `/deploy-check` → `/deploy`. If it is reliably known that implementation, deployment artifacts, the target or a material deployment condition changed after the PASS, it no longer applies: **stop**, deploy nothing, → `/deploy-check`. Do not ask for a ritual confirmation if the conversation already establishes the PASS.

### 4. Establish the mechanism and the known facts

Read `infrastructure.md`. Separate:

- **Approved infrastructure facts**, which may exist before any deployment: the chosen mechanism, the hosting model, constraints. They are inputs and are never changed here.
- **Actual deployed state of this target**, which exists only after a real deployment: paths, service or process identifier, runtime, env location and confirmed procedures.

Rules:

- The documented mechanism is used as it is. Do not reopen it, migrate it, or offer Docker Compose or systemd as a default or "for convenience".
- If no mechanism is known, or one has to be chosen or changed, you do not choose it: **stop** and send the user to `/architecture`. The mechanism must be known by the time `/deploy-check` passes.
- If the mechanism is one this skill does not know how to execute safely, **stop** and state the limitation. Follow its documented, approved procedure where there is one. Never improvise a new deployment model on the spot.
- If the mechanism needs repository-managed artifacts (a service definition, deployment config, `.env.example`, a startup script) that do not exist, **stop**. They go through the normal pipeline (`/architecture` where a decision is needed → `/tech-spec` → `/review-spec` → `/build-feature` → … → `/deploy-check`). Do not write them during a deploy and do not generate repository architecture on a server. A mechanism that works without repository artifacts is fine.
- **First deploy** if there is no actual deployed state for this target and inspection (step 7) confirms nothing is deployed. **Update** if the facts exist and inspection confirms that deployment. If the facts and the real target disagree, do not fit either to the other: **stop** and show the discrepancy.

### 5. Identify the source (deliver only)

Determine the source, ref or version that will be deployed. It must be the one the PASS covers. Show it to the user with the target. If the mechanism needs a ref to exist where the target can fetch it and it is not there, tell the user: you never run `git push`, `git add` or a commit. Nothing is stored to prove identity: the conversation and the user's confirmation are the record.

### 6. Access and credentials

**Deployment access.** The user provides it through their own existing SSH setup. Never ask for, read, store or print private key content. Check by a safe successful connection. Never disable host-key verification (`StrictHostKeyChecking=no` or the like) as a workaround: an unverified host key is something the user verifies and accepts themselves. Do not change global SSH or sudo configuration, or server security configuration, without a separate decision of the user. Use elevated privileges only for a step that really needs them.

**Runtime external credentials** (API tokens, bot tokens, database credentials, third-party keys). Onboarding belongs here, at the moment it is really needed, and is not repeated in specs or context. Take the names and purposes from what the approved sources already state. For each credential needed, explain briefly: what it is and why it is needed; where it is created or obtained; which credential exactly; where on the target to configure it; what must never be committed; how to check safely that it works. No provider is special: a bot platform is an example, not a rule.

- The user enters secret values on the target themselves, in a safe way. Never ask for a value in the chat, never print or echo one, never put one in a report or in context, never commit one, and never copy one between projects without the user's explicit decision.
- A database or other data-store credential configured for this application defaults to this project's established data boundary and only the privileges this project needs, so that independent projects gain no unintended cross-project data access through it. Do not reuse another independent project's application credential automatically. Broader access (an administrative, root or superuser-equivalent credential, or one that reaches beyond this project's data scope or is shared with another independent project) is acceptable only when an approved upstream source explicitly establishes it as necessary: follow that established boundary, and do not widen it or approve broader access on your own. If such broader or shared access is known and no approved upstream source establishes it, stop and tell the user instead of configuring it. A user's explicit decision to reuse a credential is not such a source. Never inspect, print or expose a secret value to apply this rule. If the scope is unknown and material to configuring the credential safely, use what the approved project facts already establish, otherwise stop and ask. Do not guess or invent the project's data topology or privilege model: those are architecture decisions.
- You may create the structure of a missing `.env` or equivalent with the needed names and placeholders. An existing one is **never overwritten automatically**, and an update keeps it.
- Check by the presence of the name or key, without exposing the value, and by a safe project-defined check or smoke procedure, never by displaying the value.
- Only safe facts may later be recorded: the name, the purpose, the location of the configuration, the setup and check procedure. Never a value, a fragment, a password, a connection string that contains a password, private key content or any secret content.

### 7. Inspect the existing state (read-only)

Before any mutation, inspect the target: the project directory, the service or unit, the runtime, the configuration and `.env` (existence and, where really needed, names or keys only, never values), persistent data, storage, databases and processes. Never assume the target is empty. For everything found, decide whether it belongs to this project, whether it matches the expected state, and whether it is safe to continue.

Detect conflicts with other projects before writing: service name, port, directory, runtime path, storage path and any other resource a different project owns. On any conflict or unexpected state: **stop** and explain. No overwrite and no destructive cleanup. A rerun must be safe: correct steps that are already done are neither destroyed nor redone without reason.

### 8. Show the plan and get one confirmation

Before the first mutating action, show a short plan: the target, the mechanism, the source, ref or version, and what will be changed. Wait for an explicit confirmation. This is the single confirmation boundary: no confirmation of every command. Anything outside the plan or outside this project's scope needs the user's explicit decision first.

### 9. Execute

Only in this project's scope on this target. Mechanism-agnostic: follow the documented procedure of the established mechanism. For **systemd**, a supported branch, the flow is:

1. deployment access (step 6);
2. target preparation: only what this project needs, no server-wide provisioning;
3. a separate project directory;
4. the checked source, ref or version;
5. a separate `.env` or equivalent per-project runtime configuration (step 6);
6. a separate runtime (a venv or whatever the project's runtime is);
7. a separate service of this project;
8. autostart after reboot and an appropriate restart policy;
9. operational checks: service status and logs;
10. smoke verification where a project procedure exists (step 10);
11. update: this project only, restart of this project's service or process only, status, smoke;
12. rollback only by a known safe procedure (step 11).

`systemctl daemon-reload` is allowed when installing or changing this project's unit needs it. It is a technical reload, not a licence to restart, stop or change anything that belongs to another project.

**Shared-host isolation.** Project-scoped: the directory, `.env`, runtime, service, process, logs, persistent data and data-store access. See the hard limits for what is never touched.

On an update the existing `.env` is kept and persistent data is not destroyed.

### 10. Verify

Verify the result in the way that fits the established mechanism, using only verification steps that the mechanism or the project already defines. Never invent a new verification mechanism. For a runtime service (the systemd branch included) that is the status and the logs of this project's service or process. For a delivery with no running service or process, it is the mechanism's or project's own defined verification of the delivered result, and the absence of a service or process is not a failure in itself. Run the project's smoke procedure where one is defined and applies: it has to pass for a fully verified deployment. **Never invent a production smoke test.** If none is defined, say explicitly that behavioural smoke validation was not performed, and never claim a smoke test passed. Keep two statements apart: *operationally verified* (the mechanism's own runtime or delivery verification succeeded) and *behaviourally smoke-verified*.

### 11. Rollback (only if requested, or offered after a failure)

Only by a known and applicable procedure from `infrastructure.md` or the approved technical design. If there is none, or it is ambiguous, unsafe, does not fit the current state or needs a new substantive decision: **stop**, name the missing decision or limitation. No server-wide rollback, no rollback of neighbouring services, no destructive cleanup and no improvised recovery. After a rollback, verify as in step 10 and sync only confirmed facts as in step 13.

### 12. Partial failure

A run can fail after some mutating actions already happened (code updated, dependencies changed, the service restarted, smoke failed). Then:

- do not say the target kept its previous state, and do not say the new state is current;
- list the actions that actually completed;
- show the current state you could safely observe;
- say that `infrastructure.md` may now be stale;
- offer a rollback only if a known safe applicable procedure exists (step 11);
- do not write an unconfirmed state to context.

### 13. Sync the actual deployed state

`/deploy` is the canonical writer of the actual deployed state of a target. Only a successful deliver or a successful rollback syncs it. Status and logs never write: a discrepancy found there is reported as possibly stale context and is not corrected. It is written only after real execution or inspection confirmed it: the result of the established mechanism was verified (step 10), and the smoke procedure passed if one exists. A missing smoke procedure does not block recording the confirmed facts. After a failed run or a partial failure nothing unconfirmed is written as current.

- Write only to `infrastructure.md`, only for **this** target, only deployment-related facts, in the file's existing sections (`Environments and hosting`, `Delivery mechanism`, `Runtime services and configuration`, `Operational constraints`), under the target's name, updating in place.
- Facts: target or environment, host reference, mechanism, project path, runtime, env location (never its contents), persistent storage, database facts where applicable, and the confirmed update and rollback procedures, plus, where applicable to the mechanism, the service or process identifier and the status, logs and restart procedures. A target without a runtime service simply has no service, log or restart facts. Planned values are never recorded as deployed.
- Current state only. No deployment history, timestamps of releases, release log, command history or secret values. No `deployment.md`, registry or any second context file. The approved infrastructure decisions are not edited here.
- No `git add`, commit or push.

### 14. Report and stop

The result exists only in the conversation. Report briefly: the operation, the target, the mechanism, the source, ref or version deployed, what was done, and the verification, stated honestly as one of *verified by the project's smoke procedure*, *operationally verified, behavioural smoke validation not performed*, *verification failed* or *stopped*. State whether `infrastructure.md` was updated and what (never by status and logs), any partial changes, a possibly stale context (for status and logs, any discrepancy found), and the next step with a clause on why. No PASS or FAIL for readiness. Then **stop**. Launch nothing.

## Hard limits

`/deploy` does not:

- choose a new architecture or deployment mechanism, or change the established one;
- deliver without an applicable `/deploy-check` PASS, or deliver a version, source or target the PASS no longer applies to;
- act on several targets in one run, or let anything of one target (host, path, service, env, runtime, credentials, storage, database, procedures, deployed-state facts) leak into another;
- review security or infrastructure, call a reviewer, or give a readiness PASS or FAIL;
- write repository code, deployment artifacts or specs, or generate repository architecture on a server;
- overwrite an existing `.env` or other secret-bearing configuration automatically;
- ask for a secret value in chat, print, log, store or commit one, read private key contents, or disable SSH host-key verification;
- change global SSH, sudo or server security configuration without a separate decision of the user;
- restart or stop neighbouring services or all processes on a server, change another project's env, config or unit files, clear shared directories, recreate shared users or groups, change a shared firewall or reverse proxy without a separate upstream decision, or take any destructive server-wide action;
- act outside the current project and target scope without the user's explicit decision;
- invent a rollback or a production smoke test, or hide a partial change behind a general status;
- turn `infrastructure.md` into a history, or write a planned or unconfirmed state as the actual one;
- create a deployment registry, hash registry, status registry, approval artifact, secrets registry or any other new state store;
- run `git add`, commit, push, stash, reset, checkout or any other command that changes git state;
- launch `/deploy-check` or any other skill automatically.

## Outputs

In the conversation: the report of step 14. On the target: the deployment, within this project's scope. In the project: only the target-specific actual deployed-state facts in `infrastructure.md`, and only when confirmed by a successful deliver or rollback. Status and logs create and change nothing. No other file is created or changed.

## Completion criteria

`/deploy` is done when all of these are true:

- the project, the operation and exactly one target were determined, and for a deliver the applicable `/deploy-check` PASS and the source it covers were established;
- the mechanism was already known and followed, and nothing was chosen, migrated or improvised;
- the existing state was inspected before any mutation, conflicts and unexpected state stopped the run, and no existing `.env` or neighbouring resource was touched;
- credentials were handled by the rules of step 6 and no secret value was requested, read, shown, stored or committed;
- one plan confirmation was obtained before the first mutating action;
- the result was verified honestly (step 10), and a partial failure, if any, was reported in full;
- the actual deployed state was recorded only if confirmed by a successful deliver or rollback (step 13), a status and logs run changed no file and nothing on the target, and nothing else was written;
- the report was given and no skill was launched.

## Next skills

- A deploy was completed and verified: no mandatory next step. Later status and logs: `/deploy`. A new release starts again at the normal pipeline and `/deploy-check`.
- No applicable `/deploy-check` PASS, or the checked version, artifacts, target or a material condition changed after it: `/deploy-check`, then `/deploy`.
- The deployment mechanism is unknown or has to be chosen or changed: `/architecture`.
- Repository deployment artifacts are missing or wrong: `/tech-spec` → `/review-spec` → `/build-feature` → `/test-feature` → `/review-code` → `/update-docs` → `/deploy-check` → `/deploy`, with `/architecture` first where a decision is needed.
- Framework structure missing: `/init-project`.
- Deployment access or a runtime credential is not available: the user resolves it (step 6), then `/deploy`.
- A partial failure with a known safe rollback procedure: rollback through `/deploy`. Without one: the missing decision goes to its owner.

No next skill is ever launched automatically.
