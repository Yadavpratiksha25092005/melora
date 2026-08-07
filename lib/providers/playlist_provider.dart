import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Melora/models/playlist.dart';
import 'package:Melora/repositories/playlist_repository.dart';

final playlistRepositoryProvider =
    Provider<PlaylistRepository>((ref) => PlaylistRepository());

final playlistListProvider = FutureProvider.autoDispose<List<Playlist>>((ref) {
  return ref.watch(playlistRepositoryProvider).getPlaylists();
});

final playlistByIdProvider =
    FutureProvider.autoDispose.family<Playlist, String>((ref, id) {
  return ref.watch(playlistRepositoryProvider).getPlaylistById(id);
});