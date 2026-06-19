import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;

import 'package:landymaker/core/widgets/particles/cube_mode_cubit.dart';

class AnimatedCubeModeToggle extends StatefulWidget {
  final double size;

  const AnimatedCubeModeToggle({super.key, this.size = 48.0});

  @override
  State<AnimatedCubeModeToggle> createState() => _AnimatedCubeModeToggleState();
}

class _AnimatedCubeModeToggleState extends State<AnimatedCubeModeToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.8), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 0.8, end: 1.2), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    final isMerge = context.read<CubeModeCubit>().isMergeMode;
    if (isMerge) {
      _controller.value = 1.0;
    } else {
      _controller.value = 0.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CubeModeCubit, CubeMode>(
      listener: (context, state) {
        if (state == CubeMode.merge) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final isMerge = _controller.value > 0.5;
          final colorScheme = Theme.of(context).colorScheme;

          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value * math.pi,
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
                      context.read<CubeModeCubit>().toggleMode();
                    },
                    borderRadius: BorderRadius.circular(widget.size / 2),
                    child: Center(
                      child: Icon(
                        isMerge
                            ? Icons.grid_view_rounded
                            : Icons.grain_rounded,
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
      ),
    );
  }
}
