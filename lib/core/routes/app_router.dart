import 'package:go_router/go_router.dart';

import 'route_names.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/main_shell.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../features/onboarding/widgets/common/placeholder_screen.dart';
import '../../features/onboarding/screens/onboarding_welcome.dart';
import '../../features/onboarding/screens/language_screen.dart';
import '../../features/onboarding/screens/artist_screen.dart';
import '../../features/onboarding/screens/genre_screen.dart';
import '../../features/onboarding/screens/onboarding_complete.dart';
import '../../screens/player/player_screen.dart';

final appRouter = GoRouter(
  initialLocation: RouteNames.splash,
  routes: [
    GoRoute(
      path: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RouteNames.signup,
      builder: (context, state) => const PlaceholderScreen(title: 'Signup'),
    ),
    GoRoute(
      path: RouteNames.onboardingWelcome,
      builder: (context, state) => const OnboardingWelcomeScreen(),
    ),
    GoRoute(
      path: RouteNames.onboardingLanguage,
      builder: (context, state) => const LanguageScreen(),
    ),
    GoRoute(
      path: RouteNames.onboardingArtists,
      builder: (context, state) => const ArtistScreen(),
    ),
    GoRoute(
      path: RouteNames.onboardingGenres,
      builder: (context, state) => const GenreScreen(),
    ),
    GoRoute(
      path: RouteNames.onboardingComplete,
      builder: (context, state) => const OnboardingCompleteScreen(),
    ),
    // Home / Search / Your Library / Premium are now tabs *inside*
    // MainShell (switched locally via the bottom nav, not via GoRouter),
    // so this single route covers all four. The old dedicated
    // search/library routes below are left in place for deep-linking
    // if you ever need to open one directly, but the bottom nav no
    // longer uses them.
    GoRoute(
      path: RouteNames.home,
      builder: (context, state) => const MainShell(),
    ),
    GoRoute(
      path: RouteNames.search,
      builder: (context, state) => const PlaceholderScreen(title: 'Search'),
    ),
    GoRoute(
      path: RouteNames.library,
      builder: (context, state) => const PlaceholderScreen(title: 'Library'),
    ),
    GoRoute(
      path: RouteNames.player,
      builder: (context, state) => const PlayerScreen(),
    ),
    GoRoute(
      path: RouteNames.playlist,
      builder: (context, state) => PlaceholderScreen(
        title: 'Playlist ${state.pathParameters['id']}',
      ),
    ),
    GoRoute(
      path: RouteNames.artist,
      builder: (context, state) => PlaceholderScreen(
        title: 'Artist ${state.pathParameters['id']}',
      ),
    ),
    GoRoute(
      path: RouteNames.album,
      builder: (context, state) => PlaceholderScreen(
        title: 'Album ${state.pathParameters['id']}',
      ),
    ),
    GoRoute(
      path: RouteNames.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: RouteNames.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);