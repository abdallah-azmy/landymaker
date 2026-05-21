import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class CustomLoader extends StatelessWidget {
  final double size;
  final Color color;

  const CustomLoader({
    super.key,
    this.size = 28.0,
    this.color = AppColors.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
