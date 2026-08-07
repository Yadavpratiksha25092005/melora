import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart' as audio_service;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../models/song.dart';
import '../services/melora_audio_handler.dart';
import '../services/youtube_audio_service.dart';
import 'audio_handler_provider.dart';

/// Cache of asset-path -> local temp-file path, so the same bundled poster
/// (e.g. "assets/images/tum_hi_ho.jpg") is only copied to disk once per
/// app run instead of on every play.
final Map<String, String> _assetArtCache = {};

/// The OS notification/lock-screen (a separate system process) can't read
/// Flutter's bundled assets directly — it needs a real file:// or http(s)
/// URI. This copies a local asset's bytes out to the app's temp directory
/// once, then returns a file:// URI pointing at it, so bundled Bollywood
/// posters show up in the notification exactly like network covers do.
Future<Uri?> _resolveLocalAssetArtUri(String assetPath) async {
  final cached = _assetArtCache[assetPath];
  if (cached != null && File(cached).existsSync()) {
    return Uri.file(cached);
  }
  try {
    final data = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final fileName = assetPath.split('/').last;
    final file = File('${tempDir.path}/notif_art_$fileName');
    await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
    _assetArtCache[assetPath] = file.path;
    return Uri.file(file.path);
  } catch (e) {
    // ignore: avoid_print
    print('[Player] Could not prepare local artwork for notification: $e');
    return null;
  }
}

class PlayerState {
  final Song? currentSong;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final List<Song> queue;
  final int currentIndex;
  final bool isShuffling;
  final Duration? sleepTimerRemaining;
  final String? errorMessage;

  const PlayerState({
    this.currentSong,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.queue = const [],
    this.currentIndex = -1,
    this.isShuffling = false,
    this.sleepTimerRemaining,
    this.errorMessage,
  });

  bool get hasNext => currentIndex >= 0 && currentIndex < queue.length - 1;
  bool get hasPrevious => currentIndex > 0;

