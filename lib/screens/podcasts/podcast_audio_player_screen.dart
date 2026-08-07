import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:Melora/core/theme/app_colors.dart';
import 'package:Melora/models/podcast.dart';

/// ---------------------------------------------------------------------
/// PodcastAudioPlayerScreen
///
/// For episodes with [PodcastEpisode.audioUrl] set (the normal case —
/// no video, just an mp3/m4a stream). Uses just_audio, same engine the
/// Songs player already runs on, so it's a proven playback path.
/// ---------------------------------------------------------------------
class PodcastAudioPlayerScreen extends StatefulWidget {
  const PodcastAudioPlayerScreen({super.key, required this.episode});

  final PodcastEpisode episode;

  @override
  State<PodcastAudioPlayerScreen> createState() => _PodcastAudioPlayerScreenState();
}

class _PodcastAudioPlayerScreenState extends State<PodcastAudioPlayerScreen> {
  final _player = AudioPlayer();
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      await _player.setUrl(widget.episode.audioUrl!);
      _player.play();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = "Couldn't load audio: $e");
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final episode = widget.episode;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: episode.coverUrl,
                width: 260,
                height: 260,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              episode.title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              episode.showTitle,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.redAccent))
            else
              StreamBuilder<Duration>(
                stream: _player.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final total = _player.duration ?? Duration.zero;
                  return Column(
                    children: [
                      Slider(
                        activeColor: AppColors.primary,
                        min: 0,
                        max: total.inMilliseconds.toDouble().clamp(1, double.infinity),
                        value: position.inMilliseconds
                            .toDouble()
                            .clamp(0, total.inMilliseconds.toDouble().clamp(1, double.infinity)),
                        onChanged: (v) => _player.seek(Duration(milliseconds: v.toInt())),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_fmt(position), style: TextStyle(color: Colors.grey[400])),
                            Text(_fmt(total), style: TextStyle(color: Colors.grey[400])),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      StreamBuilder<PlayerState>(
                        stream: _player.playerStateStream,
                        builder: (context, snapshot) {
                          final playing = snapshot.data?.playing ?? false;
                          return IconButton(
                            iconSize: 64,
                            color: Colors.white,
                            icon: Icon(playing ? Icons.pause_circle_filled : Icons.play_circle_filled),
                            onPressed: () => playing ? _player.pause() : _player.play(),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}