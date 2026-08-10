import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/song.dart';

/// Tracks the user's "Liked Songs", keyed by song id — powers the mini
/// player's "+" button and the "Liked Songs" entry on Your Library.
class LikedSongsNotifier extends StateNotifier<Map<String, Song>> {
  LikedSongsNotifier() : super({});

  bool isLiked(String songId) => state.containsKey(songId);

  void add(Song song) {
    if (state.containsKey(song.id)) return;
    state = {...state, song.id: song};
  }

  void remove(String songId) {
    if (!state.containsKey(songId)) return;
    final updated = {...state}..remove(songId);
    state = updated;
  }

  void toggle(Song song) {
    if (isLiked(song.id)) {
      remove(song.id);
    } else {
      add(song);
    }
  }

  /// Most-recently-liked first.
  List<Song> get likedSongsList => state.values.toList().reversed.toList();
}

final likedSongsProvider =
    StateNotifierProvider<LikedSongsNotifier, Map<String, Song>>((ref) {
  return LikedSongsNotifier();
});