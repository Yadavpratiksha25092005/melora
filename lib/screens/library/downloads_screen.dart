import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:Melora/core/theme/app_colors.dart';
import 'package:Melora/models/song.dart';
import 'package:Melora/providers/download_provider.dart';
import 'package:Melora/providers/player_provider.dart';
<<<<<<< HEAD
=======
import 'package:Melora/features/onboarding/widgets/common/mini_player_bar.dart';
>>>>>>> 3cb5a6ec211f46c4bc31b1cbd4ba22d147c15624

/// ---------------------------------------------------------------------
/// DownloadsScreen
///
/// Opened from the pinned "Downloads" entry on Your Library. Shows every
/// song that has actually finished downloading via [downloadProvider] —
/// not mock data — so a song downloaded from the player screen shows up
/// here immediately.
/// ---------------------------------------------------------------------
class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  bool _isLocalCover(Song song) {
    final cover = song.coverUrl;
    return cover != null && cover.isNotEmpty && !cover.startsWith('http');
  }

  Widget _buildCover(Song song) {
    final cover = song.coverUrl;
    if (cover == null || cover.isEmpty) {
      return Container(
        color: Colors.white.withValues(alpha: 0.06),
        child: const Icon(Icons.music_note_rounded, color: Colors.white24, size: 20),
      );
    }
    if (_isLocalCover(song)) {
      return Image.asset(
        cover,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.white.withValues(alpha: 0.06),
          child: const Icon(Icons.music_note_rounded, color: Colors.white24, size: 20),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: cover,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(color: Colors.white.withValues(alpha: 0.06)),
      errorWidget: (context, url, error) => Container(
        color: Colors.white.withValues(alpha: 0.06),
        child: const Icon(Icons.music_note_rounded, color: Colors.white24, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadMap = ref.watch(downloadProvider);
    final downloads = (downloadMap.values
            .where((info) => info.status == DownloadStatus.done && info.song != null)
            .toList()
          ..sort((a, b) =>
              (b.downloadedAt ?? DateTime(0)).compareTo(a.downloadedAt ?? DateTime(0))))
        .map((info) => info.song!)
        .toList();

<<<<<<< HEAD
    return Scaffold(
      backgroundColor: AppColors.background,
=======
  return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const MiniPlayerBar(),
>>>>>>> 3cb5a6ec211f46c4bc31b1cbd4ba22d147c15624
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Downloads', style: TextStyle(color: Colors.white)),
      ),
      body: downloads.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Songs you download will show up here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: downloads.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final song = downloads[index];
                return GestureDetector(
                  onTap: () => ref
                      .read(playerProvider.notifier)
                      .playQueue(downloads, index),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(width: 52, height: 52, child: _buildCover(song)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              song.genre?.isNotEmpty == true ? song.genre! : song.artistId,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white38, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.download_done_rounded, color: Color(0xFF1ED760), size: 20),
                    ],
                  ),
                );
              },
            ),
    );
  }
}