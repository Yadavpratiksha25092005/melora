import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:Melora/core/theme/app_colors.dart';
import 'package:Melora/providers/updates_provider.dart';

class UpdatesScreen extends ConsumerWidget {
  const UpdatesScreen({super.key});

  IconData _iconFor(IconIdentifier id) {
    switch (id) {
      case IconIdentifier.newRelease:
        return Icons.album_rounded;
      case IconIdentifier.artist:
        return Icons.person_rounded;
      case IconIdentifier.playlist:
        return Icons.queue_music_rounded;
      case IconIdentifier.system:
        return Icons.graphic_eq_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updates = ref.watch(updatesProvider);
    final unreadCount = ref.watch(unreadUpdatesCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Your Updates', style: TextStyle(color: Colors.white)),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () => ref.read(updatesProvider.notifier).markAllAsRead(),
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: updates.isEmpty
          ? const Center(
              child: Text('No updates yet', style: TextStyle(color: Colors.white38)),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: updates.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
              itemBuilder: (context, index) {
                final update = updates[index];
                return ListTile(
                  onTap: () => ref.read(updatesProvider.notifier).markAsRead(update.id),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.surfaceLight,
                    child: Icon(_iconFor(update.icon), color: AppColors.primary, size: 20),
                  ),
                  title: Text(
                    update.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: update.read ? FontWeight.w400 : FontWeight.w700,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      update.subtitle,
                      style: const TextStyle(color: Colors.white54, fontSize: 12.5),
                    ),
                  ),
                  trailing: update.read
                      ? null
                      : Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3B82F6),
                            shape: BoxShape.circle,
                          ),
                        ),
                );
              },
            ),
    );
  }
}