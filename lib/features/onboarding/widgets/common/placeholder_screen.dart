import 'package:flutter/material.dart';
import 'package:Melora/core/theme/app_colors.dart';
import 'package:Melora/features/onboarding/widgets/common/app_back_handler.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBackHandler(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text(title)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: Image.asset(
                  'assets/icons/melora_logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.graphic_eq_rounded, color: AppColors.primary, size: 40),
                ),
              ),
              const SizedBox(height: 16),
              Text('$title screen — coming soon', style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}