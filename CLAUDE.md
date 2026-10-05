# CLAUDE.md

Working instructions for Claude Code when developing **ai-dev-framework** itself. This is not the README; keep it short and keep it true.

## 1. Purpose

- ai-dev-framework is a reusable, AI-assisted software development framework covering the full engineering cycle: idea and requirements, architecture, implementation, testing, code review, documentation and deployment.
- The first and main implementation is optimized for Claude Code. The framework must not be conceptually tied to Claude Code alone: the methodology and core artifacts should remain reusable across AI development tools.

## 2. Working in this repository

- Follow the agreed repository structure.
- Do not add new skills, agents, templates, scripts, folders or any other entities unless explicitly asked.
- Do not rename or delete existing entities unless explicitly asked.
- Do not touch files that are unrelated to the current task.
- Do not make significant architectural decisions on your own. Propose, then wait for agreement.
- If something is ambiguous, ask first. A short question is cheaper than a wrong file tree.
- Do not commit unless asked.

## 3. Skills and agents

- Design and implement skills first, agents second.
- Every skill has exactly one required `SKILL.md`. Add extra reference files only when there is a real need, not because a folder looks lonely.
- Reviewer agents perform independent verification. `ui-designer` is the deliberate exception: a design agent that sets a pre-implementation visual and interaction direction, and is neither a verification agent nor a gate. Agents must not duplicate the main skill's work without a reason.
- No entities for the sake of count. Fewer, sharper pieces beat a large, decorative catalog.

## 4. Quality

- Use explicit PASS/FAIL quality gates for significant stages.
- After a FAIL: fix the findings first, then re-run the check.
- Do not proceed to the next stage while a mandatory check is failing.
- Respect the source of truth. Specs, project context, code and documentation must not contradict each other; when they do, resolve it at the source instead of patching symptoms.
- Prefer the minimally sufficient solution, and check the result for overengineering before calling it done.

## 5. Infrastructure minimalism

- Use existing infrastructure first.
- Do not add GitHub Actions, Vercel, Supabase, AWS, managed databases, third-party CI/CD or any other external service by default.
- Every new infrastructure service must solve a specific, stated problem and be justified.
- Order of choice: **existing infrastructure → scripts and local automation → self-hosted automation → external managed service.**
- Do not design infrastructure for imaginary scale.
- Prefer portable solutions and avoid needless vendor lock-in.

## 6. Style

- All framework files are written in English, except `README.ru.md`.
- Be technically precise, lively and clear. Moderate irony is fine when it helps the meaning.
- Avoid sterile corporate language and bureaucratese.
- No profanity.
