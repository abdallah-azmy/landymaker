# 🎯 Builder Audit — Progress Tracker

> **PURPOSE**: This file is the single source of truth for resuming work after a context reset or token limit.
> **READ THIS FILE FIRST** before doing anything else in any session.
> **UPDATE THIS FILE** after completing EACH sub-task (e.g., after task 1.1, before 1.2).

---

## 🔴 CURRENT STATUS

```
STATUS        : NOT STARTED
CURRENT PHASE : —
CURRENT TASK  : Read required docs first (see Section: Next Action)
LAST UPDATED  : —
```

---

## ▶️ NEXT ACTION

> This section always tells you EXACTLY what to do next. Update it after every task.

```
Read docs in order:
1. docs/ai/AI_CONTEXT.md
2. docs/ai/AI_DOCUMENTATION_RULES.md
3. docs/ai/BUILDER_ARCHITECTURE.md
4. docs/ai/BLOCK_SCHEMA_REGISTRY.md
5. docs/ai/THEME_SYSTEM.md
6. lib/features/builder/README.md
7. lib/features/public_viewer/README.md
8. docs/plans/BUILDER_PAGE_COMPREHENSIVE_AUDIT_PLAN.md

Then begin Phase 1, Task 1.1.
```

---

## ✅ Completed Phases

| Phase | Title | Completed | Files Modified |
|-------|-------|-----------|---------------|
| — | — | — | — |

---

## 📋 Completed Tasks (Granular)

> One row per completed sub-task. Add rows as you go.

| Task ID | Description | Files Changed | Key Finding |
|---------|-------------|---------------|-------------|
| — | — | — | — |

---

## 🐛 Bugs Catalog

> Track every bug found across all phases. Use this to cross-reference the report.

| Bug ID | Phase | File | Description | Status |
|--------|-------|------|-------------|--------|
| — | — | — | — | — |

---

## 📁 Files Already Read

> Track which files you've already read to avoid re-reading.

| File | Read In Phase | Notes |
|------|--------------|-------|
| — | — | — |

---

## 🔑 Key Architectural Findings

> Running notes on important architecture discoveries. Update as you learn.

```
(Empty — will be filled as work progresses)
```

---

## ⚙️ How to Update This File

After completing EACH sub-task:
1. Update `CURRENT STATUS` block (STATUS, CURRENT PHASE, CURRENT TASK, LAST UPDATED).
2. Update `NEXT ACTION` to the next task ID and description.
3. Add a row to `Completed Tasks` for the just-finished task.
4. If a bug was found, add it to `Bugs Catalog`.
5. If you read new files, add them to `Files Already Read`.
6. If you learned something architecturally important, add it to `Key Architectural Findings`.

### Status Values
- `NOT STARTED` — No work done yet
- `IN PROGRESS` — Currently executing phase N
- `PHASE N DONE` — Phase N complete, N+1 not started
- `COMPLETE` — All 15 phases done

### Example of a correctly updated Status block after finishing task 1.1:
```
STATUS        : IN PROGRESS
CURRENT PHASE : 1 — Font Picker Bug
CURRENT TASK  : 1.2 (Trace font application to canvas)
LAST UPDATED  : 2026-06-30T02:15:00Z

FINDING FROM 1.1: DesignFontsTab uses BlocBuilder<BuilderThemeCubit> correctly
but updateThemeProperty call uses key 'font_family' instead of 'defaultFont' —
this key mismatch means the theme update fires but LandingPageTheme.fromJson reads
'defaultFont' ?? 'font_family', so it may or may not work depending on sync order.
NEEDS FIX IN: design_fonts_tab.dart line ~84
```
