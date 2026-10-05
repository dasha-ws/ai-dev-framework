---
name: new-feature-spec
description: Create or substantially update the Feature Specification for one new feature, significant behaviour change or large fix in an existing product. Runs a short feature interview and writes .claude/work/<feature-name>/feature-spec.md from the installed template. Feature level only: no product-wide changes, no architecture, no Tech Spec. Run it after /init-project; after successful feature authoring the next mandatory step is /review-spec, while a product-level escape stops earlier and routes to /product-spec.
---

# new-feature-spec

## Purpose

`/new-feature-spec` creates, or substantially updates, the requirements for one piece of work on an existing product: a new feature, a meaningful change of behaviour, or a fix big enough that the expected behaviour has to be pinned down before anyone designs anything. The result lives in:

`.claude/work/<feature-name>/feature-spec.md`

It is a feature-level requirements document. It is not a Product Spec (that describes the product as a whole), not an architecture document and not a Tech Spec, which later sits next to it as `tech-spec.md` and which this skill never creates. It never rewrites the Product Specification silently (step 3). After successful feature authoring the next mandatory gate is `/review-spec`. A product-level escape stops earlier and routes to `/product-spec`. Nothing is launched automatically.

## When to use

- A new feature of an existing product, or a significant change of existing behaviour.
- An extension of an existing user scenario.
- A large enough bug or behaviour change, where the expected behaviour must be fixed in writing first.
- Any new work that needs its own Feature Spec before technical design.

## When not to use

- The current directory is the **ai-dev-framework repository itself**. It is the source of the framework, not a target. If the root contains the framework's own `skills/` folder, stop and ask which project the user means.
- The framework structure created by `/init-project` is missing. Stop, say what is missing and suggest `/init-project` (step 1).
- The whole product is new, or its general idea changes substantially, or the product context is too unclear to understand the feature: `/product-spec` (step 3).
- A small bugfix where the correct behaviour is already obvious and no separate spec is needed, or a tiny local edit (a text fix, a button label, a small tweak). There is no `/bugfix-spec` in the framework: if a bug demands a substantial behaviour change or agreed requirements first, use this skill.
- The user wants an architectural decision (`/architecture`) or a technical implementation plan (`/tech-spec`).
- The user wants finished work tested (`/test-feature`), code reviewed (`/review-code`) or documentation updated after implementation (`/update-docs`).

## Inputs

- **Target project root.** Default: the current working directory. Confirm it if there is any doubt.
- **The user:** the description of the change and the answers to the feature interview.
- **The project itself** (existing projects): README, documentation, existing specs, and existing behaviour where it matters.
- **The framework structure in the target project**, created by `/init-project`: root `CLAUDE.md`, `.claude/skills/project-context/SKILL.md`, `.claude/skills/project-context/context/product.md`, `.claude/product/product-spec.md` and `.claude/work/`. All are required.
- **Product context:** either a substantive Product Specification, or, if `product-spec.md` is still a not-started stub, an existing project and `project-context` that already define the product clearly enough (step 3).
- **The installed Feature Specification template.** `feature-spec.md` is created from it.

## Files to read

Read before writing anything. All reads are read-only. Always: the root `CLAUDE.md`, `.claude/skills/project-context/SKILL.md` (the router), `.claude/skills/project-context/context/product.md`, `.claude/product/product-spec.md`, the existing `feature-spec.md` of this work if there is one, and the installed template. For existing projects, only when it actually helps: `README*` and product documentation, relevant current and completed specs in `.claude/work/`, existing behaviour in code only as far as needed to understand the feature, and other context files only if the router says the task needs them.

Follow the router: do not load the whole project context by default. This is not a technical audit. Never read real `.env` files, keys or credentials.

## Execution steps

### 1. Confirm the target, the prerequisites and the template

