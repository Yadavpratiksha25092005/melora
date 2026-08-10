import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:Melora/core/theme/app_colors.dart';
import 'package:Melora/features/onboarding/widgets/common/artist_avatar.dart';
import 'package:Melora/features/onboarding/widgets/common/mini_player_bar.dart';
import 'package:Melora/models/song.dart';
import 'package:Melora/providers/custom_playlists_provider.dart';
import 'package:Melora/providers/followed_artists_provider.dart';
import 'package:Melora/providers/liked_songs_provider.dart';
import 'package:Melora/providers/player_provider.dart';
import 'package:Melora/providers/song_provider.dart';

/// ---------------------------------------------------------------------
/// LibraryDetailScreen
///
/// Opened when the user taps an entry on the Your Library tab (Liked
/// Songs, a playlist, or an artist). Shows a header with the entry's
/// art plus a mock track list (swap `_mockTracksFor` for a real
/// playlist/artist-tracks provider once you have the endpoint wired
/// up).
/// ---------------------------------------------------------------------
enum LibraryEntryKind { likedSongs, playlist, artist, downloads }

class _Track {
  final String title;
  final String subtitle;

  const _Track({required this.title, required this.subtitle});
}

/// Shared cover thumbnail for a song row — shows the real bundled
/// poster when the song has one (local asset, not a network URL),
/// otherwise falls back to the plain music-note icon.
Widget _songCoverThumb(Song song) {
  final cover = song.coverUrl;
  final hasLocalCover = cover != null && cover.isNotEmpty && !cover.startsWith('http');
  return Container(
    width: 40,
    height: 40,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(8),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: hasLocalCover
          ? Image.asset(
              cover,
              fit: BoxFit.cover,
              width: 40,
              height: 40,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.music_note_rounded, color: Colors.white38, size: 20),
            )
          : const Icon(Icons.music_note_rounded, color: Colors.white38, size: 20),
    ),
  );
}

