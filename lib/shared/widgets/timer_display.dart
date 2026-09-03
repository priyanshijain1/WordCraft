import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_constants.dart';

/// Displays the remaining seconds with a color that shifts from calm to urgent
/// as time runs out.
class TimerDisplay extends StatelessWidget {
  const TimerDisplay({
    super.key,
    required this.secondsLeft,
    this.totalSeconds = 30,
  });

  final int secondsLeft;
  final int totalSeconds;

  @override
  Widget build(BuildContext context) {
    final fraction =
        totalSeconds <= 0 ? 0.0 : (secondsLeft / totalSeconds).clamp(0.0, 1.0);
    final urgent = secondsLeft <= 5;
    final color = urgent ? AppColors.wrong : AppColors.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(urgent ? Icons.timer_off : Icons.timer, color: color, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '${secondsLeft}s',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 80,
          child: LinearProgressIndicator(
            value: fraction,
            color: color,
            backgroundColor: AppColors.tileLight,
            minHeight: 6,
            borderRadius: BorderRadius.circular(AppSpacing.xs),
          ),
        ),
      ],
    );
  }
}