Verify that the working directory is a target project, not the framework repo, and that everything required in "Inputs" exists: root `CLAUDE.md`, the router, `product.md`, `product-spec.md` and `.claude/work/`. If any of it is missing: **stop**, say what is missing and suggest `/init-project` first. Do not create the structure yourself and do not rebuild it from memory.

The installed Feature Specification template is required, and its structure is the structure of `feature-spec.md`. It lives at `%USERPROFILE%\.claude\ai-dev-framework\templates\work\feature-spec.md`, so do not look for it by other means. If it is unavailable, missing or empty: **stop**, say that the framework installation or template needs fixing, and do not recreate it from memory, invent your own structure or continue.

### 2. Read the current state and take the baseline

Read the files listed above and note whether `product-spec.md` is a substantive spec or a not-started stub. For an existing project, keep three things apart: the intended behaviour, the documented requirements and the current implementation. Code and current behaviour are evidence of how the product behaves today. Legacy behaviour, a bug or a quirk is not a requirement just because it exists.

Before the first write, in a git repository, take a read-only baseline with `git status --short -uall`, `git diff` and `git diff --cached`, so that staged changes and files inside untracked directories are visible. Do not require a clean working tree, and leave any changes the user already has untouched: they are not a violation of this skill's boundaries. The baseline exists so that step 7 can tell your changes from the earlier ones. Never stage, reset, checkout, stash, commit or run any other command that changes git state. If the project is not a git repository, do not invent a filesystem snapshot, hashes or any other baseline mechanism.

### 3. Check the request against the product

**Sources.** The Product Specification (`.claude/product/product-spec.md`) stays the source of truth for the product as a whole, and a substantive one binds the Feature Spec. The current Feature Spec defines the agreed requirements of this change only: it may refine the Product Specification for this work and must not quietly contradict or rewrite it. The future Tech Spec implements a Feature Spec that has passed `/review-spec` and does not rewrite the requirements to suit an implementation. There is one product truth: no second Product Specification and no competing versions of the Feature Spec. No source ledger and no `source:` label next to every requirement: it is enough that each requirement was confirmed by the user or reliably established from the existing project.

**Product context sufficiency.** A not-started Product Spec does not by itself forbid this skill. Without a substantive one you may continue only if the existing project and its `project-context` already make these clear enough: what the product is, who it is for, what it is for, its current scope and the key constraints needed to understand the feature. If product goals, relevant users, product scope or key constraints are not clear enough: do not fill the gaps with guesses. **Stop** and suggest `/product-spec` first. A not-started Product Spec is never a licence to invent product context.

**Product-level escape.** Compare the requested change with the Product Specification. If it in fact changes the overall product intent, the target users, the main scope, the key product rules or another substantial product-level decision, it is not an ordinary feature and must not be smuggled in as one. **Stop** feature authoring, explain which product-level decision is affected and suggest updating it through `/product-spec` first. This applies at any point of the run, including when the interview or a source conflict only now reveals it.

The same escape applies when, during the run, a new product-wide requirement, constraint or open question is reliably found that is not yet in the Product Specification and has to be recorded there, even if the change itself is an ordinary feature. The reason to stop is canonical ownership, not importance: this skill must not write product-wide truth, and it must not leave it only in the conversation or the report. Product-wide truth that already exists in the Product Specification does not trigger it, and neither does a `[before public launch]` marker on its own. Stop, say what belongs to the Product Specification and suggest `/product-spec`. After the Product Specification is updated and has passed `/review-spec`, the user can return to `/new-feature-spec`. This is a stop and not a completed run: do not call the Feature Specification complete or ready for review, and do not name `/review-spec` for it as the next step.

### 4. Identify the work item

One Feature Spec is one current feature or change. Do not merge unrelated work. The Feature Spec lives in `.claude/work/<feature-name>/`. Before creating anything:

