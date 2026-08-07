import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/song.dart';
import '../services/youtube_audio_service.dart';

enum DownloadStatus { none, downloading, done, failed }

class DownloadInfo {
  final DownloadStatus status;
  final double progress; // 0.0 - 1.0
  final String? localPath;
  final Song? song;
  final DateTime? downloadedAt;

  const DownloadInfo({
    this.status = DownloadStatus.none,
    this.progress = 0,
    this.localPath,
    this.song,
    this.downloadedAt,
  });
}

const _prefsKey = 'melora_downloads_v1';

/// Tracks download state per song id. Locally-bundled songs (fileUrl
/// starting with `asset:`) are already "downloaded" by definition.
///
/// Completed downloads are persisted to SharedPreferences (song metadata +
/// local file path) so the Downloads list survives app restarts, as long
/// as the underlying file still exists on disk.
class DownloadNotifier extends StateNotifier<Map<String, DownloadInfo>> {
  DownloadNotifier() : super({}) {
    _restore();
  }

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 20),
    // No overall receiveTimeout here — it's set per-chunk below instead,
    // since a global receiveTimeout on a large file over a slow mobile
    // connection was causing spurious "Download failed" results.
  ));

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return;
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final restored = <String, DownloadInfo>{};
      for (final entry in decoded.entries) {
        final map = entry.value as Map<String, dynamic>;
        final localPath = map['local_path'] as String?;
        // Only keep it if the file is still actually on disk (or it's a
        // local asset with no path) — otherwise the entry is stale (e.g.
        // app storage was cleared) and shouldn't show as "downloaded".
        if (localPath != null && !await File(localPath).exists()) {
          continue;
        }
        restored[entry.key] = DownloadInfo(
          status: DownloadStatus.done,
          localPath: localPath,
          song: Song.fromJson(map['song'] as Map<String, dynamic>),
          downloadedAt: map['downloaded_at'] != null
              ? DateTime.tryParse(map['downloaded_at'] as String)
              : null,
        );
      }
      if (restored.isNotEmpty) {
        state = {...state, ...restored};
      }
    } catch (e) {
      // ignore: avoid_print
      print('[Download] Failed to restore saved downloads: $e');
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final done = Map.fromEntries(
        state.entries.where((e) => e.value.status == DownloadStatus.done && e.value.song != null),
      );
      final encoded = jsonEncode(done.map((id, info) => MapEntry(id, {
            'local_path': info.localPath,
            'song': info.song!.toJson(),
            'downloaded_at': info.downloadedAt?.toIso8601String(),
          })));
      await prefs.setString(_prefsKey, encoded);
    } catch (e) {
      // ignore: avoid_print
      print('[Download] Failed to persist downloads: $e');
    }
  }

  Future<void> downloadSong(Song song) async {
    if (song.fileUrl.startsWith('asset:')) {
      state = {
        ...state,
        song.id: DownloadInfo(
          status: DownloadStatus.done,
          song: song,
          downloadedAt: DateTime.now(),
        ),
      };
      await _persist();
      return;
    }

    final current = state[song.id];
    if (current?.status == DownloadStatus.downloading ||
        current?.status == DownloadStatus.done) {
      return;
    }

    state = {
      ...state,
      song.id: DownloadInfo(status: DownloadStatus.downloading, progress: 0, song: song),
    };

    try {
      final dir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${dir.path}/downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      final savePath = '${downloadsDir.path}/${song.id}.mp3';
      final tmpPath = '$savePath.part';

      // Some songs (dummy/curated catalog entries) don't ship with their
      // own direct file_url — playback resolves a stream on the fly via
      // YouTube search instead. Downloading needs a real direct URL too,
      // so resolve the same way here rather than trying to hit an empty
      // string (which was the actual cause of "Download failed").
      var downloadUrl = song.fileUrl;
      if (downloadUrl.trim().isEmpty) {
        final query = song.youtubeSearchQuery ??
            '${song.title} ${song.artistName ?? ''}'.trim();
        final resolved = await YoutubeAudioService.instance.resolveStreamUrlForQuery(query);
        if (resolved == null) {
          throw Exception('Could not find a playable source for "${song.title}"');
        }
        downloadUrl = resolved;
      }

      // Audius stream URLs typically 302-redirect to the actual CDN file,
      // so redirects must be followed explicitly. Some Audius nodes don't
      // send a Content-Length header (chunked transfer), so `total` can be
      // -1 — that's expected and just means we skip the progress update,
      // not a failure. Downloading to a .part file first and renaming on
      // success avoids leaving a corrupt/partial .mp3 behind after a
      // failed attempt.
      Future<void> attemptDownload() => _dio.download(
            downloadUrl,
            tmpPath,
            options: Options(
              followRedirects: true,
              maxRedirects: 5,
              validateStatus: (status) => status != null && status < 400,
              receiveTimeout: const Duration(seconds: 90),
              sendTimeout: const Duration(seconds: 20),
              headers: const {'User-Agent': 'Melora/1.0'},
            ),
            onReceiveProgress: (received, total) {
              if (total <= 0) return;
              state = {
                ...state,
                song.id: DownloadInfo(
                  status: DownloadStatus.downloading,
                  progress: received / total,
                  song: song,
                ),
              };
            },
          );

      Object? lastError;
      var attempted = false;
      for (var i = 0; i < 3; i++) {
        try {
          await attemptDownload();
          lastError = null;
          attempted = true;
          break;
        } catch (e) {
          lastError = e;
          attempted = true;
          // ignore: avoid_print
          print('[Download] Attempt ${i + 1} failed for "${song.title}": $e');
          if (i < 2) {
            await Future.delayed(Duration(seconds: 1 + i));
          }
        }
      }

      if (!attempted || lastError != null) {
        throw lastError ?? Exception('Unknown download error');
      }

      final tmpFile = File(tmpPath);
      if (!await tmpFile.exists()) {
        throw Exception('Downloaded file missing after completion');
      }
      await tmpFile.rename(savePath);

      state = {
        ...state,
        song.id: DownloadInfo(
          status: DownloadStatus.done,
          localPath: savePath,
          song: song,
          downloadedAt: DateTime.now(),
        ),
      };
      await _persist();
    } catch (e) {
      // ignore: avoid_print
      print('[Download] Failed to download "${song.title}" from ${song.fileUrl}: $e');
      state = {
        ...state,
        song.id: DownloadInfo(status: DownloadStatus.failed, song: song),
      };
    }
  }

  Future<void> removeDownload(String songId) async {
    if (!state.containsKey(songId)) return;
    final info = state[songId];
    final path = info?.localPath;
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {
          // ignore
        }
      }
    }
    final updated = {...state}..remove(songId);
    state = updated;
    await _persist();
  }

  DownloadInfo infoFor(String songId, {required bool isLocalAsset}) {
    return state[songId] ??
        (isLocalAsset
            ? const DownloadInfo(status: DownloadStatus.done)
            : const DownloadInfo());
  }

  /// All songs that have finished downloading, most recent first — powers
  /// the "Downloads" entry on the Your Library tab.
  List<Song> get downloadedSongs {
    final entries = state.values
        .where((info) => info.status == DownloadStatus.done && info.song != null)
        .toList()
      ..sort((a, b) => (b.downloadedAt ?? DateTime(0)).compareTo(a.downloadedAt ?? DateTime(0)));
    return entries.map((info) => info.song!).toList();
  }
}

final downloadProvider =
    StateNotifierProvider<DownloadNotifier, Map<String, DownloadInfo>>((ref) {
  return DownloadNotifier();
});