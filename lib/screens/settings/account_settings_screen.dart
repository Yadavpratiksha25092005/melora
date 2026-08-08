import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:Melora/core/theme/app_colors.dart';
import 'package:Melora/providers/auth_provider.dart';
import 'package:Melora/screens/profile/edit_profile_screen.dart';

/// ---------------------------------------------------------------------
/// AccountSettingsScreen
///
/// Unlike the generic [SettingsDetailScreen], this one watches
/// [authProvider] live so the Username row always shows whatever the
/// user last saved, and "Change password" shows a masked confirmation
/// once a new password has been set this session.
/// ---------------------------------------------------------------------
class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {

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

  void _editUsername() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
  }


  void _closeAccount() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Close account?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will permanently delete your account and sign you out. This cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _showSnack('Account deletion isn\'t available yet — contact support');
            },
            child: const Text('Close account', style: TextStyle(color: Color(0xFFFF5C5C))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final username = user?.username;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Account', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          ListTile(
            onTap: _editUsername,
            leading: const Icon(Icons.badge_outlined, color: Colors.white70),
            title: const Text('Username', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            subtitle: Text(
              (username != null && username.isNotEmpty) ? username : 'Change your display name',
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white38),
          ),
        
          const Divider(color: Colors.white12, height: 1, indent: 20, endIndent: 20),
          ListTile(
            onTap: _closeAccount,
            leading: const Icon(Icons.delete_outline_rounded, color: Colors.white70),
            title: const Text('Close account', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            subtitle: const Text('Permanently delete your account', style: TextStyle(color: Colors.white38, fontSize: 12)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white38),
          ),
        ],
      ),
    );
  }
}