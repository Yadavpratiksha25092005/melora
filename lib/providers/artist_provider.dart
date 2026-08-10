import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Melora/models/artist.dart';
import 'package:Melora/repositories/artist_repository.dart';

final artistRepositoryProvider = Provider<ArtistRepository>((ref) => ArtistRepository());

final artistListProvider = FutureProvider.autoDispose<List<Artist>>((ref) {
  return ref.watch(artistRepositoryProvider).getArtists();
});

final artistByIdProvider =
    FutureProvider.autoDispose.family<Artist, String>((ref, id) {
  return ref.watch(artistRepositoryProvider).getArtistById(id);
});