# POWER_PROMPT_LITE

# LandyMaker Fast Execution Framework

Hello AI Assistant!

You are implementing a focused task inside the LandyMaker project.

Your goal is to solve the requested task with minimal token usage while respecting project architecture and documentation rules.

---

# STEP 1 — Minimal Context Loading

Read only:

1. AI_CONTEXT.md
2. docs/ai/AI_DOCUMENTATION_RULES.md

Then read ONLY the files directly related to the task.

Do not scan the entire repository.

Do not read unrelated features.

---

# STEP 2 — Task Size Detection

Determine whether the request is:

## Small Task

Examples:

* Bug fixes
* UI tweaks
* Styling adjustments
* Validation fixes
* Small widget changes
* Small refactors

If Small:

Continue immediately.

## Large Task

Examples:

* New feature
* Architecture change
* Migration
* Database change
* Multi-module refactor
* More than 4 implementation phases

If Large:

Stop immediately.

Recommend switching to POWER_PROMPT_FULL.

Do not continue implementation.

---

# STEP 3 — Duplicate Prevention

Before creating any:

* Widget
* Service
* Provider
* Model
* Utility
* Helper

Search the related code first.

Prefer modifying existing implementations.

Avoid duplicate systems.

---

# STEP 4 — Direct Execution

Implement the requested task immediately.

Run applicable validation.

At minimum:

* flutter analyze

Fix issues introduced by your changes.

---

# Lightweight Engineering Audit

While touching files, watch for:

* Performance issues
* Duplicate code
* Dead code
* UX problems
* Responsive issues
* Flutter Web issues

Record only significant findings.

---

# Completion Report

Provide the report in Arabic.

## ✅ ملخص التنفيذ

Explain what was changed.

## 📁 الملفات المعدلة

List all modified files.

## 🔍 إعادة الاستخدام

Explain what existing code was reused instead of creating new code.

## 💡 فرص التحسين

Include only high-value findings.

## 📚 تأثير التوثيق

State either:

* لا يوجد تحديث مطلوب للوثائق

OR

* يجب تحديث:

  * file1
  * file2

---

Keep responses concise.

Avoid repository-wide analysis.

Avoid planning.

Avoid unnecessary documentation reviews.

Focus on fast execution and minimal token usage.
