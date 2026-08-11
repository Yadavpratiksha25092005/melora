import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:Melora/core/theme/app_colors.dart';
import 'package:Melora/providers/auth_provider.dart';
import 'package:Melora/screens/auth/signup_screen.dart';
import 'package:Melora/screens/premium/premium_screen.dart';
import 'package:Melora/screens/settings/account_settings_screen.dart';
import 'package:Melora/screens/settings/manage_storage_screen.dart';
import 'package:Melora/screens/settings/settings_detail_screen.dart';
import 'package:Melora/screens/settings/settings_info_screen.dart';
import 'package:go_router/go_router.dart';

/// ---------------------------------------------------------------------
/// SettingsScreen
///
/// Spotify-style Settings page: "Free account" header + Go Premium
/// button, Data Saver mode / Private session quick-toggle cards, then a
/// grouped list of settings categories — each one pushes its own
/// [SettingsDetailScreen] with real, working toggles.
/// ---------------------------------------------------------------------
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _privateSession = false;

  void _showSnack(String message) {
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

  void _openPremium() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PremiumScreen()),
    );
  }

  void _openFreeAccount() {
    final isGuest = ref.read(authProvider).user == null;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => isGuest ? const SignupScreen() : const PremiumScreen()),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Log out?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
  onPressed: () async {
  Navigator.of(dialogContext).pop();
  await ref.read(authProvider.notifier).logout();
  if (context.mounted) {
    context.go('/login');
  }
},
            child: const Text('Log out', style: TextStyle(color: Color(0xFFFF5C5C))),
          ),
        ],
      ),
    );
  }

  void _openSection(String title, List<SettingsItem> items) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SettingsDetailScreen(title: title, items: items)),
    );
  }

  void _openInfo(String title, String body) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SettingsInfoScreen(title: title, body: body)),
    );
  }

  void _openAccount() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AccountSettingsScreen()),
    );
  }

  List<SettingsItem> get _aboutSupportItems => [
        const SettingsItem(icon: Icons.info_outline_rounded, title: 'Version', trailingText: '1.0.0'),
        SettingsItem(
          icon: Icons.description_outlined,
          title: 'Privacy Policy',
          showChevron: true,
          onTap: () => _openInfo(
            'Privacy Policy',
            'Melora respects your privacy. We only collect the data needed to run the '
                'app — your account details, listening activity, and playlists — and never '
                'sell it to third parties. You can request deletion of your data at any '
                'time from the Account section.',
          ),
        ),
        SettingsItem(
          icon: Icons.gavel_outlined,
          title: 'Terms of use',
          showChevron: true,
          onTap: () => _openInfo(
            'Terms of use',
            'By using Melora you agree to use the service for personal, non-commercial '
                'listening only. Content is provided by third-party sources and is subject '
                'to their respective licenses. Melora is provided "as is" without warranty '
                'of any kind.',
          ),
        ),
        SettingsItem(
          icon: Icons.help_outline_rounded,
          title: 'Help',
          showChevron: true,
          onTap: () => _openInfo(
            'Help',
            'Need help with Melora?\n\n'
                '• Playback issues: try restarting the app or checking your connection.\n'
                '• Downloads: manage them from Library > Downloads.\n'
                '• Account issues: use the Account section under Settings.\n\n'
                'For anything else, reach out at support@melora.app',
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _openFreeAccount,
            child: const Text(
              'Free account',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: ElevatedButton(
              onPressed: _openPremium,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              ),
              child: const Text('Go Premium', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _QuickCard(
                    icon: Icons.bar_chart_rounded,
                    title: 'Data Saver mode',
                    subtitle: 'Automatic',
                    onTap: () => _openSection('Data-saving and offline', _dataSavingItems),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickCard(
                    icon: _privateSession ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    title: 'Private session',
                    subtitle: _privateSession ? 'On' : 'Off',
                    onTap: () => setState(() => _privateSession = !_privateSession),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white12, height: 32),
          _SettingsRow(
            icon: Icons.person_outline_rounded,
            title: 'Account',
            subtitle: 'Username · Close account',
            onTap: _openAccount,
          ),
          _SettingsRow(
            icon: Icons.info_outline_rounded,
            title: 'About and support',
            subtitle: 'Version · Privacy Policy',
            onTap: () => _openSection('About and support', _aboutSupportItems),
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: _confirmLogout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Log out', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  List<SettingsItem> get _dataSavingItems => [
        const SettingsItem(icon: Icons.bar_chart_rounded, title: 'Data Saver mode', subtitle: 'Reduce streaming quality on mobile data', isToggle: true),
        const SettingsItem(icon: Icons.wifi_outlined, title: 'Download over cellular', isToggle: true),
        SettingsItem(
          icon: Icons.storage_outlined,
          title: 'Manage storage',
          showChevron: true,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ManageStorageScreen()),
          ),
        ),
      ];
}

// ---------------------------------------------------------------------
// Section content — each list feeds a SettingsDetailScreen.
// ---------------------------------------------------------------------

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.white70, size: 22),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
    );
  }
}