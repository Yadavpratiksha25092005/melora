import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:Melora/core/theme/app_colors.dart';
import 'package:Melora/core/utils/song_display_utils.dart';
import 'package:Melora/models/song.dart';
import 'package:Melora/providers/player_provider.dart';
import 'package:Melora/providers/song_provider.dart';
import 'package:Melora/screens/home/curated_bollywood_songs.dart';
import 'package:Melora/screens/home/curated_songs_resolver.dart';
import 'package:Melora/features/onboarding/widgets/common/mini_player_bar.dart';

/// ---------------------------------------------------------------------
/// SearchCategoryScreen
///
/// Opened when the user taps one of the four tiles on the Search tab
/// (Music, Podcasts, Live Events, Top Charts). Shows a full list for
/// that category (mock data for now — swap `_mockItemsFor` for a real
/// provider once you have the matching endpoints wired up).
/// ---------------------------------------------------------------------
enum SearchTopCategory { music, podcasts, liveEvents, topCharts }

class _CategoryItem {
  final String title;
  final String subtitle;
  final String imageUrl;
  final List<Color> colors;

  const _CategoryItem({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.colors,
  });
}

class SearchCategoryScreen extends ConsumerWidget {
  final SearchTopCategory category;
  const SearchCategoryScreen({super.key, required this.category});

  String get _title {
    switch (category) {
      case SearchTopCategory.music:
        return 'Music';
      case SearchTopCategory.podcasts:
        return 'Podcasts';
      case SearchTopCategory.liveEvents:
        return 'Live Events';
      case SearchTopCategory.topCharts:
        return 'Top Charts';
    }
  }

  List<_CategoryItem> get _items {
    switch (category) {
      case SearchTopCategory.music:
        return const [
          _CategoryItem(
            title: 'Tum Hi Ho',
            subtitle: 'Song · Arijit Singh',
            imageUrl: 'https://loremflickr.com/400/400/bollywood,romance,poster',
            colors: [Color(0xFF6E4BF0), Color(0xFF241847)],
          ),
          _CategoryItem(
            title: 'Bol Do Na Zara',
            subtitle: 'Song · Armaan Malik',
            imageUrl: 'https://loremflickr.com/400/400/bollywood,wedding,poster',
            colors: [Color(0xFF1E88C7), Color(0xFF0F2A44)],
          ),
          _CategoryItem(
            title: 'O Saki Saki',
            subtitle: 'Song · Neha Kakkar',
            imageUrl: 'https://loremflickr.com/400/400/bollywood,dance,poster',
            colors: [Color(0xFF9A3B7A), Color(0xFF2E1128)],
          ),
          _CategoryItem(
            title: 'Lut Gaye',
            subtitle: 'Song · Jubin Nautiyal',
            imageUrl: 'https://loremflickr.com/400/400/bollywood,drama,poster',
            colors: [Color(0xFF2E7D32), Color(0xFF10331A)],
          ),
        ];
      case SearchTopCategory.podcasts:
        return const [
          _CategoryItem(
            title: 'The Late Night Mix',
            subtitle: 'Episode 42 · 38 min',
            imageUrl: 'https://loremflickr.com/200/200/podcast,microphone',
            colors: [Color(0xFF6E4BF0), Color(0xFF241847)],
          ),
          _CategoryItem(
            title: 'Music & Business',
            subtitle: 'Episode 17 · 52 min',
            imageUrl: 'https://loremflickr.com/200/200/podcast,studio',
            colors: [Color(0xFF1E88C7), Color(0xFF0F2A44)],
          ),
          _CategoryItem(
            title: 'Behind The Beats',
            subtitle: 'Episode 9 · 44 min',
            imageUrl: 'https://loremflickr.com/200/200/podcast,headphones',
            colors: [Color(0xFF9A3B7A), Color(0xFF2E1128)],
          ),
          _CategoryItem(
            title: 'Indie Spotlight',
            subtitle: 'Episode 5 · 29 min',
            imageUrl: 'https://loremflickr.com/200/200/podcast,talk',
            colors: [Color(0xFF2E7D32), Color(0xFF10331A)],
          ),
        ];
      case SearchTopCategory.liveEvents:
        return const [
          _CategoryItem(
            title: 'Sunset Sessions Fest',
            subtitle: 'This weekend · Mumbai',
            imageUrl: 'https://loremflickr.com/200/200/concert,crowd',
            colors: [Color(0xFF6E4BF0), Color(0xFF241847)],
          ),
          _CategoryItem(
            title: 'Arijit Singh Live',
            subtitle: 'Aug 12 · Bengaluru',
            imageUrl: 'https://loremflickr.com/200/200/concert,stage',
            colors: [Color(0xFF1E88C7), Color(0xFF0F2A44)],
          ),
          _CategoryItem(
            title: 'Indie Underground Night',
            subtitle: 'Aug 20 · Delhi',
            imageUrl: 'https://loremflickr.com/200/200/concert,lights',
            colors: [Color(0xFF9A3B7A), Color(0xFF2E1128)],
          ),
          _CategoryItem(
            title: 'Armaan Malik Tour',
            subtitle: 'Sep 3 · Pune',
            imageUrl: 'https://loremflickr.com/200/200/band,live',
            colors: [Color(0xFF2E7D32), Color(0xFF10331A)],
          ),
        ];
      case SearchTopCategory.topCharts:
        return const [
          _CategoryItem(
            title: '#1 · Bekhayali',
            subtitle: 'Tulsi Kumar',
            imageUrl: 'https://loremflickr.com/400/400/bollywood,intense,poster',
            colors: [Color(0xFF6E4BF0), Color(0xFF241847)],
          ),
          _CategoryItem(
            title: '#2 · Deewani Mastani',
            subtitle: 'Shreya Ghoshal',
            imageUrl: 'https://loremflickr.com/400/400/bollywood,classical,poster',
            colors: [Color(0xFF1E88C7), Color(0xFF0F2A44)],
          ),
          _CategoryItem(
            title: '#3 · Chogada',
            subtitle: 'Darshan Raval',
            imageUrl: 'https://loremflickr.com/400/400/bollywood,festival,poster',
            colors: [Color(0xFF9A3B7A), Color(0xFF2E1128)],
          ),
          _CategoryItem(
            title: '#4 · Tu Jaane Na',
            subtitle: 'Atif Aslam',
            imageUrl: 'https://loremflickr.com/400/400/bollywood,emotional,poster',
            colors: [Color(0xFF2E7D32), Color(0xFF10331A)],
          ),
        ];
    }
  }

