import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:app_settings/app_settings.dart';

import 'package:Melora/core/routes/route_names.dart';
import 'package:Melora/core/theme/app_colors.dart';
import 'package:Melora/core/theme/text_styles.dart';
import 'package:Melora/providers/liked_songs_provider.dart';
import 'package:Melora/providers/player_provider.dart';

class MiniPlayerBar extends ConsumerWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerProvider);
    final song = playerState.currentSong;
    if (song == null) return const SizedBox.shrink();

    final progress = playerState.duration.inMilliseconds == 0
        ? 0.0
        : playerState.position.inMilliseconds / playerState.duration.inMilliseconds;

    return GestureDetector(
      onTap: () => context.push(RouteNames.player),
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF3A2E52), Color(0xFF2B2B36)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 64,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    // Album art
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Builder(builder: (context) {
                        final coverUrl = song.coverUrl;
                        final isNetwork = coverUrl != null && coverUrl.startsWith('http');
                        final isLocalAsset =
                            coverUrl != null && !isNetwork && coverUrl.isNotEmpty;

                        if (isNetwork) {
                          return CachedNetworkImage(
                            imageUrl: coverUrl,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 44,
                              height: 44,
                              color: AppColors.surface,
                              child: const Icon(Icons.music_note,
                                  color: AppColors.textSecondary, size: 20),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 44,
                              height: 44,
                              color: AppColors.surface,
                              child: const Icon(Icons.music_note,
                                  color: AppColors.textSecondary, size: 20),
                            ),
                          );
                        }
                        if (isLocalAsset) {
                          return Image.asset(
                            coverUrl,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 44,
                              height: 44,
                              color: AppColors.surface,
                              child: const Icon(Icons.music_note,
                                  color: AppColors.textSecondary, size: 20),
                            ),
                          );
                        }
                        return Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.music_note,
                              color: AppColors.textSecondary, size: 20),
                        );
                      }),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium,
                          ),
                          Text(
                            song.genre ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.bluetooth_rounded, color: AppColors.textSecondary, size: 19),
                      onPressed: () => AppSettings.openAppSettings(type: AppSettingsType.bluetooth),
                    ),
                    Builder(builder: (context) {
                      final isLiked = ref.watch(
                        likedSongsProvider.select((songs) => songs.containsKey(song.id)),
                      );
                      return IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          isLiked ? Icons.check_circle_rounded : Icons.add_rounded,
                          color: isLiked ? const Color(0xFF1ED760) : AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () {
                          if (isLiked) {
                            ref.read(likedSongsProvider.notifier).remove(song.id);
                          } else {
                            ref.read(likedSongsProvider.notifier).add(song);
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(SnackBar(
                                content: Text('Added "${song.title}" to Liked Songs'),
                                backgroundColor: const Color(0xFF1C1C24),
                                behavior: SnackBarBehavior.floating,
                              ));
                          }
                        },
                      );
                    }),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        playerState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: AppColors.textPrimary,
                        size: 24,
                      ),
                      onPressed: () => ref.read(playerProvider.notifier).togglePlayPause(),
                    ),
                  ],
                ),
              ),
            ),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 2,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}