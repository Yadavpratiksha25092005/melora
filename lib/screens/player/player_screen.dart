import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';

import 'package:Melora/core/theme/app_colors.dart';
import 'package:Melora/models/song.dart';
import 'package:Melora/providers/download_provider.dart';
import 'package:Melora/providers/liked_songs_provider.dart';
import 'package:Melora/providers/player_provider.dart';
import 'package:Melora/services/lyrics_service.dart';

/// Full-screen "Now Playing" player — opened by tapping the mini-player.
class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  bool _isLocalAsset(Song song) => song.fileUrl.startsWith('asset:');

  /// Whether the song's COVER IMAGE is a local asset — independent of
  /// whether the audio itself is local or streamed. This matters for
  /// curated songs that stream real audio from Audius but keep their
  /// own bundled local poster (see curated_bollywood_songs.dart), so the
  /// poster must always be rendered with Image.asset, never as a network
  /// image (which would just fail to load).
  bool _isLocalCover(Song song) {
    final cover = song.coverUrl;
    return cover != null && cover.isNotEmpty && !cover.startsWith('http');
  }

  Widget _buildCover(Song song, {BoxFit fit = BoxFit.cover}) {
    final cover = song.coverUrl;
    if (cover == null || cover.isEmpty) {
      return Container(
        color: AppColors.surface,
        child: const Icon(Icons.music_note, color: Colors.white24, size: 48),
      );
    }
    if (_isLocalCover(song)) {
      return Image.asset(
        cover,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          color: AppColors.surface,
          child: const Icon(Icons.music_note, color: Colors.white24, size: 48),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: cover,
      fit: fit,
      placeholder: (context, url) => Container(color: AppColors.surface),
      errorWidget: (context, url, error) => Container(
        color: AppColors.surface,
        child: const Icon(Icons.music_note, color: Colors.white24, size: 48),
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1C1C24),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openSleepTimerSheet(BuildContext context, WidgetRef ref) {
    const options = [5, 10, 15, 30, 45, 60];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF15151C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Sleep timer',
                    style: TextStyle(
                        color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            ...options.map((minutes) => ListTile(
                  leading: const Icon(Icons.timer_outlined, color: Colors.white70),
                  title: Text('$minutes minutes',
                      style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    ref
                        .read(playerProvider.notifier)
                        .setSleepTimer(Duration(minutes: minutes));
                    Navigator.pop(context);
                    _showSnack(context, 'Sleep timer set for $minutes minutes');
                  },
                )),
            ListTile(
              leading: const Icon(Icons.cancel_outlined, color: Colors.white38),
              title: const Text('Turn off', style: TextStyle(color: Colors.white54)),
              onTap: () {
                ref.read(playerProvider.notifier).setSleepTimer(null);
                Navigator.pop(context);
                _showSnack(context, 'Sleep timer turned off');
              },
            ),
          ],
        ),
      ),
    );
  }

  static const MethodChannel _bluetoothChannel = MethodChannel('melora/bluetooth');

  Future<void> _enableBluetooth(BuildContext context) async {
    try {
      final result = await _bluetoothChannel.invokeMethod<String>('enable');
      if (result == 'already_on') {
        _showSnack(context, 'Bluetooth is already on');
      } else {
        _showSnack(context, 'Bluetooth turned on');
      }
    } on PlatformException catch (e) {
      if (e.code == 'CANCELLED') {
        _showSnack(context, 'Bluetooth was not turned on');
      } else if (e.code == 'PERMISSION_DENIED') {
        _showSnack(context, 'Bluetooth permission was denied');
      } else if (e.code == 'NO_BLUETOOTH') {
        _showSnack(context, 'This device doesn\'t support Bluetooth');
      } else {
        _showSnack(context, 'Couldn\'t turn on Bluetooth');
      }
    } on MissingPluginException {
      _showSnack(context, 'Bluetooth toggle is only available on Android');
    }
  }

  void _openQueueSheet(BuildContext context, PlayerState playerState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF15151C),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          if (playerState.queue.isEmpty) {
            return const Center(
              child: Text('Queue is empty', style: TextStyle(color: Colors.white54)),
            );
          }
          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: playerState.queue.length,
            itemBuilder: (context, index) {
              final song = playerState.queue[index];
              final isCurrent = index == playerState.currentIndex;
              return ListTile(
                leading: Icon(
                  isCurrent ? Icons.equalizer_rounded : Icons.music_note,
                  color: isCurrent ? const Color(0xFF1ED760) : Colors.white38,
                ),
                title: Text(
                  song.title,
                  style: TextStyle(
                    color: isCurrent ? const Color(0xFF1ED760) : Colors.white,
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _handleDownload(BuildContext context, WidgetRef ref, Song song) async {
    if (_isLocalAsset(song)) {
      _showSnack(context, 'Already available offline');
      return;
    }
    final current = ref.read(downloadProvider)[song.id];
    if (current?.status == DownloadStatus.done) {
      // Tapping again after it's downloaded cancels/removes it — button
      // reverts to its original (not-downloaded) color.
      await ref.read(downloadProvider.notifier).removeDownload(song.id);
      _showSnack(context, 'Removed "${song.title}" from downloads');
      return;
    }
    _showSnack(context, 'Downloading "${song.title}"…');
    await ref.read(downloadProvider.notifier).downloadSong(song);
    final info = ref.read(downloadProvider)[song.id];
    if (info?.status == DownloadStatus.done) {
      _showSnack(context, 'Downloaded "${song.title}"');
    } else if (info?.status == DownloadStatus.failed) {
      _showSnack(context, 'Download failed — try again');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<PlayerState>(playerProvider, (previous, next) {
      final error = next.errorMessage;
      if (error != null && error != previous?.errorMessage) {
        _showSnack(context, error);
        ref.read(playerProvider.notifier).dismissError();
      }
    });
    final playerState = ref.watch(playerProvider);
    final song = playerState.currentSong;

    if (song == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text('Nothing playing', style: TextStyle(color: Colors.white54)),
        ),
      );
    }

    final durationMs = playerState.duration.inMilliseconds;
    final positionMs = playerState.position.inMilliseconds.clamp(
      0,
      durationMs == 0 ? 1 : durationMs,
    );

    final downloadInfo = ref.watch(downloadProvider)[song.id] ??
        (_isLocalAsset(song)
            ? const DownloadInfo(status: DownloadStatus.done)
            : const DownloadInfo());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: Colors.white, size: 30),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            'PLAYING FROM PLAYLIST',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            playerState.queue.length > 1 ? 'Queue' : 'Liked Songs',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
<<<<<<< HEAD
                    IconButton(
                      icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                      onPressed: () => _openQueueSheet(context, playerState),
                    ),
=======
                   const SizedBox(width: 48),
>>>>>>> 3cb5a6ec211f46c4bc31b1cbd4ba22d147c15624
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _buildCover(song),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 8),
                child: Row(
                  children: [
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
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            song.genre?.isNotEmpty == true ? song.genre! : song.artistId,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white60, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    // --- Download button ---
                    IconButton(
                      onPressed: downloadInfo.status == DownloadStatus.downloading
                          ? null
                          : () => _handleDownload(context, ref, song),
                      icon: downloadInfo.status == DownloadStatus.downloading
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value: downloadInfo.progress > 0
                                    ? downloadInfo.progress
                                    : null,
                                color: Colors.white70,
                              ),
                            )
                          : Icon(
                              downloadInfo.status == DownloadStatus.done
                                  ? Icons.download_done_rounded
                                  : Icons.download_rounded,
                              color: downloadInfo.status == DownloadStatus.done
                                  ? const Color(0xFF1ED760)
                                  : Colors.white70,
                              size: 24,
                            ),
                    ),
                    Builder(builder: (context) {
                      final isLiked = ref.watch(
                        likedSongsProvider.select((songs) => songs.containsKey(song.id)),
                      );
                      return IconButton(
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
                        icon: Icon(
                          isLiked ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                          color: isLiked ? const Color(0xFF1ED760) : Colors.white70,
                          size: 26,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white24,
                        thumbColor: Colors.white,
                      ),
                      child: Slider(
                        value: positionMs.toDouble(),
                        min: 0,
                        max: durationMs == 0 ? 1 : durationMs.toDouble(),
                        onChanged: (value) {
                          ref
                              .read(playerProvider.notifier)
                              .seek(Duration(milliseconds: value.toInt()));
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(playerState.position),
                              style: const TextStyle(color: Colors.white54, fontSize: 12)),
                          Text(_formatDuration(playerState.duration),
                              style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.shuffle_rounded,
                        color: playerState.isShuffling
                            ? const Color(0xFF1ED760)
                            : Colors.white54,
                        size: 22,
                      ),
                      onPressed: () {
                        ref.read(playerProvider.notifier).toggleShuffle();
                        _showSnack(
                          context,
                          playerState.isShuffling ? 'Shuffle off' : 'Shuffle on',
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.skip_previous_rounded,
                        color: playerState.hasPrevious ? Colors.white : Colors.white24,
                        size: 34,
                      ),
                      onPressed: playerState.hasPrevious
                          ? () => ref.read(playerProvider.notifier).skipPrevious()
                          : () => _showSnack(context, 'No previous song in queue'),
                    ),
                    GestureDetector(
                      onTap: () => ref.read(playerProvider.notifier).togglePlayPause(),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Icon(
                          playerState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.black,
                          size: 34,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.skip_next_rounded,
                        color: playerState.hasNext ? Colors.white : Colors.white24,
                        size: 34,
                      ),
                      onPressed: playerState.hasNext
                          ? () => ref.read(playerProvider.notifier).skipNext()
                          : () => _showSnack(context, 'No next song in queue'),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.timer_outlined,
                        color: playerState.sleepTimerRemaining != null
                            ? const Color(0xFF1ED760)
                            : Colors.white54,
                        size: 22,
                      ),
                      onPressed: () => _openSleepTimerSheet(context, ref),
                    ),
                  ],
                ),
              ),
            ),
            if (playerState.sleepTimerRemaining != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Center(
                    child: Text(
                      'Sleep timer: ${_formatDuration(playerState.sleepTimerRemaining!)} left',
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => _enableBluetooth(context),
                      child: const Icon(Icons.bluetooth_rounded, color: Colors.white54, size: 20),
                    ),
                    GestureDetector(
                      onTap: () {
                        Share.share('Listening to "${song.title}" on Melora 🎵');
                      },
                      child: const Icon(Icons.share_rounded, color: Colors.white54, size: 20),
                    ),
                    GestureDetector(
                      onTap: () => _openQueueSheet(context, playerState),
                      child: const Icon(Icons.queue_music_rounded, color: Colors.white54, size: 20),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _LyricsCard(song: song),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('About the artist',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: _buildCover(song),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      song.genre?.isNotEmpty == true ? song.genre! : song.artistId,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Artist details aren\'t available from the current data source yet.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lyrics card shown on the Now Playing screen. Shows the song's lyrics
/// (expandable via "Show lyrics") when available, and always shows the
/// artist name directly underneath the card.
class _LyricsCard extends StatefulWidget {
  const _LyricsCard({required this.song});

  final Song song;

  @override
  State<_LyricsCard> createState() => _LyricsCardState();
}

class _LyricsCardState extends State<_LyricsCard> {
  bool _expanded = false;

  // True once the user has manually tapped "Show lyrics" / "Hide lyrics"
  // at least once. Used so we only auto-expand for time-synced lyrics
  // (Spotify-style) before the user has taken control of the toggle
  // themselves — after that we respect whatever they chose.
  bool _userToggled = false;

  // Fetch state for lyrics pulled from the lyrics service (used when the
  // song object itself doesn't already carry lyrics text).
  bool _loading = false;
  LyricsResult? _fetchedResult;
  bool _fetchFailed = false;
  String? _fetchedForSongId;

  @override
  void initState() {
    super.initState();
    _maybeFetchLyrics();
  }

  @override
  void didUpdateWidget(covariant _LyricsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Collapse back to preview and re-fetch whenever the song changes.
    if (oldWidget.song.id != widget.song.id) {
      _expanded = false;
      _userToggled = false;
      _maybeFetchLyrics();
    }
  }

  void _maybeFetchLyrics() {
    final song = widget.song;
    final bakedInLyrics = song.lyrics?.trim();
    if (bakedInLyrics != null && bakedInLyrics.isNotEmpty) {
      // Song already ships with lyrics — nothing to fetch.
      return;
    }
    if (song.title.trim().isEmpty) return;

    setState(() {
      _loading = true;
      _fetchFailed = false;
      _fetchedResult = null;
      _fetchedForSongId = song.id;
    });

    final artist = (song.artistName?.trim().isNotEmpty == true)
        ? song.artistName!.trim()
        : song.artistId;

    LyricsService.instance
        .fetchLyricsResult(
      title: song.title,
      artist: artist,
      durationSeconds: song.durationMs > 0 ? song.durationMs ~/ 1000 : null,
    )
        .then((result) {
      if (!mounted || _fetchedForSongId != song.id) return;
      setState(() {
        _loading = false;
        _fetchedResult = result;
        _fetchFailed = result == null;
        // Spotify-style: if we got time-synced lyrics and the user hasn't
        // touched the toggle themselves yet, open the auto-scrolling view
        // automatically instead of waiting for a "Show lyrics" tap.
        if (!_userToggled && (result?.hasSynced ?? false)) {
          _expanded = true;
        }
      });
    }).catchError((_) {
      if (!mounted || _fetchedForSongId != song.id) return;
      setState(() {
        _loading = false;
        _fetchFailed = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.song;
    final bakedInLyrics = song.lyrics?.trim();
    final hasBakedInLyrics = bakedInLyrics != null && bakedInLyrics.isNotEmpty;
    final lyrics = hasBakedInLyrics ? bakedInLyrics : _fetchedResult?.plain.trim();
    final hasLyrics = lyrics != null && lyrics.isNotEmpty;
    // Baked-in lyrics never carry timing data — only lyrics we fetch from
    // lrclib do. Auto-scroll only kicks in when we actually have it.
    final syncedLines = hasBakedInLyrics ? null : _fetchedResult?.synced;
    final hasSynced = syncedLines != null && syncedLines.isNotEmpty;
    final artistName = song.artistId.isNotEmpty
        ? song.artistId
        : (song.genre?.isNotEmpty == true ? song.genre! : 'Unknown artist');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2A1F26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_expanded ? 'Lyrics' : 'Lyrics preview',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              if (_loading)
                Row(
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Fetching lyrics…',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14, height: 1.5),
                    ),
                  ],
                )
              else if (!hasLyrics)
                Text(
                  'Lyrics aren\'t available for this track yet.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14, height: 1.5),
                )
              else
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  firstChild: Text(
                    lyrics,
                    maxLines: 3,
                    overflow: TextOverflow.fade,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14, height: 1.5),
                  ),
                  secondChild: hasSynced
                      ? _SyncedLyricsView(lines: syncedLines)
                      : ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 320),
                          child: SingleChildScrollView(
                            child: Text(
                              lyrics,
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 14,
                                  height: 1.6),
                            ),
                          ),
                        ),
                ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton(
                  onPressed: hasLyrics
                      ? () => setState(() {
                            _userToggled = true;
                            _expanded = !_expanded;
                          })
                      : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: hasLyrics ? Colors.white : Colors.white38,
                    side: BorderSide(color: hasLyrics ? Colors.white54 : Colors.white24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(_expanded ? 'Hide lyrics' : 'Show lyrics'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              const Icon(Icons.person_rounded, color: Colors.white38, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  artistName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Spotify-style auto-scrolling, time-synced lyrics view. Highlights the
/// line matching the current playback position and smoothly scrolls it
/// into the center of the view as the song plays — no manual scrolling
/// needed (though the user can still scroll manually; it'll pick back up
/// syncing on the next line change).
class _SyncedLyricsView extends ConsumerStatefulWidget {
  const _SyncedLyricsView({required this.lines});

  final List<LyricLine> lines;

  @override
  ConsumerState<_SyncedLyricsView> createState() => _SyncedLyricsViewState();
}

class _SyncedLyricsViewState extends ConsumerState<_SyncedLyricsView> {
  final ScrollController _scrollController = ScrollController();
  int _activeIndex = -1;

  // Fixed row height for every lyric line. Using a fixed extent (instead of
  // letting each line size itself) is what lets us jump/animate straight to
  // ANY line's scroll offset with simple arithmetic — no need for that
  // line's widget to already be built and on-screen. This is the key fix:
  // ListView.builder only builds items near the current viewport, so the
  // previous approach (Scrollable.ensureVisible on a per-line GlobalKey)
  // silently did nothing whenever the target line hadn't been built yet —
  // e.g. opening the lyrics view mid-song, which is exactly when you need
  // the jump most.
  static const double _rowHeight = 64;
  static const double _viewportHeight = 340;

  @override
  void didUpdateWidget(covariant _SyncedLyricsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lines != widget.lines) {
      _activeIndex = -1;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int _activeIndexFor(Duration position) {
    final lines = widget.lines;
    int index = -1;
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].time <= position) {
        index = i;
      } else {
        break;
      }
    }
    return index;
  }

  void _scrollToLine(int index, {bool animate = true}) {
    if (!_scrollController.hasClients) return;
    if (index < 0 || index >= widget.lines.length) return;

    // Padding above/below the list is _viewportHeight / 2 (see padding
    // below), so this offset lands the target line's vertical center right
    // in the middle of the visible area — matching Spotify's centered
    // "current line" feel.
    const paddingTop = _viewportHeight / 2;
    final rawTarget = paddingTop + (index * _rowHeight) + (_rowHeight / 2) - (_viewportHeight / 2);
    final target = rawTarget.clamp(
      _scrollController.position.minScrollExtent,
      _scrollController.position.maxScrollExtent,
    );

    if (animate) {
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scrollController.jumpTo(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final position = ref.watch(playerProvider.select((s) => s.position));
    final activeIndex = _activeIndexFor(position);

    if (activeIndex != _activeIndex) {
      // First-ever placement (e.g. lyrics opened mid-song) should snap
      // straight there instead of visibly animating from the top.
      final isFirstPlacement = _activeIndex == -1;
      _activeIndex = activeIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scrollToLine(activeIndex, animate: !isFirstPlacement);
      });
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: _viewportHeight),
      child: ListView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        // Fixed extent — required so scroll offsets can be computed for
        // lines that aren't built/visible yet (see _scrollToLine above).
        itemExtent: _rowHeight,
        // Half a viewport of empty space above/below so the first and
        // last lines can still be centered, matching Spotify's fullscreen
        // feel.
        padding: const EdgeInsets.symmetric(vertical: _viewportHeight / 2),
        itemCount: widget.lines.length,
        itemBuilder: (context, index) {
          final line = widget.lines[index];
          final isActive = index == activeIndex;
          final isPast = index < activeIndex;
          return Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              style: TextStyle(
                color: isActive
                    ? Colors.white
                    : Colors.white.withValues(alpha: isPast ? 0.35 : 0.45),
                fontSize: isActive ? 19 : 15,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                height: 1.3,
              ),
              child: Text(
                line.text.isEmpty ? '♪' : line.text,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        },
      ),
    );
  }
}