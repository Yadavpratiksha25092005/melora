import 'package:Melora/models/playlist.dart';
import 'package:Melora/services/playlist_service.dart';

class PlaylistRepository {
  final PlaylistService _service;
  PlaylistRepository({PlaylistService? service})
      : _service = service ?? PlaylistService();

  Future<List<Playlist>> getPlaylists({int limit = 20, int offset = 0}) =>
      _service.fetchPlaylists(limit: limit, offset: offset);
  Future<Playlist> getPlaylistById(String id) => _service.fetchPlaylistById(id);
}