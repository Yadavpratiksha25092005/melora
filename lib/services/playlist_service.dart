import 'package:Melora/core/constants/app_constants.dart';
import 'package:Melora/core/network/api_client.dart';
import 'package:Melora/core/network/api_endpoints.dart';
import 'package:Melora/core/network/api_exceptions.dart';
import 'package:Melora/core/network/dummy_data_source.dart';
import 'package:Melora/models/playlist.dart';

class PlaylistService {
  final ApiClient _client = ApiClient();

  Future<Map<String, dynamic>> _hydrate(Map<String, dynamic> raw) async {
    final allSongs = await DummyDataSource.songs();
    final songIds = (raw['songs'] as List<dynamic>).cast<String>();
    final songs = songIds
<<<<<<< HEAD
        .map((id) => allSongs.firstWhere((s) => s['id'] == id))
=======
        .map((id) => allSongs.where((s) => s['id'] == id).isNotEmpty
            ? allSongs.firstWhere((s) => s['id'] == id)
            : null)
        .whereType<Map<String, dynamic>>()
>>>>>>> 3cb5a6ec211f46c4bc31b1cbd4ba22d147c15624
        .toList();
    return {...raw, 'songs': songs};
  }

  Future<List<Playlist>> fetchPlaylists({int limit = 20, int offset = 0}) async {
    if (AppConstants.useDummyData) {
      await DummyDataSource.simulateDelay();
      final all = await DummyDataSource.playlists();
      final page = all.skip(offset).take(limit).toList();
      final hydrated = await Future.wait(page.map(_hydrate));
      return hydrated.map((e) => Playlist.fromJson(e)).toList();
    }
    return _client.request(
      () => _client.dio.get(
        ApiEndpoints.playlists,
        queryParameters: {'limit': limit, 'offset': offset},
      ),
      (data) =>
          (data as List<dynamic>).map((e) => Playlist.fromJson(e)).toList(),
    );
  }

  Future<Playlist> fetchPlaylistById(String id) async {
    if (AppConstants.useDummyData) {
      await DummyDataSource.simulateDelay();
      final all = await DummyDataSource.playlists();
      final match = all.where((e) => e['id'] == id);
      if (match.isEmpty) {
        throw ApiException(code: 'NOT_FOUND', message: 'Playlist $id not found');
      }
      final hydrated = await _hydrate(match.first);
      return Playlist.fromJson(hydrated);
    }
    return _client.request(
      () => _client.dio.get('${ApiEndpoints.playlists}/$id'),
      (data) => Playlist.fromJson(data),
    );
  }
}