# Feature Specification

> The agreed requirements for exactly one feature or change. It refines the Product Specification for this work and must not contradict or rewrite it, and it restates product context only where this change needs it. A change to product-level truth belongs in the Product Specification. Requirements only: no architecture, technical design or implementation detail. Existing behaviour is not a requirement just because it exists.
>
> Each line under a heading describes what belongs there. Replace it with confirmed content. If a section does not apply, say so in one line. Undecided questions go under Open questions.

## Feature

The name of the feature or change, why it is needed, and who or what is affected.

## Current and desired behaviour

### Current behaviour

The existing observable behaviour that matters for understanding the change, not how it is implemented. If there is no meaningful current behaviour, say so in one line.

### Desired behaviour

The agreed, externally observable behaviour after the change.

## Key scenarios

How users or actors use the feature: the action or condition, and the expected result.

## Scope

### In scope

What this feature or change includes.

### Out of scope

What this feature or change explicitly does not include.

## Business rules

Rules that apply specifically to this change. A product-wide rule is referenced only where this feature is ambiguous without it.

## Edge cases

Boundary or exceptional conditions, including failures a user can observe, that change the expected behaviour, and what should happen. Only those that matter to this feature.

## User-facing text

The main user-facing text of this feature, such as button labels, commands, messages, confirmations, meaningful errors and empty states and notifications, quoted verbatim in the product's language as the user agreed. Where only the meaning was agreed, record the meaning. Text that already lives in the Product Specification is not restated here, and reusable tone and wording conventions belong in `ux-guide.md`. Text not agreed yet goes under Open questions. If the feature has no user-facing interaction, say so in one line.

## Acceptance criteria

Feature-level acceptance criteria, each an observable, verifiable result or rule: what a user or actor can do, under which conditions, and what they observe.

## Constraints and dependencies

Known product or business constraints, and dependencies that affect externally observable behaviour. A technical fact belongs here only as an external, mandatory constraint, never as a solution. If a known requirement or constraint must be satisfied before applicable public launch, mark its line `[before public launch]`, for example `- [before public launch] A Privacy Policy must be available to users.` Use the marker only when that need is already known from the user's decision, an approved requirement or a known external constraint, never because something is usually needed. The line stays here after a related open question is resolved, with the concrete value if it belongs to this feature specification.

## Open questions

Unresolved feature questions and decisions, one per line, each stating what is undecided. An unresolved item is not a requirement and must not be worded as one. A question that is already known not to block this specification but must be resolved before applicable public launch is marked `[before public launch]`, for example `- [before public launch] Exact Privacy Policy URL is not known yet.` The section decides what a marked line is: under Constraints and dependencies it is a known requirement, here it is an unresolved question. When the question is resolved, remove it. The requirement stays under Constraints and dependencies if the condition still applies. Questions without the marker stay as they are.

None recorded yet.
