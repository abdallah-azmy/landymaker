# LANDYMAKER FAST POWER PROMPT

Follow AI_CONTEXT.md as the Single Source of Truth.

---

# QUICK DISCOVERY MODE

Before implementation:

Read:

1. AI_CONTEXT.md
2. docs/ai/AI_ONBOARDING.md
3. docs/ai/AI_NAVIGATION.md
4. docs/ai/TASK_ROUTING_GUIDE.md
5. docs/ai/AI_DOCUMENTATION_RULES.md

Identify the affected subsystem.

Then read only the relevant documentation.

Examples:

If task relates to screens:
→ SCREEN_INDEX.md

If task relates to routes:
→ ROUTE_INDEX.md

If task relates to services:
→ SERVICE_INDEX.md

If task relates to features:
→ FEATURE_INDEX.md

If task relates to Builder:
→ BUILDER_ARCHITECTURE.md

If task relates to dependencies:
→ DEPENDENCY_MAPS.md

Do NOT scan unrelated project areas.

Documentation-first navigation is mandatory.

---

# QUICK ANALYSIS

Before coding:

1. Explain the task.
2. Identify affected systems.
3. Identify affected files.
4. Identify risks.
5. Explain implementation approach.

---

# EXECUTION RULES

* Reuse existing code first.
* Preserve architecture.
* Preserve backward compatibility.
* Never guess.
* Never invent implementations.
* Verify before modifying.
* Search before creating new files.
* Extend before replacing.

---

# PROTECTED SYSTEMS

Do not break:

* Builder Workspace
* JSON Schema
* Parser Layer
* SectionRenderer
* ActionHandlerService
* Auto Save
* Undo / Redo
* Supabase Sync
* Publish Flow
* Security Layer
* SEO Layer

---

# SECURITY RULES

Verify:

* No secrets exposed.
* No hardcoded keys.
* Existing validation preserved.
* Existing Turnstile preserved.
* Existing Rate Limiting preserved.
* Existing security assumptions preserved.

---

# LIGHTWEIGHT DOCUMENTATION AUDIT

If the task introduces or modifies:

* Screens
* Features
* Services
* Routes
* Builder Components
* Folder Structure

Verify whether AI documentation should be updated.

Keep documentation synchronized with the codebase.

---

# QUALITY CHECK

Verify:

* No compile errors.
* No analyzer errors.
* No null-safety issues.
* No dead code.
* No duplicate logic.
* No unused imports.
* No architecture violations.
* No RTL regressions.
* No responsiveness regressions.

---

# FINAL REPORT

Provide Arabic report containing:

1. Files inspected.
2. Files modified.
3. Files created (if any).
4. What changed.
5. Risks.
6. Manual testing steps.
7. AI documentation updates (if applicable).
8. Recommendations.

---

# TASK REQUEST

(Insert task here)
