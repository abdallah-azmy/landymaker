# Builder Feature

The core drag-and-drop landing page editor. Manages the entire editing lifecycle: blocks, theme, undo/redo, auto-save, AI generation, template loading, and publishing.

## File Map

| Path | Role |
|------|------|
| `controllers/builder_cubit.dart` | `LandingPageBuilderCubit` — main cubit (207 lines): fields, constructor, `_history`/`_historyIndex`, `_emitDirty`, undo/redo |
| `controllers/builder_cubit_blocks.dart` | `BuilderCubitBlocks` mixin — 26 block CRUD methods (addBlock, removeBlock, duplicateBlock, moveBlock, updateBlockProperty, etc.) |
| `controllers/builder_cubit_persistence.dart` | `BuilderCubitPersistence` mixin — 18 persistence methods (loadPage, savePage, _saveGuestDesign, _handleLoadedPage, importTemplateAssets) |
| `controllers/builder_state.dart` | `BuilderState` — sealed class: `BuilderInitial`, `BuilderLoading`, `BuilderLoaded(designMap, theme, pageId, ...)`, `BuilderFailure` |
| `controllers/builder_theme_cubit.dart` | `BuilderThemeCubit` — separate cubit managing `LandingPageTheme`; main cubit subscribes to its stream |
| `controllers/ai_generation_cubit.dart` | `AIGenerationCubit` — AI chat session scoped per page (`ai_session_$pageId`) |
| `controllers/upload_manager_cubit.dart` | Manages image upload queue with progress tracking |
| `controllers/image_picker_cubit.dart` | Image picker state management |
| `controllers/pixabay_selector_cubit.dart` | Pixabay image search state |
| `screens/builder_workspace_screen.dart` | Main editor entry — desktop/mobile app bars, canvas, sidebar wiring |
| `screens/guest_preview_screen.dart` | Guest preview with mobile/desktop toggle |
| `registries/block_registry.dart` | Maps JSON `type` strings to Flutter render widgets (29 types) |
| `registries/template_registry.dart` | Barrel re-export for template modules |
| `registries/template_registry_base.dart` | `TemplateMetadata` + `TemplateRegistry` — public API |
| `registries/template_registry_saas.dart` | SaaS/Tech template designs (7 functions) |
| `registries/template_registry_ecommerce.dart` | E-commerce template designs (3 functions) |
| `registries/template_registry_services.dart` | Services/Local Business template designs (11 functions) |
| `registries/font_registry.dart` | Available Google Fonts for design |
| `models/landing_page_theme.dart` | `LandingPageTheme` — colors, fonts, backgrounds |
| `models/preview_mode.dart` | `PreviewMode` enum (desktop/mobile) |
| `models/selected_image_data.dart` | Image selection data class |
| `widgets/organisms/builder_canvas.dart` | Visual editing area with RepaintBoundary |
| `widgets/organisms/builder_sidebar.dart` | Sidebar shell with tab switching |
| `widgets/organisms/builder_app_bar.dart` | Editor toolbar (save, publish, undo/redo, preview) |
| `widgets/organisms/global_upload_manager_widget.dart` | Upload progress overlay |
| `widgets/tabs/builder_sidebar_tabs.dart` | Barrel re-export (9 lines) for 7 tab files |
| `widgets/tabs/outline_tab.dart` | Reorderable section list with visibility toggles |
| `widgets/tabs/templates_tab.dart` | Template type selection cards |
| `widgets/tabs/design_colors_tab.dart` | Palette list + custom color picker |
| `widgets/tabs/design_fonts_tab.dart` | Font family picker with preview |
| `widgets/tabs/design_tab.dart` | Composes MagicImageSwapper + DesignColorsTab + DesignFontsTab |
| `widgets/tabs/magic_image_swapper.dart` | Pixabay category field with preset chips |
| `widgets/tabs/content_tab.dart` | Quick-add buttons + section list |
| `widgets/editors/block_properties_editor.dart` | 1500-line editor dispatcher — routes block type to correct `*Editor` |
| `widgets/editors/block_actions.dart` | Block action settings |
| `widgets/editors/block_design_settings.dart` | Block design overrides (bg_color, theme_override, padding, animation) |
| `widgets/editors/blocks/` | 24 individual block editor files (hero_editor, pricing_editor, etc.) |
| `widgets/editors/common/dynamic_list_editor.dart` | Safe array-based property editor |
| `widgets/modals/section_library_modal.dart` | Shell (189 lines) + 3 part files (section_data, dual_mini_preview, section_variant_card) |
| `widgets/modals/builder_options_modal.dart` | Save, publish, SEO options |
| `widgets/modals/ai_chat_modal.dart` | AI conversational editor modal |
| `widgets/modals/seo_settings_modal.dart` | SEO metadata editor |
| `widgets/modals/image_picker_modal.dart` | Image selection dialog |
| `widgets/modals/pixabay_selector_modal.dart` | Pixabay image search UI |
| `widgets/layout_picker/` | Layout picker system (panel, option cards, slot grid) |
| `widgets/molecules/builder_mobile_toolbar.dart` | Mobile bottom toolbar |
| `widgets/molecules/section_toolbar_overlay.dart` | Selection/edit handles on canvas |
| `widgets/atoms/dynamic_styled_text.dart` | Dynamic text rendering |
| `widgets/atoms/dynamic_styled_image.dart` | Dynamic image rendering |

## State & Services

- `LandingPageBuilderCubit` — central state manager, split into 2 mixins (blocks + persistence)
- `BuilderThemeCubit` — owns `LandingPageTheme`, main cubit subscribes via stream
- `AIGenerationCubit` — per-page AI chat sessions
- `UploadManagerCubit` — image upload queue management
- All cubits use `BlocProvider` in `builder_workspace_screen.dart`

## ⚠️ AI Warnings

- **DO NOT merge mixin part files** — `builder_cubit_blocks.dart` and `builder_cubit_persistence.dart` are deliberately separated to stay under the 800-line AI readability limit.
- **`_emitDirty`** is the single emit-path — always call it instead of `emit()` directly. It handles history + dirty flag.
- **`_history` / `_historyIndex`** are critical for undo/redo. Do NOT modify the history logic.
- **`_suppressHistoryFromTheme`** prevents double-recording when undo/redo restores theme. Do NOT remove this guard.
- **`block_properties_editor.dart`** (1500 lines) is rebuild-isolated via `BlocSelector` but full split is deferred. Do NOT add new block type handlers inside it — use an existing or new `blocks/*_editor.dart` file.
- **`style_registry.dart`** is deprecated. Do NOT import or restore it.
- **29 block types** are registered in `BlockRegistry`. Do NOT generate a new type unless renderer, editor, default preset, and `schema_registry.json` entry all exist.
- **Isolate offloading**: All `jsonEncode`/`jsonDecode` must use `Isolate.run()` — never call them synchronously on the main thread.
- **`BuilderThemeCubit`** owns theme state. The font picker (`DesignFontsTab`) MUST listen to `BuilderThemeCubit` directly, NOT `LandingPageBuilderCubit`.
