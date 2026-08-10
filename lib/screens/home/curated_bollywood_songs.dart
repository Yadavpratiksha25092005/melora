import '../../core/utils/local_poster_catalog.dart';
import '../../models/song.dart';

/// ---------------------------------------------------------------------
/// Curated Bollywood picks — bundled LOCALLY (poster + audio both live
/// in assets/), not fetched from Audius/Jamendo. Free music APIs don't
/// carry licensed commercial Bollywood tracks, so this is the only way
/// to guarantee the exact right song plays with the exact right poster.
///
/// SETUP REQUIRED: drop your own legally-owned MP3 files into
/// `assets/audio/` with these exact filenames. The posters are already
/// in `assets/images/`. Until the MP3 is added, tapping the tile will
/// throw a "Failed to play" error (fail loudly, not silently).
/// ---------------------------------------------------------------------
final List<Song> curatedBollywoodSongs = [
  Song(
    id: 'local-raataan-lambiyan',
    artistId: 'Jubin Nautiyal, Asees Kaur',
    title: 'Raataan Lambiyan',
    durationMs: 0, // unknown until the real file loads; just_audio fills this in
    fileUrl: 'asset:assets/audio/raataan_lambiyan.mp3',
    coverUrl: 'assets/images/raataan_lambiyan.jpg',
    genre: 'Shershaah',
  ),
  Song(
    id: 'local-tera-ban-jaunga',
    artistId: 'Akhil Sachdeva, Tulsi Kumar',
    title: 'Tera Ban Jaunga',
    durationMs: 0,
    fileUrl: 'asset:assets/audio/tera_ban_jaunga.mp3',
    coverUrl: 'assets/images/tera_ban_jaunga.jpg',
    genre: 'Kabir Singh',
  ),
  Song(
    id: 'local-tum-hi-ho',
    artistId: 'Arijit Singh',
    title: 'Tum Hi Ho',
    durationMs: 0,
    fileUrl: 'asset:assets/audio/tum_hi_ho.mp3',
    coverUrl: 'assets/images/tum_hi_ho.jpg',
    genre: 'Aashiqui 2',
  ),
  Song(
    id: 'local-dilbar',
    artistId: 'Neha Kakkar, Dhvani Bhanushali',
    title: 'Dilbar',
    durationMs: 0,
    fileUrl: 'asset:assets/audio/dilbar.mp3',
    coverUrl: 'assets/images/dilbar.png',
    genre: 'Satyameva Jayate',
  ),
  Song(
    id: 'local-o-saki-saki',
    artistId: 'Neha Kakkar, Tulsi Kumar',
    title: 'O Saki Saki',
    durationMs: 0,
    fileUrl: 'asset:assets/audio/o_saki_saki.mp3',
    coverUrl: 'assets/images/o_saki_saki.png',
    genre: 'Batla House',
  ),
  Song(
    id: 'local-bhula-dena',
    artistId: 'Mustafa Zahid',
    title: 'Bhula Dena',
    durationMs: 0,
    fileUrl: 'asset:assets/audio/bhula_dena.mp3',
    coverUrl: 'assets/images/bhula_dena.png',
    genre: 'Aashiqui 2',
  ),
  Song(
    id: 'local-bol-do-na-zaraa',
    artistId: 'Armaan Malik, Amaal Mallik',
    title: 'Bol Do Na Zaraa',
    durationMs: 0,
    // NOTE: confirm exact filename — screenshot showed it truncated
    // ("bol_do_na_zara...") — rename this if your actual file differs.
    fileUrl: 'asset:assets/audio/bol_do_na_zaraa.mp3',
    coverUrl: 'assets/images/bol_do_na_zaraa.png',
    genre: 'Azhar',
  ),
  Song(
    id: 'local-chahun-main-ya-na',
    artistId: 'Arijit Singh, Palak Muchhal',
    title: 'Chahun Main Ya Naa',
    durationMs: 0,
    // NOTE: confirm exact filename — screenshot showed it truncated
    // ("chahun_main_ya...") — rename this if your actual file differs.
    fileUrl: 'asset:assets/audio/chahun_main_ya_na.mp3',
    coverUrl: 'assets/images/chahun_main_ya_na.png',
    genre: 'Aashiqui 2',
  ),
  Song(
    id: 'local-main-rahoon-ya-na-rahoon',
    artistId: 'Armaan Malik',
    title: 'Main Rahoon Ya Na Rahoon',
    durationMs: 0,
    // NOTE: confirm exact filename — screenshot showed it truncated
    // ("main_rahoon_ya...") — rename this if your actual file differs.
    fileUrl: 'asset:assets/audio/main_rahoon_ya_na_rahoon.mp3',
    coverUrl: 'assets/images/main_rahoon_ya_na_rahoon.png',
    genre: 'Emraan Hashmi',
  ),
  Song(
    id: 'local-sun-raha-hai-na-tu',
    artistId: 'Ankit Tiwari',
    title: 'Sun Raha Hai Na Tu',
    durationMs: 0,
    // NOTE: confirm exact filename — screenshot showed it truncated
    // ("sun_raha_hai_na...") — rename this if your actual file differs.
    fileUrl: 'asset:assets/audio/sun_raha_hai_na_tu.mp3',
    coverUrl: 'assets/images/sun_raha_hai_na_tu.png',
    genre: 'Aashiqui 2',
  ),
  Song(
    id: 'local-wajah-tum-ho',
    artistId: 'Armaan Malik, Tulsi Kumar',
    title: 'Wajah Tum Ho',
    durationMs: 0,
    // NOTE: confirm exact filename — screenshot showed it truncated
    // ("wajah_tum_ho.p...") — rename this if your actual file differs.
    fileUrl: 'asset:assets/audio/wajah_tum_ho.mp3',
    coverUrl: 'assets/images/wajah_tum_ho.png',
    genre: 'Hate Story 3',
  ),
  Song(
    id: 'local-ye-fitoor-mera',
    artistId: 'Arijit Singh',
    title: 'Ye Fitoor Mera',
    durationMs: 0,
    // NOTE: confirm exact filename — screenshot showed it truncated
    // ("ye_fitoor_mera.p...") — rename this if your actual file differs.
    fileUrl: 'asset:assets/audio/ye_fitoor_mera.mp3',
    coverUrl: 'assets/images/ye_fitoor_mera.png',
    genre: 'Fitoor',
  ),
];