- look through `.claude/work/`, and read `.claude/work/completed/` too, for work on the same change, and do not create a duplicate. If the same work exists and the request already makes clear that the user wants to continue or update exactly that work, do not ask again. If the intent is unclear, show the work you found and ask how to proceed;
- never modify anything in `.claude/work/completed/` unless the user explicitly asks for it;
- if a work folder for this change already holds a Feature Spec, this is potentially an update. If the request already clearly says to update it, do not ask again. Otherwise ask whether the existing requirements really need to change. Never overwrite an existing Feature Spec silently;
- if an existing `feature-spec.md` is empty, damaged, or so far from the installed template that continuing safely is impossible: **stop** and describe the problem. Do not invent a new structure.
- an existing `.claude/work/<feature-name>/` folder is occupied by a work item unless it is established that it is this same work. A matching name, the same technical area, an existing `tech-spec.md` or the absence of a `feature-spec.md` does not establish it, and a missing Feature Spec does not make the folder available. If it is established as this same work, use it under the rules above. If it belongs to another work item, do not add a Feature Spec there: choose another short, unambiguous name. If it is unclear, show the folder briefly and ask before writing anything.

Use the project's or framework's naming convention for work folders, if there is one. If there is none and the name is ambiguous, propose a short, clear name and wait for agreement before creating a new folder. No extra directory levels and no new way of organising work items.

### 5. Resolve conflicts and run the feature interview

If the Product Spec, an existing Feature Spec, the project context, the documentation or the observable implementation contradict each other on the requirements of this feature: do not pick the convenient version and do not fix it silently. Show the user the exact divergence, explain the variants in a few lines and wait for the decision before recording anything. If the conflict means a change of product-level truth, that is the product-level escape of step 3.

Then a short conversation, noticeably lighter than the full `/product-spec` interview. Study what is known first, then ask.

- Do not ask what is reliably known already, and never repeat a question the user has explicitly answered.
- Ask only what is really needed to define this feature, in small logical blocks. If an answer opens a real new uncertainty, follow up.
- If the user has not decided something yet, do not decide for them. Leave the unknown as unresolved or open. Do not turn an assumption into a requirement.
- Do not drift into technical implementation.

Cover the aspects that actually apply: the feature or change name, the problem or reason, affected users or actors, current and desired behaviour, key scenarios, functional scope and what is explicitly out of scope, important feature-level business rules, edge cases that affect the expected behaviour, feature-level acceptance criteria, known product or business constraints, dependencies that affect externally observable behaviour, and open questions. The template defines the structure of the document, not this list.

**User-facing text (conditional).** If the feature has user-facing interaction (a bot, a web or mobile UI, a CLI with prompts for the user and the like), then before the spec is finished show the user the main user-facing text of this feature that can be defined at this stage, so that they can agree to the wording, change it or leave it unresolved. Where applicable this covers main button labels, commands, messages, confirmations, meaningful errors and empty states, notifications and reminders, and consent or privacy messages. Propose a draft only as something to confirm. Do not present a wording the user has not agreed to as agreed: an unconfirmed text stays an open question, and if the user agreed only the meaning, record the meaning. Do not ask about every technical string or about obvious service text such as Back, Cancel or OK. This is about words, not about visual design. Text already recorded in the Product Specification is not asked about or restated, and a change to it is a product-level change (step 3). A backend, an API or a library with no user-facing interaction gets none of this.

### 6. Write or update `feature-spec.md`

Use only the installed template's structure. Do not add, rename or remove its sections, and do not introduce sections of your own or markers beyond the one the template defines. If the template cannot hold information a Feature Spec needs, do not improvise: **stop** and report that the framework template needs fixing.

- **New work:** create the missing `.claude/work/<feature-name>/` folder, create only `feature-spec.md` in it and fill the template with confirmed requirements.
- **Existing Feature Spec:** change only the agreed parts and keep everything current that the change does not touch. If a change alters a previously agreed feature decision, show it to the user first and apply it only after agreement. Leave no competing versions.
- **An existing `tech-spec.md`** next to the Feature Spec is never modified, even if the change may make it outdated.

