import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Resolves a playable audio stream URL for a [Song] that doesn't have its
/// own `file_url`, by searching YouTube for a matching video and extracting
/// its best-quality audio-only stream.
///
/// NOTE: this relies on youtube_explode_dart's unofficial extraction of
/// YouTube's internal player APIs. It's convenient for local/testing
/// playback, but it is not an official YouTube API and can break if YouTube
/// changes its internals, and using it this way sits outside YouTube's
/// Terms of Service — keep that in mind before shipping this to production.
class YoutubeAudioService {
  YoutubeAudioService._internal();
  static final YoutubeAudioService instance = YoutubeAudioService._internal();

  final YoutubeExplode _yt = YoutubeExplode();

  /// videoId cache keyed by search query, so we don't re-search every time
  /// the same song is played. Stream URLs themselves are NOT cached here
  /// because they expire after a few hours — only the stable videoId is.
  final Map<String, String> _videoIdCache = {};

  /// Finds a YouTube video id for the given search query (e.g. "Kesariya
  /// Arijit Singh"). Returns null if nothing was found.
  Future<String?> searchVideoId(String query) async {
    if (_videoIdCache.containsKey(query)) return _videoIdCache[query];
    try {
      final results = await _yt.search.search(query);
      if (results.isEmpty) return null;
      final id = results.first.id.value;
      _videoIdCache[query] = id;
      return id;
    } catch (_) {
      return null;
    }
  }

  /// Extracts a direct, playable audio-only stream URL for [videoId].
  /// This URL is short-lived (expires after a few hours) so fetch it fresh
  /// right before playback rather than storing it.
  Future<String?> getAudioStreamUrl(String videoId) async {
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(
        videoId,
        ytClients: [YoutubeApiClient.androidVr],
      );
      if (manifest.audioOnly.isEmpty) return null;
      final audioStream = manifest.audioOnly.withHighestBitrate();
      return audioStream.url.toString();
    } catch (_) {
      return null;
    }
  }

  /// Convenience: given a search query, returns a ready-to-play stream URL
  /// in one call (search + manifest resolution).
  Future<String?> resolveStreamUrlForQuery(String query) async {
    final videoId = await searchVideoId(query);
    if (videoId == null) return null;
    return getAudioStreamUrl(videoId);
  }

  void dispose() => _yt.close();
}