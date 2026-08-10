import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:Melora/core/network/dummy_data_source.dart';
import 'package:Melora/core/theme/app_colors.dart';
import 'package:Melora/models/podcast.dart';
import 'package:Melora/providers/followed_shows_provider.dart';
import 'package:Melora/screens/podcasts/podcast_audio_player_screen.dart';
import 'package:Melora/screens/podcasts/podcast_file_player_screen.dart';
import 'package:Melora/screens/podcasts/podcast_video_player_screen.dart';

/// ---------------------------------------------------------------------
/// FollowingShowsScreen
///
/// Opened from Home's Podcasts "Following" pill. Shows the podcast shows
/// you actually follow (followedShowsProvider) — tapping one opens its
/// first episode.
/// ---------------------------------------------------------------------
class FollowingShowsScreen extends ConsumerWidget {
  const FollowingShowsScreen({super.key});

  void _openEpisode(BuildContext context, PodcastEpisode episode) {
    if (episode.isDirectVideoFile) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PodcastFilePlayerScreen(episode: episode)),
      );
      return;
    }
    if (episode.isYoutubeVideo) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PodcastVideoPlayerScreen(episode: episode)),
      );
      return;
    }
    if (episode.hasAudio) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PodcastAudioPlayerScreen(episode: episode)),
      );
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('"${episode.title}" has no playable source yet'),
        backgroundColor: const Color(0xFF1C1C24),
        behavior: SnackBarBehavior.floating,
      ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followedTitles = ref.watch(followedShowsProvider).toList()..sort();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Following', style: TextStyle(color: Colors.white)),
      ),
      body: followedTitles.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Podcasts you follow will show up here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
            )
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: DummyDataSource.podcasts(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }
                final allEpisodes = snapshot.data!.map(PodcastEpisode.fromJson).toList();

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: followedTitles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 18),
                  itemBuilder: (context, index) {
                    final showTitle = followedTitles[index];
                    final showEpisodes =
                        allEpisodes.where((e) => e.showTitle == showTitle).toList();
                    final firstEpisode = showEpisodes.isNotEmpty ? showEpisodes.first : null;

                    return GestureDetector(
                      onTap: () {
                        if (firstEpisode == null) {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(SnackBar(
                              content: Text('No episodes found for $showTitle'),
                              backgroundColor: const Color(0xFF1C1C24),
                              behavior: SnackBarBehavior.floating,
                            ));
                          return;
                        }
                        _openEpisode(context, firstEpisode);
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A35),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.podcasts_rounded, color: Colors.white38, size: 26),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  showTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  showEpisodes.isEmpty
                                      ? 'Podcast'
                                      : '${showEpisodes.length} episode${showEpisodes.length == 1 ? '' : 's'}',
                                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF1ED760)),
                            tooltip: 'Following — tap to unfollow',
                            onPressed: () =>
                                ref.read(followedShowsProvider.notifier).unfollow(showTitle),
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
}