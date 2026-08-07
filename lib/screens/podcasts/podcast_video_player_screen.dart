import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'package:Melora/core/theme/app_colors.dart';
import 'package:Melora/models/podcast.dart';

/// ---------------------------------------------------------------------
/// PodcastVideoPlayerScreen
///
/// Opened for episodes that have a YouTube [PodcastEpisode.videoUrl].
///
/// Since late 2025 YouTube tightened referrer/origin verification for
/// embedded players, which currently breaks inline WebView playback
/// (error codes 150/152/153) across most Flutter/React Native/web
/// YouTube-embed packages — not specific to this app. We still attempt
/// the inline embed (it does work on many devices/networks), but always
/// show a guaranteed-to-work "Watch on YouTube" fallback right below it,
/// so an episode is never actually stuck.
/// ---------------------------------------------------------------------
class PodcastVideoPlayerScreen extends StatefulWidget {
  const PodcastVideoPlayerScreen({super.key, required this.episode});

  final PodcastEpisode episode;

  @override
  State<PodcastVideoPlayerScreen> createState() => _PodcastVideoPlayerScreenState();
}

class _PodcastVideoPlayerScreenState extends State<PodcastVideoPlayerScreen> {
  YoutubePlayerController? _controller;
  String? _initError;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayerController.convertUrlToId(widget.episode.videoUrl ?? '');
    if (videoId == null) {
      _initError = 'This episode\'s video link looks invalid.';
      return;
    }
    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        strictRelatedVideos: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  Future<void> _openInYoutube() async {
    final url = widget.episode.videoUrl;
    if (url == null) return;
    final uri = Uri.parse(url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Couldn\'t open YouTube')),
      );
    }
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
              child: _initError != null
                  ? Container(
                      color: Colors.black,
                      alignment: Alignment.center,
                      child: Text(_initError!, style: const TextStyle(color: Colors.white54)),
                    )
                  : YoutubePlayer(controller: _controller!, aspectRatio: 16 / 9),
            ),
            // Always-visible, guaranteed-to-work fallback — YouTube's own
            // referrer/origin checks currently break inline embeds on many
            // devices/networks, so this is the reliable path, not just an
            // error-state extra.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: OutlinedButton.icon(
                onPressed: _openInYoutube,
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text('Video not playing above? Watch on YouTube'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
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
                    Row(
                      children: [
                        Text(
                          episode.showTitle,
                          style: const TextStyle(color: Colors.white60, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        Container(width: 3, height: 3, decoration: const BoxDecoration(color: Colors.white38, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Text(
                          episode.durationLabel,
                          style: const TextStyle(color: Colors.white38, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white12, height: 1),
                    const SizedBox(height: 16),
                    Text(
                      'Playing straight from YouTube — video quality, playback controls, and fullscreen are handled by the YouTube player.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13, height: 1.5),
                    ),
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