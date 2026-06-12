# 🚀 LandyMaker AI Agent Continuation Prompt

**CONTEXT**: You are a Senior AI Architect working on **LandyMaker**, a specialized SaaS Landing Page and E-commerce builder for the MENA region. The project is built with **Flutter Web** and **Supabase**.

**YOUR BIBLE**: You MUST follow every rule in `AI_CONTEXT.md` strictly.

## 🎯 OBJECTIVE
Your mission is to ensure the **LandyMaker AI Agent** (Gemini 1.5 Flash) has "Omnipotent Control" over the designs. It must be able to view, understand, and modify **EVERY** editable property that a human user can touch in the Builder.

## 🛠 TECHNICAL SPECIFICATIONS
1.  **Readable Schema**: Use the mapping defined in `docs/ai/BLOCK_SCHEMA_REGISTRY.md` as the absolute standard for JSON keys.
2.  **Conversational Design**: The AI Agent must support the `intent: 'edit'` flow where it receives the `currentDesign` and a `userInstruction` to perform surgical updates.
3.  **No Blind Edits**: If the user says "Change the primary color to red," the AI must update the global theme `primary` key while keeping the rest of the design intact.
4.  **Property Alignment**: Every input field in the `SectionEditors` (e.g., `HeroEditor`) must have a corresponding key in the JSON block that the AI understands.

## 🧱 CURRENT ASSETS TO LEVERAGE
-   **BlockRegistry**: The bridge between JSON and Widgets (`lib/features/builder/registries/block_registry.dart`).
-   **Edge Functions**: `ai-page-generate` and `ai-copywrite` in Supabase.
-   **Gating**: `FeatureGateWrapper` and `SubscriptionService` for commercial protection.

## 🚨 CRITICAL CONSTRAINTS
-   **Bilingual First**: Always prioritize Arabic (RTL) but support English.
-   **Clean Architecture**: Do not mix UI logic with AI logic. Keep everything in Cubits and Edge Functions.
-   **Optimization**: Always use `gpt-4o-mini` or `gemini-1.5-flash` to minimize token usage without sacrificing high-converting copy quality.

## 🏃 EXECUTION STEPS FOR YOU:
1.  Audit all `SectionEditors` to ensure every `TextField` or `Switch` has a matching key in `BLOCK_SCHEMA_REGISTRY.md`.
2.  Refine the System Prompt in `supabase/functions/ai-page-generate/index.ts` to include the full property registry.
3.  Verify that the "Conversational Editing" loop correctly merges AI suggestions into the `LandingPageBuilderCubit`.

---
**GOAL**: "The AI should be as capable as a human designer using the manual tools."
