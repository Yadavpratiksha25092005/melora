import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// The official Melora mark (violet -> cyan wings with an equalizer notch),
/// rendered from the brand asset at assets/icons/melora_logo.png.
/// Used on the splash screen, headers, and anywhere the brand mark is needed.
class MeloraLogo extends StatelessWidget {
  final double size;
  final bool showBackgroundTile;

  const MeloraLogo({
    super.key,
    this.size = 96,
    this.showBackgroundTile = false,
  });

  @override
  Widget build(BuildContext context) {
    // Source art is ~569x554, roughly square — keep native aspect ratio.
    const aspect = 569 / 554;
    final mark = Image.asset(
      'assets/icons/melora_logo.png',
      width: size * aspect,
      height: size,
      fit: BoxFit.contain,
    );

    if (!showBackgroundTile) return mark;

    return Container(
      width: size * 1.7,
      height: size * 1.7,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(size * 0.42),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: size * 0.35,
            spreadRadius: size * 0.02,
          ),
        ],
      ),
      child: Center(child: mark),
    );
  }
}