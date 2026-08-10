import 'package:Melora/core/constants/app_constants.dart';
import 'package:Melora/core/network/api_client.dart';
import 'package:Melora/core/network/api_endpoints.dart';
import 'package:Melora/core/network/api_exceptions.dart';
import 'package:Melora/core/network/audius_client.dart';
import 'package:Melora/core/network/dummy_data_source.dart';
import 'package:Melora/models/song.dart';

class SongService {
  final ApiClient _client = ApiClient();
  final AudiusClient _audius = AudiusClient();

  Future<List<Song>> fetchSongs({int limit = 20, int offset = 0}) async {
    if (AppConstants.useAudiusForSongs) {
      final response = await _audius.dio.get('/tracks/trending', queryParameters: {
        'limit': limit,
      });
      final results = (response.data['data'] as List<dynamic>? ?? []);
      final page = results.skip(offset).take(limit).toList();
      return page.map((e) => Song.fromAudiusJson(e)).toList();
    }
    if (AppConstants.useDummyData) {
      await DummyDataSource.simulateDelay();
      final all = await DummyDataSource.songs();
      final page = all.skip(offset).take(limit).toList();
      return page.map((e) => Song.fromJson(e)).toList();
    }
    return _client.request(
      () => _client.dio.get(
        ApiEndpoints.songs,
        queryParameters: {'limit': limit, 'offset': offset},
      ),
      (data) => (data as List<dynamic>).map((e) => Song.fromJson(e)).toList(),
    );
  }

  /// Search songs by title/artist. Hits Audius's real search first when
  /// live mode is on; only falls back to a client-side filter over dummy
  /// data if Audius is disabled.
  Future<List<Song>> searchSongs(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) return [];