Acceptance criteria describe verifiable expected behaviour, so that later it is possible to tell whether the feature was implemented as agreed: what action the user can perform, under which conditions, what observable result they get, which business rule holds and what happens in a relevant edge case. State the result, not the implementation: no classes, functions, database schema, endpoints, internal algorithms, module boundaries, libraries, implementation tasks or deployment mechanisms. If a technical constraint objectively exists and affects the requirements, record it as a constraint and do not design the solution.

Unresolved and open questions are recorded only where and in the format the installed template provides.

**Before public launch.** The template defines one marker, `[before public launch]`, and the section decides what a marked line is. Put a known requirement or constraint of this feature that must be satisfied before applicable public launch under `Constraints and dependencies`, and an unresolved question that does not block this Feature Specification but must be resolved before applicable public launch under `Open questions`, each marked. Mark only when that need is already established by the user's decision, an approved requirement or a known external constraint. Never mark something because it is usually needed, and do not ask the user about every requirement whether it is needed before public launch. A marked open question does not imply a constraint: write the constraint only if the underlying requirement itself is established. If the requirement is known and only a detail of it is not, keep both lines. When a marked question is resolved, remove it, keep the constraint while the condition still applies, and write the concrete value into it if the value belongs in this Feature Specification. Do not create the constraint retroactively without an established basis, and record no resolved flag, checkbox or other completion record. On an existing Feature Specification, unmarked questions stay as they are and are not reclassified. A line you are updating that plainly says it must be closed before public launch is rewritten with the marker.

**Ownership.** Three cases. Truth that belongs only to this feature or change, whether a requirement, a constraint or an open question, is owned here and is recorded under the rules above. Product-wide truth that already exists in the Product Specification stays there: do not record or copy it here as a second authoritative requirement, and refer to it only where the feature is ambiguous without it. This alone does not stop the run. Product-wide truth that is newly found during the run and has to be recorded in the Product Specification, whether a requirement, a constraint or an open question, triggers the product-level escape of step 3: it is not written here and is not left only in the report. That includes a product-wide open question whose underlying requirement is not established: do not turn it into a constraint. The `[before public launch]` marker never decides ownership or stopping by itself.

### 7. Check your work

Reread the resulting Feature Specification and verify that:

- the requirements concern exactly one feature or change, and the feature does not hide a substantial change to the product as a whole;
- problem, affected users, desired behaviour and scope agree with each other, scope and out of scope do not contradict each other, scenarios match the requirements, business rules do not conflict, and current and desired behaviour are told apart wherever it matters;
- acceptance criteria are verifiable and describe behaviour, not implementation, and the document has not turned into a Tech Spec;
- unresolved questions are kept explicitly, nothing is invented and the Product Spec was not silently overridden;
- a feature-level requirement known to be needed before public launch is a marked line under `Constraints and dependencies`, a question known to need resolving before it is a marked open question, no product-wide truth was recorded here as a second authoritative one, none that was newly found was left only in the report, and no marker or constraint was invented;
- if the feature has user-facing interaction, the template's `User-facing text` section holds the agreed text verbatim in the product's language (the surrounding prose stays English), only the meaning where only the meaning was agreed, and everything unagreed is an open question, with no text duplicated from the Product Specification; if it does not, that section says so in one line;
- nothing outside the write scope of "Hard limits" changed, and no `tech-spec.md` was created or touched: in a git repository, repeat `git status --short -uall`, `git diff` and `git diff --cached` (read-only) and compare them, contents included and not only paths, with the baseline from step 2. Changes the user already had are not counted.

If you find a problem that can be fixed without a new product or feature decision, fix it. If it needs a decision from the user, ask, and do not guess the answer. This self-check is not an independent review.

### 8. Report and stop

