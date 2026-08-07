import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import 'package:Melora/core/theme/app_colors.dart';
import 'package:Melora/models/podcast.dart';
import 'package:Melora/providers/followed_shows_provider.dart';

/// ---------------------------------------------------------------------
/// PodcastFilePlayerScreen
///
/// For episodes whose [PodcastEpisode.videoUrl] points at a direct video
/// file (your own server, S3, Firebase, etc — anything ending in .mp4,
/// .mov, .m3u8...) rather than YouTube. Streams the file straight into
/// a native player — no WebView, no YouTube referrer/origin checks, so
/// it isn't affected by the YouTube embed issues.
/// ---------------------------------------------------------------------
class PodcastFilePlayerScreen extends StatefulWidget {
  const PodcastFilePlayerScreen({super.key, required this.episode});

  final PodcastEpisode episode;

  @override
  State<PodcastFilePlayerScreen> createState() => _PodcastFilePlayerScreenState();
}

class _PodcastFilePlayerScreenState extends State<PodcastFilePlayerScreen> {
  late final VideoPlayerController _controller;
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final url = widget.episode.videoUrl!;
    // Bundled local video (e.g. "asset:assets/videos/episode_1.mp4") vs a
    // network-hosted direct video file — both end up in the same native
    // player either way.
    _controller = url.startsWith('asset:')
        ? VideoPlayerController.asset(url.replaceFirst('asset:', ''))
        : VideoPlayerController.networkUrl(Uri.parse(url));
    _controller
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _ready = true);
        _controller.play();
      }).catchError((e) {
        if (!mounted) return;
        setState(() => _error = 'Couldn\'t load this video: $e');
      });
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '${d.inHours}:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final episode = widget.episode;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Now Playing',
                      style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _error != null
                  ? Container(
                      color: Colors.black,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(20),
                      child: Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54)),
                    )
                  : !_ready
                      ? Container(
                          color: Colors.black,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(color: AppColors.primary),
                        )
                      : GestureDetector(
                          onTap: () => setState(
                              () => _controller.value.isPlaying ? _controller.pause() : _controller.play()),
                          child: Stack(
                            alignment: Alignment.center,
                            fit: StackFit.expand,
                            children: [
                              VideoPlayer(_controller),
                              if (!_controller.value.isPlaying)
                                Container(
                                  color: Colors.black26,
                                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 56),
                                ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: VideoProgressIndicator(
                                  _controller,
                                  allowScrubbing: true,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  colors: const VideoProgressColors(
                                    playedColor: AppColors.primary,
                                    bufferedColor: Colors.white30,
                                    backgroundColor: Colors.white12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
            if (_ready)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(_controller.value.position),
                        style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    Text(_formatDuration(_controller.value.duration),
                        style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                episode.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                episode.showTitle,
                                style: const TextStyle(
                                    color: Colors.white60, fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        _FollowButton(showTitle: episode.showTitle),
                      ],
                    ),
                    if (episode.chapters.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      const Text(
                        'Chapters',
                        style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 12),
                      ...episode.chapters.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.graphic_eq_rounded, color: Colors.white54, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(c.title,
                                          style: const TextStyle(
                                              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                                      Text(c.durationLabel,
                                          style: const TextStyle(color: Colors.white38, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                    if ((episode.showDescription ?? '').isNotEmpty) ...[
                      const SizedBox(height: 28),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'About the podcast',
                              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.podcasts_rounded, color: Colors.white54, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    episode.showHost ?? episode.showTitle,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              episode.showDescription!,
                              style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if ((episode.episodeDescription ?? '').isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'About the episode',
                              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              episode.title,
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              episode.episodeDescription!,
                              style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Follow/Following toggle — wired to followedShowsProvider so it stays
/// in sync with FollowingShowsScreen (Home → Podcasts → Following).
class _FollowButton extends ConsumerWidget {
  const _FollowButton({required this.showTitle});

  final String showTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final following = ref.watch(followedShowsProvider).contains(showTitle);

    return OutlinedButton(
      onPressed: () {
        final notifier = ref.read(followedShowsProvider.notifier);
        following ? notifier.unfollow(showTitle) : notifier.follow(showTitle);
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: following ? Colors.black : Colors.white,
        backgroundColor: following ? Colors.white : Colors.transparent,
        side: const BorderSide(color: Colors.white38),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(
        following ? 'Following' : 'Follow',
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }
}