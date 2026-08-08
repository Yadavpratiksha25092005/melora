import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:Melora/core/theme/app_colors.dart';
import 'package:Melora/providers/auth_provider.dart';
import 'package:Melora/providers/updates_provider.dart';
import 'package:Melora/screens/auth/login_screen.dart';
import 'package:Melora/screens/profile/profile_screen.dart';
import 'package:Melora/screens/settings/settings_screen.dart';
import 'package:Melora/screens/updates/updates_screen.dart';
import 'package:go_router/go_router.dart';

/// ---------------------------------------------------------------------
/// AppDrawer
///
/// Slide-out side menu (Guest/profile header, Add account, Recents,
/// Your Updates, Settings and privacy) — everything here is wired up:
///   • header + "View profile"  -> ProfileScreen
///   • Add account              -> LoginScreen
///   • Recents                  -> jumps the bottom nav to the Library
///                                  tab (where Recents lives)
///   • Your Updates              -> UpdatesScreen (unread dot updates live)
///   • Settings and privacy      -> SettingsScreen
///
/// Mount this as the `drawer:` of MainShell's Scaffold and open it with
/// `Scaffold.of(context).openDrawer()` from anywhere inside the shell
/// (e.g. tapping the avatar on the Library screen).
/// ---------------------------------------------------------------------
class AppDrawer extends ConsumerWidget {
  /// Called when the user taps "Recents" — lets the parent (MainShell)
  /// switch the bottom-nav tab to Library instead of pushing a new route.
  final VoidCallback? onRecentsTap;

  const AppDrawer({super.key, this.onRecentsTap});

  void _closeThen(BuildContext context, VoidCallback action) {
    Navigator.of(context).pop(); // close the drawer first
    action();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isGuest = user == null;
    final unreadUpdates = ref.watch(unreadUpdatesCountProvider);

    final displayName = isGuest ? 'Guest' : user.username;
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'G';

    return Drawer(
      backgroundColor: AppColors.background,
      width: MediaQuery.of(context).size.width * 0.82,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            _DrawerHeader(
              initial: initial,
              displayName: displayName,
              isGuest: isGuest,
              onTap: () => _closeThen(
                context,
                () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(color: Colors.white12, height: 1),
            ),
            const SizedBox(height: 8),
            _DrawerTile(
              icon: Icons.person_add_alt_1_rounded,
              label: 'Add account',
             onTap: () => _closeThen(
  context,
  () => context.push('/login'),
),
            ),
            _DrawerTile(
              icon: Icons.history_rounded,
              label: 'Recents',
              onTap: () => _closeThen(context, () {
                if (onRecentsTap != null) {
                  onRecentsTap!();
                } else {
                  Navigator.of(context).pop();
                }
              }),
            ),
            _DrawerTile(
              icon: Icons.campaign_outlined,
              label: 'Your Updates',
              trailing: unreadUpdates > 0
                  ? Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3B82F6),
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
              onTap: () => _closeThen(
                context,
                () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const UpdatesScreen()),
                ),
              ),
            ),
            _DrawerTile(
              icon: Icons.settings_outlined,
              label: 'Settings and privacy',
              onTap: () => _closeThen(
                context,
                () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  final String initial;
  final String displayName;
  final bool isGuest;
  final VoidCallback onTap;

  const _DrawerHeader({
    required this.initial,
    required this.displayName,
    required this.isGuest,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6E7CF2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isGuest ? 'Sign in to view profile' : 'View profile',
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
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
  final Widget? trailing;

  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}