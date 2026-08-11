import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:Melora/core/theme/app_colors.dart';
import 'package:Melora/core/utils/local_poster_catalog.dart';
import 'package:Melora/providers/player_provider.dart';
import 'package:Melora/models/song.dart';
import 'package:Melora/providers/song_provider.dart';
import 'package:Melora/screens/home/home_screen.dart' show genreGradient;
import 'package:Melora/screens/home/song_collection_screen.dart';
import 'package:Melora/screens/search/search_category_screen.dart';
import 'package:Melora/screens/podcasts/podcast_feed_screen.dart';
import 'package:Melora/features/onboarding/widgets/common/profile_avatar_button.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  List<Song> _filterSongs(List<Song> allSongs) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return allSongs.where((s) {
      final title = s.title.toLowerCase();
      final artist = (s.artistName ?? '').toLowerCase();
      final genre = (s.genre ?? '').toLowerCase();
      return title.contains(q) || artist.contains(q) || genre.contains(q);
    }).toList();
  }

  static const List<_CategoryData> _categories = [
    _CategoryData(
      title: 'Music',
      colors: [Color(0xFFE0247E), Color(0xFF8B1554)],
      icon: Icons.music_note_rounded,
      category: SearchTopCategory.music,
    ),
    _CategoryData(
      title: 'Podcasts',
      colors: [Color(0xFF1CA36B), Color(0xFF0F5A3A)],
      icon: Icons.podcasts_rounded,
      category: SearchTopCategory.podcasts,
    ),
  ];

  static const List<String> _languages = [
    'Hindi',
    'Bollywood',
    'Marathi',
    'Punjabi',
    'Tamil',
    'Telugu',
    'English Pop',
    'Haryanvi',
    'Bhojpuri',
  ];

  void _openLanguage(String genre, List<Song> allSongs) {
    final filtered = allSongs.where((s) => s.genre == genre).toList();
    if (filtered.isEmpty) {
      _showSnack('No songs available for $genre yet');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SongCollectionScreen(songs: filtered, initialIndex: 0),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _playFromResults(Song song, List<Song> results) {
    final index = results.indexWhere((s) => s.id == song.id);
    ref.read(playerProvider.notifier).playQueue(results, index >= 0 ? index : 0);
    _showSnack('Playing "${song.title}"');
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(
              child: _SearchHeader(),
            ),
            SliverToBoxAdapter(
              child: _SearchField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                onSubmitted: (value) => setState(() => _query = value),
              ),
            ),
            if (_query.trim().isNotEmpty) ...[
              Consumer(builder: (context, ref, _) {
                final songsAsync = ref.watch(allSongsProvider);
                return songsAsync.when(
                  loading: () => const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  error: (e, st) => const SliverToBoxAdapter(child: SizedBox.shrink()),
                  data: (allSongs) {
                    final results = _filterSongs(allSongs);
                    if (results.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20, 24, 20, 24),
                          child: Text(
                            'No songs found. Try a different title, artist, or genre.',
                            style: TextStyle(color: Colors.white54, fontSize: 14),
                          ),
                        ),
                      );
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final song = results[index];
                            return _SearchResultTile(
                              song: song,
                              onTap: () => _playFromResults(song, results),
                            );
                          },
                          childCount: results.length,
                        ),
                      ),
                    );
                  },
                );
              }),
            ] else ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.9,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final category = _categories[index];
                      return _CategoryCard(
                        data: category,
                        onTap: () {
                          if (category.category == SearchTopCategory.podcasts) {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const PodcastFeedScreen()),
                            );
                            return;
                          }
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SearchCategoryScreen(category: category.category),
                            ),
                          );
                        },
                      );
                    },
                    childCount: _categories.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Text(
                    'Browse by Language',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Consumer(builder: (context, ref, _) {
                final songsAsync = ref.watch(allSongsProvider);
                return songsAsync.when(
                  loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                  error: (e, st) => const SliverToBoxAdapter(child: SizedBox.shrink()),
                  data: (allSongs) => SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 1.9,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final genre = _languages[index];
                          final colors = genreGradient[genre] ??
                              const [Color(0xFF3B2E7D), Color(0xFF14103A)];
                          return _CategoryCard(
                            data: _CategoryData(
                              title: genre,
                              colors: colors,
                              icon: Icons.language_rounded,
                              category: SearchTopCategory.music,
                            ),
                            onTap: () => _openLanguage(genre, allSongs),
                          );
                        },
                        childCount: _languages.length,
                      ),
                    ),
                  ),
                );
              }),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ],
        ),
      ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          ProfileAvatarButton(size: 40),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Search',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String>? onChanged;

  const _SearchField({required this.controller, required this.onSubmitted, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.black54, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                style: const TextStyle(color: Colors.black87, fontSize: 15),
                decoration: const InputDecoration(
                  hintText: 'What do you want to listen to?',
                  hintStyle: TextStyle(color: Colors.black54, fontSize: 15),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            if (controller.text.isNotEmpty)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  controller.clear();
                  onChanged?.call('');
                },
                child: const Icon(Icons.close_rounded, color: Colors.black45, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const _SearchResultTile({required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final poster = localPosterForTitle(song.title);
    final cover = song.coverUrl;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 52,
                height: 52,
                child: poster != null
                    ? Image.asset(
                        poster,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.surface,
                          child: const Icon(Icons.music_note, color: Colors.white24),
                        ),
                      )
                    : (cover != null && cover.isNotEmpty && cover.startsWith('http'))
                        ? Image.network(
                            cover,
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
                        color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.artistName ?? song.genre ?? '',
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
      ),
    );
  }
}

class _CategoryData {
  final String title;
  final List<Color> colors;
  final IconData icon;
  final SearchTopCategory category;

  const _CategoryData({
    required this.title,
    required this.colors,
    required this.icon,
    required this.category,
  });
}

class _CategoryCard extends StatelessWidget {
  final _CategoryData data;
  final VoidCallback onTap;

  const _CategoryCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: data.colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                data.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Positioned(
              right: -6,
              bottom: -6,
              child: Transform.rotate(
                angle: 0.4,
                child: Icon(
                  data.icon,
                  color: Colors.white.withValues(alpha: 0.25),
                  size: 54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscoverData {
  final String title;
  final String imageUrl;

  const _DiscoverData({required this.title, required this.imageUrl});
}

class _DiscoverRow extends StatelessWidget {
  final List<_DiscoverData> items;
  final ValueChanged<String> onTap;

  const _DiscoverRow({required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTap(item.title),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 130,
                height: 150,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3A2C7A), Color(0xFF1A1230)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) =>
                      progress == null ? child : const SizedBox.shrink(),
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}