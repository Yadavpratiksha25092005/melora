import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:Melora/core/routes/route_names.dart';
import 'package:Melora/core/theme/app_colors.dart';
import 'package:Melora/providers/auth_provider.dart';

/// The side drawer that slides in when [ProfileAvatarButton] is tapped —
/// mirrors Spotify's account menu: avatar + "View profile" up top, then
/// Add account / Recents / Your Updates / Settings and privacy below.
class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  void _closeThen(BuildContext context, VoidCallback action) {
    Navigator.of(context).pop(); // close the drawer first
    action();
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1C1C24),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final username = (user != null && user.username.trim().isNotEmpty)
        ? user.username.trim()
        : 'Guest';
    final initial = username.isEmpty ? 'G' : username[0].toUpperCase();

    return Drawer(
      backgroundColor: AppColors.surface,
      width: MediaQuery.of(context).size.width * 0.82,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: GestureDetector(
                onTap: () => _closeThen(context, () => context.push(RouteNames.profile)),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'View profile',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 8),
            _DrawerTile(
              icon: Icons.person_add_alt_1_outlined,
              label: 'Add account',
              onTap: () => _closeThen(context, () => _showSnack(context, 'Add account coming soon')),
            ),
            _DrawerTile(
              icon: Icons.history_rounded,
              label: 'Recents',
              onTap: () => _closeThen(context, () => _showSnack(context, 'No recent activity yet')),
            ),
            _DrawerTile(
              icon: Icons.campaign_outlined,
              label: 'Your Updates',
              showDot: true,
              onTap: () => _closeThen(context, () => _showSnack(context, 'No new updates')),
            ),
            _DrawerTile(
              icon: Icons.settings_outlined,
              label: 'Settings and privacy',
              onTap: () => _closeThen(context, () => context.push(RouteNames.settings)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showDot;

  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 22),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (showDot)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: Color(0xFF3B82F6), shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}