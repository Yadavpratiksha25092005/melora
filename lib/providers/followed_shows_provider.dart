import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks which podcast shows the user follows, by show title — mirrors
/// followedArtistsProvider so the same Follow/Following pattern works
/// for podcasts too.
class FollowedShowsNotifier extends StateNotifier<Set<String>> {
  FollowedShowsNotifier() : super(const {});

  bool isFollowing(String showTitle) => state.contains(showTitle);

  void follow(String showTitle) => state = {...state, showTitle};

  void unfollow(String showTitle) => state = {...state}..remove(showTitle);
}

final followedShowsProvider =
    StateNotifierProvider<FollowedShowsNotifier, Set<String>>((ref) {
  return FollowedShowsNotifier();
});