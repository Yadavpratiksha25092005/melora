import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:Melora/core/network/dummy_data_source.dart';
import 'package:Melora/core/theme/app_colors.dart';
import 'package:Melora/models/podcast.dart';
import 'package:Melora/screens/podcasts/podcast_audio_player_screen.dart';
import 'package:Melora/screens/podcasts/podcast_file_player_screen.dart';
import 'package:Melora/screens/podcasts/podcast_video_player_screen.dart';

/// ---------------------------------------------------------------------
/// PodcastFeedScreen
///
/// Opened from Search → Podcasts. A vertical feed of big episode cards
/// (thumbnail + duration badge, title, show name). Loads real episodes
/// from assets/dummy/podcasts.json (swap DummyDataSource.podcasts() for
/// a live API/repository call once the backend is ready — nothing else
/// here needs to change, since it only depends on [PodcastEpisode]).
/// Tapping a video episode opens the video player; audio episodes open
/// [PodcastAudioPlayerScreen] and actually play with sound via just_audio.
/// ---------------------------------------------------------------------
class PodcastFeedScreen extends StatelessWidget {
  const PodcastFeedScreen({super.key});

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Podcasts', style: TextStyle(color: Colors.white)),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DummyDataSource.podcasts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          final episodes = snapshot.data!.map(PodcastEpisode.fromJson).toList();
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: episodes.length,
            itemBuilder: (context, index) => _EpisodeCard(
              episode: episodes[index],
              onTap: () => _openEpisode(context, episodes[index]),
            ),
          );
        },
      ),
    );
  }
}

class _EpisodeCard extends StatelessWidget {
  const _EpisodeCard({required this.episode, required this.onTap});

  final PodcastEpisode episode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    episode.coverUrl.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: episode.coverUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: Colors.white.withValues(alpha: 0.06)),
                            errorWidget: (_, __, ___) => Container(
                              color: Colors.white.withValues(alpha: 0.06),
                              child: const Icon(Icons.podcasts_rounded, color: Colors.white24, size: 36),
                            ),
                          )
                        : Image.asset(
                            episode.coverUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.white.withValues(alpha: 0.06),
                              child: const Icon(Icons.podcasts_rounded, color: Colors.white24, size: 36),
                            ),
                          ),
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          episode.durationLabel,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          episode.hasVideo ? Icons.videocam_rounded : Icons.headphones_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              episode.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, height: 1.3),
            ),
            const SizedBox(height: 4),
            Text(
              episode.showTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}