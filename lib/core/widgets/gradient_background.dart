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
              ? const [
                  Color(0xFF050B1A),
                  AppColors.darkBackground,
                  AppColors.darkSurface,
                ]
              : const [Color(0xFFF8FAFC), Color(0xFFE0E7FF), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          if (theme == Brightness.dark) ...[
            Positioned(
              top: -70,
              left: -50,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.darkPrimary.withOpacity(0.24),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 80,
              right: -80,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.secondary.withOpacity(0.16),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ] else ...[
            Positioned(
              top: -40,
              right: -50,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.10),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withOpacity(0.10),
                ),
              ),
            ),
          ],
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}
