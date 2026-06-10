# Interactive AI Agent - Deep Analysis

## Overview
This document analyzes the current state of LandyMaker's AI and Builder systems to prepare for the transformation into a true AI-native conversational builder.

## Existing AI Flow
- **Trigger**: Currently triggered via `AIGenerationCubit.generatePage`.
- **Backend**: `ai-page-generate` Edge Function (Deno/TypeScript).
- **Model**: Gemini 1.5 Flash.
- **Payload**: Includes business info, intent (`create`/`edit`), current design, and instructions.
- **Process**: 
  1. Frontend sends request.
  2. Edge Function constructs a prompt based on `BLOCK_SCHEMA_REGISTRY`.
  3. AI generates JSON.
  4. Edge Function resolves `pixabay_search` placeholders into real URLs.
  5. Frontend receives `designJson` and applies it.

## Existing Builder Flow
- **State**: `LandingPageBuilderCubit` manages `designMap` (JSON).
- **Rendering**: `SectionRenderer` parses JSON and renders Flutter widgets.
- **Updates**: `updateElementProperty` for granular changes, `applyDesignJson` for full page updates.
- **History**: Local undo/redo stack (up to 50 steps).
- **Auto-save**: Persists to Supabase `landing_pages` table.

## Existing State Flow
- **BuilderState**: `Initial`, `Loading`, `Loaded`, `Error`.
- **AIGenerationState**: `Initial`, `Loading`, `PixabaySelection`, `Success`, `Failure`.
- **UploadManagerState**: Map of `UploadTask` tracked by `upload://` UUIDs.

## Existing Asset Flow
- **Deduplication**: SHA-256 hashing of bytes before upload.
- **Storage**: ImgBB for CDN delivery, Supabase `user_assets` for gallery/ownership.
- **Lazy Loading**: `CustomNetworkImage` handles `upload://` scheme and shimmer loading.

## Existing Pixabay Flow
- **Search**: `PixabaySelectorCubit` and `PixabaySelectorModal`.
- **AI Integration**: AI can return a `pixabay_selection` action which triggers the modal on the frontend.
- **Automated RESOLUTION**: Edge function can automatically fetch the first few results for `pixabay_search` keys.

## Existing ToastService Usage
- Custom `ToastService` using `toastification` package.
- Methods: `showSuccess`, `showError`, `showInfo`.
- Standards: Neon Cyan for success, Danger Red for error, standard project colors for info.

## Existing API Contracts
- **ai-page-generate**:
  - Request: `businessName`, `businessType`, `location`, `language`, `offer`, `intent`, `currentDesign`, `instruction`.
  - Response: `{ designJson: Map<String, dynamic> }`.

## Existing Cubit States
- `AIGenerationCubit`: Manages the lifecycle of an AI request.
- `LandingPageBuilderCubit`: Manages the actual page data.
- `UploadManagerCubit`: Manages background uploads.

## Existing Data Models
- `ThemeModel`: Global styles (colors, fonts).
- `SelectedImageData`: Wrapper for image source and data.
- `UploadTask`: Tracks progress and errors for uploads.

## Existing Risks
1. **Token Inefficiency**: Sending the full `designMap` on every "edit" request will quickly hit token limits for large pages.
2. **Context Fragmentation**: The AI doesn't have a "memory" of previous interactions beyond the immediate instruction.
3. **Validation Gap**: AI might return malformed JSON or invalid schema properties that could crash the renderer.
4. **Latency**: Multiple Pixabay API calls + Gemini can be slow.
5. **State Desync**: Rapid AI edits might conflict with local manual edits if not handled carefully.

## Conclusion
The foundation is strong, but the "Target Flow" requires a dedicated conversation memory system, context compression, and a more robust input experience.
