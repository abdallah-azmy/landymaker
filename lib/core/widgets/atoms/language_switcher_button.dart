import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../localization/localization_cubit.dart';
import '../../theme/app_typography.dart';

enum LanguageSwitcherVariant {
  iconOnly,
  iconAndText,
}

class LanguageSwitcherButton extends StatelessWidget {
  final LanguageSwitcherVariant variant;
  final Color? color;

  const LanguageSwitcherButton({
    super.key,
    required this.variant,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();
    final iconColor = color ?? Theme.of(context).colorScheme.onSurfaceVariant;

    if (variant == LanguageSwitcherVariant.iconOnly) {
      return IconButton(
        tooltip: loc.translate('switch_language'),
        icon: Icon(
          Icons.language_rounded,
          color: iconColor,
          size: 20,
        ),
        onPressed: () => loc.toggleLanguage(),
      );
    }

    return TextButton.icon(
      onPressed: () => loc.toggleLanguage(),
      icon: Icon(
        Icons.language_rounded,
        size: 20,
        color: iconColor,
      ),
      label: Text(
        loc.translate('switch_language'),
        style: AppTypography.bodyMedium.copyWith(
          color: iconColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
