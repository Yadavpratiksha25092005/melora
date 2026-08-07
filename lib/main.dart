import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import 'app.dart';
import 'providers/audio_handler_provider.dart';
import 'screens/home/curated_bollywood_songs.dart';
import 'screens/home/curated_songs_resolver.dart';
import 'services/melora_audio_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Android 13+ blocks ALL notifications — including the media/lock-screen
  // player — unless the app has been granted POST_NOTIFICATIONS at
  // runtime. Just declaring it in the manifest isn't enough; without this
  // request the notification silently never appears.
  try {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  } catch (e) {
    // ignore: avoid_print
    print('[main] Notification permission request failed: $e');
  }

  // Sets up the Spotify-style lock-screen / notification media player
  // (play, pause, next, previous, artwork) — must be initialized once,
  // before the app starts, and shared app-wide via Riverpod.
  //
  // Wrapped in try/catch: if the native/OS side of AudioService ever
  // fails to init (e.g. a platform quirk), we still want the app to
  // launch normally instead of hanging on a blank screen forever — the
  // app just won't have lock-screen controls in that case.
  MeloraAudioHandler audioHandler;
  try {
    audioHandler = await AudioService.init(
      builder: () => MeloraAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.melora.audio.playback',
        androidNotificationChannelName: 'Melora playback',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
        androidNotificationIcon: 'mipmap/ic_launcher',
      ),
    );
  } catch (e, st) {
    // ignore: avoid_print
    print('[main] AudioService.init failed, continuing without lock-screen controls: $e');
    // ignore: avoid_print
    print(st);
    audioHandler = MeloraAudioHandler();
  }

  // Resolve real, playable Audius audio + real cover art for EVERY
  // curated Home song BEFORE the app UI shows — home_screen.dart reads
  // these as plain lists/maps (not providers), so they must already be
  // resolved by the time Home first builds. Runs all searches in
  // parallel (across both resolvers) to keep this fast.
  //
  // Guarded the same way: if Audius is unreachable or slow, don't let
  // the app hang on a blank screen indefinitely — time out and let the
  // UI show with whatever curated data resolved so far / fallbacks.
  try {
    await Future.wait([
      resolveCuratedBollywoodAudioFromAudius(),
      resolveCuratedSongsFromAudius(),
    ]).timeout(const Duration(seconds: 12));
  } catch (e, st) {
    // ignore: avoid_print
    print('[main] Curated song resolution failed or timed out: $e');
    // ignore: avoid_print
    print(st);
  }

  runApp(
    ProviderScope(
      overrides: [
        audioHandlerProvider.overrideWithValue(audioHandler),
      ],
      child: const App(),
    ),
  );
}