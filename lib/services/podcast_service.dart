import 'package:dart_rss/dart_rss.dart';
import 'package:dio/dio.dart';

import 'package:Melora/core/network/dummy_data_source.dart';
import 'package:Melora/models/podcast.dart';
import 'package:Melora/services/seed_rss_feeds.dart';

/// Fetches real podcast episodes straight from a show's own public RSS
/// feed — no API key, no signup, no approval wait. This is literally
/// how Spotify/Apple Podcasts/every podcast app gets episode data.
class PodcastService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  /// Fetches + parses ONE show's RSS feed into a [PodcastShow] with all
  /// its episodes already attached (RSS gives you everything in one
  /// request — no separate "episodes" call needed, unlike Podcast Index).
  Future<PodcastShow> fetchShowFromRss(String feedUrl, {int episodeLimit = 10}) async {
    final response = await _dio.get<String>(feedUrl);
    final feed = RssFeed.parse(response.data!);

    final showTitle = feed.title ?? 'Untitled show';
    final showImage = feed.image?.url ?? feed.itunes?.image?.href ?? '';

    final episodes = feed.items.take(episodeLimit).map((item) {
      return PodcastEpisode(
        id: item.guid ?? item.link ?? item.title ?? UniqueKey().toString(),
        title: item.title ?? 'Untitled episode',
        showTitle: showTitle,
        coverUrl: item.itunes?.image?.href ?? showImage,
        durationLabel: _formatItunesDuration(item.itunes?.duration),
        // enclosure.url is the actual playable mp3/m4a file straight
        // from the show's own hosting — this is the real audio.
        audioUrl: item.enclosure?.url,
      );
    }).toList();

    return PodcastShow(
      id: feedUrl,
      title: showTitle,
      host: feed.itunes?.author ?? '',
      coverUrl: showImage,
      episodes: episodes,
    );
  }

  /// Fetches all [seedRssFeeds] in parallel and flattens their episodes
  /// into one feed — this is what powers the Search → Podcasts screen.
  /// Falls back to the static assets/dummy/podcasts.json catalog if
  /// every feed fails (e.g. no internet).
  Future<List<PodcastEpisode>> fetchFeed({int episodesPerShow = 4}) async {
    try {
      final shows = await Future.wait(
        seedRssFeeds.map((url) => fetchShowFromRss(url, episodeLimit: episodesPerShow)),
        eagerError: false,
      );
      final episodes = shows.expand((show) => show.episodes).toList();
      if (episodes.isNotEmpty) return episodes;
    } catch (_) {
      // fall through to dummy data below
    }
    final data = await DummyDataSource.podcasts();
    return data.map(PodcastEpisode.fromJson).toList();
  }

  /// itunes:duration parses as a Duration in dart_rss 3.x (it accepts
  /// both "1234" seconds and "HH:MM:SS" in the raw XML, but the parsed
  /// field itself is a Duration) — format it into "MM:SS"/"H:MM:SS".
  String _formatItunesDuration(Duration? duration) {
    if (duration == null || duration.inSeconds <= 0) return '--:--';
    final totalSeconds = duration.inSeconds;
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    final mm = m.toString().padLeft(h > 0 ? 2 : 1, '0');
    final ss = s.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
  }
}

/// Tiny local helper — avoids pulling in Flutter's UniqueKey in a pure
/// Dart service file. Just needs to be unique-ish as an id fallback.
class UniqueKey {
  static int _counter = 0;
  @override
  String toString() => 'rss_item_${_counter++}';
}