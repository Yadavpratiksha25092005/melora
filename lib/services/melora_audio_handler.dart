import 'package:audio_service/audio_service.dart';

/// ---------------------------------------------------------------------
/// MeloraAudioHandler
///
/// Bridges playback to the OS-level media notification (and lock screen)
/// the way Spotify does — play/pause, next/previous, artwork, title and
/// artist. It doesn't own an AudioPlayer itself; PlayerNotifier (the
/// single source of truth for playback in this app) still drives the
/// actual `just_audio` player and simply pushes updates into this
/// handler via [setMediaItem] / [setPlaybackState] whenever its state
/// changes. Button presses on the notification/lock screen come back
/// in through the overridden methods below, which are wired (in
/// PlayerNotifier) to call back into the real playback logic.
/// ---------------------------------------------------------------------
class MeloraAudioHandler extends BaseAudioHandler with SeekHandler {
  /// Set by PlayerNotifier right after construction so notification /
  /// lock-screen button presses route back into real playback logic.
  Future<void> Function()? onPlay;
  Future<void> Function()? onPause;
  Future<void> Function()? onSkipToNext;
  Future<void> Function()? onSkipToPrevious;
  Future<void> Function(Duration)? onSeek;
  Future<void> Function()? onStop;

  void setMediaItem(MediaItem item) {
    mediaItem.add(item);
  }

  void setPlaybackState({
    required bool playing,
    required Duration position,
    required bool hasNext,
    required bool hasPrevious,
    AudioProcessingState processingState = AudioProcessingState.ready,
  }) {
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          if (hasPrevious) MediaControl.skipToPrevious,
          playing ? MediaControl.pause : MediaControl.play,
          if (hasNext) MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: processingState,
        playing: playing,
        updatePosition: position,
      ),
    );
  }

  @override
  Future<void> play() async => onPlay?.call();

  @override
  Future<void> pause() async => onPause?.call();

  @override
  Future<void> skipToNext() async => onSkipToNext?.call();

  @override
  Future<void> skipToPrevious() async => onSkipToPrevious?.call();

  @override
  Future<void> seek(Duration position) async => onSeek?.call(position);

  @override
  Future<void> stop() async {
    await onStop?.call();
    await super.stop();
  }
}