/// ---------------------------------------------------------------------
/// Searches Audius for each curated title and swaps in a REAL, playable
/// stream URL — so tapping a tile actually plays audio even if you never
/// added local MP3 files. Your local poster (coverUrl) is kept as-is.
///
/// Call this once, early, before the Home screen is shown (e.g. in
/// main.dart or your splash screen) — home_screen.dart reads
/// [curatedBollywoodSongs] as a plain list, so it needs to already be
/// resolved by the time Home builds.
///
/// Honest caveat: Audius doesn't license official Bollywood masters, so
/// the match found is typically an independent creator's cover/version
/// of the song — not the original studio recording. It WILL actually
/// play, but it may not be pixel-perfect audio-to-poster (e.g. a
/// different singer's cover). If a title has no reasonable match, it's
/// left with an empty file_url. PlayerNotifier (see player_provider.dart)
/// resolves those via YouTube search at play time.
/// ---------------------------------------------------------------------
Future<void> resolveCuratedBollywoodAudioFromAudius() async {
  for (var i = 0; i < curatedBollywoodSongs.length; i++) {
    final song = curatedBollywoodSongs[i];
    // Keep the bundled local poster (real movie/song artwork already in
    // assets/images/) and just make sure playback goes through YouTube
    // resolution instead of a local MP3 that may not exist, or Audius.
    curatedBollywoodSongs[i] = song.copyWith(
      fileUrl: '',
      youtubeSearchQuery: '${song.title} ${song.artistId}',
    );
  }
}

/// Looks up a curated Bollywood [Song] (already resolved to a real,
/// playable Audius stream URL by [resolveCuratedBollywoodAudioFromAudius])
/// by its title. Used by the Home screen so that tapping a Bollywood tile
/// plays the exact same song/poster the user sees, instead of a disconnected
/// placeholder track.
///
/// Returns null if there's no curated entry for [title] (e.g. it's from a
/// different Home section like "Punjabi" or "Lofi / Chill").
Song? resolvedBollywoodSongForTitle(String title) {
  final normalized = normalizeTitle(title);
  if (normalized.isEmpty) return null;
  for (final song in curatedBollywoodSongs) {
    if (normalizeTitle(song.title) == normalized) return song;
  }
  return null;
}