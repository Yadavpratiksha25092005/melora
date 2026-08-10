import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:Melora/core/theme/app_colors.dart';
import 'package:Melora/providers/auth_provider.dart';
import 'package:Melora/providers/custom_playlists_provider.dart';
import 'package:Melora/screens/auth/login_screen.dart';
import 'package:Melora/screens/profile/edit_profile_screen.dart';
import 'package:go_router/go_router.dart';

/// ---------------------------------------------------------------------
/// ProfileScreen
///
/// Spotify-style profile page: gradient header with avatar + name +
/// followers/following, Edit + settings actions, then a "Playlists"
/// section listing the user's own playlists (from
/// [customPlaylistsProvider]), each with a stacked/song-art preview.
/// ---------------------------------------------------------------------
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isGuest = user == null;

    final displayName = isGuest ? 'Guest' : user.username;
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'G';

    final playlists = ref.watch(customPlaylistsProvider).values.toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            pinned: false,
            floating: false,
            iconTheme: const IconThemeData(color: Colors.white),
            expandedHeight: 230,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF8B5CF6).withValues(alpha: 0.55),
                      AppColors.background,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 48),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Color(0xFF8B5CF6), Color(0xFF6E7CF2)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Text(
                                initial,
                                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '0 followers · 0 following',
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            OutlinedButton(
                             onPressed: () {
  if (isGuest) {
    context.push('/login');
  } else {
    Navigator.of(context).push(
      
                                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                                  );
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white38),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                              ),
                              child: Text(isGuest ? 'Sign in' : 'Edit'),
                            ),
                            const SizedBox(width: 10),
                            if (!isGuest)
                              IconButton(
                                onPressed: () async {
                                  await ref.read(authProvider.notifier).logout();
                                  if (context.mounted) Navigator.of(context).pop();
                                },
                                icon: const Icon(Icons.more_vert, color: Colors.white70),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Playlists',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  TextButton.icon(
                   onPressed: () {
  if (isGuest) {
    context.push('/login');
  } else {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
  }
},
                    icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.white70),
                    label: const Text('Manage', style: TextStyle(color: Colors.white70)),
                  ),
                ],
              ),
            ),
          ),
          if (playlists.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Text(
                  'No playlists yet. Create one from the Create tab.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final playlist = playlists[index];
                  return _PlaylistTile(
                    name: playlist.name,
                    subtitle: '${playlist.songs.length} ${playlist.songs.length == 1 ? 'save' : 'saves'}',
                    coverSongArt: playlist.songs.isNotEmpty ? playlist.songs.first.coverUrl : null,
                  );
                },
                childCount: playlists.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _PlaylistTile extends StatelessWidget {
  final String name;
  final String subtitle;
  final String? coverSongArt;

  const _PlaylistTile({required this.name, required this.subtitle, this.coverSongArt});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 52,
              height: 52,
              color: AppColors.surfaceLight,
              alignment: Alignment.center,
              child: (coverSongArt != null && coverSongArt!.isNotEmpty)
                  ? Image.asset(
                      coverSongArt!,
                      fit: BoxFit.cover,
                      width: 52,
                      height: 52,
                      errorBuilder: (_, __, ___) => const Icon(Icons.music_note, color: Colors.white38),
                    )
                  : const Icon(Icons.music_note, color: Colors.white38),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: Colors.white38, size: 20),
        ],
      ),
    );
  }
}