import 'package:flutter/material.dart';

import 'package:Melora/core/theme/app_colors.dart';

/// ---------------------------------------------------------------------
/// SettingsInfoScreen
///
/// Generic static-content page used for things like Privacy Policy,
/// Terms of use, and Help — just a title + scrollable body text.
/// ---------------------------------------------------------------------
class SettingsInfoScreen extends StatelessWidget {
  const SettingsInfoScreen({super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Text(
            body,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 14, height: 1.6),
          ),
        ),
      ),
    );
  }
}