import 'package:flutter/material.dart';

class AnswerCard extends StatelessWidget {
  final String answer;
  final bool selected;
  final bool isCorrect;
  final bool showResult;
  final VoidCallback onTap;

  const AnswerCard({
    super.key,
    required this.answer,
    required this.selected,
    required this.onTap,
    this.isCorrect = false,
    this.showResult = false,
  });

  Color _backgroundColor(ThemeData theme) {
    if (!showResult) {
      return selected ? theme.primaryColor.withOpacity(0.15) : theme.cardColor;
    }
    if (selected && isCorrect) {
      return Colors.green.shade300;
    }
    if (selected && !isCorrect) {
      return Colors.red.shade300;
    }
    return theme.cardColor;
  }

  Color _borderColor(ThemeData theme) {
    if (!showResult) {
      return selected ? theme.primaryColor : theme.dividerColor;
    }
    if (selected && isCorrect) {
      return Colors.green;
    }
    if (selected && !isCorrect) {
      return Colors.red;
    }
    return theme.dividerColor;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: _backgroundColor(theme),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor(theme), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            child: Text(
              answer,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
