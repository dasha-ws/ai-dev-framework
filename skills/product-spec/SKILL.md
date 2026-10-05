---
name: product-spec
description: Create or substantially update the full Product Specification of a target project through a short product interview. Turns the product idea, the user's answers and the existing project context into agreed product requirements in .claude/product/product-spec.md, then syncs the short product.md context. Product level only: no architecture, no technical design. Run it after /init-project; the next mandatory step is /review-spec.
---

# product-spec

## Purpose

`/product-spec` creates, or substantially updates, the full Product Specification of a **target project**: `.claude/product/product-spec.md`, the canonical product-level intended requirements. It turns the product idea, the user's answers and whatever the project already says into agreed requirements: what problem the product solves, for whom and why, what it must do, what is in and out of scope, which product rules and constraints are agreed, and how to tell at product level that they are met. It answers *what* and *why*, never *how it is built*: no architecture and no technical design.

Two documents, two jobs. `product-spec.md` is the full specification. `.claude/skills/project-context/context/product.md` is a short durable digest of it for Claude Code, not a second requirements document. After substantive authoring, `/review-spec` is mandatory (step 8). Nothing is launched automatically.

## When to use

- A new project after `/init-project`, where `product-spec.md` is still a not-started stub.
- An existing project that has no Product Specification, or one that is not complete enough.
- An existing product whose requirements the user wants to formalise for the first time.
- A substantial change to the overall product idea, when the user explicitly asks to update the Product Specification.

## When not to use

- The current directory is the **ai-dev-framework repository itself**. It is the source of the framework, not a target. If the root contains the framework's own `skills/` folder, stop and ask which project the user means.
- The framework structure created by `/init-project` is missing. Stop, say what is missing and suggest `/init-project` (step 1).
- A Product Specification already exists and is current enough for the task. Its existence is not a reason to run this skill again.
- The user wants one new feature of an existing product described: `/new-feature-spec`.
- The user wants architecture or a technical implementation plan: `/architecture` and `/tech-spec`.
- The user wants a small bug fixed, code changed, code reviewed, a finished implementation tested, or documentation updated after implementation.

## Inputs

- **Target project root.** Default: the current working directory. Confirm it if there is any doubt.
- **The user:** the product idea and the answers to the product interview.
- **The project itself** (existing projects): README, product documentation, existing specs, and facts about what the product does today.
- **The framework structure in the target project**, created by `/init-project`: `.claude/product/product-spec.md`, `.claude/skills/project-context/SKILL.md` and `.claude/skills/project-context/context/product.md`. All three are required.
- **The installed Product Specification template.** `product-spec.md` was created from it.

## Files to read

Read before writing anything. All reads are read-only. Always: the root `CLAUDE.md`, `.claude/skills/project-context/SKILL.md` (the router), `.claude/skills/project-context/context/product.md`, `.claude/product/product-spec.md` and the installed template. For existing projects, only when it actually helps: `README*` and product documentation, relevant existing specs (`.claude/work/`, `docs/`), other context files that carry constraints bearing directly on product requirements, and code only as far as needed to check existing observable behaviour.

Follow the router: do not load the whole project context by default. This is not a technical audit. Never read real `.env` files, keys or credentials.

## Execution steps

### 1. Confirm the target, the prerequisites and the template

Verify that the working directory is a target project, not the framework repo, and that the three required files from "Inputs" exist. If any is missing: **stop**, say what is missing and suggest `/init-project` first. Do not create the structure yourself and do not rebuild it from memory.

The installed Product Specification template is required, and its structure is the structure of `product-spec.md`. It lives at `%USERPROFILE%\.claude\ai-dev-framework\templates\product-spec.md`, so do not look for it by other means. If it is unavailable, missing or empty: **stop**, say that the framework installation or template needs fixing, and do not recreate it from memory, invent your own structure or continue. If `product-spec.md` exists but is empty, damaged, or so far from the template that continuing safely is impossible: **stop** and describe the problem. Fixing a broken framework installation is not this skill's job.

### 2. Read the current state, classify it and take the baseline

Read the files listed above and classify `product-spec.md`: a **not-started stub** (the template structure with nothing confirmed in it) or a **substantive spec** (real, agreed content). Note what `product.md` already says: confirmed statements or `TODO(product-spec)` gaps.

