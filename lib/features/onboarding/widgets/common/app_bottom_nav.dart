import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:Melora/core/theme/app_colors.dart';

/// ---------------------------------------------------------------------
/// NOTE
/// This keeps your existing dark theme colors (AppColors.background +
/// the purple accent already used across the app) and only changes the
/// layout/icons to match: Home · Search · Your Library · Premium · Create
///
/// Usage is unchanged in spirit — pass whichever index is currently
/// active. If your app currently calls `AppBottomNav(currentRoute: ...)`
/// with route-name strings, either:
///   a) switch call sites to `AppBottomNav(currentIndex: 0..4)`, or
///   b) tell me your RouteNames values and I'll map them for you.
/// ---------------------------------------------------------------------

enum BottomNavItem { home, search, library, premium, create }

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  static const List<_NavItemData> _items = [
    _NavItemData(icon: Icons.home_rounded, outlineIcon: Icons.home_outlined, label: 'Home'),
    _NavItemData(icon: Icons.search_rounded, outlineIcon: Icons.search_rounded, label: 'Search'),
    _NavItemData(icon: Icons.library_music_rounded, outlineIcon: Icons.library_music_outlined, label: 'Your Library'),
    _NavItemData(icon: Icons.stars_rounded, outlineIcon: Icons.stars_outlined, label: 'Premium'),
    _NavItemData(icon: Icons.add_circle, outlineIcon: Icons.add_circle_outline, label: 'Create'),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            // Frosted-glass look: dark, semi-transparent fill (so content
            // scrolling underneath is blurred + tinted, not fully see-through)
            // plus a soft top border to separate it from the page.
            color: AppColors.background.withValues(alpha: 0.55),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1),
            ),
          ),
          child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_items.length, (index) {
            final isSelected = index == currentIndex;
            final item = _items[index];
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap == null ? null : () => onTap!(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected ? item.icon : item.outlineIcon,
                    color: isSelected ? AppColors.primary : Colors.white38,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : Colors.white38,
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData outlineIcon;
  final String label;

  const _NavItemData({
    required this.icon,
    required this.outlineIcon,
    required this.label,
  });
}