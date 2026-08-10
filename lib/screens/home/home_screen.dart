import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:Melora/core/theme/app_colors.dart';
import 'package:Melora/core/constants/artist_photos.dart';
import 'package:Melora/core/utils/local_poster_catalog.dart';
import 'package:Melora/models/song.dart';
import 'package:Melora/providers/player_provider.dart';
import 'package:Melora/providers/song_provider.dart';
import 'package:Melora/providers/updates_provider.dart';
import 'package:Melora/screens/home/curated_bollywood_songs.dart';
import 'package:Melora/screens/home/following_screen.dart';
import 'package:Melora/screens/home/curated_songs_data.dart';
import 'package:Melora/screens/home/curated_songs_resolver.dart';
import 'package:Melora/screens/home/song_collection_screen.dart';
import 'package:Melora/screens/podcasts/podcast_feed_screen.dart';
import 'package:Melora/screens/updates/updates_screen.dart';
import 'package:Melora/features/onboarding/widgets/common/profile_avatar_button.dart';
import 'package:Melora/screens/podcasts/following_shows_screen.dart';
import 'package:Melora/screens/library/library_detail_screen.dart';

List<Song> _dedupedHomeSongs(List<Song> songs) {
  final withImage = <Song>[];
  final withoutImage = <Song>[];
  final seenImageTitles = <String>{};
  for (final s in songs) {
    if (_SongGridTile.hasLocalCover(s)) {
      if (seenImageTitles.add(normalizeTitle(s.title))) {
        withImage.add(s);
      }
    } else {
      withoutImage.add(s);
    }
  }
  return [...withImage, ...withoutImage];
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedPill = 1;

  void _showSnack(String message) {
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

  void _onPillSelected(int index) {
    if (index == 4) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const FollowingShowsScreen(),
        ),
      );
      return;
    }
    if (index == 3) {
      setState(() => _selectedPill = index);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const PodcastFeedScreen(),
        ),
      );
      return;
    }
    if (index == 2) {
      setState(() => _selectedPill = index);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const FollowingScreen(),
        ),
      );
      return;
    }
    setState(() => _selectedPill = index);
  }

  void _openSeeAll(CuratedSection section) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _SeeAllScreen(
          section: section,
          onSongTap: (s) => _playSong(s, section),
          onSongLongPress: _openSongOptions,
        ),
      ),
    );
  }

  void _playSong(CuratedSong song, [CuratedSection? section]) {
    Song buildSong(CuratedSong s) {
      final resolved = resolvedBollywoodSongForTitle(s.title) ??
          resolvedCuratedSongForTitle(s.title);
      return resolved != null
          ? resolved.copyWith(id: s.id)
          : Song(
              id: s.id,
              artistId: 'melora',
              title: s.title,
              durationMs: 0,
              fileUrl: s.fileUrl,
              coverUrl: localPosterForTitle(s.title),
              genre: s.category,
            );
    }

    final sectionSongs = section?.songs ?? [song];
    final builtQueue = sectionSongs.map(buildSong).toList();
    final startIndex = sectionSongs.indexWhere((s) => s.id == song.id);
    ref.read(playerProvider.notifier).playQueue(
          builtQueue,
          startIndex >= 0 ? startIndex : 0,
        );
    _showSnack('Playing "${song.title}"');
  }

  void _openSongOptions(CuratedSong song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF15151C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              _sheetTile(Icons.play_arrow_rounded, 'Play "${song.title}"', () {
                Navigator.pop(context);
                _playSong(song);
              }),
              _sheetTile(Icons.favorite_border_rounded, 'Add to Library', () {
                Navigator.pop(context);
                _showSnack('Added "${song.title}" to Library');
              }),
              _sheetTile(Icons.share_rounded, 'Share', () {
                Navigator.pop(context);
                _showSnack('Sharing "${song.title}"');
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetTile(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
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
            SliverToBoxAdapter(
              child: _HomeHeader(
                selectedPill: _selectedPill,
                onPillSelected: _onPillSelected,
                onBellTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const UpdatesScreen()),
                ),
              ),
            ),
            Consumer(builder: (context, ref, _) {
              final songsAsync = ref.watch(allSongsProvider);
              return songsAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (e, st) => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text('Failed to load songs', style: TextStyle(color: Colors.white38)),
                    ),
                  ),
                ),
                data: (songs) {
                  final sortedSongs = _dedupedHomeSongs(songs);

                  Widget titledGrid(String title, List<Song> rowSongs, int startIndex) {
                    return SliverMainAxisGroup(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 210,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                              itemCount: rowSongs.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 14),
                              itemBuilder: (context, i) {
                                final song = rowSongs[i];
                                return SizedBox(
                                  width: 148,
                                  child: _SongGridTile(
                                    song: song,
                                    onTap: () {
                                      ref
                                          .read(playerProvider.notifier)
                                          .playQueue(rowSongs, i);
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => SongCollectionScreen(
                                            songs: rowSongs,
                                            initialIndex: i,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  Widget artistsRow() {
                    final entries = artistPhotoAssets.entries.toList();
                    if (entries.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
                    return SliverMainAxisGroup(
                      slivers: [
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
                            child: Text(
                              'Artists',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 112,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                              itemCount: entries.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 16),
                              itemBuilder: (context, i) {
                                final name = entries[i].key;
                                final asset = entries[i].value;
                                return SizedBox(
                                  width: 78,
                                  child: GestureDetector(
                                    onTap: () {
                                      final artistSongs = sortedSongs
                                          .where((s) =>
                                              (s.artistName ?? '').trim().toLowerCase() ==
                                              name.trim().toLowerCase())
                                          .toList();
                                      if (artistSongs.isEmpty) {
                                        _showSnack('No songs found for $name');
                                        return;
                                      }
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => LibraryDetailScreen(
                                            title: name,
                                            subtitle: '${artistSongs.length} songs',
                                            kind: LibraryEntryKind.artist,
                                            imageUrl: null,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 34,
                                          backgroundColor: const Color(0xFF2A2A35),
                                          backgroundImage: AssetImage(asset),
                                          onBackgroundImageError: (_, __) {},
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return _selectedPill == 1
                    ? SliverMainAxisGroup(
                        slivers: [
                          if (sortedSongs.isNotEmpty)
                            titledGrid(
                              'Recommended for you',
                              sortedSongs.take(4).toList(),
                              0,
                            ),
                          artistsRow(),
                          if (sortedSongs.length > 4)
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                              sliver: SliverToBoxAdapter(
                                child: Text(
                                  'Try something else',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          if (sortedSongs.length > 4)
                            Builder(builder: (context) {
                              final top4 = sortedSongs.take(4).toList();
                              final rest = sortedSongs.skip(4).toList();
                              final mid = rest.length ~/ 2;
                              final reordered = [
                                ...rest.take(mid),
                                ...top4,
                                ...rest.skip(mid),
                              ];
                              return SliverPadding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                                sliver: SliverGrid(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 14,
                                    childAspectRatio: 0.72,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final song = reordered[index];
                                      return _SongGridTile(
                                        song: song,
                                        onTap: () {
                                          ref
                                              .read(playerProvider.notifier)
                                              .playQueue(reordered, index);
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => SongCollectionScreen(
                                                songs: reordered,
                                                initialIndex: index,
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    childCount: reordered.length,
                                  ),
                                ),
                              );
                            }),
                          const SliverToBoxAdapter(child: SizedBox(height: 8)),
                        ],
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.72,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final song = sortedSongs[index];
                              return _SongGridTile(
                                song: song,
                                onTap: () {
                                  ref
                                      .read(playerProvider.notifier)
                                      .playQueue(sortedSongs, index);
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => SongCollectionScreen(
                                        songs: sortedSongs,
                                        initialIndex: index,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            childCount: sortedSongs.length,
                          ),
                        ),
                      );
                },
              );
            }),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends ConsumerWidget {
  final int selectedPill;
  final ValueChanged<int> onPillSelected;
  final VoidCallback onBellTap;

  const _HomeHeader({
    required this.selectedPill,
    required this.onPillSelected,
    required this.onBellTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadUpdates = ref.watch(unreadUpdatesCountProvider);
    final showFollowing = selectedPill == 1;
    final showPodcastFollowing = selectedPill == 3;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          const ProfileAvatarButton(),
          const SizedBox(width: 14),
          Expanded(
            child: SizedBox(
              height: 36,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterPill(
                      label: 'All',
                      isSelected: selectedPill == 0,
                      onTap: () => onPillSelected(0),
                    ),
                    const SizedBox(width: 10),
                    _FilterPill(
                      label: 'Music',
                      isSelected: selectedPill == 1,
                      onTap: () => onPillSelected(1),
                    ),
                    ClipRect(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeOutCubic,
                        width: showFollowing ? 118 : 0,
                        margin: EdgeInsets.only(left: showFollowing ? 10 : 0),
                        child: OverflowBox(
                          minWidth: 118,
                          maxWidth: 118,
                          alignment: Alignment.centerLeft,
                          child: AnimatedSlide(
                            duration: const Duration(milliseconds: 320),
                            curve: Curves.easeOutCubic,
                            offset: showFollowing ? Offset.zero : const Offset(0.4, 0),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 260),
                              opacity: showFollowing ? 1 : 0,
                              child: _FilterPill(
                                label: 'Following',
                                isSelected: selectedPill == 2,
                                onTap: () => onPillSelected(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _FilterPill(
                      label: 'Podcasts',
                      isSelected: selectedPill == 3,
                      onTap: () => onPillSelected(3),
                    ),
                    ClipRect(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeOutCubic,
                        width: showPodcastFollowing ? 118 : 0,
                        margin: EdgeInsets.only(left: showPodcastFollowing ? 10 : 0),
                        child: OverflowBox(
                          minWidth: 118,
                          maxWidth: 118,
                          alignment: Alignment.centerLeft,
                          child: AnimatedSlide(
                            duration: const Duration(milliseconds: 320),
                            curve: Curves.easeOutCubic,
                            offset: showPodcastFollowing ? Offset.zero : const Offset(0.4, 0),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 260),
                              opacity: showPodcastFollowing ? 1 : 0,
                              child: _FilterPill(
                                label: 'Following',
                                isSelected: false,
                                onTap: () => onPillSelected(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onBellTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white70,
                    size: 22,
                  ),
                ),
                if (unreadUpdates > 0)
                  Positioned(
                    top: -1,
                    right: -1,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.background, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6E7CF2)],
                )
              : null,
          color: isSelected ? null : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          softWrap: false,
          overflow: TextOverflow.visible,
          maxLines: 1,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white60,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              'See All',
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

const Map<String, List<Color>> categoryGradient = {
  'Hindi / Indie': [Color(0xFF7C3AED), Color(0xFF2E1065)],
  'Bollywood Style': [Color(0xFFE0703A), Color(0xFF7C2D12)],
  'Marathi Style': [Color(0xFF0EA5A0), Color(0xFF134E4A)],
  'Punjabi': [Color(0xFFE6A317), Color(0xFF7C4A03)],
  'Lofi / Chill': [Color(0xFF3B5BDB), Color(0xFF1E1B4B)],
};

const Map<String, List<Color>> genreGradient = {
  'Bollywood': [Color(0xFFE0703A), Color(0xFF7C2D12)],
  'Hindi': [Color(0xFF7C3AED), Color(0xFF2E1065)],
  'Marathi': [Color(0xFF0EA5A0), Color(0xFF134E4A)],
  'Telugu': [Color(0xFFDB2777), Color(0xFF701A45)],
  'Tamil': [Color(0xFF16A34A), Color(0xFF14532D)],
  'English Pop': [Color(0xFF2563EB), Color(0xFF1E3A8A)],
  'Punjabi': [Color(0xFFE6A317), Color(0xFF7C4A03)],
  'Haryanvi': [Color(0xFFCA8A04), Color(0xFF713F12)],
  'Bhojpuri': [Color(0xFFEA580C), Color(0xFF7C2D12)],
  'Love': [Color(0xFFE11D48), Color(0xFF881337)],
  'Party': [Color(0xFF9333EA), Color(0xFF3B0764)],
  'Mood': [Color(0xFF0891B2), Color(0xFF164E63)],
  'Rock': [Color(0xFF52525B), Color(0xFF18181B)],
  'Classical': [Color(0xFFB45309), Color(0xFF451A03)],
};

class _SongGridTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const _SongGridTile({required this.song, required this.onTap});

  static bool hasLocalCover(Song song) {
    final cover = song.coverUrl;
    return cover != null && cover.isNotEmpty && !cover.startsWith('http');
  }

  @override
  Widget build(BuildContext context) {
    final cover = song.coverUrl;
    final hasLocalCover = _SongGridTile.hasLocalCover(song);
    final colors = genreGradient[song.genre] ?? const [Color(0xFF3B2E7D), Color(0xFF14103A)];

    Widget gradientFallback() => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.music_note_rounded,
            color: Colors.white.withValues(alpha: 0.35),
            size: 34,
          ),
        );

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: hasLocalCover
                        ? Image.asset(
                            cover!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => gradientFallback(),
                          )
                        : gradientFallback(),
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            song.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            song.artistName ?? song.genre ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _PosterBox extends StatelessWidget {
  final String title;
  final String category;
  final BorderRadius borderRadius;

  const _PosterBox({
    required this.title,
    required this.category,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final posterPath = localPosterForTitle(title);
    final networkCover = resolvedCuratedSongForTitle(title)?.coverUrl;
    final colors = categoryGradient[category] ?? [const Color(0xFF3B2E7D), const Color(0xFF14103A)];

    Widget gradientFallback() => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.music_note_rounded,
            color: Colors.white.withValues(alpha: 0.35),
            size: 34,
          ),
        );

    if (posterPath != null) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Image.asset(
          posterPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => gradientFallback(),
        ),
      );
    }

    if (networkCover != null && networkCover.isNotEmpty) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: CachedNetworkImage(
          imageUrl: networkCover,
          fit: BoxFit.cover,
          placeholder: (context, url) => gradientFallback(),
          errorWidget: (context, url, error) => gradientFallback(),
        ),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: gradientFallback(),
    );
  }
}

class _PosterRow extends StatelessWidget {
  final CuratedSection section;
  final void Function(CuratedSong song) onTap;
  final void Function(CuratedSong song) onLongPress;

  const _PosterRow({
    required this.section,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: section.songs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final song = section.songs[index];
          return GestureDetector(
            onTap: () => onTap(song),
            onLongPress: () => onLongPress(song),
            child: SizedBox(
              width: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: Stack(
                      children: [
                        _PosterBox(
                          title: song.title,
                          category: song.category,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    song.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ClassicsGridSection extends StatelessWidget {
  final CuratedSection section;
  final void Function(CuratedSong song) onTap;
  final void Function(CuratedSong song) onLongPress;

  const _ClassicsGridSection({
    required this.section,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: section.songs.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.5,
        ),
        itemBuilder: (context, index) {
          final song = section.songs[index];
          return GestureDetector(
            onTap: () => onTap(song),
            onLongPress: () => onLongPress(song),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: _PosterBox(
                      title: song.title,
                      category: song.category,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      song.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => onTap(song),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Colors.white12,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ClassicsCarousel extends StatelessWidget {
  final CuratedSection section;
  final void Function(CuratedSong song) onTap;
  final void Function(CuratedSong song) onLongPress;

  const _ClassicsCarousel({
    required this.section,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: section.songs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final song = section.songs[index];
          return GestureDetector(
            onTap: () => onTap(song),
            onLongPress: () => onLongPress(song),
            child: SizedBox(
              width: 190,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 190,
                    height: 190,
                    child: Stack(
                      children: [
                        _PosterBox(
                          title: song.title,
                          category: song.category,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(14),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.75),
                                ],
                              ),
                            ),
                            child: Text(
                              song.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                fontStyle: FontStyle.italic,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SeeAllScreen extends StatelessWidget {
  final CuratedSection section;
  final void Function(CuratedSong song) onSongTap;
  final void Function(CuratedSong song) onSongLongPress;

  const _SeeAllScreen({
    required this.section,
    required this.onSongTap,
    required this.onSongLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(section.title, style: const TextStyle(color: Colors.white)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: section.songs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final song = section.songs[index];
          return GestureDetector(
            onTap: () => onSongTap(song),
            onLongPress: () => onSongLongPress(song),
            child: Row(
              children: [
                SizedBox(
                  width: 52,
                  height: 52,
                  child: _PosterBox(
                    title: song.title,
                    category: song.category,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => onSongTap(song),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}