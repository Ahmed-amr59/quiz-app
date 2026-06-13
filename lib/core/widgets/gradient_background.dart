import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).brightness;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: theme == Brightness.dark
              ? [AppColors.darkBackground, AppColors.darkSurface]
              : [AppColors.background, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}
