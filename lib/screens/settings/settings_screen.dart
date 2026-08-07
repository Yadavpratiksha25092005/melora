import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:Melora/core/theme/app_colors.dart';
import 'package:Melora/providers/auth_provider.dart';
import 'package:Melora/screens/auth/login_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pushNotifications = true;
  bool _dataSaver = false;
  bool _privateSession = false;
  bool _showListeningActivity = true;

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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isGuest = authState.user == null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Settings and privacy', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const _SectionLabel('Notifications'),
          SwitchListTile(
            value: _pushNotifications,
            onChanged: (v) => setState(() => _pushNotifications = v),
            activeThumbColor: AppColors.primary,
            title: const Text('Push notifications', style: TextStyle(color: Colors.white)),
            subtitle: const Text('New releases, updates and reminders',
                style: TextStyle(color: Colors.white38, fontSize: 12)),
          ),
          const Divider(color: Colors.white12, height: 24),
          const _SectionLabel('Playback'),
          SwitchListTile(
            value: _dataSaver,
            onChanged: (v) => setState(() => _dataSaver = v),
            activeThumbColor: AppColors.primary,
            title: const Text('Data saver', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Reduce streaming quality on mobile data',
                style: TextStyle(color: Colors.white38, fontSize: 12)),
          ),
          const Divider(color: Colors.white12, height: 24),
          const _SectionLabel('Privacy'),
          SwitchListTile(
            value: _privateSession,
            onChanged: (v) => setState(() => _privateSession = v),
            activeThumbColor: AppColors.primary,
            title: const Text('Private session', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Listening won\'t be added to your history',
                style: TextStyle(color: Colors.white38, fontSize: 12)),
          ),
          SwitchListTile(
            value: _showListeningActivity,
            onChanged: (v) => setState(() => _showListeningActivity = v),
            activeThumbColor: AppColors.primary,
            title: const Text('Show listening activity', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Let followers see what you\'re playing',
                style: TextStyle(color: Colors.white38, fontSize: 12)),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined, color: Colors.white70),
            title: const Text('Privacy policy', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white38),
            onTap: () => _showSnack('Opening privacy policy'),
          ),
          const Divider(color: Colors.white12, height: 24),
          const _SectionLabel('Account'),
          if (isGuest)
            ListTile(
              leading: const Icon(Icons.login_rounded, color: Colors.white70),
              title: const Text('Sign in', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Save your library and sync across devices',
                  style: TextStyle(color: Colors.white38, fontSize: 12)),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
            )
          else
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text('Log out', style: TextStyle(color: AppColors.error)),
              onTap: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}