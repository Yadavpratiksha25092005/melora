import 'package:flutter/material.dart';

import 'package:Melora/core/theme/app_colors.dart';

/// A single row inside a [SettingsDetailScreen].
///
/// If [isToggle] is true it renders as a switch (state kept in-memory by
/// the screen). Otherwise it renders as a plain informational row with
/// an optional trailing value/chevron — tapping it just shows a snackbar
/// (there's no deeper screen or backend behind it yet).
class SettingsItem {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final bool isToggle;
  final bool initialValue;
  final String? trailingText;
  final bool showChevron;
  final VoidCallback? onTap;

  const SettingsItem({
    this.icon,
    required this.title,
    this.subtitle,
    this.isToggle = false,
    this.initialValue = false,
    this.trailingText,
    this.showChevron = false,
    this.onTap,
  });
}

/// ---------------------------------------------------------------------
/// SettingsDetailScreen
///
/// Generic reusable "section" page opened from a row on [SettingsScreen]
/// (Account, Content and display, Privacy and social, Playback,
/// Notifications, Apps and devices, Data-saving and offline, Media
/// quality, Advertisements, About and support). Each section passes in
/// its own [items] list; toggle switches keep local in-memory state.
/// ---------------------------------------------------------------------
class SettingsDetailScreen extends StatefulWidget {
  const SettingsDetailScreen({super.key, required this.title, required this.items});

  final String title;
  final List<SettingsItem> items;

  @override
  State<SettingsDetailScreen> createState() => _SettingsDetailScreenState();
}

class _SettingsDetailScreenState extends State<SettingsDetailScreen> {
  late final Map<String, bool> _toggleValues = {
    for (final item in widget.items.where((i) => i.isToggle)) item.title: item.initialValue,
  };

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: widget.items.length,
        separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1, indent: 20, endIndent: 20),
        itemBuilder: (context, index) {
          final item = widget.items[index];
          if (item.isToggle) {
            return SwitchListTile(
              value: _toggleValues[item.title] ?? item.initialValue,
              onChanged: (v) => setState(() => _toggleValues[item.title] = v),
              activeThumbColor: AppColors.primary,
              secondary: item.icon != null ? Icon(item.icon, color: Colors.white70) : null,
              title: Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
              subtitle: item.subtitle != null
                  ? Text(item.subtitle!, style: const TextStyle(color: Colors.white38, fontSize: 12))
                  : null,
            );
          }
          return ListTile(
            onTap: item.onTap ?? () => _showSnack(item.title),
            leading: item.icon != null ? Icon(item.icon, color: Colors.white70) : null,
            title: Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            subtitle: item.subtitle != null
                ? Text(item.subtitle!, style: const TextStyle(color: Colors.white38, fontSize: 12))
                : null,
            trailing: item.trailingText != null
                ? Text(item.trailingText!, style: const TextStyle(color: Colors.white54, fontSize: 13))
                : item.showChevron
                    ? const Icon(Icons.chevron_right, color: Colors.white38)
                    : null,
          );
        },
      ),
    );
  }
}