import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:Melora/core/constants/artist_photos.dart';

/// Tracks which artists the user follows, by artist name (matches
/// [artistPhotoAssets] keys and [Song.artistName]). Seeded with the
/// artists already added to the app, so the "Following" tab has real
/// content immediately instead of being empty.
class FollowedArtistsNotifier extends StateNotifier<Set<String>> {
  FollowedArtistsNotifier() : super(artistPhotoAssets.keys.toSet());

  bool isFollowing(String name) => state.contains(name);

  void toggle(String name) {
    final updated = {...state};
    if (updated.contains(name)) {
      updated.remove(name);
    } else {
      updated.add(name);
    }
    state = updated;
  }

  void follow(String name) => state = {...state, name};

  void unfollow(String name) => state = {...state}..remove(name);
}

final followedArtistsProvider =
    StateNotifierProvider<FollowedArtistsNotifier, Set<String>>((ref) {
  return FollowedArtistsNotifier();
});