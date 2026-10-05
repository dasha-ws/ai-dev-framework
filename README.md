**English** | [Русский](README.ru.md)

# AI-Dev-Framework

ai-dev-framework helps you build projects with AI through a clear development process – from the initial idea and requirements to architecture, implementation, verification, and deployment. The framework currently works with [Claude Code](https://claude.com/product/claude-code).

Important decisions, requirements, and project context are kept directly in the repository. This means you do not have to re-explain to the AI what the project is, what has already been decided, and what should happen next every time you return to it.

You can use it to build Telegram bots, websites, web applications, APIs and backend services, dashboards and admin interfaces, Mini Apps, integrations and automation, as well as mobile and desktop applications. The framework defines the development process, not a ready-made implementation or a specific technology stack.

## Who it is for

For people who want to build their own projects with AI – even if they have not worked with Claude Code or other coding AI before and have never followed a full software-development process.

Professional software-development experience is not required. This is not a no-code tool, but anything that is unclear can be discussed separately with AI: use one chat to build the project with the framework, and another to ask any questions about terminology, decisions, and what is happening at each stage.

## How it works

The framework includes skills for different stages of development and specialised AI roles that review the result. You do not need to understand how they work internally before you start: the main commands, the purpose of each stage and the order of work are described below.

The framework includes 11 AI roles. Ten are reviewers that independently check requirements, architecture, technical design, functional behaviour, product intent, UX, code quality, documentation, security and infrastructure. `ui-designer` is a separate design helper for projects that genuinely need a custom visual UI.

This is not an autonomous software factory. You start each stage yourself. If a required decision cannot be established from the project, the framework asks you. Product and business decisions stay with you.

- **Project-local context.** `/init-project` adds a small context to your project: product, architecture, development, infrastructure and, where applicable, UX conventions. A router tells Claude Code what to read for a particular task.
- **Working language.** Before the project starts, the framework asks which language you prefer to work in. Specifications and other artifacts of your project are created in that language, while the framework's own internal files and instructions remain in English.
- **Specifications as inputs.** Requirements and technical design are written to files before code is written, and implementation follows them.
- **Skills.** Each stage is a skill, a slash command with one job: some skills write specifications, others review them, one skill performs implementation, and `/deploy` performs the actual deployment.
- **Reviewer agents.** Reviewers are called by the relevant skills to independently check a result. They do not edit your project files, and you do not normally call them yourself. `ui-designer` is the exception: you invoke it yourself when it is genuinely needed.
- **Gates.** Important work does not move forward until it passes the check for its stage. If a gate fails, the work goes back to the skill that owns the problem, and the check runs again afterward.
- **One responsibility – one canonical place.** Every rule and artifact has a single owner. This README is a map: the detailed contracts live in [`skills/`](skills/), [`agents/`](agents/) and [`templates/`](templates/).

Skills do not launch each other. Each one names the next step and stops. Gate results are not stored in files: a skill that depends on an earlier check relies on the current conversation or on your explicit confirmation.

## Requirements

- Claude Code (Claude Pro subscription or higher).
- Windows with PowerShell, for the installer this repository currently provides (see [Platform support and limitations](#platform-support-and-limitations)).
- A local checkout of this repository. Clone or download it however you like. The installer itself does not need Git.

## Installation

Three different places are involved, and they are not the same folder:

- **The framework repository**: your local checkout of `ai-dev-framework`. It is only the source the installer copies from.
- **The installed framework**: the copy in `%USERPROFILE%\.claude\`, which Claude Code actually uses (see [What gets installed](#what-gets-installed)).
- **Your project**: the folder you want to develop with the framework. It is a separate directory.

Run the installer once, in one of two ways. Both run the same canonical installer, [`scripts/install.ps1`](scripts/install.ps1).

**Double-click `install.cmd`** in the repository root (the `ai-dev-framework` folder you cloned or unzipped). It is only a small launcher: it runs `scripts/install.ps1` with `powershell.exe -NoProfile -ExecutionPolicy Bypass`, where the bypass applies to that one process only, and keeps the window open so you can read the result. It works from any location and needs no setup.

**Or run the script directly**, from the repository root, in PowerShell:

```powershell
.\scripts\install.ps1
```

If PowerShell blocks local scripts, run it with an execution policy override for that one process:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

The installer does not change your PowerShell execution policy, needs no Administrator rights and uses no network. It checks the sources before writing anything, and it stops with a message if something required is missing or a destination conflicts. It installs framework artifacts only. It does not touch your projects.

The installation is finished when the installer prints `ai-dev-framework installed.` followed by the three destinations. You do not work in the repository after that: move on to your own project (see [Quick start](#quick-start)). The checkout is needed again only to update.

## What gets installed

| Artifact | Location |
| --- | --- |
| Skills | `%USERPROFILE%\.claude\skills\<skill-name>\` |
| Agents | `%USERPROFILE%\.claude\agents\<agent-name>.md` |
| Runtime templates | `%USERPROFILE%\.claude\ai-dev-framework\templates\` |

Skills and agents become available to Claude Code. The templates are runtime dependencies: framework skills read them (for example, `/init-project` creates your project's files from them). They are not part of your project, and the installer creates no project files.

## Quick start

1. Install the framework (see [Installation](#installation)).
2. Create or pick the folder of your own project. For a new project you want under version control, run `git init` in it yourself. `/init-project` does not run `git init`, and it works without Git, but without Git it has no baseline to check its own changes against.
3. Open Claude Code in your project folder, not in the `ai-dev-framework` repository. Framework skills stop if they are run inside the repository itself.
4. Run `/init-project`, the first framework step. It inspects the project and creates only the missing framework structure from the installed templates. It does not invent facts and does not overwrite existing files. Anything it cannot confirm stays a `TODO`, and it asks only what it cannot find in the project.
5. Continue with the skill that fits your situation:
   - a new product: `/product-spec`;
   - a new feature of an existing product: `/new-feature-spec`, which needs enough product context (a Product Specification or a clear existing project context);
   - an existing project whose structure should be written down: `/architecture`.

Running the installer does not run `/init-project`.

### Expected permission prompt

The framework is installed outside your project, so its templates live in your user directory. When a skill such as `/init-project` reads them, Claude Code may ask for permission to read a path like `%USERPROFILE%\.claude\ai-dev-framework\templates\...`. That is expected. It does not mean the framework is reading another project of yours.

Check the path before you approve: it should be inside the installed `ai-dev-framework` directory. If a prompt asks for something else, such as an unrelated folder or another project, do not approve it until you understand why.

## Typical workflows

The chains below are the normal order. A skill names its next step and never starts it for you.

### New product

1. `/init-project`
2. `/product-spec` writes the Product Specification.
3. `/review-spec` reviews it.
4. `/architecture` defines the initial architecture. The skill has it reviewed by `architecture-reviewer` itself.
5. `/tech-spec` writes the Technical Specification of one work item.
6. `/review-spec` reviews the Tech Spec.
7. `/build-feature` implements it.
8. `/test-feature` verifies the implementation.
9. `/review-code` reviews the code.
10. `/update-docs` updates the affected documentation and project context.
11. `/deploy-check` checks deployment readiness. It does not deploy.
12. `/deploy` performs the actual deployment of the checked version. It is a separate step that you start yourself, and it is not needed when `/deploy-check` reports that no deployment or release action is required.

Steps 5 to 12 work on one implementation work item at a time.

### Feature on an existing product

1. `/new-feature-spec` writes the Feature Specification.
2. `/review-spec` reviews it.
3. The architecture step is conditional:
   - if the feature clearly needs no architecture change, go straight to `/tech-spec`;
   - if it clearly needs a substantial architecture change, or its impact is unclear, run `/architecture` first. It decides whether a change is needed, and if none is, you continue with `/tech-spec`.
4. `/tech-spec`, then `/review-spec` on the Tech Spec.
5. `/build-feature`, `/test-feature`, `/review-code`, `/update-docs`, `/deploy-check`, and `/deploy` where there is something to deploy, as in the new-product flow.

If the feature turns out to change the product itself (its overall intent, main users or scope), it goes through `/product-spec` first.

### Microchange

A genuinely microscopic change, such as a typo, a trivial text edit, an obvious one-line fix or a very small isolated bugfix, can go without formal specifications. `/build-feature` works directly from your request, with proportional implementation and developer checks. `/test-feature`, `/review-code`, `/update-docs` and `/deploy-check` are used in proportion rather than as one mandatory fixed chain. If you run one of these gates, its normal prerequisites still apply: for example, `/update-docs` needs a current PASS from any earlier gate the change actually went through, `/deploy-check` always needs a current `/update-docs` PASS, and `/deploy` always needs a current `/deploy-check` PASS to deliver a change. If a change turns out to be substantial, the skills stop and send you to the normal workflow.

### Deployment

A `/deploy-check` PASS means ready to deploy, not deployed. Deploying is a separate step, `/deploy`, which you start yourself.

- **One target per run** (for example production, staging or one particular server). `/deploy` delivers exactly the version that `/deploy-check` passed, through the deployment mechanism the project has already established. systemd is a normal supported option, Docker or Compose is not assumed, and `/deploy` never picks or changes the mechanism itself: that is an `/architecture` decision. It verifies the result in the way that mechanism defines.
- **First deploy and update** of an existing deployment, plus read-only status and logs, and rollback only by an already known safe procedure. Status, logs and rollback need no new `/deploy-check`.
- **Confirmation once, scope kept narrow.** Before the first change on the target, `/deploy` shows the target, the mechanism, the version and what will change, and waits for your confirmation. It does not ask again for every command. It stays within the current project and target, does not touch other projects or services on the same server, and takes no destructive server-wide action without your separate decision.
- **External credentials.** When a credential is needed, `/deploy` explains what it is, why it is needed, where to get it, where to configure it and how to check it safely. You enter secret values yourself, never in the chat. They are not stored in project context or committed, and private key contents are never requested.
- **Deployed state.** After a verified deploy or rollback, `/deploy` records the confirmed state of that target in `infrastructure.md`: current facts per target, with no secret values and no deployment history.

## Skills

Each `SKILL.md` in [`skills/`](skills/) is the full contract of its skill.

| Skill | Purpose |
| --- | --- |
| `/init-project` | Prepares a project: creates the missing framework context, work folders and a short root `CLAUDE.md`, without inventing facts or overwriting files. |
| `/product-spec` | Writes or updates the Product Specification through a short interview and keeps `product.md` in sync. |
| `/new-feature-spec` | Writes or updates the Feature Specification for one feature or meaningful change of an existing product. |
| `/architecture` | Owns the durable architecture: documents an existing system, designs the initial architecture, or resolves the architecture impact of a reviewed Feature Spec. |
| `/tech-spec` | Writes the Technical Specification for one work item: how the agreed requirements are implemented inside the agreed architecture. |
| `/review-spec` | The independent PASS/FAIL gate for one Product, Feature or Technical Specification. |
| `/build-feature` | Implements one work item in code with its tests and developer checks, and fixes implementation-side findings from later gates. |
| `/test-feature` | The verification gate after implementation: independent functional, product-intent and, for user-facing work, UX review of the implemented behaviour. |
| `/review-code` | The code-quality gate after a successful `/test-feature`. |
| `/update-docs` | Updates the documentation and permitted project context affected by the accepted implementation, then has that reviewed. "No changes required" is a valid result. |
| `/deploy-check` | The final security and infrastructure readiness gate for one deployment target. It checks readiness and never deploys. |
| `/deploy` | Performs the actual deployment of the checked version to one target through the project's established deployment mechanism, verifies the result and records confirmed deployed-state facts. Also status, logs and rollback by a known safe procedure. |

## Agents

Agents are specialised roles that skills use. They live in [`agents/`](agents/).

### Reviewer agents

Reviewers are called by their owning skill and recommend a result. The skill owns the final outcome.

| Agent | Called by | Reviews |
| --- | --- | --- |
| `requirements-reviewer` | `/review-spec` | Product and Feature Specifications. |
| `tech-spec-reviewer` | `/review-spec` | Technical Specifications. |
| `architecture-reviewer` | `/architecture` | `architecture.md`. |
| `qa-reviewer` | `/test-feature` | Functional behaviour of the implementation. |
| `product-reviewer` | `/test-feature` | The implementation against the approved product or feature intent. |
| `ux-reviewer` | `/test-feature` | The user-facing experience against approved UX and UI expectations, for user-facing work. |
| `code-reviewer` | `/review-code` | Code quality. |
| `docs-reviewer` | `/update-docs` | Documentation impact and updates. |
| `security-reviewer` | `/deploy-check` | Security readiness for a deployment target. |
| `infrastructure-reviewer` | `/deploy-check` | Infrastructure and deployment readiness for a deployment target. |

### ui-designer

`ui-designer` is a standalone design helper, not a reviewer. You invoke it deliberately, before implementation, for work that genuinely needs a custom visual UI, such as a website, a web application, a dashboard or a mobile app. It proposes a visual and interaction direction as a conversation-only handoff, which stays a proposal until you approve it. It gives no PASS or FAIL, `/test-feature` never invokes it, and no skill owns it. Many projects never need it: an ordinary Telegram bot, an API or a library has no custom visual UI to design.

## Target-project structure

After `/init-project`, your project contains:

```
CLAUDE.md
.claude/
  skills/
    project-context/
      SKILL.md
      context/
        product.md
        architecture.md
        development.md
        infrastructure.md
        ux-guide.md        (only if the project has a user interface, user-facing scenarios or user-facing content)
  product/
    product-spec.md        (a not-started stub)
  work/
    completed/
```

- `CLAUDE.md` is a short entry point that points Claude Code to the project context.
- `.claude/skills/project-context/` is the project's context: a router and the durable context files.
- `.claude/work/` holds the specifications of current work, in one folder per work item, and `completed/` is for finished ones. Feature and Technical Specifications are created there later by their skills, as `<name>/feature-spec.md` and `<name>/tech-spec.md`. They do not exist right after initialization.

The framework templates are not part of this structure. They stay in the installation directory.

## Specifications and context

| Artifact | Owns | Written by |
| --- | --- | --- |
| Product Specification, `.claude/product/product-spec.md` | Product-level requirements. | `/product-spec` |
| Feature Specification, `.claude/work/<name>/feature-spec.md` | The requirements of one feature or change. | `/new-feature-spec` |
| Technical Specification, `.claude/work/<name>/tech-spec.md` | How one work item is implemented. | `/tech-spec` |
| `architecture.md` | The durable, agreed architecture. | `/architecture` |
| Other context files | Short durable facts and conventions: product digest, development, infrastructure, optional UX. | Created by `/init-project`. `/product-spec` syncs `product.md`, `/update-docs` may sync descriptive facts, and `/deploy` records the confirmed deployed state of a target in `infrastructure.md`. |

The code shows what is implemented today. It does not define what the product should do. When a spec, the project context and the code disagree, the difference is resolved at its owning source instead of patching symptoms.

## Updating

1. Update your local checkout of the repository (pull, or download a newer copy).
2. Run the installer again, as in [Installation](#installation): double-click `install.cmd` on Windows, or run `scripts/install.ps1` directly from PowerShell. Both use the same canonical `scripts/install.ps1`.

The installer refreshes every current framework skill and the runtime template tree from the checkout, replacing their installed copies, so edits made inside those copies are overwritten. It overwrites the current framework agent files. Other skills, other agents and other Claude configuration are left alone. The installer keeps no record of what it installed before, so it cannot remove a skill or agent that a newer version no longer ships. Delete such leftovers by hand.

## Platform support and limitations

- The automated installer provided by this repository is Windows-only (PowerShell). The repository contains no `install.sh` or other installer for macOS or Linux. This concerns the installer only: a deployment target is whatever the project's established mechanism uses, for example a remote Linux server.
- There is no uninstall command and no version management. Updating means running the installer again.
- ai-dev-framework does not replace your product decisions, your project's dependencies, your deployment infrastructure or your project's own tests and tools. Skills ask you for decisions they cannot derive, `/deploy-check` checks readiness without deploying, and verification follows the checks and procedures defined by your project or by its established deployment mechanism.

## License

MIT License — see [`LICENSE`](LICENSE).

© 2026 Darya Lyam
