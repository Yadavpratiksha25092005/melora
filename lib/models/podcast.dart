class PodcastChapter {
  final String title;
  final String durationLabel;

  const PodcastChapter({required this.title, required this.durationLabel});

  factory PodcastChapter.fromJson(Map<String, dynamic> json) {
    return PodcastChapter(
      title: json['title'] as String? ?? '',
      durationLabel: json['duration_label'] as String? ?? '',
    );
  }
}

/// A single podcast episode.
///
/// [videoUrl] can be either a YouTube ID/link or a direct video file
/// link (.mp4 etc) — opens the matching player.
/// [audioUrl] is the normal case for a real podcast episode — a direct
/// mp3/m4a stream (e.g. straight from an RSS <enclosure> tag), played
/// via just_audio (see PodcastAudioPlayerScreen).
class PodcastEpisode {
  final String id;
  final String title;
  final String showTitle;
  final String coverUrl;
  final String durationLabel;
  final String? videoUrl;
  final String? audioUrl;
  final String? showHost;
  final String? showDescription;
  final String? episodeDescription;
  final List<PodcastChapter> chapters;

  const PodcastEpisode({
    required this.id,
    required this.title,
    required this.showTitle,
    required this.coverUrl,
    required this.durationLabel,
    this.videoUrl,
    this.audioUrl,
    this.showHost,
    this.showDescription,
    this.episodeDescription,
    this.chapters = const [],
  });

  factory PodcastEpisode.fromJson(Map<String, dynamic> json) {
    return PodcastEpisode(
      id: json['id'] as String,
      title: json['title'] as String,
      showTitle: json['show_title'] as String? ?? '',
      coverUrl: json['cover_url'] as String? ?? '',
      durationLabel: json['duration_label'] as String? ?? '--:--',
      videoUrl: json['video_url'] as String?,
      audioUrl: json['audio_url'] as String?,
      showHost: json['show_host'] as String?,
      showDescription: json['show_description'] as String?,
      episodeDescription: json['episode_description'] as String?,
      chapters: (json['chapters'] as List<dynamic>?)
              ?.map((c) => PodcastChapter.fromJson(c as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  bool get hasAudio => audioUrl != null && audioUrl!.trim().isNotEmpty;

  bool get hasVideo => videoUrl != null && videoUrl!.trim().isNotEmpty;

  static const _directVideoExtensions = ['.mp4', '.mov', '.m3u8', '.webm', '.mkv'];

  bool get isDirectVideoFile {
    final url = videoUrl?.toLowerCase();
    if (url == null) return false;
    return _directVideoExtensions.any((ext) => url.contains(ext));
  }

  bool get isYoutubeVideo => hasVideo && !isDirectVideoFile;
}

class PodcastShow {
  final String id;
  final String title;
  final String host;
  final String coverUrl;
  final List<PodcastEpisode> episodes;

  const PodcastShow({
    required this.id,
    required this.title,
    required this.host,
    required this.coverUrl,
    required this.episodes,
  });
}