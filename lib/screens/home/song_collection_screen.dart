import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:Melora/core/theme/app_colors.dart';
import 'package:Melora/features/onboarding/widgets/common/mini_player_bar.dart';
import 'package:Melora/models/song.dart';
import 'package:Melora/providers/custom_playlists_provider.dart';
import 'package:Melora/providers/download_provider.dart';
import 'package:Melora/providers/liked_songs_provider.dart';
import 'package:Melora/providers/player_provider.dart';
import 'package:Melora/screens/library/library_detail_screen.dart';

import 'home_screen.dart' show genreGradient;

/// ---------------------------------------------------------------------
/// SongCollectionScreen
///
/// Opened when the user taps a song tile on the Home "Music" grid.
/// Mirrors a typical streaming-app mix/playlist screen: big header art +
/// title + a big Play button up top, then the rest of the tapped grid's
/// songs listed below it — tapping any row plays starting from there,
/// and the big Play button starts from the song that was originally
/// tapped.
/// ---------------------------------------------------------------------
class SongCollectionScreen extends ConsumerWidget {
  final List<Song> songs;
  final int initialIndex;

  const SongCollectionScreen({
    super.key,
    required this.songs,
    required this.initialIndex,
  });

  Song get _headerSong => songs[initialIndex];

  bool _hasLocalCover(Song song) {
    final cover = song.coverUrl;
    return cover != null && cover.isNotEmpty && !cover.startsWith('http');
  }

  bool _isLocalAssetSong(Song song) => song.fileUrl.startsWith('asset:');