The sources keep their roles. `product-spec.md` holds the agreed intended product behaviour, scope and product-level requirements. Code and current behaviour are evidence of what the product does today: they do not override the spec, and existing behaviour, legacy quirks and bugs are not requirements just because they exist. For an existing project keep three things apart: the intended behaviour, the documented requirements and the current implementation. `product.md` reflects the spec: if the two disagree after a change, the spec wins and `product.md` is synced. Specs in `.claude/work/` may refine one change and must not quietly rewrite the Product Specification. There is one product truth and no competing versions. No source ledger and no `source:` tag next to every fact.

Before the first write, in a git repository, take a read-only baseline with `git status --short -uall`, `git diff` and `git diff --cached`, so that staged changes and individual untracked files are visible. Do not require a clean working tree, and leave any changes the user already has untouched: they are not a violation of this skill's boundaries. The baseline exists so that step 7 can tell your changes from the earlier ones. Never stage, reset, checkout, stash, commit or run any other command that changes git state. If the project is not a git repository, do not invent a filesystem snapshot, hashes or any other baseline mechanism.

### 3. Establish what is changing and resolve conflicts

If the user's request already makes clear that they want to update the overall Product Specification, do not ask again. Ask only when it is unclear whether the change concerns the overall product intent or just one feature. If it is one feature, point to `/new-feature-spec` and stop. If it is an update of the Product Specification, work out which parts change and leave the rest alone.

If the README, the Product Specification, the project context, other documents or the observed behaviour contradict each other on product requirements: do not pick the convenient version and do not fix it silently. Show the user what exactly diverges, explain the variants in a few lines, and wait for the decision before recording anything. A contradiction in substance is resolved by the user, not by this skill.

### 4. Run the product interview

A conversation, not a form. Study what is known first, then ask.

- Do not ask what is reliably known from the project or was already confirmed by the user, and never repeat a question the user has answered.
- Ask only what the Product Specification really needs, in small logical blocks, never the whole survey in one message.
- If an answer opens a real new uncertainty, follow up.
- The user owns product decisions. If they have not decided something, do not decide for them. If it is unknown and they cannot or do not want to settle it now, leave it as an explicit open question: a plausible-sounding guess is worse than an honest gap.
- Tell three things apart: a confirmed fact, a decision the user has made and an unresolved question. Do not invent users, needs, goals, features, constraints, business rules or metrics.
- Do not drift into technical design.

Cover the aspects that actually apply: the problem or need, target users or actors, the product goal, key user scenarios, functional scope and what is explicitly out of scope, important business rules, product-level acceptance criteria, known constraints, external dependencies that affect product behaviour, terminology where the requirements are ambiguous without it, and open questions. The concrete structure is whatever the installed template says.

**User data and privacy (conditional).** Once the interview shows that the product receives, stores, transmits or otherwise processes data about its users (accounts, contact details, messenger or device identifiers, user content, usage data and the like), raise the privacy and data-processing questions yourself. Do not wait for the user to mention them, and do not skip them because they were not asked about. If it is unclear whether the product handles such data, ask that one question first. A product that does not process user data gets none of this: do not run the block, and do not ask "just in case".

Ask in small blocks, only what is not yet known, and cover:

- which user data is processed, why, and which of it the product really needs;
- whether a Privacy Policy is needed and how the user reaches it;
- whether explicit consent is required, what happens on refusal, and whether the product can be used without consent;
- whether the user can request access, correction or deletion of their data, and what happens to the data and the user's account after deletion;
- known retention requirements;
- the known lawful basis for processing, if any;
- known data-subject rights requirements, data residency or localization requirements, and registration, notification or similar operator obligations;
- known jurisdiction or compliance constraints;
- which of these must be closed before public launch.

This skill is not a lawyer. It does not decide which law applies, which basis is valid, whether consent, registration or a policy is legally required, or what a compliant product looks like. Keep the three kinds apart. A requirement or fact the user states as known (for example a jurisdiction, a data-localization requirement or a retention period) is a confirmed fact or external constraint: record it as such, as stated, and do not present it as a product decision. A product choice the user makes (for example what is collected, or how consent refusal behaves) is a decision: record it as a decision. What is unknown or not yet decided, record as an open question and do not fill it with a plausible answer or a legal conclusion. Where it is already known that a privacy or compliance requirement must be satisfied before public launch, record it under `Constraints and dependencies` marked `[before public launch]`, and record a related unknown part as an open question marked `[before public launch]` too. If only the uncertainty is known to need resolving before public launch and the requirement itself is not established, record just the marked open question, never an invented constraint or a legal conclusion. The product-level decisions (what is collected and why, consent and refusal behaviour, access, correction and deletion behaviour, the Privacy Policy being available to users) go into the template's existing sections as business rules, acceptance criteria and constraints. How they are built, stored or secured is not decided here.

