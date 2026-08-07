import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/song.dart';

/// A user-created playlist: a name + an ordered list of songs.
class CustomPlaylist {
  final String id;
  final String name;
  final List<Song> songs;

  const CustomPlaylist({required this.id, required this.name, this.songs = const []});

  CustomPlaylist copyWith({String? name, List<Song>? songs}) {
    return CustomPlaylist(
      id: id,
      name: name ?? this.name,
      songs: songs ?? this.songs,
    );
  }
}

/// Tracks playlists the user creates in-app (via "Add to playlist" or the
/// Create tab), keyed by playlist id. In-memory for this session — same
/// approach as [LikedSongsNotifier], since this app has no backend to
/// persist to yet.
class CustomPlaylistsNotifier extends StateNotifier<Map<String, CustomPlaylist>> {
  CustomPlaylistsNotifier() : super({});

  List<CustomPlaylist> get playlists => state.values.toList();

  /// Creates a new playlist with [name] and returns its id. If a song is
  /// supplied, it's added immediately (the common "add to playlist" ->
  /// "new playlist" flow).
  String createPlaylist(String name, {Song? withSong}) {
    final id = 'playlist_${DateTime.now().microsecondsSinceEpoch}';
    final playlist = CustomPlaylist(
      id: id,
      name: name.trim().isEmpty ? 'New Playlist' : name.trim(),
      songs: withSong != null ? [withSong] : const [],
    );
    state = {...state, id: playlist};
    return id;
  }

  void deletePlaylist(String id) {
    if (!state.containsKey(id)) return;
    final updated = {...state}..remove(id);
    state = updated;
  }

  bool containsSong(String playlistId, String songId) {
    final playlist = state[playlistId];
    if (playlist == null) return false;
    return playlist.songs.any((s) => s.id == songId);
  }

  void addSong(String playlistId, Song song) {
    final playlist = state[playlistId];
    if (playlist == null) return;
    if (playlist.songs.any((s) => s.id == song.id)) return;
    state = {
      ...state,
      playlistId: playlist.copyWith(songs: [...playlist.songs, song]),
    };
  }

  void removeSong(String playlistId, String songId) {
    final playlist = state[playlistId];
    if (playlist == null) return;
    state = {
      ...state,
      playlistId: playlist.copyWith(
        songs: playlist.songs.where((s) => s.id != songId).toList(),
      ),
    };
  }
}

final customPlaylistsProvider =
    StateNotifierProvider<CustomPlaylistsNotifier, Map<String, CustomPlaylist>>((ref) {
  return CustomPlaylistsNotifier();
});