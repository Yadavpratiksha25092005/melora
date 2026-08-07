import 'package:flutter/material.dart';

import 'package:Melora/core/theme/app_colors.dart';

/// Row of segmented bars showing how far through onboarding the user
/// is (e.g. step 2 of 5). Completed/current segments glow accent,
/// remaining ones stay dim.
class OnboardingProgressIndicator extends StatelessWidget {
  final int currentStep; // 1-indexed
  final int totalSteps;

  const OnboardingProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index < currentStep;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 6),
            decoration: BoxDecoration(
              color: isActive ? AppColors.accent : Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}