**User-facing text (conditional).** If the product has user-facing interaction (a bot, a web or mobile UI, a CLI with prompts for the user and the like), then before the spec is finished show the user the main user-facing text that can be defined at this stage, so that they can agree to the wording, change it or leave it unresolved. Where applicable this covers main button labels, commands, start and onboarding messages, navigation messages, confirmations, meaningful errors and empty states, notifications and reminders, and consent or privacy messages. Propose a draft only as something to confirm. Do not present a wording the user has not agreed to as agreed: an unconfirmed text stays an open question, and if the user agreed only the meaning, record the meaning. Do not ask about every technical string or about obvious service text such as Back, Cancel or OK. This is about words, not about visual design. A backend, an API or a library with no user-facing interaction gets none of this. For consent and privacy messages, the privacy block above decides what is required, and this block only records the text.

### 5. Write or update `product-spec.md`

Use only the installed template's structure. Do not add, rename or remove its sections, and do not add a status field or any approval mechanism it lacks. If the template cannot hold information a Product Specification needs, or you think it insufficient, do not improvise: **stop**, report that the framework template needs fixing, propose the framework change separately and wait for agreement.

- **Stub:** fill the existing structure with confirmed content from the interview.
- **Substantive spec:** change only what the agreed update touches and keep everything else. If a change alters a previously recorded product decision, show that material change to the user first and apply it only after agreement. Never overwrite existing decisions silently.
- **One spec only.** No second Product Specification and no alternative version anywhere else.

Unresolved and open questions are recorded only where and in the format the template provides. Do not introduce `TODO(product-spec)` or any other marker of your own unless the template defines it.

**Before public launch.** The template defines one marker, `[before public launch]`, and the section decides what a marked line is. Put a known requirement or constraint that must be satisfied before applicable public launch under `Constraints and dependencies`, and an unresolved question that does not block this specification but must be resolved before applicable public launch under `Open questions`, each marked. Mark only when that need is already established by the user's decision, an approved requirement or a known external constraint. Never mark something because it is usually needed, and do not ask the user about every requirement whether it is needed before public launch. A marked open question does not imply a constraint: write the constraint only if the underlying requirement itself is established. If the requirement is known and only a detail of it is not, keep both lines, the constraint and the marked question. When a marked question is resolved, remove it, keep the constraint while the condition still applies, and write the concrete value into it if the value belongs in this specification. Do not create the constraint retroactively without an established basis, and record no resolved flag, checkbox or other completion record. On an existing specification, unmarked questions stay as they are and are not reclassified. A line you are updating that plainly says it must be closed before public launch is rewritten with the marker.

Keep it at product level. Acceptance criteria describe an observable, verifiable result for the product or the user: an action they can perform, a result they get, a rule that holds. They do not describe classes, functions, endpoints, database schema, libraries, internal algorithms, module structure or implementation tasks. If a technical detail is already an external, mandatory constraint on the product, record it as a constraint and do not design how to satisfy it.

### 6. Sync `product.md`

After the spec is created or substantively updated, bring `.claude/skills/project-context/context/product.md` in line with it. Only short durable context belongs there, the kind that helps Claude Code in almost any later work: what the product is, who it is for, the main problem it solves, the product goal, product constraints or rules of broad importance, and established terminology needed all the time. Do not copy the spec, and do not copy the user-facing text into it (only established terminology belongs there). Do not turn `product.md` into a second requirements document, and add no implementation details or temporary details of a single feature unless they became long-lived product context. If `product.md` contains a statement that the newly accepted decision changes, sync it. If the target's rules (its root `CLAUDE.md` or the router) require agreement before an existing file is changed, show the exact proposed change first and wait.

The sync does not mean the Product Specification is reviewed.

### 7. Check your work

Reread the resulting Product Specification and verify that:

