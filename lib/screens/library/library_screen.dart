import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:Melora/core/theme/app_colors.dart';
import 'package:Melora/screens/library/library_data.dart';
import 'package:Melora/screens/library/library_detail_screen.dart';
import 'package:Melora/screens/library/library_search_screen.dart';
import 'package:Melora/screens/library/downloads_screen.dart';
import 'package:Melora/features/onboarding/widgets/common/create_options_sheet.dart';
import 'package:Melora/features/onboarding/widgets/common/profile_avatar_button.dart';
import 'package:Melora/features/onboarding/widgets/common/artist_avatar.dart';
import 'package:Melora/providers/custom_playlists_provider.dart';

enum _LibraryFilter { all, playlists, artists }

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  _LibraryFilter _filter = _LibraryFilter.all;
  bool _gridView = false;

  /// Combines the fixed mock entries (Liked Songs, Downloads, artists)
  /// with any playlists the user has actually created via "Add to
  /// playlist" / the Create tab — so a new playlist shows up here right
  /// after creating it.
  List<LibraryEntry> get _allEntries {
    final customPlaylists = ref.watch(customPlaylistsProvider).values.toList().reversed;
    final customEntries = customPlaylists.map(
      (p) => LibraryEntry(
        title: p.name,
        subtitle: 'Playlist • You',
        kind: LibraryEntryKind.playlist,
        playlistId: p.id,
      ),
    );
    return [...customEntries, ...libraryEntries];
  }

  List<LibraryEntry> get _filteredEntries {
    final entries = _allEntries;
    switch (_filter) {
      case _LibraryFilter.playlists:
        return entries
            .where((e) => e.kind == LibraryEntryKind.playlist || e.kind == LibraryEntryKind.likedSongs)
            .toList();
      case _LibraryFilter.artists:
        return entries.where((e) => e.kind == LibraryEntryKind.artist).toList();
      case _LibraryFilter.all:
        return entries;
    }
  }

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

  void _openEntry(LibraryEntry entry) {
    if (entry.kind == LibraryEntryKind.downloads) {
      // Real downloads (from downloadProvider), not the generic mock
      // detail screen — otherwise songs you actually download never
      // show up here.
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const DownloadsScreen()),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LibraryDetailScreen(
          title: entry.title,
          subtitle: entry.subtitle,
          kind: entry.kind,
          imageUrl: entry.imageUrl,
          playlistId: entry.playlistId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = _filteredEntries;

    return Material(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _LibraryHeader(
                onSearchTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LibrarySearchScreen()),
                ),
                onAddTap: () => showCreateOptionsSheet(context),
              ),
            ),
            SliverToBoxAdapter(
              child: _LibraryFilterChips(
                selected: _filter,
                onSelected: (f) => setState(() => _filter = f),
              ),
            ),
            SliverToBoxAdapter(
              child: _RecentsHeader(
                gridView: _gridView,
                onSortTap: () => _showSnack('Sort options'),
                onLayoutToggle: () => setState(() => _gridView = !_gridView),
              ),
            ),
            if (entries.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child: Center(
                    child: Text('Nothing here yet', style: TextStyle(color: Colors.white38)),
                  ),
                ),
              )
            else if (_gridView)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _LibraryGridTile(
                      entry: entries[index],
                      onTap: () => _openEntry(entries[index]),
                    ),
                    childCount: entries.length,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: _LibraryListTile(
                        entry: entries[index],
                        onTap: () => _openEntry(entries[index]),
                      ),
                    ),
                    childCount: entries.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LibraryHeader extends StatelessWidget {
  final VoidCallback onSearchTap;
  final VoidCallback onAddTap;

  const _LibraryHeader({
    required this.onSearchTap,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          const ProfileAvatarButton(size: 40),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Your Library',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
            ),
          ),
          GestureDetector(
            onTap: onSearchTap,
            child: const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Icon(Icons.search, color: Colors.white, size: 24),
            ),
          ),
          GestureDetector(
            onTap: onAddTap,
            child: const Icon(Icons.add, color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }
}

class _LibraryFilterChips extends StatelessWidget {
  final _LibraryFilter selected;
  final ValueChanged<_LibraryFilter> onSelected;

  const _LibraryFilterChips({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final chips = [
      (_LibraryFilter.playlists, 'Playlists'),
      (_LibraryFilter.artists, 'Artists'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Row(
        children: chips.map((chip) {
          final isSelected = selected == chip.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => onSelected(isSelected ? _LibraryFilter.all : chip.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  chip.$2,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _RecentsHeader extends StatelessWidget {
  final bool gridView;
  final VoidCallback onSortTap;
  final VoidCallback onLayoutToggle;

  const _RecentsHeader({
    required this.gridView,
    required this.onSortTap,
    required this.onLayoutToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onSortTap,
            child: const Row(
              children: [
                Icon(Icons.swap_vert_rounded, color: Colors.white, size: 20),
                SizedBox(width: 6),
                Text(
                  'Recents',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onLayoutToggle,
            child: Icon(
              gridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
              color: Colors.white70,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryThumbnail extends StatelessWidget {
  final LibraryEntry entry;
  final double size;

  const _EntryThumbnail({required this.entry, required this.size});

  @override
  Widget build(BuildContext context) {
    final isArtist = entry.kind == LibraryEntryKind.artist;
    final radius = isArtist ? (size.isFinite ? size / 2 : 200.0) : 10.0;

    Widget content;
    if (entry.kind == LibraryEntryKind.likedSongs) {
      content = Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6E4BF0), Color(0xFF00D9F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Icon(Icons.favorite_rounded, color: Colors.white, size: size * 0.42),
      );
    } else if (isArtist) {
      content = ArtistAvatar(name: entry.title, fallbackImageUrl: entry.imageUrl);
    } else if (entry.imageUrl != null) {
      content = Image.network(
        entry.imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : Container(color: Colors.white.withValues(alpha: 0.06)),
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.white.withValues(alpha: 0.06),
          child: Icon(
            isArtist ? Icons.person_rounded : Icons.music_note_rounded,
            color: Colors.white24,
          ),
        ),
      );
    } else {
      content = Container(
        color: Colors.white.withValues(alpha: 0.06),
        child: const Icon(Icons.music_note_rounded, color: Colors.white24),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: size.isFinite
          ? SizedBox(width: size, height: size, child: content)
          : SizedBox.expand(child: content),
    );
  }
}

class _LibraryListTile extends StatelessWidget {
  final LibraryEntry entry;
  final VoidCallback onTap;

  const _LibraryListTile({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          _EntryThumbnail(entry: entry, size: 56),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    if (entry.pinned) ...[
                      const Icon(Icons.push_pin_rounded, color: Color(0xFF1CA36B), size: 13),
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                      child: Text(
                        entry.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white38, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryGridTile extends StatelessWidget {
  final LibraryEntry entry;
  final VoidCallback onTap;

  const _LibraryGridTile({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: _EntryThumbnail(entry: entry, size: double.infinity),
          ),
          const SizedBox(height: 8),
          Text(
            entry.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            entry.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 11,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}