# Infrastructure context

> Durable facts about the environments the project runs in and how it is delivered. Record what exists, never secret values and never deployment history. Approved infrastructure decisions may be recorded before any deployment. The actual deployed state of a target is recorded only after a real deployment confirmed it: current state, not history, kept per target. Infrastructure minimalism applies: existing setup first, then local scripts and automation, then self-hosted automation, and an external managed service only when justified. A project need not use every layer. New infrastructure is an architecture and design decision, not an entry here.

## Environments and hosting

TODO(infrastructure): known environments and the hosting or deployment model. With several targets, keep each target's facts under its own name.

## Delivery mechanism

TODO(infrastructure): how the project is built, deployed or released today, including existing scripts and automation.

## Runtime services and configuration

TODO(infrastructure): services the runtime depends on, where and how they run, and the names and purposes of configuration and secrets, never their values. The architectural role of a service belongs in `architecture.md`.

## Operational constraints

TODO(infrastructure): durable constraints on deploying, operating and recovering the project.
