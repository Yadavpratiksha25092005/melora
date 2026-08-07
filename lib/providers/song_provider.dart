import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/song.dart';
import '../repositories/song_repository.dart';

final songRepositoryProvider = Provider<SongRepository>((ref) {
  return SongRepository();
});

/// Fetches the default song list (home feed).
final songListProvider = FutureProvider.autoDispose<List<Song>>((ref) async {
  final repo = ref.watch(songRepositoryProvider);
  return repo.getSongs();
});

/// Fetches the entire dummy catalog (all 500 songs), used by the
/// browsable "All Songs" screen.
final allSongsProvider = FutureProvider.autoDispose<List<Song>>((ref) async {
  final repo = ref.watch(songRepositoryProvider);
  return repo.getSongs(limit: 500);
});

/// Fetches a single song by id, e.g. for the player screen.
final songByIdProvider =
    FutureProvider.autoDispose.family<Song, String>((ref, id) async {
  final repo = ref.watch(songRepositoryProvider);
  return repo.getSongById(id);
});

/// Searches songs by query string, e.g. for search_screen.dart.
/// Usage: ref.watch(songSearchProvider("arijit"))
final songSearchProvider =
    FutureProvider.autoDispose.family<List<Song>, String>((ref, query) async {
  final repo = ref.watch(songRepositoryProvider);
  return repo.searchSongs(query);
});

/// Trending songs — used for the Home screen's Quick Picks grid.
final trendingSongsProvider =
    FutureProvider.autoDispose<List<Song>>((ref) async {
  final repo = ref.watch(songRepositoryProvider);
  return repo.getTrendingSongs(limit: 10);
});

/// Songs filtered by genre/tag — used for Home screen rows like
/// "Recommended for today" and "Popular right now".
/// Usage: ref.watch(genreSongsProvider("pop"))
final genreSongsProvider =
    FutureProvider.autoDispose.family<List<Song>, String>((ref, genre) async {
  final repo = ref.watch(songRepositoryProvider);
  return repo.getSongsByGenre(genre, limit: 10);
});

/// Songs by a specific artist — used by the artist detail screen in
/// Your Library.
/// Usage: ref.watch(songsByArtistProvider("Arijit Singh"))
final songsByArtistProvider =
    FutureProvider.autoDispose.family<List<Song>, String>((ref, artistName) async {
  final repo = ref.watch(songRepositoryProvider);
  return repo.getSongsByArtist(artistName);
});