/// Follow / Following pill shown on artist detail screens — reads and
/// writes the same followedArtistsProvider used by Home's "Following"
/// pill and FollowingScreen, so state stays in sync everywhere.
class _FollowButton extends ConsumerWidget {
  final String artistName;
  const _FollowButton({required this.artistName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFollowing = ref.watch(
      followedArtistsProvider.select((set) => set.contains(artistName)),
    );

    return GestureDetector(
      onTap: () {
        final notifier = ref.read(followedArtistsProvider.notifier);
        if (isFollowing) {
          notifier.unfollow(artistName);
        } else {
          notifier.follow(artistName);
        }
      },
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isFollowing ? Colors.white24 : Colors.white54,
          ),
          color: isFollowing ? Colors.white.withValues(alpha: 0.08) : Colors.transparent,
        ),
        child: Text(
          isFollowing ? 'Following' : 'Follow',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class LibraryDetailScreen extends ConsumerWidget {
  final String title;
  final String subtitle;
  final LibraryEntryKind kind;
  final String? imageUrl;
  /// Set for entries backed by a real user-created playlist — when
  /// present, songs come from customPlaylistsProvider instead of the
  /// mock _tracks list below.
  final String? playlistId;

  const LibraryDetailScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.kind,
    this.imageUrl,
    this.playlistId,
  });

  List<_Track> get _tracks {
    switch (kind) {
      case LibraryEntryKind.likedSongs:
        return const [
          _Track(title: 'Midnight Drive', subtitle: 'Kabir Anand'),
          _Track(title: 'Chill Vibes', subtitle: 'Melora'),
          _Track(title: 'Golden Hour', subtitle: 'Ananya Rao'),
          _Track(title: 'Neon Nights', subtitle: 'The Midnight Sound'),
          _Track(title: 'Late Bloom', subtitle: 'Sunset Duo'),
        ];
      case LibraryEntryKind.playlist:
        return const [
          _Track(title: 'Lo-Fi Sunrise', subtitle: 'Rhea Kapoor'),
          _Track(title: 'Study Beats', subtitle: 'Kabir Mehta'),
          _Track(title: 'Rainy Window', subtitle: 'Sunset Duo'),
          _Track(title: 'Slow Focus', subtitle: 'Melora'),
        ];
      case LibraryEntryKind.artist:
        // Real songs are fetched via songsByArtistProvider in build() —
        // this case is unused now but kept so the switch stays exhaustive.
        return const [];
      case LibraryEntryKind.downloads:
        return const [];
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
  Widget build(BuildContext context, WidgetRef ref) {
    final isArtist = kind == LibraryEntryKind.artist;
    final isCustomPlaylist = kind == LibraryEntryKind.playlist && playlistId != null;
    final likedSongs = ref.watch(likedSongsProvider.select(
      (songs) => songs.values.toList().reversed.toList(),
    ));
    final customPlaylistSongs = isCustomPlaylist
        ? ref.watch(customPlaylistsProvider.select((p) => p[playlistId]?.songs ?? const <Song>[]))
        : const <Song>[];
    final tracks =
        (kind == LibraryEntryKind.likedSongs || isCustomPlaylist) ? const <_Track>[] : _tracks;
    final artistSongsAsync = isArtist ? ref.watch(songsByArtistProvider(title)) : null;
    final artistSongs = artistSongsAsync?.value ?? const <Song>[];

    // The list this screen's big play button controls (Liked Songs list,
    // this user-created playlist's songs, or this artist's songs).
    final playableList = kind == LibraryEntryKind.likedSongs
        ? likedSongs
        : (isCustomPlaylist ? customPlaylistSongs : (isArtist ? artistSongs : const <Song>[]));

    final playerState = ref.watch(playerProvider);
    final currentSongId = playerState.currentSong?.id;
    // True when the song currently loaded in the player is part of *this*
    // screen's list — i.e. this screen is the thing playing right now, as
    // opposed to some unrelated song playing elsewhere in the app.
    final isThisListActive =
        currentSongId != null && playableList.any((s) => s.id == currentSongId);
    final isThisListPlaying = isThisListActive && playerState.isPlaying;

    void handlePlayButtonTap() {
      if (playableList.isEmpty) {
        _showSnack(context, 'Playing "$title"');
        return;
      }
      if (isThisListActive) {
        // Already this screen's queue — just toggle play/pause instead of
        // restarting from track 1 every time.
        ref.read(playerProvider.notifier).togglePlayPause();
        return;
      }
      ref.read(playerProvider.notifier).playQueue(playableList, 0);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const MiniPlayerBar(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            expandedHeight: 260,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(24, 80, 24, 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3A2C7A), Color(0xFF121016)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(isArtist ? 90 : 12),
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: kind == LibraryEntryKind.likedSongs
                          ? Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF6E4BF0), Color(0xFF00D9F5)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 56),
                            )
                          : isArtist
                              // Artists use the same local-photo-first lookup
                              // as everywhere else in the app (Library list,
                              // Home, onboarding) instead of the raw
                              // imageUrl, which is just a random stand-in
                              // placeholder — this is what was showing an
                              // unrelated photo instead of the real artist.
                              ? ArtistAvatar(name: title, fallbackImageUrl: imageUrl)
                              : imageUrl != null
                                  ? Image.network(
                                      imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Colors.white.withValues(alpha: 0.06),
                                        child: const Icon(Icons.music_note_rounded, color: Colors.white24, size: 40),
                                      ),
                                    )
                                  : Container(
                                      color: Colors.white.withValues(alpha: 0.06),
                                      child: const Icon(Icons.music_note_rounded, color: Colors.white24, size: 40),
                                    ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 13)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: handlePlayButtonTap,
                        child: Container(
                          width: 54,
                          height: 54,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                          child: Icon(
                            isThisListPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      if (isArtist) ...[
                        const SizedBox(width: 14),
                        _FollowButton(artistName: title),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (kind == LibraryEntryKind.likedSongs && likedSongs.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Text(
                  'Songs you like will show up here. Tap the + on the mini player to like a song.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
            )
          else if (kind == LibraryEntryKind.likedSongs)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final song = likedSongs[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: () => ref
                            .read(playerProvider.notifier)
                            .playQueue(likedSongs, index),
                        child: Row(
                          children: [
                            _songCoverThumb(song),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    song.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
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
                            IconButton(
                              icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF1ED760), size: 20),
                              onPressed: () =>
                                  ref.read(likedSongsProvider.notifier).remove(song.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: likedSongs.length,
                ),
              ),
            )
          else if (isCustomPlaylist && customPlaylistSongs.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Text(
                  'No songs in this playlist yet. Use "Add to playlist" on any song to add it here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
            )
          else if (isCustomPlaylist)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final song = customPlaylistSongs[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: () => ref
                            .read(playerProvider.notifier)
                            .playQueue(customPlaylistSongs, index),
                        child: Row(
                          children: [
                            _songCoverThumb(song),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    song.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
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
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: Colors.white38, size: 20),
                              onPressed: () => ref
                                  .read(customPlaylistsProvider.notifier)
                                  .removeSong(playlistId!, song.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: customPlaylistSongs.length,
                ),
              ),
            )
          else if (isArtist)
            artistSongsAsync!.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                ),
              ),
              error: (_, __) => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  child: Text(
                    'Couldn\'t load songs for this artist. Pull to refresh or try again later.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ),
              ),
              data: (songs) => songs.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                        child: Text(
                          'No songs found for this artist yet.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final song = songs[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: GestureDetector(
                                onTap: () => ref
                                    .read(playerProvider.notifier)
                                    .playQueue(songs, index),
                                child: Row(
                                  children: [
                                    _songCoverThumb(song),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            song.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            song.genre?.isNotEmpty == true ? song.genre! : 'Song',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(color: Colors.white38, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.more_vert, color: Colors.white38, size: 20),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: songs.length,
                        ),
                      ),
                    ),
            )
          else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final track = tracks[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () => _showSnack(context, 'Playing "${track.title}"'),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.music_note_rounded, color: Colors.white38, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  track.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  track.subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.more_vert, color: Colors.white38, size: 20),
                        ],
                      ),
                    ),
                  );
                },
                childCount: tracks.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}