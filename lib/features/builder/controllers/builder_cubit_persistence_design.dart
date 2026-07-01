part of 'builder_cubit.dart';

/// Mixin handling AI/external design JSON merge operations.
mixin BuilderCubitPersistenceDesign on Cubit<BuilderState> {
  void _emitDirty(
    BuilderLoaded state, {
    bool isClean = false,
    bool skipHistory = false,
  });
  BuilderThemeCubit get _themeCubit;
  bool get _suppressHistoryFromTheme;
  set _suppressHistoryFromTheme(bool value);

  /// Merges an incoming JSON design (from AI or external source) into the current state.
  ///
  /// Supports three modes:
  /// - `full_rebuild`: replaces all blocks.
  /// - Partial (blocks with `_index`): merge/replace at specific indices.
  /// - Full list: heuristic subset-edit or block-by-block merge by type.
  /// Also merges theme and top-level metadata. Does NOT skip history.
  /// Called when AI generates or edits a design.
  void applyDesignJson(Map<String, dynamic> designJson) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    // 1. Theme Update
    LandingPageTheme? newTheme;
    final themeJson = designJson['theme'] ?? designJson['global_theme'];
    if (themeJson != null && themeJson is Map) {
      final Map<String, dynamic> mergedThemeJson = currentState.theme.toJson();
      themeJson.forEach((key, value) {
        if (value != null) {
          mergedThemeJson[key] = value;
        }
      });
      newTheme = LandingPageTheme.fromJson(mergedThemeJson);
    }

    // 2. Blocks Update
    Map<String, dynamic> newDesignMap = Map<String, dynamic>.from(
      currentState.designMap,
    );
    if (newTheme != null) {
      newDesignMap['theme'] = newTheme.toJson();
      newDesignMap['global_theme'] = newTheme.toJson();
    }

    final List incomingBlocks = designJson['blocks'] as List? ?? [];

    // Check if it's a partial update (contains _index)
    bool isPartial = incomingBlocks.any(
      (b) => b is Map && b.containsKey('_index'),
    );
    final bool isFullRebuild = designJson['full_rebuild'] == true;

    if (isFullRebuild) {
      newDesignMap['blocks'] = incomingBlocks;
      designJson.forEach((key, value) {
        if (key != 'blocks' &&
            key != 'theme' &&
            key != 'global_theme' &&
            key != 'full_rebuild') {
          newDesignMap[key] = value;
        }
      });
    } else if (isPartial) {
      final List currentBlocks = List.from(newDesignMap['blocks'] ?? []);
      for (var block in incomingBlocks) {
        if (block is Map && block.containsKey('_index')) {
          final int index = block['_index'];
          if (index >= 0 && index < currentBlocks.length) {
            // Merge or replace specific block
            final existing = Map<String, dynamic>.from(
              currentBlocks[index] as Map,
            );
            final updated = Map<String, dynamic>.from(block)..remove('_index');
            final cleanedUpdated = _cleanIncomingMap(updated);
            existing.addAll(cleanedUpdated);
            currentBlocks[index] = existing;
          } else if (index == currentBlocks.length) {
            // New block at the end
            final updated = Map<String, dynamic>.from(block)..remove('_index');
            currentBlocks.add(_cleanIncomingMap(updated));
          }
        }
      }
      newDesignMap['blocks'] = currentBlocks;

      // Also update business info if provided
      if (designJson.containsKey('business_name'))
        newDesignMap['business_name'] = designJson['business_name'];
      if (designJson.containsKey('business_type'))
        newDesignMap['business_type'] = designJson['business_type'];
    } else {
      final List currentBlocks = List.from(newDesignMap['blocks'] ?? []);

      // Smart Heuristic: Check if the incoming blocks list is a subset edit
      bool isSubsetEdit = false;
      if (currentBlocks.isNotEmpty &&
          incomingBlocks.isNotEmpty &&
          incomingBlocks.length < currentBlocks.length) {
        final bool currentHasHero = currentBlocks.any(
          (b) => b is Map && (b['type'] == 'hero' || b['type'] == 'hero_saas'),
        );
        final bool incomingHasHero = incomingBlocks.any(
          (b) => b is Map && (b['type'] == 'hero' || b['type'] == 'hero_saas'),
        );

        if ((currentHasHero && !incomingHasHero) ||
            incomingBlocks.length <= 2) {
          isSubsetEdit = true;
        }
      }

      if (incomingBlocks.isEmpty) {
        // AI returned empty blocks - DO NOT overwrite with empty. Keep current blocks.
      } else if (isSubsetEdit) {
        // Merge incoming blocks into current blocks by matching their types sequentially
        final List<bool> matched = List.filled(currentBlocks.length, false);
        for (var inBlock in incomingBlocks) {
          if (inBlock is Map) {
            final String inType = (inBlock['type'] ?? '').toString();
            int matchIdx = -1;
            for (int j = 0; j < currentBlocks.length; j++) {
              if (!matched[j]) {
                final currentBlock = currentBlocks[j] as Map;
                if (currentBlock['type'] == inType) {
                  matchIdx = j;
                  break;
                }
              }
            }

            if (matchIdx != -1) {
              matched[matchIdx] = true;
              final existing = Map<String, dynamic>.from(
                currentBlocks[matchIdx] as Map,
              );
              final updated = Map<String, dynamic>.from(inBlock);
              final cleanedUpdated = _cleanIncomingMap(updated);
              existing.addAll(cleanedUpdated);
              currentBlocks[matchIdx] = existing;
            } else {
              // No matching type found, append it as a new block
              currentBlocks.add(
                _cleanIncomingMap(Map<String, dynamic>.from(inBlock)),
              );
            }
          }
        }
        newDesignMap['blocks'] = currentBlocks;
      } else {
        // Full update edit: merge block-by-block with current blocks.
        // We want to preserve all current blocks, and merge incoming blocks where they match.
        final List mergedBlocks = List.from(currentBlocks);
        final List<bool> mergedIndices = List.filled(
          currentBlocks.length,
          false,
        );

        for (int blockIdx = 0; blockIdx < incomingBlocks.length; blockIdx++) {
          final inBlock = incomingBlocks[blockIdx];
          if (inBlock is Map) {
            final String inType = (inBlock['type'] ?? '').toString();
            int matchIdx = -1;

            // First, try matching at the same index if the type matches and it's not already merged
            final int index = blockIdx;
            if (index < currentBlocks.length && !mergedIndices[index]) {
              final currentBlock = currentBlocks[index] as Map;
              if (currentBlock['type'] == inType) {
                matchIdx = index;
              }
            }

            // If no index match, search for the first unmerged block of the same type
            if (matchIdx == -1) {
              for (int j = 0; j < currentBlocks.length; j++) {
                if (!mergedIndices[j]) {
                  final currentBlock = currentBlocks[j] as Map;
                  if (currentBlock['type'] == inType) {
                    matchIdx = j;
                    break;
                  }
                }
              }
            }

            if (matchIdx != -1) {
              mergedIndices[matchIdx] = true;
              final existing = Map<String, dynamic>.from(
                mergedBlocks[matchIdx] as Map,
              );
              final cleanedInBlock = _cleanIncomingMap(
                Map<String, dynamic>.from(inBlock),
              );
              existing.addAll(cleanedInBlock);
              mergedBlocks[matchIdx] = existing;
            } else {
              // No matching block found, append it as a new block
              mergedBlocks.add(
                _cleanIncomingMap(Map<String, dynamic>.from(inBlock)),
              );
            }
          }
        }
        newDesignMap['blocks'] = mergedBlocks;
        designJson.forEach((key, value) {
          if (key != 'blocks' && key != 'theme' && key != 'global_theme') {
            newDesignMap[key] = value;
          }
        });
      }
    }

    if (newTheme != null) {
      _suppressHistoryFromTheme = true;
      _themeCubit.replaceTheme(newTheme);
      Future.microtask(() {
        _suppressHistoryFromTheme = false;
      });
    }
    DynamicFontService.loadFontsFromDesign(newDesignMap);
    _emitDirty(
      currentState.copyWith(
        designMap: newDesignMap,
        theme: newTheme,
        hasUnsavedChanges: true,
      ),
    );
  }

  /// Recursively strips null/empty values from [map].
  ///
  /// Used to sanitise incoming AI/API data before merging into the design.
  /// Never returns nulls or empty strings — these are considered "unset".
  Map<String, dynamic> _cleanIncomingMap(Map<String, dynamic> map) {
    final cleaned = <String, dynamic>{};
    map.forEach((key, value) {
      if (value == null || value == "") {
        return;
      }
      if (value is Map<String, dynamic>) {
        cleaned[key] = _cleanIncomingMap(value);
      } else if (value is Map) {
        cleaned[key] = _cleanIncomingMap(Map<String, dynamic>.from(value));
      } else if (value is List) {
        cleaned[key] = value
            .map((item) {
              if (item is Map<String, dynamic>) {
                return _cleanIncomingMap(item);
              } else if (item is Map) {
                return _cleanIncomingMap(Map<String, dynamic>.from(item));
              }
              return item;
            })
            .where((item) => item != null && item != "")
            .toList();
      } else {
        cleaned[key] = value;
      }
    });
    return cleaned;
  }
}
