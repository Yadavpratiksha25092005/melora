import 'package:dio/dio.dart';

/// A single time-synced lyric line, e.g. parsed from an LRC line like
/// "[00:12.34] some line".
class LyricLine {
  final Duration time;
  final String text;
  const LyricLine(this.time, this.text);
}

/// Result of a lyrics lookup: always carries plain text (for the preview
/// snippet / fallback), and optionally a list of time-synced lines when the
/// provider had LRC-style synced lyrics available (used to drive the
/// Spotify-style auto-scrolling lyrics view).
class LyricsResult {
  final String plain;
  final List<LyricLine>? synced;
  const LyricsResult({required this.plain, this.synced});

  bool get hasSynced => synced != null && synced!.isNotEmpty;
}

/// Fetches song lyrics from lrclib.net — a free, keyless, open lyrics
/// database. Used to populate the "Lyrics" card on the Now Playing screen
/// for songs that don't already ship with lyrics baked into their data.
class LyricsService {
  LyricsService._();
  static final LyricsService instance = LyricsService._();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://lrclib.net/api',
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
    ),
  );

  /// In-memory cache so we don't re-fetch lyrics every time the user
  /// re-opens the player for a song they've already looked up.
  final Map<String, LyricsResult?> _cache = {};

  /// Strips things like "(v2)", "(From \"Movie\")", "- Remastered",
  /// "[Official Video]" etc. off a title, since these are common in
  /// catalog/YouTube-style titles but break exact-match lookups against
  /// lyrics databases.
  String _cleanTitle(String title) {
    var cleaned = title
        .replaceAll(RegExp(r'\(v\d+\)', caseSensitive: false), '')
        .replaceAll(RegExp(r'\[[^\]]*\]'), '')
        .replaceAll(RegExp(r'\((?:from|feat\.?|ft\.?)[^)]*\)', caseSensitive: false), '')
        .replaceAll(RegExp(r'-\s*(remastered|remix|acoustic|live|reprise).*$', caseSensitive: false), '')
        .trim();
    return cleaned.isEmpty ? title.trim() : cleaned;
  }

  /// Returns plain-text lyrics for [title] by [artist], or null if no
  /// lyrics could be found (instrumental track, not in the database, etc).
  ///
  /// Kept for backwards compatibility — prefer [fetchLyricsResult] for new
  /// call sites since it also exposes time-synced lines when available.
  Future<String?> fetchLyrics({
    required String title,
    required String artist,
    int? durationSeconds,
    String? album,
  }) async {
    final result = await fetchLyricsResult(
      title: title,
      artist: artist,
      durationSeconds: durationSeconds,
      album: album,
    );
    return result?.plain;
  }

  /// Returns both plain-text lyrics and, when the provider has them,
  /// time-synced lyric lines for [title] by [artist]. Returns null if no
  /// lyrics could be found at all (instrumental track, not in the
  /// database, etc).
  Future<LyricsResult?> fetchLyricsResult({
    required String title,
    required String artist,
    int? durationSeconds,
    String? album,
  }) async {
    final cleanTitle = _cleanTitle(title);
    final cacheKey = '${artist.toLowerCase()}|${cleanTitle.toLowerCase()}';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey];
    }

    try {
      // 1) Try the precise "get" endpoint first — it matches on exact
      // track/artist/duration and returns synced + plain lyrics.
      final getResponse = await _dio.get('/get', queryParameters: {
        'track_name': cleanTitle,
        'artist_name': artist,
        if (album != null && album.isNotEmpty) 'album_name': album,
        if (durationSeconds != null) 'duration': durationSeconds,
      });
      final result = _extractLyrics(getResponse.data);
      if (result != null) {
        _cache[cacheKey] = result;
        return result;
      }
    } catch (_) {
      // Fall through to the fuzzy search endpoint below.
    }

    try {
      // 2) Fall back to fuzzy search when there's no exact match (e.g.
      // slightly different title/artist punctuation, or duration mismatch).
      final searchResponse = await _dio.get('/search', queryParameters: {
        'track_name': cleanTitle,
        'artist_name': artist,
      });
      final results = searchResponse.data;
      if (results is List && results.isNotEmpty) {
        final result = _extractLyrics(results.first);
        if (result != null) {
          _cache[cacheKey] = result;
          return result;
        }
      }
    } catch (_) {
      // No connectivity, no match, or the API is unavailable.
    }

    try {
      // 3) Search by title alone (no artist filter) — helps when the
      // artist name in our catalog differs slightly from the lyrics DB's
      // records (common for Bollywood/regional tracks with singer vs.
      // credited-artist naming differences).
      final broadSearch = await _dio.get('/search', queryParameters: {
        'q': '$cleanTitle $artist',
      });
      final results = broadSearch.data;
      if (results is List && results.isNotEmpty) {
        final result = _extractLyrics(results.first);
        if (result != null) {
          _cache[cacheKey] = result;
          return result;
        }
      }
    } catch (_) {
      // Still nothing.
    }

    try {
      // 4) Last resort: lyrics.ovh, a different free provider with its
      // own independent catalog — sometimes has tracks lrclib doesn't.
      // It never has synced timing, only plain text.
      final ovh = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
      ));
      final ovhResponse = await ovh.get(
        'https://api.lyrics.ovh/v1/${Uri.encodeComponent(artist)}/${Uri.encodeComponent(cleanTitle)}',
      );
      final ovhLyrics = (ovhResponse.data is Map<String, dynamic>)
          ? (ovhResponse.data['lyrics'] as String?)?.trim()
          : null;
      if (ovhLyrics != null && ovhLyrics.isNotEmpty) {
        final result = LyricsResult(plain: ovhLyrics);
        _cache[cacheKey] = result;
        return result;
      }
    } catch (_) {
      // Genuinely not found anywhere.
    }

    _cache[cacheKey] = null;
    return null;
  }

  LyricsResult? _extractLyrics(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    if (data['instrumental'] == true) {
      return const LyricsResult(plain: 'This track is instrumental.');
    }

    final synced = data['syncedLyrics'] as String?;
    final syncedLines = (synced != null && synced.trim().isNotEmpty)
        ? _parseSyncedLyrics(synced)
        : null;

    final plain = (data['plainLyrics'] as String?)?.trim();
    if (plain != null && plain.isNotEmpty) {
      return LyricsResult(
        plain: plain,
        synced: (syncedLines != null && syncedLines.isNotEmpty) ? syncedLines : null,
      );
    }

    // No plain lyrics field — fall back to deriving plain text from the
    // synced lines themselves (still show *something* in the preview).
    if (syncedLines != null && syncedLines.isNotEmpty) {
      final derivedPlain = syncedLines
          .map((l) => l.text)
          .where((t) => t.trim().isNotEmpty)
          .join('\n');
      if (derivedPlain.trim().isNotEmpty) {
        return LyricsResult(plain: derivedPlain.trim(), synced: syncedLines);
      }
    }

    return null;
  }

  /// Parses LRC-style synced lyrics ("[mm:ss.xx] line text" per line) into
  /// a list of [LyricLine]s sorted by timestamp. Lines with empty text
  /// (common LRC padding, e.g. instrumental gaps) are kept so the
  /// auto-scroll view can still advance through musical breaks.
  List<LyricLine> _parseSyncedLyrics(String synced) {
    final timestampPattern = RegExp(r'^\[(\d{2}):(\d{2})(?:\.(\d{1,3}))?\]\s*(.*)$');
    final lines = <LyricLine>[];
    for (final rawLine in synced.split('\n')) {
      final match = timestampPattern.firstMatch(rawLine);
      if (match == null) continue;
      final minutes = int.parse(match.group(1)!);
      final seconds = int.parse(match.group(2)!);
      final fraction = match.group(3);
      final milliseconds =
          fraction == null ? 0 : int.parse(fraction.padRight(3, '0').substring(0, 3));
      final text = (match.group(4) ?? '').trim();
      lines.add(LyricLine(
        Duration(minutes: minutes, seconds: seconds, milliseconds: milliseconds),
        text,
      ));
    }
    lines.sort((a, b) => a.time.compareTo(b.time));
    return lines;
  }
}