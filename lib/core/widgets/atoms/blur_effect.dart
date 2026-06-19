import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';

/// A reusable widget that applies a backdrop blur filter to whatever is behind it,
/// clipped to a specified [borderRadius].
///
/// It should wrap any container or widget that has a transparent/semi-transparent
/// background color to allow the blurred content behind it to show through.
class AppBlurEffect extends StatelessWidget {
  /// The widget to display on top of the blur effect.
  final Widget child;

  /// The amount of blur to apply (sigma values for X and Y axes).
  final double blur;

  /// The border radius to clip the blur effect to.
  final BorderRadius borderRadius;

  const AppBlurEffect({
    super.key,
    required this.child,
    this.blur = 6.0,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: child,
      ),
    );
  }
}
