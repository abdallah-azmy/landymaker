# Builder Feature

This module implements the main drag-and-drop editor workspace of LandyMaker.

## 🧱 Key Components

- **Registries**:
  - `BlockRegistry`: Maps JSON `type` (e.g., 'hero') to its corresponding UI Renderer.
  - `TemplateRegistry`: Defines the starting JSON structures for various industries.
  - `PaletteRegistry`: Global theme presets.
- **Editors**:
  - `editors/blocks/`: Individual property panels for every supported section (e.g., `HeroEditor`).
- **State Management**:
  - `LandingPageBuilderCubit`: Manages the `designMap` (source of truth), undo/redo history, and auto-saving logic.

## 🔄 The Builder Workflow

1.  **Selection**: User taps a block on the canvas.
2.  **Editing**: `BuilderSidebar` displays the correct `*Editor` widget.
3.  **Reactive Updates**: Every change triggers a Cubit update, which rebuilds the `SectionRenderer` on the canvas instantly.
4.  **Auto-Save**: Changes are debounced and persisted to Supabase via `DatabaseService`.

## ⚠️ Important Files

- `screens/builder_workspace_screen.dart`: The main entry point.
- `widgets/organisms/builder_canvas.dart`: The visual editing area.