    if (AppConstants.useAudiusForSongs) {
      final response = await _audius.dio.get('/tracks/search', queryParameters: {
        'query': query,
        'limit': limit,
      });
      final results = (response.data['data'] as List<dynamic>? ?? []);
      return results.map((e) => Song.fromAudiusJson(e)).toList();
    }
    if (AppConstants.useDummyData) {
      await DummyDataSource.simulateDelay();
      final all = await DummyDataSource.songs();
      final q = query.toLowerCase();
      final matches = all
          .where((e) => (e['title'] as String? ?? '').toLowerCase().contains(q))
          .take(limit)
          .toList();
      return matches.map((e) => Song.fromJson(e)).toList();
    }
    return _client.request(
      () => _client.dio.get(
        ApiEndpoints.search,
        queryParameters: {'q': query, 'limit': limit},
      ),
      (data) => (data as List<dynamic>).map((e) => Song.fromJson(e)).toList(),
    );
  }

  /// Songs filtered by genre/tag — used for curated home-screen rows
  /// (e.g. "Kokani song", "Trending Hindi Songs"). Uses real search, not
  /// `/tracks/trending?genre=`, because Audius's genre filter only
  /// accepts its own fixed taxonomy (Electronic, Pop, Hip-Hop/Rap, ...)
  /// — free-text queries like these would silently return nothing.
  Future<List<Song>> fetchSongsByGenre(String query, {int limit = 10}) async {
    if (AppConstants.useAudiusForSongs) {
      final response = await _audius.dio.get('/tracks/search', queryParameters: {
        'query': query,
        'limit': limit,
      });
      final results = (response.data['data'] as List<dynamic>? ?? []);
      return results.map((e) => Song.fromAudiusJson(e)).toList();
    }
    if (AppConstants.useDummyData) {
      await DummyDataSource.simulateDelay();
      final all = await DummyDataSource.songs();
      return all.take(limit).map((e) => Song.fromJson(e)).toList();
    }
    return _client.request(
      () => _client.dio.get(
        ApiEndpoints.songs,
        queryParameters: {'genre': query, 'limit': limit},
      ),
      (data) => (data as List<dynamic>).map((e) => Song.fromJson(e)).toList(),
    );
  }

  /// Songs by a specific artist (matched by name, catching collab
  /// credits like "Arijit Singh, Antara Mitra" too) — used by the artist
  /// detail screen in Your Library.
  Future<List<Song>> fetchSongsByArtist(String artistName, {int limit = 20}) async {
    if (AppConstants.useAudiusForSongs) {
      final response = await _audius.dio.get('/tracks/search', queryParameters: {
        'query': artistName,
        'limit': limit,
      });
      final results = (response.data['data'] as List<dynamic>? ?? []);
      return results.map((e) => Song.fromAudiusJson(e)).toList();
    }
    if (AppConstants.useDummyData) {
      await DummyDataSource.simulateDelay();
      final all = await DummyDataSource.songs();
      final name = artistName.toLowerCase();
      final matches = all
          .where((e) => (e['artist_name'] as String? ?? '').toLowerCase().contains(name))
          .take(limit)
          .toList();
      return matches.map((e) => Song.fromJson(e)).toList();
    }
    // Backend's GET /songs doesn't support an `artist` query filter yet
    // (it only handles limit/offset), so filtering by artist has to
    // happen client-side: fetch a large page, then keep only songs
    // whose artistName matches (handles collab credits too, e.g.
    // "Arijit Singh, Antara Mitra").
    final all = await _client.request(
      () => _client.dio.get(
        ApiEndpoints.songs,
        queryParameters: {'limit': 500},
      ),
      (data) => (data as List<dynamic>).map((e) => Song.fromJson(e)).toList(),
    );
    final name = artistName.toLowerCase();
    return all
        .where((s) => (s.artistName ?? '').toLowerCase().contains(name))
        .take(limit)
        .toList();
  }

  /// Currently-trending songs — used for "Quick Picks" / radio-style tiles.
  Future<List<Song>> fetchTrendingSongs({int limit = 10}) async {
    if (AppConstants.useAudiusForSongs) {
      final response = await _audius.dio.get('/tracks/trending', queryParameters: {
        'limit': limit,
      });
      final results = (response.data['data'] as List<dynamic>? ?? []);
      return results.map((e) => Song.fromAudiusJson(e)).toList();
    }
    if (AppConstants.useDummyData) {
      await DummyDataSource.simulateDelay();
      final all = await DummyDataSource.songs();
      return all.take(limit).map((e) => Song.fromJson(e)).toList();
    }
    return _client.request(
      () => _client.dio.get(
        ApiEndpoints.songs,
        queryParameters: {'order': 'trending', 'limit': limit},
      ),
      (data) => (data as List<dynamic>).map((e) => Song.fromJson(e)).toList(),
    );
  }

  /// A single representative cover image for a text query — used to give
  /// mock/curated tiles (e.g. "Baawra Radio") a real-looking poster
  /// without needing a full Song object. Returns null if nothing found.
  Future<String?> fetchPosterForQuery(String query) async {
    if (AppConstants.useAudiusForSongs) {
      final response = await _audius.dio.get('/tracks/search', queryParameters: {
        'query': query,
        'limit': 1,
      });
      final results = (response.data['data'] as List<dynamic>? ?? []);
      if (results.isEmpty) return null;
      final artwork = results.first['artwork'] as Map<String, dynamic>?;
      return artwork?['480x480'] as String? ??
          artwork?['150x150'] as String? ??
          artwork?['1000x1000'] as String?;
    }
    if (AppConstants.useDummyData) {
      return null; // _PosterImage already has its own gradient/URL fallback
    }
    return null;
  }

  Future<Song> fetchSongById(String id) async {
    if (AppConstants.useAudiusForSongs) {
      final response = await _audius.dio.get('/tracks/$id');
      final data = response.data['data'];
      if (data == null) {
        throw ApiException(code: 'NOT_FOUND', message: 'Song $id not found');
      }
      return Song.fromAudiusJson(data);
    }
    if (AppConstants.useDummyData) {
      await DummyDataSource.simulateDelay();
      final all = await DummyDataSource.songs();
      final match = all.where((e) => e['id'] == id);
      if (match.isEmpty) {
        throw ApiException(code: 'NOT_FOUND', message: 'Song $id not found');
      }
      return Song.fromJson(match.first);
    }
    return _client.request(
      () => _client.dio.get('${ApiEndpoints.songs}/$id'),
      (data) => Song.fromJson(data),
    );
  }

  Future<Song> createSong(Map<String, dynamic> payload) {
    return _client.request(
      () => _client.dio.post(ApiEndpoints.songs, data: payload),
      (data) => Song.fromJson(data),
    );
  }

  Future<void> deleteSong(String id) {
    return _client.request(
      () => _client.dio.delete('${ApiEndpoints.songs}/$id'),
      (_) {},
    );
  }
}