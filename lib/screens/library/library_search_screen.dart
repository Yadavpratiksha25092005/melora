import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:Melora/core/theme/app_colors.dart';
import 'package:Melora/features/onboarding/widgets/common/artist_avatar.dart';
import 'package:Melora/models/song.dart';
import 'package:Melora/providers/custom_playlists_provider.dart';
import 'package:Melora/providers/player_provider.dart';
import 'package:Melora/providers/song_provider.dart';
import 'package:Melora/screens/library/library_data.dart';
import 'package:Melora/screens/library/library_detail_screen.dart';

/// ---------------------------------------------------------------------
/// LibrarySearchScreen
///
/// Opened when the user taps the search icon on the Your Library tab.
/// Filters `libraryEntries` (the same data the Library tab shows) by
/// title as the user types.
/// ---------------------------------------------------------------------
class LibrarySearchScreen extends ConsumerStatefulWidget {
  const LibrarySearchScreen({super.key});

  @override
  ConsumerState<LibrarySearchScreen> createState() => _LibrarySearchScreenState();
}

class _LibrarySearchScreenState extends ConsumerState<LibrarySearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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

  List<LibraryEntry> get _results {
    final entries = _allEntries;
    if (_query.trim().isEmpty) return entries;
    final q = _query.trim().toLowerCase();
    return entries.where((e) => e.title.toLowerCase().contains(q)).toList();
  }

  void _openEntry(LibraryEntry entry) {
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

  Future<void> _playSong(List<Song> songs, int index) async {
    await ref.read(playerProvider.notifier).playQueue(songs, index);
  }

  Widget _libraryTile(LibraryEntry entry) {
    final isArtist = entry.kind == LibraryEntryKind.artist;
    return GestureDetector(
      onTap: () => _openEntry(entry),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(isArtist ? 28 : 10),
            child: SizedBox(
              width: 56,
              height: 56,
              child: entry.kind == LibraryEntryKind.likedSongs
                  ? Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF6E4BF0), Color(0xFF00D9F5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 24),
                    )
                  : isArtist
                      // Same local-photo-first lookup as the rest of the
                      // app, instead of the raw placeholder imageUrl.
                      ? ArtistAvatar(name: entry.title, fallbackImageUrl: entry.imageUrl)
                      : Image.network(
                          entry.imageUrl ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.white.withValues(alpha: 0.06),
                            child: const Icon(Icons.music_note_rounded, color: Colors.white24),
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
                  entry.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _songTile(List<Song> songs, int index) {
    final song = songs[index];
    return GestureDetector(
      onTap: () => _playSong(songs, index),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 56,
              height: 56,
              child: (song.coverUrl != null && song.coverUrl!.isNotEmpty)
                  ? Image.network(
                      song.coverUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.white.withValues(alpha: 0.06),
                        child: const Icon(Icons.music_note_rounded, color: Colors.white24),
                      ),
                    )
                  : Container(
                      color: Colors.white.withValues(alpha: 0.06),
                      child: const Icon(Icons.music_note_rounded, color: Colors.white24),
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
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
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
          const Icon(Icons.play_circle_fill_rounded, color: Colors.white38, size: 26),
        ],
      ),
    );
  }

  Widget _buildList(List<LibraryEntry> entries, List<Song> songs, {bool isLoadingSongs = false}) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      children: [
        for (final entry in entries) ...[
          _libraryTile(entry),
          const SizedBox(height: 16),
        ],
        if (songs.isNotEmpty || isLoadingSongs) ...[
          if (entries.isNotEmpty) const SizedBox(height: 4),
          const Text(
            'Songs',
            style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (isLoadingSongs)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
            )
          else
            for (var i = 0; i < songs.length; i++) ...[
              _songTile(songs, i),
              if (i != songs.length - 1) const SizedBox(height: 16),
            ],
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    final query = _query.trim();
    // Library entries only cover playlists/artists — actual songs live in
    // the real catalog, so we search that separately via songSearchProvider
    // (same provider the main Search tab uses) and show a "Songs" section
    // beneath the library matches.
    final songResults = query.isEmpty
        ? const AsyncValue<List<Song>>.data(<Song>[])
        : ref.watch(songSearchProvider(query));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.black54, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              autofocus: true,
                              onChanged: (value) => setState(() => _query = value),
                              style: const TextStyle(color: Colors.black87, fontSize: 15),
                              decoration: const InputDecoration(
                                hintText: 'Search your library',
                                hintStyle: TextStyle(color: Colors.black54, fontSize: 15),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: songResults.when(
                loading: () => results.isEmpty
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : _buildList(results, const [], isLoadingSongs: true),
                error: (_, __) => _buildList(results, const []),
                data: (songs) => (results.isEmpty && songs.isEmpty)
                    ? const Center(
                        child: Text(
                          'No matches found',
                          style: TextStyle(color: Colors.white38),
                        ),
                      )
                    : _buildList(results, songs),
              ),
            ),
          ],
        ),
      ),
    );
  }
}