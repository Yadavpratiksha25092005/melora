import 'package:flutter/material.dart';

import 'package:Melora/core/theme/app_colors.dart';

/// ---------------------------------------------------------------------
/// CategoryScreen
///
/// Opened when the user taps "Podcasts", "Artists" or "Playlists" on the
/// Home tab's filter chips. Shows a full list for that category (mock
/// data for now — swap `_mockItemsFor` for a real provider once you
/// have podcast/artist/playlist endpoints wired up).
/// ---------------------------------------------------------------------
enum HomeCategory { podcasts, artists, playlists }

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

class CategoryScreen extends StatelessWidget {
  final HomeCategory category;
  const CategoryScreen({super.key, required this.category});

  String get _title {
    switch (category) {
      case HomeCategory.podcasts:
        return 'Podcasts';
      case HomeCategory.artists:
        return 'Artists';
      case HomeCategory.playlists:
        return 'Playlists';
    }
  }

  bool get _circularArt => category == HomeCategory.artists;

  List<_CategoryItem> get _items {
    switch (category) {
      case HomeCategory.podcasts:
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
      case HomeCategory.artists:
        return const [
          _CategoryItem(
            title: 'Arijit Singh',
            subtitle: 'Artist',
            imageUrl: 'https://loremflickr.com/400/400/singer,microphone,indianmusic',
            colors: [Color(0xFF6E4BF0), Color(0xFF241847)],
          ),
          _CategoryItem(
            title: 'Armaan Malik',
            subtitle: 'Artist',
            imageUrl: 'https://loremflickr.com/400/400/singer,guitar,indianmusic',
            colors: [Color(0xFF1E88C7), Color(0xFF0F2A44)],
          ),
          _CategoryItem(
            title: 'Neha Kakkar',
            subtitle: 'Artist',
            imageUrl: 'https://loremflickr.com/400/400/singer,concert,indianmusic',
            colors: [Color(0xFF9A3B7A), Color(0xFF2E1128)],
          ),
          _CategoryItem(
            title: 'Jubin Nautiyal',
            subtitle: 'Artist',
            imageUrl: 'https://loremflickr.com/400/400/singer,studio,indianmusic',
            colors: [Color(0xFF2E7D32), Color(0xFF10331A)],
          ),
          _CategoryItem(
            title: 'Shreya Ghoshal',
            subtitle: 'Artist',
            imageUrl: 'https://loremflickr.com/400/400/singer,stage,indianmusic',
            colors: [Color(0xFFB05A2E), Color(0xFF3A2416)],
          ),
          _CategoryItem(
            title: 'Darshan Raval',
            subtitle: 'Artist',
            imageUrl: 'https://loremflickr.com/400/400/singer,acoustic,indianmusic',
            colors: [Color(0xFF1E3A8A), Color(0xFF0F1F4A)],
          ),
        ];
      case HomeCategory.playlists:
        return const [
          _CategoryItem(
            title: 'Arijit Singh Radio',
            subtitle: 'Playlist · Melora',
            imageUrl: 'https://loremflickr.com/400/400/singer,microphone,indianmusic',
            colors: [Color(0xFF6E4BF0), Color(0xFF241847)],
          ),
          _CategoryItem(
            title: 'Trending Hindi Songs 2026',
            subtitle: 'What everyone\'s playing',
            imageUrl: 'https://loremflickr.com/400/400/bollywood,trending,music',
            colors: [Color(0xFF1E88C7), Color(0xFF0F2A44)],
          ),
          _CategoryItem(
            title: 'Armaan Malik Hits',
            subtitle: 'Melodic love songs',
            imageUrl: 'https://loremflickr.com/400/400/singer,guitar,indianmusic',
            colors: [Color(0xFF2E7D32), Color(0xFF10331A)],
          ),
          _CategoryItem(
            title: 'Party Anthems',
            subtitle: 'High-energy dance numbers',
            imageUrl: 'https://loremflickr.com/400/400/bollywood,dance,poster',
            colors: [Color(0xFF9A3B7A), Color(0xFF2E1128)],
          ),
          _CategoryItem(
            title: 'Lofi Flip Feels',
            subtitle: 'Chill Bollywood lofi flips',
            imageUrl: 'https://loremflickr.com/400/400/lofi,headphones,mood',
            colors: [Color(0xFFB05A2E), Color(0xFF3A2416)],
          ),
        ];
    }
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
  Widget build(BuildContext context) {
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
            onTap: () => _showSnack(context, 'Opening "${item.title}"'),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: _circularArt
                      ? BorderRadius.circular(28)
                      : BorderRadius.circular(10),
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
                Icon(
                  category == HomeCategory.artists
                      ? Icons.arrow_forward_ios_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.white54,
                  size: category == HomeCategory.artists ? 16 : 22,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}