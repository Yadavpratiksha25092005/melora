import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/melora_audio_handler.dart';

/// Provided a real value via ProviderScope.overrides in main.dart, once
/// AudioService.init() has finished setting up the OS-level media
/// session. PlayerNotifier reads this to push now-playing info to the
/// lock screen / notification.
final audioHandlerProvider = Provider<MeloraAudioHandler>((ref) {
  throw UnimplementedError('audioHandlerProvider must be overridden in main.dart');
});