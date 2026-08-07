import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Melora/models/album.dart';
import 'package:Melora/repositories/album_repository.dart';

final albumRepositoryProvider = Provider<AlbumRepository>((ref) => AlbumRepository());

final albumListProvider = FutureProvider.autoDispose<List<Album>>((ref) {
  return ref.watch(albumRepositoryProvider).getAlbums();
});

final albumByIdProvider =
    FutureProvider.autoDispose.family<Album, String>((ref, id) {
  return ref.watch(albumRepositoryProvider).getAlbumById(id);
});

final albumsByArtistProvider =
    FutureProvider.autoDispose.family<List<Album>, String>((ref, artistId) {
  return ref.watch(albumRepositoryProvider).getAlbumsByArtist(artistId);
});