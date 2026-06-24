import 'package:flutter/material.dart';
import 'cube_loader.dart';

/// Legacy enum — maps to [CubeLoaderState].
enum LoadingLogoState {
  idle,
  breathing,
  loading,
  rotatingLayers,
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

  static CubeLoaderState _mapState(LoadingLogoState s) {
    switch (s) {
      case LoadingLogoState.idle: return CubeLoaderState.idle;
      case LoadingLogoState.breathing: return CubeLoaderState.breathing;
      case LoadingLogoState.loading: return CubeLoaderState.loading;
      case LoadingLogoState.rotatingLayers: return CubeLoaderState.rotatingLayers;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CubeLoader(
      size: size,
      initialState: _mapState(initialState),
      variant: CubeLoaderVariant.logoPremiumCornerAxis,
      interactive: interactive,
      showGlow: showGlow,
    );
  }
}