If the run stopped at the product-level escape, there is no normal completion: report briefly what belongs to the Product Specification, name `/product-spec` as the next step and **stop**. Do not name `/review-spec` as the next step and do not call the Feature Spec complete, reviewed or ready for review. Otherwise report briefly: which Feature Spec was created or updated and its work folder; the unresolved and open questions that remain; downstream artifacts that may need a second look, such as an existing `tech-spec.md`, which should be revisited after `/review-spec` passes (named, not changed); and that the next mandatory step is `/review-spec`, the independent check of whether the Feature Spec is a safe basis for technical design. Do not run `/review-spec`, do not issue a PASS or FAIL, and do not call the Feature Spec reviewed or approved. **Stop.**

## Hard limits

`/new-feature-spec` does not:

- change the overall product intent, or create or update the Product Spec;
- design architecture, choose a technology stack, design a database, an API or internal components, or create or change a Tech Spec or an implementation plan;
- write or change production code or tests, install dependencies, change infrastructure, create Docker or CI/CD configuration, add external services, or deploy;
- turn unknown decisions into assumptions (user-facing text included: an unagreed wording is never recorded as agreed);
- run `git add`, commit, stash, reset, checkout, restore or any other command that changes git state;
- create skills, agents, templates, scripts or document types, or change the structure of the Feature Specification template;
- launch `/review-spec`, `/architecture`, `/tech-spec` or any other skill on its own.

During a normal run it may only create the `.claude/work/<feature-name>/` folder, if it does not exist yet, and create or change `.claude/work/<feature-name>/feature-spec.md`. It reads other project files but never modifies anything else: the Product Spec, `product.md`, other context files, the root `CLAUDE.md`, `tech-spec.md`, other Feature Specs, code, tests, documentation and infrastructure. If another artifact goes stale because of the new requirements, say so in the report and do not fix it here.

## Outputs

In the target project: `.claude/work/<feature-name>/feature-spec.md` (the created or updated Feature Specification, in the installed template's structure) and the `.claude/work/<feature-name>/` folder, if it did not exist. In the conversation: the report of step 8. No Tech Spec.

## Completion criteria

`/new-feature-spec` is done when all of these are true:

- the prerequisites and the template were checked and the project state was read before any write;
- the change is a single feature, not a hidden Product Spec update, and the product context was clear enough;
- the Feature Specification is authored or updated in the installed template's structure, every open question is settled or explicitly unresolved, and nothing is invented;
- a feature-level requirement known to be needed before public launch is a marked line under `Constraints and dependencies`, a question known to need resolving before it is a marked open question, no product-wide truth was recorded here as a second authoritative one, none that was newly found was left only in the report, and no marker or constraint was invented;
- for a feature with user-facing interaction, the main user-facing text of this feature that can be defined at this stage is either agreed in wording or meaning and recorded in `User-facing text`, or explicitly left unresolved as an open question, with no text duplicated from the Product Specification; for a feature without it, that section says so;
- substantive contradictions were resolved by the user, and no previously agreed decision was overwritten without agreement;
- the acceptance criteria are verifiable and describe behaviour, the document contains no technical design, the Product Spec was not silently overridden, and no `tech-spec.md` was created or changed;
- only `feature-spec.md` (and its folder, if new) changed, checked against the baseline, with the user's own changes not counted and a clean tree not required;
- the report was given, and `/review-spec` was named as the next mandatory step, not run. A run that stopped at the product-level escape is not a completed run: `/product-spec` was named instead.

## Next skills

- `/review-spec`: the mandatory quality gate after creating or substantially updating a Feature Spec. Until it returns PASS, the Feature Spec is not reviewed or approved, and it is not a verified basis for technical design. On FAIL, fix the findings and run `/review-spec` again. Routing after a PASS (architecture or Tech Spec) belongs to `/review-spec`.
- `/product-spec`: if the request turned out to be a product-level change, the product context was too unclear to specify the feature, or a new product-wide requirement, constraint or open question was found that belongs to the Product Specification.

No next skill is ever launched automatically.
