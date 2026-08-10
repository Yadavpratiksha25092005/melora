import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class DummyDataSource {
  DummyDataSource._();

  static final Map<String, dynamic> _cache = {};

  static Future<dynamic> _load(String assetName) async {
    if (_cache.containsKey(assetName)) return _cache[assetName];
    final raw = await rootBundle.loadString('assets/dummy/$assetName');
    final decoded = jsonDecode(raw);
    _cache[assetName] = decoded;
    return decoded;
  }

  static Future<List<Map<String, dynamic>>> songs() async {
    final data = await _load('songs.json') as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> albums() async {
    final data = await _load('albums.json') as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> artists() async {
    final data = await _load('artists.json') as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> playlists() async {
    final data = await _load('playlists.json') as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> podcasts() async {
    final data = await _load('podcasts.json') as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  static Future<Map<String, dynamic>> user() async {
    final data = await _load('user.json');
    return data as Map<String, dynamic>;
  }

  static Future<void> simulateDelay({int ms = 400}) =>
      Future.delayed(Duration(milliseconds: ms));
}