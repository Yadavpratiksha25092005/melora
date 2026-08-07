/// ---------------------------------------------------------------------
/// Local poster catalog — maps a normalized song title to a poster file
/// under `assets/images/`. Used to show a curated local poster instead
/// of (or as a fallback for) a song's Audius network cover, and to keep
/// that same poster consistent across the home tiles, the mini player,
/// and the full player screen.
///
/// To add more: drop the file in `assets/images/` and add a line below.
/// ---------------------------------------------------------------------
const Map<String, String> localPosterCatalog = {
  'bhula dena': 'assets/images/bhula_dena.png',
  'bol do na zara': 'assets/images/bol_do_na_zara.png',
  'chahun main ya naa': 'assets/images/chahun_main_ya_naa.png',
  'dilbar': 'assets/images/dilbar.png',
  'main rahoon ya na rahoon': 'assets/images/main_rahoon_ya_na_rahoon.png',
  'o saki saki': 'assets/images/o_saki_saki.png',
  'sun raha hai na tu': 'assets/images/sun_raha_hai_na_tu.png',
  'tum hi ho': 'assets/images/tum_hi_ho.jpg',
  'wajah tum ho': 'assets/images/wajah_tum_ho.png',
  'ye fitoor mera': 'assets/images/ye_fitoor_mera.png',
};

/// Fixed display order for the "Bollywood Classics" row — title +
/// poster pairs, always shown regardless of what Audius returns.
const List<MapEntry<String, String>> bollywoodClassics = [
  MapEntry('Bhula Dena', 'assets/images/bhula_dena.png'),
  MapEntry('Bol Do Na Zara', 'assets/images/bol_do_na_zara.png'),
  MapEntry('Chahun Main Ya Naa', 'assets/images/chahun_main_ya_naa.png'),
  MapEntry('Dilbar', 'assets/images/dilbar.png'),
  MapEntry('Main Rahoon Ya Na Rahoon', 'assets/images/main_rahoon_ya_na_rahoon.png'),
  MapEntry('O Saki Saki', 'assets/images/o_saki_saki.png'),
  MapEntry('Sun Raha Hai Na Tu', 'assets/images/sun_raha_hai_na_tu.png'),
  MapEntry('Tum Hi Ho', 'assets/images/tum_hi_ho.jpg'),
  MapEntry('Wajah Tum Ho', 'assets/images/wajah_tum_ho.png'),
  MapEntry('Ye Fitoor Mera', 'assets/images/ye_fitoor_mera.png'),
];

/// Lowercases, strips punctuation/brackets, and collapses whitespace so
/// "Tum Hi Ho (Reprise)" and "tum-hi-ho" both normalize the same way.
String normalizeTitle(String title) {
  return title
      .toLowerCase()
      .replaceAll(RegExp(r'[\(\[].*?[\)\]]'), ' ') // drop "(...)" / "[...]"
      .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// Finds a local poster for [title], if any. Tries an exact normalized
/// match first, then falls back to "does the song title contain this
/// catalog entry" (or vice versa) so close variants still match.
String? localPosterForTitle(String title) {
  final normalized = normalizeTitle(title);
  if (normalized.isEmpty) return null;
  final exact = localPosterCatalog[normalized];
  if (exact != null) return exact;
  for (final entry in localPosterCatalog.entries) {
    if (normalized.contains(entry.key) || entry.key.contains(normalized)) {
      return entry.value;
    }
  }
  return null;
}