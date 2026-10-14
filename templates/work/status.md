# Workflow status

> The ledger of confirmed gate results and explicit user approvals. It is the one place where the workflow state lives between sessions, and it is written and checked only by `workflow-state.ps1`. A row is a claim, not a proof: it counts only while the script reports it `FRESH`. Never edit a row by hand. To forget a row, delete its line.

**Work items.** A work item id is the name of its folder under `.claude/work/`. A microchange has no folder: `/build-feature` picks a short kebab-case id that is not a folder under `.claude/work/` or `.claude/work/completed/` and not the id of a different change in this ledger, and records it in a `scope` row. Project-level rows use the subjects `product-spec` and `architecture`.

**Subjects.** `<id>` for implementation gates and `scope`. `<id>/feature-spec` and `<id>/tech-spec` for `review-spec`. `<id>@<target>` for `deploy-check`. `<id>#<topic>` or `project#<topic>` for approvals.

**Rows.**

- `scope`: written by `/build-feature`. Its inputs are all files of the work item (code, tests, configuration), and its note starts with `kind=feature`, `kind=product` or `kind=microchange`. A later run records the whole scope again.
- A gate row (`review-spec`, `architecture`, `test-feature`, `review-code`, `update-docs`, `deploy-check`): `PASS`, `by=reviewer`. Written by the owner skill of the gate, as its very last step, only after a valid reviewer PASS and its own integrity check. Only a PASS is recorded. A FAIL or BLOCKED result leaves no row.
- An approval (`approval`): `APPROVED`, `by=user`. Written by the skill that asked, only after the user's own answer in the conversation, with the user's decision in the note. An approval of a specific version of an artifact (a spec, a configuration, a release file) must list that artifact as inputs, so that it goes stale when the artifact changes. Only an independent confirmation, one that is about no file (for example that an external account exists), is recorded with no inputs, and it then holds until its line is deleted.
- An explicit user confirmation of a gate state is the gate's own row with `by=user`. The skill that received the confirmation writes it, with the inputs the gate itself would record.
- A `by=user` row never counts as a reviewer PASS, and a `by=reviewer` row never counts as a user approval.

**Fresh.** `check` reports a row `FRESH` only if every recorded input still has its recorded content hash, no file of the work item's current scope is missing from the inputs of a row recorded `+scope`, no project file outside `.claude/` that no work item's `scope` row lists has been added or removed since such a row was recorded (a new file that nobody has claimed could belong to anything, so it makes every such PASS stale until a `scope` row claims it, and then only the PASSes of the work item that claimed it are affected), and no earlier gate row of the same work item (`test-feature`, then `review-code`, `update-docs`, `deploy-check`) is stale or was recorded later. Anything else is `STALE`, with the reason. A stale or missing row is not established: run the gate again, or ask the user to confirm explicitly.

**Stage.** There is no stage field. The current stage is the first step of the existing chain for the work item whose result is not `FRESH`, or whose artifact does not exist yet.

**Commands**, run from the project root with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%USERPROFILE%\.claude\ai-dev-framework\scripts\workflow-state.ps1"` (write the path the way your shell expects it, for example `$USERPROFILE` in Git Bash). Always keep `-ExecutionPolicy Bypass`: without it a restrictive policy refuses to load the script. Do not change the machine's policy:

- `check [-Item <id>]` prints every row (or one item's rows) with its state. It writes nothing.
- `record -Gate <gate> -Subject <subject> [-Verdict PASS|APPROVED] [-By reviewer|user] [-Inputs <path>,<path>] [-WithScope] [-Note <text>]` writes or replaces the row with the same gate and subject. Paths are relative to the project root. `-WithScope` adds the files of the item's `scope` row to the inputs.

Without Git on the machine the script cannot hash, and nothing in this ledger counts.

| gate | subject | verdict | by | inputs | note | date |
| --- | --- | --- | --- | --- | --- | --- |