  PlayerState copyWith({
    Song? currentSong,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    List<Song>? queue,
    int? currentIndex,
    bool? isShuffling,
    Duration? sleepTimerRemaining,
    bool clearSleepTimer = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PlayerState(
      currentSong: currentSong ?? this.currentSong,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      isShuffling: isShuffling ?? this.isShuffling,
      sleepTimerRemaining: clearSleepTimer
          ? null
          : (sleepTimerRemaining ?? this.sleepTimerRemaining),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// App-wide audio player. Kept as a single instance so the mini-player
/// and full player screen share the same playback state across the app.
class PlayerNotifier extends StateNotifier<PlayerState> {
  PlayerNotifier(this._audioHandler) : super(const PlayerState()) {
    _player.positionStream.listen((pos) {
      if (!_isMock) {
        state = state.copyWith(position: pos);
        _pushPlaybackState();
      }
    });
    _player.durationStream.listen((dur) {
      if (!_isMock) state = state.copyWith(duration: dur ?? Duration.zero);
    });
    _player.playingStream.listen((playing) {
      if (!_isMock) {
        state = state.copyWith(isPlaying: playing);
        _pushPlaybackState();
      }
    });
    // Auto-advance to the next song when the current one finishes.
    _player.processingStateStream.listen((processingState) {
      if (!_isMock && processingState == ProcessingState.completed) {
        if (state.hasNext) {
          skipNext();
        }
      }
    });

    // Route lock-screen / notification media-button presses back into
    // real playback logic, the way Spotify's notification does.
    _audioHandler.onPlay = togglePlayPause;
    _audioHandler.onPause = togglePlayPause;
    _audioHandler.onSkipToNext = skipNext;
    _audioHandler.onSkipToPrevious = skipPrevious;
    _audioHandler.onSeek = seek;
    _audioHandler.onStop = () async {
      await _player.stop();
    };

    // Mock auto-play disabled — real Audius-backed songs are wired in now
    // (see curated_bollywood_songs.dart), so the mini player should stay
    // hidden until the user actually taps a song, and then show exactly
    // that song.
    // _initMockSongForTesting();
  }

  final MeloraAudioHandler _audioHandler;
  final AudioPlayer _player = AudioPlayer();

  /// Pushes the current song's title/artist/artwork to the OS
  /// notification / lock screen, exactly like Spotify shows what's
  /// currently playing there.
  Future<void> _pushMediaItem(Song song) async {
    Uri? artUri;
    final cover = song.coverUrl;
    if (cover != null && cover.isNotEmpty) {
      if (cover.startsWith('http')) {
        artUri = Uri.tryParse(cover);
      } else if (cover.startsWith('assets/')) {
        // Bundled Bollywood-poster covers — copy to a temp file so the
        // OS-level notification/lock-screen (which can't read Flutter's
        // asset bundle directly) can display it, exactly like Spotify
        // shows local/downloaded artwork.
        artUri = await _resolveLocalAssetArtUri(cover);
      }
    }
    // Guard against a race where the user skipped to a different song
    // while the asset copy above was in flight — don't overwrite the
    // notification with stale artwork for a song that's no longer playing.
    if (state.currentSong?.id != song.id) return;
    _audioHandler.setMediaItem(
      audio_service.MediaItem(
        id: song.id,
        title: song.title,
        artist: song.artistName ?? 'Unknown artist',
        album: song.genre,
        duration: state.duration == Duration.zero ? null : state.duration,
        artUri: artUri,
      ),
    );
    _pushPlaybackState();
  }

  void _pushPlaybackState() {
    _audioHandler.setPlaybackState(
      playing: state.isPlaying,
      position: state.position,
      hasNext: state.hasNext,
      hasPrevious: state.hasPrevious,
    );
  }

  // --- TEMP MOCK MODE ---------------------------------------------------
  Timer? _mockTicker;
  bool _isMock = false;
  Timer? _sleepTimer;
  Timer? _sleepTimerTicker;

  void playMock(
    Song song, {
    Duration duration = const Duration(minutes: 3, seconds: 30),
  }) {
    _isMock = true;
    _mockTicker?.cancel();
    state = state.copyWith(
      currentSong: song,
      isPlaying: true,
      position: Duration.zero,
      duration: duration,
      queue: [song],
      currentIndex: 0,
    );
    _mockTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.isPlaying) return;
      final next = state.position + const Duration(seconds: 1);
      state = next >= state.duration
          ? state.copyWith(position: Duration.zero)
          : state.copyWith(position: next);
    });
  }

  /// Play a single song with no queue context (e.g. from search results).
  Future<void> playSong(Song song) => playQueue([song], 0);

  /// Play a song as part of a larger list (e.g. a Home row/grid), so
  /// next/previous can move through the rest of that list.
  Future<void> playQueue(List<Song> songs, int startIndex) async {
    if (songs.isEmpty) return;
    _isMock = false;
    _mockTicker?.cancel();
    final song = songs[startIndex];
    state = state.copyWith(
      currentSong: song,
      queue: songs,
      currentIndex: startIndex,
      clearError: true,
    );
    _pushMediaItem(song);
    await _playCurrent();
  }

  Future<void> _playCurrent() async {
    final song = state.currentSong;
    if (song == null) return;
    try {
      if (song.fileUrl.startsWith('asset:')) {
        final assetPath = song.fileUrl.replaceFirst('asset:', '');
        await _player.setAsset(assetPath);
      } else if (song.fileUrl.isEmpty) {
        // No direct file_url on this song — resolve a stream from YouTube
        // instead, using the video id if we already have one, or a search
        // query (title + artist) otherwise.
        final query = song.youtubeSearchQuery ?? '${song.title} ${song.artistName ?? ''}';
        final videoId = song.youtubeVideoId ?? await YoutubeAudioService.instance.searchVideoId(query);
        if (videoId == null) {
          state = state.copyWith(
            isPlaying: false,
            errorMessage: 'Couldn\'t find "${song.title}" to play.',
          );
          return;
        }

        // Use the YouTube thumbnail as the poster/cover art if this song
        // didn't already have a real one, and reflect it immediately in
        // state so the UI (mini player, now playing screen, queue) updates.
        final thumbnailUrl = 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
        final updatedSong = song.copyWith(
          youtubeVideoId: videoId,
          coverUrl: (song.coverUrl == null || song.coverUrl!.isEmpty)
              ? thumbnailUrl
              : song.coverUrl,
        );
        final updatedQueue = [...state.queue];
        if (state.currentIndex >= 0 && state.currentIndex < updatedQueue.length) {
          updatedQueue[state.currentIndex] = updatedSong;
        }
        state = state.copyWith(currentSong: updatedSong, queue: updatedQueue);
        _pushMediaItem(updatedSong);

        final streamUrl = await YoutubeAudioService.instance.getAudioStreamUrl(videoId);
        if (streamUrl == null) {
          state = state.copyWith(
            isPlaying: false,
            errorMessage: 'Couldn\'t find "${song.title}" to play.',
          );
          return;
        }
        await _player.setUrl(streamUrl);
      } else {
        await _player.setUrl(song.fileUrl);
      }
      await _player.play();
    } catch (e, st) {
      // ignore: avoid_print
      print('[Player] FAILED to play "${song.title}": $e');
      // ignore: avoid_print
      print(st);
      // Surface the failure to the UI instead of leaving the mini player
      // and Now Playing screen stuck silently at 0:00/0:00.
      state = state.copyWith(
        isPlaying: false,
        errorMessage: 'Couldn\'t play "${song.title}" — the audio source is unavailable.',
      );
    }
  }

  Future<void> skipNext() async {
    if (!state.hasNext) return;
    final nextIndex = state.isShuffling
        ? _randomIndexExcluding(state.currentIndex)
        : state.currentIndex + 1;
    state = state.copyWith(
      currentIndex: nextIndex,
      currentSong: state.queue[nextIndex],
      position: Duration.zero,
    );
    _pushMediaItem(state.queue[nextIndex]);
    await _playCurrent();
  }

  Future<void> skipPrevious() async {
    if (!state.hasPrevious) return;
    final prevIndex = state.currentIndex - 1;
    state = state.copyWith(
      currentIndex: prevIndex,
      currentSong: state.queue[prevIndex],
      position: Duration.zero,
    );
    _pushMediaItem(state.queue[prevIndex]);
    await _playCurrent();
  }

  int _randomIndexExcluding(int exclude) {
    if (state.queue.length <= 1) return exclude;
    final indices = List.generate(state.queue.length, (i) => i)
      ..remove(exclude);
    indices.shuffle();
    return indices.first;
  }

  void toggleShuffle() {
    state = state.copyWith(isShuffling: !state.isShuffling);
  }

  /// Starts (or cancels, if [duration] is null) a sleep timer that pauses
  /// playback once it elapses.
  void setSleepTimer(Duration? duration) {
    _sleepTimer?.cancel();
    _sleepTimerTicker?.cancel();
    if (duration == null) {
      state = state.copyWith(clearSleepTimer: true);
      return;
    }
    state = state.copyWith(sleepTimerRemaining: duration);
    _sleepTimer = Timer(duration, () {
      togglePlayPause();
      state = state.copyWith(clearSleepTimer: true);
    });
    _sleepTimerTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = state.sleepTimerRemaining;
      if (remaining == null || remaining.inSeconds <= 0) {
        _sleepTimerTicker?.cancel();
        return;
      }
      state = state.copyWith(
        sleepTimerRemaining: remaining - const Duration(seconds: 1),
      );
    });
  }

  void dismissError() {
    if (state.errorMessage != null) {
      state = state.copyWith(clearError: true);
    }
  }

  Future<void> togglePlayPause() async {
    if (_isMock) {
      state = state.copyWith(isPlaying: !state.isPlaying);
      return;
    }
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seek(Duration position) {
    if (_isMock) {
      state = state.copyWith(position: position);
      return Future.value();
    }
    return _player.seek(position);
  }

  @override
  void dispose() {
    _mockTicker?.cancel();
    _sleepTimer?.cancel();
    _sleepTimerTicker?.cancel();
    _player.dispose();
    super.dispose();
  }
}

final playerProvider =
    StateNotifierProvider<PlayerNotifier, PlayerState>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return PlayerNotifier(handler);
});