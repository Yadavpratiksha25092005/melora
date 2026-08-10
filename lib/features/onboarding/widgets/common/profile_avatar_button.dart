import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:Melora/core/theme/app_colors.dart';
import 'package:Melora/providers/auth_provider.dart';

/// Small circular avatar that shows the first letter of the logged-in
/// user's username (Spotify-style). Tapping it slides the account
/// drawer ([AppDrawer]) in from the side.
///
/// Lives inside the Home tab, but relies on finding the nearest
/// [Scaffold] up the tree (the one in `MainShell`) to open its
/// `drawer`, so it must be used somewhere below that Scaffold.
class ProfileAvatarButton extends ConsumerWidget {
  final double size;
  const ProfileAvatarButton({super.key, this.size = 34});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final username = (user != null && user.username.trim().isNotEmpty)
        ? user.username.trim()
        : 'Guest';
    final initial = username.isEmpty ? 'G' : username[0].toUpperCase();

    return GestureDetector(
      onTap: () => Scaffold.of(context).openDrawer(),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [AppColors.primary, Color(0xFF8A6BFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.42,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}