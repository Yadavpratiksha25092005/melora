import '../../models/podcast.dart';

/// Dummy podcast catalog powering the Search → Podcasts feed. Swap this
/// for a real `GET /shows` + `GET /episodes` call once the backend
/// `episodes` table (with its `video_url TEXT` column) is wired up —
/// nothing else in the UI needs to change, since it only depends on the
/// [PodcastEpisode] shape.
const List<PodcastEpisode> dummyPodcastFeed = [
  // Direct-hosted .mp4 files — play via the built-in video_player, no
  // YouTube/WebView embedding involved at all, so there's nothing for
  // YouTube's referrer/embedding restrictions to block.
  //
  // NOTE: the old `gtv-videos-bucket` (Google's ancient GCS demo bucket)
  // now returns AccessDenied for anonymous reads — Google locked it down,
  // it's not a bug in this app. Swapped to sources that are verified
  // public as of Aug 2026: Flutter's own official docs asset repo, and a
  // well-known open Big Buck Bunny test-media repo. Swap these for your
  // own hosted episode files whenever you have them (S3, Firebase, your
  // backend) — `coverUrl` uses picsum.photos (seeded, so each id always
  // gets the same stable placeholder image) until you have real posters.
  PodcastEpisode(
    id: 'ep_1',
    title: 'Psychiatrist Explains: Psychology Behind Cheating & choosing Wrong Partner',
    showTitle: "Psychiatrist's Explains",
    coverUrl: 'https://picsum.photos/seed/ep_1/400/400',
    durationLabel: '1:29:21',
    videoUrl: 'raw.githubusercontent.com/chthomos/video-media-samples/master/big-buck-bunny-480p-30sec.mp4',
  ),
  PodcastEpisode(
    id: 'ep_2',
    title: 'Building in Public: Lessons From Shipping Fast',
    showTitle: 'Tech Talk Podcast',
    coverUrl: 'https://picsum.photos/seed/ep_2/400/400',
    durationLabel: '24:24',
    videoUrl: 'flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
  ),
  PodcastEpisode(
    id: 'ep_3',
    title: 'A TED Talk Worth Spreading',
    showTitle: 'TED Talks',
    coverUrl: 'https://picsum.photos/seed/ep_3/400/400',
    durationLabel: '18:32',
    videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
  ),
  PodcastEpisode(
    id: 'ep_4',
    title: 'Coding Advice Nobody Tells You',
    showTitle: 'Tech Talk Podcast',
    coverUrl: 'https://picsum.photos/seed/ep_4/400/400',
    durationLabel: '18:02',
    videoUrl: 'https://raw.githubusercontent.com/chthomos/video-media-samples/master/big-buck-bunny-1080p-30sec.mp4',
  ),
  PodcastEpisode(
    id: 'ep_5',
    title: 'Personal Finance 101: Where Should Your First Salary Go?',
    showTitle: 'Paisa Vaisa',
    coverUrl: 'https://picsum.photos/seed/ep_5/400/400',
    durationLabel: '44:00',
    videoUrl: 'https://raw.githubusercontent.com/chthomos/video-media-samples/master/big-buck-bunny-1080p-60fps-30sec.mp4',
  ),
  PodcastEpisode(
    id: 'ep_6',
    title: 'Inside the Indian Startup Ecosystem',
    showTitle: 'The Startup Fridays Podcast',
    coverUrl: 'https://picsum.photos/seed/ep_6/400/400',
    durationLabel: '55:00',
    videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
  ),
  PodcastEpisode(
    id: 'ep_7',
    title: 'Fintech in India: The Wild West of Digital Money',
    showTitle: 'India Fintech Diaries',
    coverUrl: 'https://picsum.photos/seed/ep_7/400/400',
    durationLabel: '37:00',
    videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
  ),
  // YouTube-hosted episodes — `videoUrl` is a plain YouTube link, so
  // PodcastEpisode.isYoutubeVideo picks it up automatically and it opens
  // in the in-app YouTube player (podcast_video_player_screen.dart), not
  // an external browser/app.
  PodcastEpisode(
    id: 'ep_8',
    title: 'Bear Bicep Shiva',
    showTitle: 'Fitness',
    coverUrl: 'https://picsum.photos/seed/ep_8/400/400',
    durationLabel: '--:--',
    videoUrl: 'yi8hQ5XxzgM',
  ),
  PodcastEpisode(
    id: 'ep_9',
    title: 'Business Talk',
    showTitle: 'Business',
    coverUrl: 'https://picsum.photos/seed/ep_9/400/400',
    durationLabel: '--:--',
    videoUrl: 'JqxZGXQf0qg',
  ),
  PodcastEpisode(
    id: 'ep_10',
    title: 'AI Talk',
    showTitle: 'AI',
    coverUrl: 'https://picsum.photos/seed/ep_10/400/400',
    durationLabel: '--:--',
    videoUrl: 'fVXJ4gpy95Y',
  ),
  PodcastEpisode(
    id: 'ep_11',
    title: 'Self Improvement',
    showTitle: 'Self Improvement',
    coverUrl: 'https://picsum.photos/seed/ep_11/400/400',
    durationLabel: '--:--',
    videoUrl: 'OcISVEh1jyw',
  ),
  PodcastEpisode(
    id: 'ep_12',
    title: 'Emotional Intelligence',
    showTitle: 'Emotional Intelligence',
    coverUrl: 'https://picsum.photos/seed/ep_12/400/400',
    durationLabel: '--:--',
    videoUrl: 'YcGXViwXItM',
  ),
];