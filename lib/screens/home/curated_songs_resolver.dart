import 'package:flutter/foundation.dart';

import '../../core/network/dummy_data_source.dart';
import '../../core/utils/local_poster_catalog.dart';
import '../../models/song.dart';
import 'curated_bollywood_songs.dart';
import 'curated_songs_data.dart';

/// Real data (playable via YouTube resolution + poster) for every curated
/// Home song OUTSIDE the "Bollywood Style" section — that section already
/// ships its own local posters (see `curated_bollywood_songs.dart`).
///
/// Keyed by normalized title -> resolved [Song]. Populated once at startup
/// by [resolveCuratedSongsFromAudius] (called from main.dart, same pattern
/// as the Bollywood resolver) so the gradient tiles (Hindi/Indie, Marathi,
/// Punjabi, Lofi/Chill) get a real song from our own catalog instead of a
/// generic SoundHelix placeholder track. Playback and poster are resolved
/// from YouTube at play time by PlayerNotifier (see player_provider.dart).
final Map<String, Song> resolvedCuratedSongs = {};

/// Home section title -> genre in assets/dummy/songs.json.
const Map<String, String> _sectionToGenre = {
  'Hindi / Indie': 'Hindi',
  'Marathi Style': 'Marathi',
  'Punjabi': 'Punjabi',
  'Lofi / Chill': 'Mood',
};

/// Picks a matching song from our own 500-song catalog (assets/dummy/songs.json)
/// for every curated Home song outside "Bollywood Style", and fills
/// [resolvedCuratedSongs]. No network call — pure local lookup, so this is
/// fast and doesn't depend on any third-party API.
Future<void> resolveCuratedSongsFromAudius() async {
  try {
    final allSongsJson = await DummyDataSource.songs();
    final byGenre = <String, List<Map<String, dynamic>>>{};
    for (final s in allSongsJson) {
      final genre = s['genre'] as String? ?? '';
      byGenre.putIfAbsent(genre, () => []).add(s);
    }

    for (final section in curatedHomeSections) {
      if (section.title == 'Bollywood Style') continue;
      final genre = _sectionToGenre[section.title];
      final pool = genre != null ? (byGenre[genre] ?? const []) : const <Map<String, dynamic>>[];
      if (pool.isEmpty) continue;

      for (var i = 0; i < section.songs.length; i++) {
        final curated = section.songs[i];
        final match = pool[i % pool.length];
        final resolved = Song.fromJson(match).copyWith(id: curated.id, genre: section.title);
        resolvedCuratedSongs[normalizeTitle(curated.title)] = resolved;
      }
    }
  } catch (e) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[CuratedSongs] Could not load local catalog: $e');
    }
    // Leave unresolved — tiles keep their gradient-box fallback and
    // placeholder track.
  }
}

/// Looks up a resolved real song by title (any curated section except
/// "Bollywood Style", which has its own resolver/lookup).
Song? resolvedCuratedSongForTitle(String title) {
  final normalized = normalizeTitle(title);
  if (normalized.isEmpty) return null;
  return resolvedCuratedSongs[normalized];
}

/// Builds a real, playable [Song] from a [CuratedSong] — reusing whichever
/// resolved (real audio + real poster) version is available, exactly the
/// same logic `_playSong` in home_screen.dart uses, so every screen that
/// plays a curated song (Home, Search, See All) plays the SAME song.
Song buildSongFromCurated(CuratedSong song) {
  final resolved =
      resolvedBollywoodSongForTitle(song.title) ?? resolvedCuratedSongForTitle(song.title);
  return resolved != null
      ? resolved.copyWith(id: song.id)
      : Song(
          id: song.id,
          artistId: 'melora',
          title: song.title,
          durationMs: 0,
          fileUrl: song.fileUrl,
          coverUrl: localPosterForTitle(song.title),
          genre: song.category,
        );
}

/// All 50 curated songs across every Home section, flattened — used to
/// power the Search tab.
List<CuratedSong> get allCuratedSongs => [
      for (final section in curatedHomeSections) ...section.songs,
    ];

/// Case-insensitive search across every curated song's title, artist and
/// genre/category. Empty query returns an empty list (search screen shows
/// its default browse UI instead).
List<CuratedSong> searchCuratedSongs(String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];
  return allCuratedSongs.where((song) {
    final resolved = buildSongFromCurated(song);
    return song.title.toLowerCase().contains(q) ||
        song.category.toLowerCase().contains(q) ||
        resolved.artistId.toLowerCase().contains(q) ||
        (resolved.genre?.toLowerCase().contains(q) ?? false);
  }).toList();
}