  /// Downloads every song in this collection (the "album"). Used by the
  /// header download button — mirrors the per-song download button on the
  /// player screen, just applied to the whole list at once.
  Future<void> _handleDownloadAlbum(BuildContext context, WidgetRef ref) async {
    final downloadable = songs.where((s) => !_isLocalAssetSong(s)).toList();
    if (downloadable.isEmpty) {
      _showSnack(context, 'Already available offline');
      return;
    }

    final map = ref.read(downloadProvider);
    final allDone = downloadable.every((s) => map[s.id]?.status == DownloadStatus.done);

    if (allDone) {
      // Tapping again after everything's downloaded cancels/removes it —
      // button reverts to its original color.
      for (final song in downloadable) {
        await ref.read(downloadProvider.notifier).removeDownload(song.id);
      }
      _showSnack(context, 'Removed downloads');
      return;
    }

    _showSnack(context, 'Downloading ${downloadable.length} song${downloadable.length == 1 ? '' : 's'}…');
    for (final song in downloadable) {
      final status = ref.read(downloadProvider)[song.id]?.status;
      if (status == DownloadStatus.done || status == DownloadStatus.downloading) continue;
      await ref.read(downloadProvider.notifier).downloadSong(song);
    }
    final finalMap = ref.read(downloadProvider);
    final succeeded = downloadable.where((s) => finalMap[s.id]?.status == DownloadStatus.done).length;
    if (succeeded == downloadable.length) {
      _showSnack(context, 'Downloaded');
    } else {
      _showSnack(context, 'Downloaded $succeeded of ${downloadable.length} — some failed');
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

  void _showMoreOptions(BuildContext context, WidgetRef ref, Song song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.playlist_add_rounded, color: Colors.white70),
              title: const Text('Add to playlist', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(sheetContext);
                _showAddToPlaylistSheet(context, ref, song);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_rounded, color: Colors.white70),
              title: const Text('Share', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(sheetContext);
                final artist = song.artistName ?? song.artistId;
                final videoId = song.youtubeVideoId;
                final link = (videoId != null && videoId.isNotEmpty)
                    ? 'https://youtube.com/watch?v=$videoId'
                    : (song.fileUrl.startsWith('http') ? song.fileUrl : null);
                final message = link != null
                    ? '${song.title} by $artist — listen on Melora!\n$link'
                    : '${song.title} by $artist — listen on Melora!';
                Share.share(
                  message,
                  subject: song.title,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_rounded, color: Colors.white70),
              title: const Text('Go to artist', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(sheetContext);
                final artist = song.artistName ?? song.artistId;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LibraryDetailScreen(
                      title: artist,
                      subtitle: 'Artist',
                      kind: LibraryEntryKind.artist,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom sheet listing the user's playlists (with a checkmark for ones
  /// [song] is already in) plus a "New playlist" action at the top. Tapping
  /// a playlist toggles [song] in/out of it via [customPlaylistsProvider] —
  /// real, working add/remove, not just a snackbar.
  void _showAddToPlaylistSheet(BuildContext context, WidgetRef ref, Song song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (sheetContext) => Consumer(
        builder: (context, sheetRef, _) {
          final playlists = sheetRef.watch(customPlaylistsProvider).values.toList();
          return SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
                    child: Row(
                      children: [
                        Text(
                          'Add to playlist',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                    ),
                    title: const Text('New playlist', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      final name = await _promptPlaylistName(context);
                      if (name == null) return;
                      // Outer `ref` (the one passed into this method) is tied to the
                      // screen, not the now-disposed bottom sheet — safe to use here.
                      ref.read(customPlaylistsProvider.notifier).createPlaylist(name, withSong: song);
                      if (context.mounted) {
                        _showSnack(context, 'Added "${song.title}" to "$name"');
                      }
                    },
                  ),
                  const Divider(color: Colors.white12, height: 1),
                  Flexible(
                    child: playlists.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              'No playlists yet — create one above.',
                              style: TextStyle(color: Colors.white38, fontSize: 13),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: playlists.length,
                            itemBuilder: (context, index) {
                              final playlist = playlists[index];
                              final alreadyIn = playlist.songs.any((s) => s.id == song.id);
                              return ListTile(
                                leading: Container(
                                  width: 36,
                                  height: 36,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.music_note_rounded, color: Colors.white54, size: 18),
                                ),
                                title: Text(playlist.name, style: const TextStyle(color: Colors.white)),
                                subtitle: Text(
                                  '${playlist.songs.length} song${playlist.songs.length == 1 ? '' : 's'}',
                                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                                ),
                                trailing: alreadyIn
                                    ? const Icon(Icons.check_circle_rounded, color: Color(0xFF1ED760))
                                    : null,
                                onTap: () {
                                  final notifier = sheetRef.read(customPlaylistsProvider.notifier);
                                  if (alreadyIn) {
                                    notifier.removeSong(playlist.id, song.id);
                                    _showSnack(context, 'Removed from "${playlist.name}"');
                                  } else {
                                    notifier.addSong(playlist.id, song);
                                    _showSnack(context, 'Added "${song.title}" to "${playlist.name}"');
                                  }
                                  Navigator.pop(sheetContext);
                                },
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<String?> _promptPlaylistName(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C24),
        title: const Text('Playlist name', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'My Playlist',
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          ),
          onSubmitted: (value) => Navigator.pop(dialogContext, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Create', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final headerSong = _headerSong;
    final colors = genreGradient[headerSong.genre] ?? const [Color(0xFF3B2E7D), Color(0xFF14103A)];

    final playerState = ref.watch(playerProvider);
    final currentSongId = playerState.currentSong?.id;
    final isThisListActive = currentSongId != null && songs.any((s) => s.id == currentSongId);
    final isThisListPlaying = isThisListActive && playerState.isPlaying;

    void handlePlayButtonTap() {
      if (isThisListActive) {
        ref.read(playerProvider.notifier).togglePlayPause();
        return;
      }
      ref.read(playerProvider.notifier).playQueue(songs, initialIndex);
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
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(24, 76, 24, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.first, AppColors.background],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 180,
                      height: 180,
                      child: _hasLocalCover(headerSong)
                          ? Image.asset(
                              headerSong.coverUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _coverFallback(colors),
                            )
                          : _coverFallback(colors),
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
                    headerSong.title,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    headerSong.artistName ?? headerSong.genre ?? 'Melora',
                    style: const TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${songs.length} song${songs.length == 1 ? '' : 's'}',
                    style: const TextStyle(color: Colors.white24, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Consumer(builder: (context, ref, _) {
                    final isLiked = ref.watch(
                      likedSongsProvider.select((songs) => songs.containsKey(headerSong.id)),
                    );
                    final isShuffling = ref.watch(playerProvider.select((s) => s.isShuffling));
                    return Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isLiked ? AppColors.primary : Colors.white70,
                          ),
                          onPressed: () {
                            ref.read(likedSongsProvider.notifier).toggle(headerSong);
                            _showSnack(
                              context,
                              isLiked ? 'Removed from Liked Songs' : 'Added to Liked Songs',
                            );
                          },
                        ),
                        Builder(builder: (context) {
                          final downloadable = songs.where((s) => !_isLocalAssetSong(s)).toList();
                          final downloadMap = ref.watch(downloadProvider);
                          final anyDownloading = downloadable
                              .any((s) => downloadMap[s.id]?.status == DownloadStatus.downloading);
                          final allDone = downloadable.isNotEmpty &&
                              downloadable.every((s) => downloadMap[s.id]?.status == DownloadStatus.done);
                          return IconButton(
                            icon: anyDownloading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white70,
                                    ),
                                  )
                                : Icon(
                                    allDone ? Icons.download_done_rounded : Icons.download_outlined,
                                    color: allDone ? const Color(0xFF1ED760) : Colors.white70,
                                  ),
                            onPressed: anyDownloading ? null : () => _handleDownloadAlbum(context, ref),
                          );
                        }),
                        IconButton(
                          icon: const Icon(Icons.more_vert_rounded, color: Colors.white70),
                          onPressed: () => _showMoreOptions(context, ref, headerSong),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            Icons.shuffle_rounded,
                            color: isShuffling ? AppColors.primary : Colors.white70,
                          ),
                          onPressed: () {
                            ref.read(playerProvider.notifier).toggleShuffle();
                            _showSnack(
                              context,
                              isShuffling ? 'Shuffle off' : 'Shuffle on',
                            );
                          },
                        ),
                        const SizedBox(width: 6),
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
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final song = songs[index];
                  final isCurrent = song.id == currentSongId;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () => ref.read(playerProvider.notifier).playQueue(songs, index),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 44,
                              height: 44,
                              child: _hasLocalCover(song)
                                  ? Image.asset(
                                      song.coverUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _rowCoverFallback(song),
                                    )
                                  : _rowCoverFallback(song),
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
                                  style: TextStyle(
                                    color: isCurrent ? AppColors.primary : Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  song.artistName ?? song.genre ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white38, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          if (isCurrent)
                            Icon(
                              playerState.isPlaying ? Icons.volume_up_rounded : Icons.pause_rounded,
                              color: AppColors.primary,
                              size: 18,
                            ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: songs.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _coverFallback(List<Color> colors) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.music_note_rounded, color: Colors.white70, size: 56),
    );
  }

  Widget _rowCoverFallback(Song song) {
    final colors = genreGradient[song.genre] ?? const [Color(0xFF3B2E7D), Color(0xFF14103A)];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.music_note_rounded, color: Colors.white38, size: 18),
    );
  }
}