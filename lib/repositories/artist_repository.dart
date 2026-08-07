import 'package:Melora/models/artist.dart';
import 'package:Melora/services/artist_service.dart';

class ArtistRepository {
  final ArtistService _service;
  ArtistRepository({ArtistService? service}) : _service = service ?? ArtistService();

  Future<List<Artist>> getArtists({int limit = 20, int offset = 0}) =>
      _service.fetchArtists(limit: limit, offset: offset);
  Future<Artist> getArtistById(String id) => _service.fetchArtistById(id);
}