import 'package:Melora/core/constants/app_constants.dart';
import 'package:Melora/core/network/api_client.dart';
import 'package:Melora/core/network/api_endpoints.dart';
import 'package:Melora/core/network/api_exceptions.dart';
import 'package:Melora/core/network/dummy_data_source.dart';
import 'package:Melora/models/album.dart';

class AlbumService {
  final ApiClient _client = ApiClient();

  Future<List<Album>> fetchAlbums({int limit = 20, int offset = 0}) async {
    if (AppConstants.useDummyData) {
      await DummyDataSource.simulateDelay();
      final all = await DummyDataSource.albums();
      final page = all.skip(offset).take(limit).toList();
      return page.map((e) => Album.fromJson(e)).toList();
    }
    return _client.request(
      () => _client.dio.get(
        ApiEndpoints.albums,
        queryParameters: {'limit': limit, 'offset': offset},
      ),
      (data) => (data as List<dynamic>).map((e) => Album.fromJson(e)).toList(),
    );
  }

  Future<Album> fetchAlbumById(String id) async {
    if (AppConstants.useDummyData) {
      await DummyDataSource.simulateDelay();
      final all = await DummyDataSource.albums();
      final match = all.where((e) => e['id'] == id);
      if (match.isEmpty) {
        throw ApiException(code: 'NOT_FOUND', message: 'Album $id not found');
      }
      return Album.fromJson(match.first);
    }
    return _client.request(
      () => _client.dio.get('${ApiEndpoints.albums}/$id'),
      (data) => Album.fromJson(data),
    );
  }

  Future<List<Album>> fetchAlbumsByArtist(String artistId) async {
    if (AppConstants.useDummyData) {
      await DummyDataSource.simulateDelay();
      final all = await DummyDataSource.albums();
      return all
          .where((e) => e['artist_id'] == artistId)
          .map((e) => Album.fromJson(e))
          .toList();
    }
    return _client.request(
      () => _client.dio.get(
        ApiEndpoints.albums,
        queryParameters: {'artist_id': artistId},
      ),
      (data) => (data as List<dynamic>).map((e) => Album.fromJson(e)).toList(),
    );
  }
}