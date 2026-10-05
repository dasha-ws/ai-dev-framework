# Technical Specification

> The technical design for exactly one implementation work item: how the agreed requirements are implemented inside the agreed architecture. It implements the reviewed requirements and does not rewrite them. It consumes `architecture.md` and does not decide architecture: a substantive architecture decision belongs to `/architecture`. Design level only: no production code. Tie each significant decision to the requirement or constraint that needs it, without copying the requirements.
>
> Each line under a heading describes what belongs there. Replace it with confirmed content. If a section does not apply, say so in one line. Never present a planned artifact as existing.

## Scope and requirements

The one work item this design covers, the reviewed requirements it implements (referenced, not copied), and anything explicitly not part of this work.

## Affected artifacts

### Existing now

Existing modules, components and files that this work changes or reuses, what each is responsible for here, and what changes.

### Planned, not implemented yet

Agreed elements, for example in `architecture.md`, that do not exist in the code yet and matter to this work but are not created by it. Never describe them as existing.

### Created by this work

New modules, components, interfaces and files this work creates, and what each is responsible for.

### Depends on unfinished work

Artifacts that another unfinished work item must provide, and what this work needs from them. State plainly if the work cannot be built safely before them.

## Interfaces, contracts and data

Interfaces and contracts this work adds or changes, such as APIs, messages or events, integration contracts and module boundaries that matter, and changes to stored data or schemas: shapes, rules, compatibility and state changes. Design level, not code.

## Flow and failure handling

Significant control and data flow, validation, and the failure behaviour that must be implemented, such as invalid input, an unavailable dependency or a partial operation. Only failure paths that matter to implementation.

## Security and sensitive data

If applicable: implications of authentication, permissions, personal or sensitive data, external input, tokens or secrets, external APIs and privileged operations. Refer to configuration and secrets by name only, never by value.

## User-facing implementation

If applicable: the technical implications of the approved requirements, `ux-guide.md` and any explicitly approved design direction for user-facing UI, interaction or text. No new product behaviour and no visual or interaction design here.

## Dependencies and infrastructure

Package, service and infrastructure dependencies this work adds, changes or relies on. Prefer existing infrastructure, then scripts and local automation, then self-hosted automation, and only then an external managed service. A new dependency, service or platform needs a concrete need stated here.

## Migration and compatibility

If applicable: migrations of existing data or state, and compatibility with existing contracts, data and versions, including any transition or ordering requirement.

## Configuration, deployment and rollback

If applicable: configuration and environment changes, deployment or migration order, compatibility during rollout, a feature flag if really needed, and rollback limits for this work. Not a deployment runbook.

## Testing approach

How this work will be verified, in proportion to it: the kinds of test or check that fit, tied to the requirements and to the important failure and regression behaviour, plus any setup the implementation needs. The approach only, not results.

## Implementation sequence

Only if order materially matters, for example a migration before code or a staged change that must stay compatible. Otherwise say so in one line.

## Open decisions and assumptions

Unresolved technical decisions and assumptions the design rests on, one per line, each stating what is undecided or assumed. Only items that do not block implementation. A missing requirement, architecture decision or prerequisite blocks implementation: resolve it upstream first, do not record it here.

None recorded yet.
