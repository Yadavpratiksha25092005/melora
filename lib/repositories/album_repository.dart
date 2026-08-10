import 'package:Melora/models/album.dart';
import 'package:Melora/services/album_service.dart';

class AlbumRepository {
  final AlbumService _service;
  AlbumRepository({AlbumService? service}) : _service = service ?? AlbumService();

  Future<List<Album>> getAlbums({int limit = 20, int offset = 0}) =>
      _service.fetchAlbums(limit: limit, offset: offset);
  Future<Album> getAlbumById(String id) => _service.fetchAlbumById(id);
  Future<List<Album>> getAlbumsByArtist(String artistId) =>
      _service.fetchAlbumsByArtist(artistId);
}