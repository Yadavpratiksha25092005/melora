import '../models/song.dart';
import '../services/song_service.dart';

class SongRepository {
  final SongService _service;

  SongRepository({SongService? service}) : _service = service ?? SongService();

  Future<List<Song>> getSongs({int limit = 20, int offset = 0}) {
    return _service.fetchSongs(limit: limit, offset: offset);
  }

  Future<Song> getSongById(String id) {
    return _service.fetchSongById(id);
  }

  Future<List<Song>> searchSongs(String query, {int limit = 20}) {
    return _service.searchSongs(query, limit: limit);
  }

  Future<List<Song>> getSongsByGenre(String query, {int limit = 10}) {
    return _service.fetchSongsByGenre(query, limit: limit);
  }

  Future<List<Song>> getSongsByArtist(String artistName, {int limit = 20}) {
    return _service.fetchSongsByArtist(artistName, limit: limit);
  }

  Future<List<Song>> getTrendingSongs({int limit = 10}) {
    return _service.fetchTrendingSongs(limit: limit);
  }

  Future<String?> getPosterForQuery(String query) {
    return _service.fetchPosterForQuery(query);
  }

  Future<Song> createSong(Map<String, dynamic> payload) {
    return _service.createSong(payload);
  }

  Future<void> deleteSong(String id) {
    return _service.deleteSong(id);
  }
}