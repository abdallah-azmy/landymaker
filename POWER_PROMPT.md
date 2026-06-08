
**Role**: Senior Flutter UI/UX Developer & System Architect.
**Project**: **LandyMaker** (لاندي ميكر) - A Professional SaaS Builder.

**CRITICAL PREREQUISITE**: 
Before writing any code, you **MUST** read and strictly adhere to the project's core memory file: `AI_CONTEXT.md`. This file contains the definitive rules for Architecture, Security, CI/CD, and RTL (Arabic-first) patterns. Your implementation must not break any existing logic defined there.

**UI/UX Professional Standards (Mandatory)**:
Every component or section you build MUST follow these "UI/UX 2.0" standards:
1. **The 3-Tab Rule**: Every section editor MUST have a TabBar with:
   - **[المحتوى - Content]**: For texts, titles, and data fields.
   - **[الأفعال - Actions]**: For buttons, links, and WhatsApp triggers.
   - **[التصميم - Design]**: For backgrounds, padding, font-family, and overlays.
2. **Smart Media Management**: NEVER use plain text fields for image URLs. Use the custom component `CustomImageField`. It handles thumbnails and opens the `ImagePickerModal`.
3. **Visual Readability & Overlays**: Any section with a background image MUST include a `bg_overlay_opacity` slider (0.0 to 1.0) and a `bg_overlay_color` picker to ensure text remains readable on any image.
4. **Responsivity**: Use `LayoutBuilder` and `constraints.maxWidth` for all layout logic. Do NOT use hardcoded heights or `MediaQuery` for component-level responsivity.
5. **Branding & Consistency**: Use `CustomTextField` for all inputs. Labels must be bilingual using `context.translate('key')`. Add new keys to both `translations_ar.dart` and `translations_en.dart`.
6. **State Integrity**: All design updates MUST be routed through `LandingPageBuilderCubit` to ensure Undo/Redo and Save functionality work correctly.

**Final Deliverable Requirement**:
Upon completing the task, you MUST provide a **Detailed Report in Arabic (تقرير مفصل باللغة العربية)** explaining exactly what was implemented, which files were changed, and how to verify the results.

---


Context: We are refactoring the "Builder Workspace" for LandyMaker, a SaaS Landing Page platform.
Goal: Transform the editor from a basic tool into a professional-grade builder like Carrd or Wix.

Strict Rules to Follow:
1. Follow project architecture in AI_CONTEXT.md (Clean Feature-Driven).
2. Never use hardcoded values for padding or sizes; use LayoutBuilder and constraints.maxWidth.
3. Use 'EnvUtils' for any environment variables.
4. Ensure Arabic-first support (RTL) is 100% accurate.

Task 1: Workspace Layout (lib/features/builder/screens/builder_workspace_screen.dart)
- Redesign the desktop view: Left sidebar should be fixed (350px), and the Canvas (Preview) should be centered with a subtle frame like a browser/tablet/mobile device.
- Add a "Device Switcher" in the top bar to toggle preview sizes (Desktop/Tablet/Mobile) instantly.

Task 2: Properties Editor (lib/features/builder/widgets/editors/block_properties_editor.dart)
- Refactor the UI to use Tabs: [Content, Style, Advanced].
- CONTENT: Edit all texts, buttons, and links.
- STYLE: Add controls for Background (Color/Image), Text Color, Font Size, and Spacing (Padding/Margin).
- IMAGE EDITING: Replace simple text fields for image URLs with a 'CustomImageField' widget that shows a thumbnail + 'Change' button which opens 'ImagePickerModal'.

Task 3: Visual Polish & Readability
- In every block that has a background image (Hero, Lead Magnet), add a property called 'overlay_opacity' (0.0 to 1.0).
- Update SectionRenderer to apply a black semi-transparent layer based on this value so text remains readable.
- Ensure all text inputs use 'CustomTextField' and have proper labels in Arabic and English.

Task 4: Component Deep-Link
- When the user clicks ANY element on the Preview Canvas, the Sidebar should automatically focus on that specific element's properties for "Instant Feedback".

Deliverable: Provide the full code for updated 'builder_workspace_screen.dart' and 'block_properties_editor.dart' ensuring NO logic is broken and all designMap data is saved correctly to Supabase.


---

