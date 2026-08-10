import 'package:Melora/core/utils/local_poster_catalog.dart';
import 'package:Melora/models/song.dart';

/// True when this song has a real bundled poster image (an asset path,
/// not a network URL) set as its cover.
bool hasLocalCover(Song song) {
  final cover = song.coverUrl;
  return cover != null && cover.isNotEmpty && !cover.startsWith('http');
}

/// Puts every song that has a real bundled poster image first (so the
/// songs images added under `assets/images/songs/` show at the top),
/// de-duplicated by normalized title so the same song is never listed
/// twice. Everything else keeps its original order and follows after.
List<Song> dedupedWithImagesFirst(List<Song> songs) {
  final withImage = <Song>[];
  final withoutImage = <Song>[];
  final seenImageTitles = <String>{};
  for (final s in songs) {
    if (hasLocalCover(s)) {
      if (seenImageTitles.add(normalizeTitle(s.title))) {
        withImage.add(s);
      }
      // else: same image-song already added once — skip the duplicate.
    } else {
      withoutImage.add(s);
    }
  }
  return [...withImage, ...withoutImage];
}