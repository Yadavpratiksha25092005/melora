/// ---------------------------------------------------------------------
/// Local artist photo assets, provided directly by the app owner and
/// bundled into the app (assets/images/artists/...). Looked up by exact
/// artist name wherever an artist's name is shown (Library, Home
/// "Artists" category, onboarding artist picker, search, ...).
///
/// Add a new entry here + drop the matching file into
/// assets/images/artists/ to add a photo for another artist.
/// ---------------------------------------------------------------------
const Map<String, String> artistPhotoAssets = {
  'Adarsh Shinde': 'assets/images/artists/adarsh_shinde.jpg',
  'Ajay Atul': 'assets/images/artists/ajay_atul.jpg',
  'Akhil Sachdeva': 'assets/images/artists/akhil_sachdeva.jpg',
  'Arijit Singh': 'assets/images/artists/arijit_singh.jpg',
  'Armaan Malik': 'assets/images/artists/armaan_malik.jpg',
  'Badshah': 'assets/images/artists/badshah.jpg',
  'Diljit Dosanjh': 'assets/images/artists/diljit_dosanjh.jpg',
  'Jubin Nautiyal': 'assets/images/artists/jubin_nautiyal.jpg',
  'Shreya Ghoshal': 'assets/images/artists/shreya_ghoshal.jpg',
  'Sonu Nigam': 'assets/images/artists/sonu_nigam.jpg',
};

/// Case/space-insensitive lookup helper.
String? artistPhotoAssetFor(String name) {
  final key = name.trim().toLowerCase();
  for (final entry in artistPhotoAssets.entries) {
    if (entry.key.toLowerCase() == key) return entry.value;
  }
  return null;
}