  Song? _resolvedSongFor(String title) {
    return resolvedBollywoodSongForTitle(title) ?? resolvedCuratedSongForTitle(title);
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1C1C24),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (category == SearchTopCategory.music) {
      // Real catalog (all songs), with the ones that have a real poster
      // image pinned to the top and de-duplicated — same rule as Home.
      final songsAsync = ref.watch(allSongsProvider);
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('Music', style: TextStyle(color: Colors.white)),
        ),
        bottomNavigationBar: const MiniPlayerBar(),
        body: songsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (err, st) => const Center(
            child: Text(
              'Couldn\'t load songs',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          data: (allSongs) {
            final songs = dedupedWithImagesFirst(allSongs);
            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: songs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final song = songs[index];
                final coverImage = hasLocalCover(song) ? song.coverUrl : null;
                return GestureDetector(
                  onTap: () {
                    ref.read(playerProvider.notifier).playQueue(songs, index);
                    _showSnack(context, 'Playing "${song.title}"');
                  },
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: coverImage != null
                              ? Image.asset(
                                  coverImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: AppColors.surface,
                                    child: const Icon(Icons.music_note, color: Colors.white24),
                                  ),
                                )
                              : Container(
                                  color: AppColors.surface,
                                  child: const Icon(Icons.music_note, color: Colors.white24),
                                ),
                        ),
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
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${song.artistName ?? 'Unknown'} • ${song.genre ?? ''}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white38, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.play_arrow_rounded, color: Colors.white54, size: 22),
                    ],
                  ),
                );
              },
            );
          },
        ),
      );
    }

    final items = _items;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(_title, style: const TextStyle(color: Colors.white)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () {
              if (category == SearchTopCategory.music || category == SearchTopCategory.topCharts) {
                final resolved = _resolvedSongFor(item.title);
                if (resolved != null) {
                  final queue = items
                      .map((i) => _resolvedSongFor(i.title))
                      .whereType<Song>()
                      .toList();
                  final startIndex = queue.indexWhere((s) => s.title == resolved.title);
                  ref.read(playerProvider.notifier).playQueue(
                        queue,
                        startIndex >= 0 ? startIndex : 0,
                      );
                  _showSnack(context, 'Playing "${item.title}"');
                  return;
                }
                _showSnack(context, '"${item.title}" isn\'t available to stream yet');
                return;
              }
              _showSnack(context, 'Opening "${item.title}"');
            },
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: item.colors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        loadingBuilder: (context, child, progress) =>
                            progress == null ? child : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.play_arrow_rounded, color: Colors.white54, size: 22),
              ],
            ),
          );
        },
      ),
    );
  }
}