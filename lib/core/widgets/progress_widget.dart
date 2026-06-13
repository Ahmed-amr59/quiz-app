import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ProgressWidget extends StatelessWidget {
  final int current;
  final int total;
  final double progress;

  const ProgressWidget({
    super.key,
    required this.current,
    required this.total,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question $current / $total',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 600),
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: AppColors.secondary.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              );
            },
          ),
        ),
      ],
    );
  }
}
