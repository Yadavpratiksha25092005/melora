# Spotify Clone — Mobile App (Flutter)

## Quick start

```bash
flutter pub get
flutter run
```

Set the backend URL in `lib/core/constants/app_constants.dart`
(`10.0.2.2` is the Android emulator's alias for your host machine's
`localhost`; use `localhost` for iOS simulator, or your machine's LAN IP
for a physical device).

## Project layout

- `core/` — theme, routes, network client, constants, utils, errors
- `models/` — plain Dart data classes matching backend DTOs
- `services/` — raw API calls only (thin, one per feature)
- `repositories/` — wraps services, will hold caching/local-storage later
- `providers/` — Riverpod state, exposed to the UI
- `screens/` — one folder per feature/route
- `widgets/` — shared, reusable UI pieces

## Adding a new feature (e.g. `playlist`)

1. Add the model in `models/playlist.dart` (already scaffolded).
2. Copy the shape of `services/song_service.dart` →
   `services/playlist_service.dart`.
3. Copy `repositories/song_repository.dart` →
   `repositories/playlist_repository.dart`.
4. Copy `providers/song_provider.dart` →
   `providers/playlist_provider.dart`.
5. Build the screen in `screens/playlist/`, wire it into
   `core/routes/app_router.dart` (replace the `PlaceholderScreen`).

## Testing

Run with:

```bash
flutter test
```

See `test/services/song_repository_test.dart` for the mocking pattern
used with `mocktail`.
