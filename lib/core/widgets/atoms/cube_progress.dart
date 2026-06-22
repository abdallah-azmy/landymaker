import 'package:flutter/material.dart';
import '../particles/cube_loader.dart';

/// Thin wrapper around [CubeLoader] for backward compatibility.
///
/// Prefer using [CubeLoader(variant: CubeLoaderVariant.cluster)] directly.
class CubeProgress extends StatelessWidget {
  final double size;
  final Color color;
  final double? value;
  final bool showPercentage;

  const CubeProgress({
    super.key,
    this.size = 48.0,
    required this.color,
    this.value,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    return CubeLoader(
      size: size,
      color: color,
      initialState: CubeLoaderState.loading,
      variant: CubeLoaderVariant.cluster,
      showGlow: false,
      value: value,
      showPercentage: showPercentage,
    );
  }
}
