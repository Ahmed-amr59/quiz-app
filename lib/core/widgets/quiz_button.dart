import 'package:flutter/material.dart';

class QuizButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool enabled;
  final Gradient? gradient;

  const QuizButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: enabled
            ? gradient ??
                  const LinearGradient(
                    colors: [Color(0xFF5B21B6), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
            : const LinearGradient(
                colors: [Color(0xFF6B7280), Color(0xFF374151)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
      ),
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,color: Colors.white),
        ),
      ),
    );
  }
}
