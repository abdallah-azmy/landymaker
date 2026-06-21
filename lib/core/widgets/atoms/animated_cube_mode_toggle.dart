import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:landymaker/core/widgets/particles/cube_mode_cubit.dart';

class AnimatedCubeModeToggle extends StatefulWidget {
  final double size;

  const AnimatedCubeModeToggle({super.key, this.size = 48.0});

  @override
  State<AnimatedCubeModeToggle> createState() => _AnimatedCubeModeToggleState();
}

class _AnimatedCubeModeToggleState extends State<AnimatedCubeModeToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.85), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 0.85, end: 1.15), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.15, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  IconData _icon(CubeMode mode) {
    return switch (mode) {
      CubeMode.standard => Icons.grain_rounded,
      CubeMode.merge => Icons.grid_view_rounded,
      CubeMode.orbit => Icons.language_rounded,
      CubeMode.gravity => Icons.arrow_downward_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<CubeModeCubit, CubeMode>(
      builder: (context, mode) {
        return AnimatedBuilder(
          animation: _bounceController,
          builder: (context, _) {
            return Transform.scale(
              scale: _scaleAnim.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.surfaceContainerHigh,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _bounceController.forward(from: 0.0);
                      context.read<CubeModeCubit>().toggleMode();
                    },
                    borderRadius: BorderRadius.circular(widget.size / 2),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return RotationTransition(
                            turns: animation,
                            child: child,
                          );
                        },
                        child: Icon(
                          _icon(mode),
                          key: ValueKey(mode),
                          size: widget.size * 0.5,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
