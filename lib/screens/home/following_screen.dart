import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:Melora/core/theme/app_colors.dart';
import 'package:Melora/core/constants/artist_photos.dart';
import 'package:Melora/models/song.dart';
import 'package:Melora/providers/followed_artists_provider.dart';
import 'package:Melora/providers/player_provider.dart';
import 'package:Melora/providers/song_provider.dart';
import 'package:Melora/screens/home/song_collection_screen.dart';
/// ---------------------------------------------------------------------
/// FollowingScreen
///
/// Opened from Home's "Following" pill. Shows the artists you actually
/// follow (followedArtistsProvider) — tapping one opens their songs
/// (pulled from the same real song catalog used across Home), which
/// play immediately.
/// ---------------------------------------------------------------------
class FollowingScreen extends ConsumerWidget {
  const FollowingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final following = ref.watch(followedArtistsProvider).toList()..sort();
    final songsAsync = ref.watch(allSongsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Following', style: TextStyle(color: Colors.white)),
      ),
      body: following.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Artists you follow will show up here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
            )
          : songsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => const Center(
                child: Text('Failed to load songs', style: TextStyle(color: Colors.white38)),
              ),
              data: (allSongs) {
                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: following.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 18),
                  itemBuilder: (context, index) {
                    final name = following[index];
                    final asset = artistPhotoAssetFor(name);
                    final artistSongs = allSongs
                        .where((s) => (s.artistName ?? '').trim().toLowerCase() == name.trim().toLowerCase())
                        .toList();

                    return GestureDetector(
                      onTap: () => _openArtist(context, ref, name, artistSongs),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: const Color(0xFF2A2A35),
                            backgroundImage: asset != null ? AssetImage(asset) : null,
                            onBackgroundImageError: asset != null ? (_, __) {} : null,
                            child: asset == null
                                ? const Icon(Icons.person_rounded, color: Colors.white38)
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  artistSongs.isEmpty
                                      ? 'Artist'
                                      : '${artistSongs.length} song${artistSongs.length == 1 ? '' : 's'}',
                                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF1ED760)),
                            tooltip: 'Following — tap to unfollow',
                            onPressed: () =>
                                ref.read(followedArtistsProvider.notifier).unfollow(name),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  void _openArtist(BuildContext context, WidgetRef ref, String name, List<Song> artistSongs) {
    if (artistSongs.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text('No songs found for $name'),
          backgroundColor: const Color(0xFF1C1C24),
          behavior: SnackBarBehavior.floating,
        ));
      return;
    }
    ref.read(playerProvider.notifier).playQueue(artistSongs, 0);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SongCollectionScreen(songs: artistSongs, initialIndex: 0),
      ),
    );
  }
}