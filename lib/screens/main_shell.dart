import 'package:flutter/material.dart';

import 'package:Melora/core/theme/app_colors.dart';
import 'package:Melora/screens/home/home_screen.dart';
import 'package:Melora/screens/search/search_screen.dart';
import 'package:Melora/screens/library/library_screen.dart';
import 'package:Melora/screens/premium/premium_screen.dart';
import 'package:Melora/features/onboarding/widgets/common/app_back_handler.dart';
import 'package:Melora/features/onboarding/widgets/common/app_bottom_nav.dart';
import 'package:Melora/features/onboarding/widgets/common/app_drawer.dart';
import 'package:Melora/features/onboarding/widgets/common/create_options_sheet.dart';
import 'package:Melora/features/onboarding/widgets/common/mini_player_bar.dart';

/// Main shell that owns the Scaffold, mini player, and bottom nav.
/// Home / Search / Library / Premium screens are now "dumb" tab bodies (no Scaffold
/// of their own) held in an IndexedStack, so tapping a nav icon just swaps
/// `_currentIndex` — no navigation, no rebuild of other tabs.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // IndexedStack keeps all four tabs alive (scroll position, search text,
  // etc. are preserved when you switch away and back).
  static const List<Widget> _tabs = [
    HomeScreen(),
    SearchScreen(),
    LibraryScreen(),
    PremiumScreen(),
  ];

  void _onNavTap(int index) {
    if (index == 4) {
      showCreateOptionsSheet(context);
      return;
    }
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return AppBackHandler(
      isAtHome: () => _currentIndex == 0,
      goHome: () => setState(() => _currentIndex = 0),
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBody: true,
        drawer: AppDrawer(
          onRecentsTap: () => setState(() => _currentIndex = 2), // Library tab
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: _tabs,
        ),
        bottomNavigationBar: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Shows the current playing song with controls
              const MiniPlayerBar(),

              /// Bottom navigation tabs
              AppBottomNav(
                currentIndex: _currentIndex,
                onTap: _onNavTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}