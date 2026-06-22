import 'package:flutter/material.dart';
import 'cube_loader.dart';

/// Legacy enum — maps to [CubeLoaderState].
enum LoadingLogoState {
  idle,
  breathing,
  loading,
  success,
  error,
}

/// Legacy enum — maps to [CubeLoader] size tier.
enum LoadingLogoSize {
  micro,
  tiny,
  small,
  medium,
  large,
}

/// Thin wrapper around [CubeLoader] for backward compatibility.
///
/// Prefer using [CubeLoader] directly for new code.
class LoadingLogo extends StatelessWidget {
  final double size;
  final LoadingLogoState initialState;
  final bool interactive;
  final bool showGlow;

  const LoadingLogo({
    super.key,
    this.size = 48.0,
    this.initialState = LoadingLogoState.breathing,
    this.interactive = false,
    this.showGlow = true,
  });

  LoadingLogoSize get _tier {
    if (size <= 24) return LoadingLogoSize.micro;
    if (size <= 32) return LoadingLogoSize.tiny;
    if (size <= 48) return LoadingLogoSize.small;
    if (size <= 96) return LoadingLogoSize.medium;
    return LoadingLogoSize.large;
  }

  static CubeLoaderState _mapState(LoadingLogoState s) {
    switch (s) {
      case LoadingLogoState.idle: return CubeLoaderState.idle;
      case LoadingLogoState.breathing: return CubeLoaderState.breathing;
      case LoadingLogoState.loading: return CubeLoaderState.loading;
      case LoadingLogoState.success: return CubeLoaderState.success;
      case LoadingLogoState.error: return CubeLoaderState.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CubeLoader(
      size: size,
      initialState: _mapState(initialState),
      variant: CubeLoaderVariant.logo,
      interactive: interactive,
      showGlow: showGlow,
    );
  }
}
