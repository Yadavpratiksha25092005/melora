import 'package:flutter/material.dart';

import 'package:Melora/core/theme/app_colors.dart';
import 'package:Melora/screens/create/create_form_screen.dart';

/// ---------------------------------------------------------------------
/// "Create" bottom sheet — shown when the Create tab is tapped.
/// Matches the reference: a dark rounded sheet listing creation options
/// (Playlist / Collaborative playlist / Blend), with the bottom nav
/// still visible behind it and a floating white "X" replacing the
/// Create icon so the user can dismiss it.
///
/// Tapping an option closes the sheet and opens CreateFormScreen for
/// that type (form UI only — saving is a placeholder until a real
/// "create playlist" backend endpoint exists).
///
/// USAGE
/// Wherever `AppBottomNav`'s onTap receives index 4 (Create), call:
///
///   onTap: (index) {
///     if (index == 4) {
///       showCreateOptionsSheet(context);
///       return;
///     }
///     // ...handle the other tabs as usual
///   },
/// ---------------------------------------------------------------------

Future<void> showCreateOptionsSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) => _CreateOptionsSheet(parentContext: context),
  );
}

class _CreateOptionsSheet extends StatelessWidget {
  final BuildContext parentContext;
  const _CreateOptionsSheet({required this.parentContext});

  static const List<_CreateOption> _options = [
    _CreateOption(
      icon: Icons.music_note_rounded,
      title: 'Playlist',
      subtitle: 'Create a playlist with songs or episodes',
      type: CreateFormType.playlist,
    ),
    _CreateOption(
      icon: Icons.groups_rounded,
      title: 'Collaborative playlist',
      subtitle: 'Create a playlist together with friends',
      type: CreateFormType.collaborative,
    ),
    _CreateOption(
      icon: Icons.blender_rounded,
      title: 'Blend',
      subtitle: "Combine your friends' tastes into a playlist",
      type: CreateFormType.blend,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Options card
            Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C24),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final option in _options)
                    _OptionTile(
                      option: option,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          parentContext,
                          MaterialPageRoute(
                            builder: (_) => CreateFormScreen(type: option.type),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            // Bottom-nav-style footer with a floating close (X) button
            // replacing the Create icon, matching the reference.
            _FauxNavWithClose(onClose: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}

class _CreateOption {
  final IconData icon;
  final String title;
  final String subtitle;
  final CreateFormType type;

  const _CreateOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.type,
  });
}

class _OptionTile extends StatelessWidget {
  final _CreateOption option;
  final VoidCallback onTap;

  const _OptionTile({required this.option, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(option.icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.subtitle,
                    style: const TextStyle(color: Colors.white54, fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// A visual copy of the bottom nav row (Home / Search / Your Library /
/// Premium, all dimmed/inactive) with a floating white "X" button where
/// Create normally sits — tapping it dismisses the sheet.
/// ---------------------------------------------------------------------
class _FauxNavWithClose extends StatelessWidget {
  final VoidCallback onClose;
  const _FauxNavWithClose({required this.onClose});

  static const List<_FauxNavItem> _items = [
    _FauxNavItem(icon: Icons.home_outlined, label: 'Home'),
    _FauxNavItem(icon: Icons.search_rounded, label: 'Search'),
    _FauxNavItem(icon: Icons.library_music_outlined, label: 'Your Library'),
    _FauxNavItem(icon: Icons.stars_outlined, label: 'Premium'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ..._items.map(
            (item) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.icon, color: Colors.white38, size: 24),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, color: Colors.black, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

class _FauxNavItem {
  final IconData icon;
  final String label;

  const _FauxNavItem({required this.icon, required this.label});
}