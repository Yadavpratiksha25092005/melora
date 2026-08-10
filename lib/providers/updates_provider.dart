import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ---------------------------------------------------------------------
/// A single "update" shown on the Your Updates screen (new release,
/// artist announcement, etc). Kept intentionally simple — swap the
/// mock list in [UpdatesNotifier] for a real feed/service later.
/// ---------------------------------------------------------------------
class UpdateItem {
  final String id;
  final String title;
  final String subtitle;
  final IconIdentifier icon;
  bool read;

  UpdateItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.read = false,
  });
}

enum IconIdentifier { newRelease, artist, playlist, system }

class UpdatesNotifier extends StateNotifier<List<UpdateItem>> {
  UpdatesNotifier()
      : super([
          UpdateItem(
            id: '1',
            title: 'New release from The Midnight Sound',
            subtitle: 'Their new single just dropped — give it a listen',
            icon: IconIdentifier.newRelease,
          ),
          UpdateItem(
            id: '2',
            title: 'Rhea Kapoor posted an update',
            subtitle: '"Studio sessions all week for the new EP 🎙️"',
            icon: IconIdentifier.artist,
          ),
          UpdateItem(
            id: '3',
            title: 'Your playlist "Chill Hop Weekly" was updated',
            subtitle: '6 new tracks added by Melora',
            icon: IconIdentifier.playlist,
          ),
          UpdateItem(
            id: '4',
            title: 'Welcome to Melora',
            subtitle: 'Follow artists to see their updates here',
            icon: IconIdentifier.system,
            read: true,
          ),
        ]);

  int get unreadCount => state.where((u) => !u.read).length;

  void markAsRead(String id) {
    state = [
      for (final u in state)
        if (u.id == id) (u..read = true) else u,
    ];
  }

  void markAllAsRead() {
    for (final u in state) {
      u.read = true;
    }
    state = List.of(state);
  }
}

final updatesProvider = StateNotifierProvider<UpdatesNotifier, List<UpdateItem>>(
  (ref) => UpdatesNotifier(),
);

final unreadUpdatesCountProvider = Provider<int>((ref) {
  return ref.watch(updatesProvider).where((u) => !u.read).length;
});