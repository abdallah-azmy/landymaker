import 'package:flutter/material.dart';
import '../particles/cube_loader.dart';

/// Thin wrapper around [CubeLoader] for backward compatibility.
///
/// Prefer using [CubeLoader(variant: CubeLoaderVariant.single)] directly.
class CubeSpinner extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const CubeSpinner({
    super.key,
    this.size = 16.0,
    this.color,
    this.strokeWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return CubeLoader(
      size: size,
      color: color,
      initialState: CubeLoaderState.loading,
      variant: CubeLoaderVariant.single,
      showGlow: false,
    );
  }
}
