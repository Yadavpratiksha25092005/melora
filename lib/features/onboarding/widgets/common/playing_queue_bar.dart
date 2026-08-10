import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import 'package:Melora/core/routes/route_names.dart';
import 'package:Melora/core/theme/app_colors.dart';
import 'package:Melora/core/theme/text_styles.dart';
import 'package:Melora/models/song.dart';
import 'package:Melora/providers/player_provider.dart';
import 'package:Melora/providers/song_provider.dart';

/// Playing queue bar - shows "Now playing" songs list below mini player
class PlayingQueueBar extends ConsumerWidget {
  const PlayingQueueBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerProvider);
    final songsAsync = ref.watch(songListProvider);

    // Hide if no song is playing
    if (playerState.currentSong == null) return const SizedBox.shrink();

    return Container(
      height: 280,
      color: AppColors.background,
      child: Column(
        children: [
          // "Now playing" header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Now playing',
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ),
          // Songs list
          Expanded(
            child: songsAsync.when(
              data: (songs) {
                // Show up to 5 songs
                final upcomingSongs = songs.take(5).toList();
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: upcomingSongs.length,
                  itemBuilder: (context, index) {
                    final song = upcomingSongs[index];
                    return _SongQueueTile(song: song);
                  },
                );
              },
              loading: () => const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ),
              error: (_, __) => Center(
                child: Text(
                  'Failed to load queue',
                  style: AppTextStyles.caption,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SongQueueTile extends StatelessWidget {
  final Song song;

  const _SongQueueTile({required this.song});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => context.push(RouteNames.player),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                // Album art thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: song.coverUrl != null
                      ? CachedNetworkImage(
                          imageUrl: song.coverUrl!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 40,
                            height: 40,
                            color: AppColors.surface,
                            child: const Icon(
                              Icons.music_note,
                              color: AppColors.textSecondary,
                              size: 16,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 40,
                            height: 40,
                            color: AppColors.surface,
                            child: const Icon(
                              Icons.music_note,
                              color: AppColors.textSecondary,
                              size: 16,
                            ),
                          ),
                        )
                      : Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.music_note,
                            color: AppColors.textSecondary,
                            size: 16,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                // Song info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body,
                      ),
                      Text(
                        song.genre ?? 'Unknown',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                // Duration
                Text(
                  _formatDuration(song.durationMs),
                  style: AppTextStyles.caption,
                ),
                const SizedBox(width: 8),
                // More options button
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                  onPressed: () {
                    // Show options menu (optional)
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(int durationMs) {
    final duration = Duration(milliseconds: durationMs);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}