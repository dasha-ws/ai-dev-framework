---
name: project-context
description: Router for this project's durable context files. Use it to decide which of product.md, architecture.md, development.md, infrastructure.md and ux-guide.md to read for the current task, and to read only what the task needs.
---

# Project context

This is a router, not a summary. It says what each context file owns and when to read it. The files live in `context/`, next to this one.

## Context files

| File | Owns | Read when the task touches |
|------|------|----------------------------|
| `context/product.md` | Durable product facts: what the product is, who it is for, its goal and boundaries, established terminology. | Product intent or terminology. |
| `context/architecture.md` | Durable architecture: components, boundaries, data flows, integrations and agreed patterns, current and agreed target. | System structure, boundaries or integrations. |
| `context/development.md` | Stack and toolchain, commands, engineering conventions and constraints. | Writing, running, building or testing code. |
| `context/infrastructure.md` | Environments, hosting, the delivery mechanism, runtime services and operational constraints. | Deployment, configuration or environments. |
| `context/ux-guide.md` | Durable UX and UI conventions: interaction, visual conventions, content and tone, accessibility. Exists only if the project has a user interface or user-facing content. | User-facing interface, interaction or text. |

## How to use it

- Read only what the current task needs. Do not load all context by default.
- A `TODO(...)` marks a gap. Ask about it. Never treat it as permission to guess.
- Context holds durable facts, conventions and constraints. It is not a specification and it does not track work, review status or history.

## Sources of truth

- Intended product requirements live in `.claude/product/product-spec.md`, and the requirements and design of current work in `.claude/work/`. Context does not duplicate or override them.
- The code is the current implementation. Context does not override it either.
- Project documentation is kept in sync separately. Context does not replace it.

If a context file disagrees with a spec or with the code, do not silently pick one. Resolve the difference at its source.
