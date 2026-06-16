import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme/app_typography.dart';
import '../../../features/auth/controllers/auth_cubit.dart';
import '../../../features/auth/controllers/auth_state.dart';

class LandyMakerLogo extends StatelessWidget {
  final double fontSize;
  final bool isClickable;

  const LandyMakerLogo({
    super.key,
    this.fontSize = 22,
    this.isClickable = true,
  });

  @override
  Widget build(BuildContext context) {
    final logo = Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Landy',
            style: AppTypography.h3.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: fontSize,
              letterSpacing: -0.5,
            ),
          ),
          TextSpan(
            text: 'Maker',
            style: AppTypography.h3.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00E5FF),
              fontSize: fontSize,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    );

    if (!isClickable) return logo;

    return InkWell(
      onTap: () {
        try {
          final authState = context.read<AuthCubit>().state;
          if (authState is Authenticated) {
            context.go('/dashboard');
            return;
          }
        } catch (_) {}
        context.go('/');
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: logo,
      ),
    );
  }
}
