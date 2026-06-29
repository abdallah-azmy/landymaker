/// ======================================================
/// FEATURE: Builder State Management
/// PURPOSE: Core logic for editing landing pages (Undo/Redo, Auto-save)
/// USED BY: BuilderWorkspaceScreen
/// DEPENDENCIES:
/// - DatabaseService
/// - StorageService
/// - TemplateRegistry
/// ======================================================

import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:landymaker/features/builder/controllers/upload_manager_cubit.dart';
import 'package:landymaker/features/builder/models/selected_image_data.dart';
import 'package:landymaker/injection_container.dart';
import 'package:landymaker/services/image_media_service.dart';
import 'package:uuid/uuid.dart';
import '../../../services/auth_service.dart';
import '../../../services/database_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/subscription_service.dart';
import '../models/landing_page_theme.dart';
import '../registries/template_registry.dart';
import 'builder_state.dart';
import 'builder_theme_cubit.dart';

part 'builder_cubit_blocks.dart';
part 'builder_cubit_persistence.dart';

/// [LandingPageBuilderCubit] — central state manager for the landing page builder.
///
/// **Responsibility**: Owns the entire page editing lifecycle (blocks, theme, undo/redo,
/// auto-save, page loading, image management, settings).
/// **Used by**: `BuilderWorkspaceScreen` (and its child widgets via `BlocProvider`).
/// **Key state**: `BuilderState` (typically `BuilderLoaded`) containing `designMap`,
/// `theme`, `subdomain`, `pageId`, `isPublished`, undo/redo flags, messages.
/// **⚠️ AI Warning**: Do NOT change `_history` / `_historyIndex` logic, `_emitDirty`,
/// or the `_themeSubscription` listener — these are critical for undo/redo and
/// theme sync. Do NOT remove `_suppressHistoryFromTheme` guard.
class LandingPageBuilderCubit extends Cubit<BuilderState>
    with BuilderCubitBlocks, BuilderCubitPersistence {
  /// Auth service for current user identity.
  final AuthService _authService;

  /// Database service for CRUD on landing pages.
  final DatabaseService _databaseService;

  /// Storage service for file uploads (images, etc.).
  final StorageService _storageService;

  /// Subscription service for page-limit checks.
  final SubscriptionService _subscriptionService;

  /// Theme cubit — any theme change emitted here is mirrored into the builder state.
  final BuilderThemeCubit _themeCubit;

  /// Subscription to theme changes from `_themeCubit`.
  StreamSubscription? _themeSubscription;

  /// Guard against re-recording history when theme changes originate from undo/redo.
  bool _suppressHistoryFromTheme = false;

  /// Serialised history stack of `{designMap, theme}` snapshots for undo/redo.
  final List<String> _history = [];

  /// Current position in `_history` (-1 = no history).
  int _historyIndex = -1;

  /// Creates the cubit, wires dependencies, and starts listening to theme changes.
  ///
  /// Initialises with `BuilderInitial`. Every theme change from `_themeCubit` is
  /// merged into the current `BuilderLoaded` state (unless suppressed by undo/redo).
  /// **⚠️ Do NOT remove the theme subscription — it is the only link between theme
  /// edits in the panel and the builder state.**
  LandingPageBuilderCubit({
    required AuthService authService,
    required DatabaseService databaseService,
    required StorageService storageService,
    required SubscriptionService subscriptionService,
    required BuilderThemeCubit themeCubit,
  }) : _authService = authService,
       _databaseService = databaseService,
       _storageService = storageService,
       _subscriptionService = subscriptionService,
       _themeCubit = themeCubit,
       super(BuilderInitial()) {
    _themeSubscription = _themeCubit.stream.listen((theme) {
      if (_suppressHistoryFromTheme) return;
      final currentState = state;
      if (currentState is BuilderLoaded) {
        _emitDirty(currentState.copyWith(theme: theme));
      }
    });
  }

  /// Cancels the theme subscription and closes the cubit.
  @override
  Future<void> close() {
    _themeSubscription?.cancel();
    return super.close();
  }

  /// Serialises [state]'s design+theme and pushes onto the undo stack.
  ///
  /// Trims any redo branch ahead of the current index. Caps history at 50 entries.
  /// Skips if the new snapshot is identical to the current top.
  void _saveToHistory(BuilderLoaded state) {
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }

    final newStateStr = jsonEncode({
      'designMap': state.designMap,
      'theme': state.theme.toJson(),
    });

    // Do not add duplicate states if the data hasn't actually changed
    if (_history.isNotEmpty &&
        _historyIndex >= 0 &&
        _historyIndex < _history.length) {
      if (_history[_historyIndex] == newStateStr) {
        return;
      }
    }

    _history.add(newStateStr);
    _historyIndex = _history.length - 1;

    // Limit history to 50 steps
    if (_history.length > 50) {
      _history.removeAt(0);
      _historyIndex--;
    }
  }

  /// Emits [state] with up-to-date `hasUnsavedChanges`, `canUndo`, `canRedo` flags.
  ///
  /// Saves to history unless [skipHistory] is true. Sets `hasUnsavedChanges` to
  /// `!isClean`. This is the single emit-path for all mutations — always call this
  /// instead of `emit()` directly.
  void _emitDirty(
    BuilderLoaded state, {
    bool isClean = false,
    bool skipHistory = false,
  }) {
    if (!skipHistory) {
      _saveToHistory(state);
    }
    emit(
      state.copyWith(
        hasUnsavedChanges: !isClean,
        canUndo: _historyIndex > 0,
        canRedo: _historyIndex < _history.length - 1,
      ),
    );
  }

  /// Steps back one entry in the undo history.
  ///
  /// Restores both `designMap` and `theme` from the serialised snapshot. Suppresses
  /// theme-cubit re-entry via `_suppressHistoryFromTheme`.
  Future<void> undo() async {
    final currentState = state;
    if (currentState is! BuilderLoaded || _historyIndex <= 0) return;

    _historyIndex--;
    final snapshot = await Isolate.run(
      () => Map<String, dynamic>.from(jsonDecode(_history[_historyIndex])),
    );
    final restoredTheme = LandingPageTheme.fromJson(snapshot['theme']);
    _suppressHistoryFromTheme = true;
    _themeCubit.replaceTheme(restoredTheme);
    _suppressHistoryFromTheme = false;
    _emitDirty(
      currentState.copyWith(
        designMap: snapshot['designMap'],
        theme: restoredTheme,
      ),
      isClean: false,
      skipHistory: true,
    );
  }

  /// Steps forward one entry in the redo history.
  ///
  /// Same restoration logic as `undo()`.
  Future<void> redo() async {
    final currentState = state;
    if (currentState is! BuilderLoaded || _historyIndex >= _history.length - 1)
      return;

    _historyIndex++;
    final snapshot = await Isolate.run(
      () => Map<String, dynamic>.from(jsonDecode(_history[_historyIndex])),
    );
    final restoredTheme = LandingPageTheme.fromJson(snapshot['theme']);
    _suppressHistoryFromTheme = true;
    _themeCubit.replaceTheme(restoredTheme);
    _suppressHistoryFromTheme = false;
    _emitDirty(
      currentState.copyWith(
        designMap: snapshot['designMap'],
        theme: restoredTheme,
      ),
      isClean: false,
      skipHistory: true,
    );
  }
}
