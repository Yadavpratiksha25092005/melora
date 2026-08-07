import 'package:Melora/screens/library/library_detail_screen.dart';

/// ---------------------------------------------------------------------
/// Shared "Your Library" entry model + mock data.
///
/// Lives in its own file (instead of inside library_screen.dart) so
/// LibrarySearchScreen can filter the same list the Library tab shows.
/// Swap `libraryEntries` for your real library/playlist provider when
/// it's ready.
/// ---------------------------------------------------------------------
class LibraryEntry {
  final String title;
  final String subtitle;
  final LibraryEntryKind kind;
  final String? imageUrl;
  final bool pinned;
  /// Set only for entries backed by a real user-created playlist (see
  /// customPlaylistsProvider) — lets LibraryDetailScreen look up its
  /// actual songs instead of showing mock tracks.
  final String? playlistId;

  const LibraryEntry({
    required this.title,
    required this.subtitle,
    required this.kind,
    this.imageUrl,
    this.pinned = false,
    this.playlistId,
  });
}

const List<LibraryEntry> libraryEntries = [
  LibraryEntry(
    title: 'Liked Songs',
    subtitle: 'Playlist • You',
    kind: LibraryEntryKind.likedSongs,
    pinned: true,
  ),
  LibraryEntry(
    title: 'Downloads',
    subtitle: 'Downloaded songs',
    kind: LibraryEntryKind.downloads,
    pinned: true,
  ),
  LibraryEntry(
    title: 'Arijit Singh',
    subtitle: 'Artist',
    kind: LibraryEntryKind.artist,
    imageUrl: 'assets/images/artists/arijit_singh.jpg',
  ),
  LibraryEntry(
    title: 'Armaan Malik',
    subtitle: 'Artist',
    kind: LibraryEntryKind.artist,
    imageUrl: 'assets/images/artists/armaan_malik.jpg',
  ),
  LibraryEntry(
    title: 'Jubin Nautiyal',
    subtitle: 'Artist',
    kind: LibraryEntryKind.artist,
    imageUrl: 'assets/images/artists/jubin_nautiyal.jpg',
  ),
  LibraryEntry(
    title: 'Shreya Ghoshal',
    subtitle: 'Artist',
    kind: LibraryEntryKind.artist,
    imageUrl: 'assets/images/artists/shreya_ghoshal.jpg',
  ),
  LibraryEntry(
    title: 'Sonu Nigam',
    subtitle: 'Artist',
    kind: LibraryEntryKind.artist,
    imageUrl: 'assets/images/artists/sonu_nigam.jpg',
  ),
  LibraryEntry(
    title: 'Badshah',
    subtitle: 'Artist',
    kind: LibraryEntryKind.artist,
    imageUrl: 'assets/images/artists/badshah.jpg',
  ),
  LibraryEntry(
    title: 'Diljit Dosanjh',
    subtitle: 'Artist',
    kind: LibraryEntryKind.artist,
    imageUrl: 'assets/images/artists/diljit_dosanjh.jpg',
  ),
  LibraryEntry(
    title: 'Ajay Atul',
    subtitle: 'Artist',
    kind: LibraryEntryKind.artist,
    imageUrl: 'assets/images/artists/ajay_atul.jpg',
  ),
  LibraryEntry(
    title: 'Akhil Sachdeva',
    subtitle: 'Artist',
    kind: LibraryEntryKind.artist,
    imageUrl: 'assets/images/artists/akhil_sachdeva.jpg',
  ),
  LibraryEntry(
    title: 'Adarsh Shinde',
    subtitle: 'Artist',
    kind: LibraryEntryKind.artist,
    imageUrl: 'assets/images/artists/adarsh_shinde.jpg',
  ),
];