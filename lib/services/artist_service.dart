import 'package:Melora/core/constants/app_constants.dart';
import 'package:Melora/core/network/api_client.dart';
import 'package:Melora/core/network/api_endpoints.dart';
import 'package:Melora/core/network/api_exceptions.dart';
import 'package:Melora/core/network/dummy_data_source.dart';
import 'package:Melora/models/artist.dart';

class ArtistService {
  final ApiClient _client = ApiClient();

  Future<List<Artist>> fetchArtists({int limit = 20, int offset = 0}) async {
    if (AppConstants.useDummyData) {
      await DummyDataSource.simulateDelay();
      final all = await DummyDataSource.artists();
      final page = all.skip(offset).take(limit).toList();
      return page.map((e) => Artist.fromJson(e)).toList();
    }
    return _client.request(
      () => _client.dio.get(
        ApiEndpoints.artists,
        queryParameters: {'limit': limit, 'offset': offset},
      ),
      (data) => (data as List<dynamic>).map((e) => Artist.fromJson(e)).toList(),
    );
  }

  Future<Artist> fetchArtistById(String id) async {
    if (AppConstants.useDummyData) {
      await DummyDataSource.simulateDelay();
      final all = await DummyDataSource.artists();
      final match = all.where((e) => e['id'] == id);
      if (match.isEmpty) {
        throw ApiException(code: 'NOT_FOUND', message: 'Artist $id not found');
      }
      return Artist.fromJson(match.first);
    }
    return _client.request(
      () => _client.dio.get('${ApiEndpoints.artists}/$id'),
      (data) => Artist.fromJson(data),
    );
  }
}