- the problem, users, goal and scope do not contradict each other, scope and out of scope do not conflict, and the key scenarios match the declared scope;
- business rules do not contradict the requirements, and the main product questions are settled or explicitly unresolved, with nothing invented;
- acceptance criteria are verifiable and describe results, not implementation, and the document has not turned into a Tech Spec;
- if the product processes user data, every topic of the user data and privacy block in step 4 is either recorded as a confirmed fact or external constraint, as a user decision, or listed as an open question, none was skipped, none of the three was recorded as another, and no legal requirement or conclusion was invented; if it does not process user data, no privacy content was added;
- a requirement known to be needed before public launch is a marked line under `Constraints and dependencies`, a question known to need resolving before it is a marked open question, and no marker, constraint or legal conclusion was invented;
- if the product has user-facing interaction, the template's `User-facing text` section holds the agreed text verbatim in the product's language (the surrounding prose stays English), only the meaning where only the meaning was agreed, and everything unagreed is an open question; if it does not, that section says so in one line;
- no existing product decision was overwritten silently;
- `product.md` is in sync with the spec and is still short durable context;
- nothing outside the write scope of "Hard limits" changed: in a git repository, repeat `git status --short -uall`, `git diff` and `git diff --cached` (read-only) and compare them, contents included and not only paths, with the baseline from step 2. Changes that were already there before the run are not counted.

If you find a contradiction that can be fixed without a new product decision, fix it. If fixing it needs a decision from the user, ask, and do not make up the answer. This self-check is not an independent review.

### 8. Report and stop

Report briefly: what was created or changed in the spec and in `product.md`; the open questions and unresolved decisions that remain; other files that will need syncing later (for example `architecture.md` or `ux-guide.md`), named but not touched; and that the next mandatory step is `/review-spec`, the independent check of whether the spec is a safe basis for the next stage. Do not run `/review-spec`, do not issue a PASS or FAIL, and do not call the spec reviewed or approved. **Stop.**

## Hard limits

`/product-spec` does not:

- design architecture, choose a technology stack, design a database, an API or internal components, or write a Tech Spec, a Feature Spec or an implementation plan;
- write or change production code or tests, install dependencies, change infrastructure, create Docker or CI/CD configuration, add external services, or deploy;
- refactor an existing project or run a full technical audit;
- turn unknown decisions into assumptions (user-facing text included: an unagreed wording is never recorded as agreed), or give legal advice or legal conclusions about privacy and data processing;
- run `git add`, commit, stash, reset, checkout, restore or any other command that changes git state;
- create skills, agents, templates, scripts, folders or document types, or change the structure of the Product Specification template;
- launch `/review-spec`, `/architecture`, `/tech-spec` or any other skill on its own.

During a normal run it changes only these two files:

1. `.claude/product/product-spec.md`
2. `.claude/skills/project-context/context/product.md`

It reads other project files but never modifies anything else. If another file will need syncing, say so in the report.

## Outputs

In the target project: `.claude/product/product-spec.md` (the created or updated Product Specification, in the installed template's structure) and `.claude/skills/project-context/context/product.md` (synced short product context). In the conversation: the report of step 8.

## Completion criteria

`/product-spec` is done when all of these are true:

- the prerequisites and the template were checked and the project state was read before any write;
- the Product Specification is authored or updated in the installed template's structure, every open product question is settled or explicitly unresolved, and nothing is invented;
- for a product that processes user data, the privacy and data-processing topics were raised, and each is recorded as a confirmed fact or external constraint, a user decision or an open question, with no legal conclusion of this skill's own;
- a requirement known to be needed before public launch is a marked line under `Constraints and dependencies`, a question known to need resolving before it is a marked open question, and no marker, constraint or legal conclusion was invented;
- for a product with user-facing interaction, the main user-facing text that can be defined at this stage is either agreed in wording or meaning and recorded in `User-facing text`, or explicitly left unresolved as an open question; for a product without it, that section says so;
- substantive contradictions were resolved by the user, and no existing product decision was overwritten without agreement;
- the acceptance criteria are product-level and verifiable, and the document contains no technical design;
- `product.md` is synced and remains short;
- only the two allowed files changed, checked against the baseline, with the user's own changes not counted and a clean tree not required;
- the report was given, and `/review-spec` was named as the next mandatory step, not run.

## Next skills

- `/review-spec`: the mandatory quality gate after creating or substantially updating the Product Specification. Until it returns PASS, the spec is not reviewed or approved. On FAIL, fix the findings and run `/review-spec` again. Routing after a PASS belongs to `/review-spec`.
- `/new-feature-spec`: for later single features of an existing product, once the Product Specification is current enough.

No next skill is ever launched automatically.
