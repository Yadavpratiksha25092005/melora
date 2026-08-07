class AppConstants {
  AppConstants._();

  static const String appName = "Melora";
  static const String tagline = "FEEL EVERY BEAT";

  // change this to your backend base URL
  static const String baseUrl = "http://192.168.1.17:8080/api/v1";

  static const String tokenKey = "auth_token";

  /// No backend/SMS gateway wired up yet — screens run on mock data
  /// (DummyDataSource) so the UI can be built and tested standalone.
  /// Flip to false once the backend partner's API is ready.
  static const bool useDummyData = false;


  // ---------------------------------------------------------------------
  // Audius (no signup/API key needed for basic use). We point at Audius's
  // maintained gateway (api.audius.co) instead of a single hardcoded
  // discovery node — Audius is decentralized, so any single node
  // (like discoveryprovider.audius.co) can go down or lag on its own.
  // The gateway auto-routes to a healthy node behind the scenes.
  // ---------------------------------------------------------------------

  static const String audiusBaseUrl = "https://api.audius.co/v1";

  /// Sent as app_name on every Audius request — just identifies your app,
  /// no signup or key needed.
  static const String audiusAppName = "Melora";

  /// Songs ke liye Audius se real audio/streaming data laayenge, taaki
  /// player real songs ke saath test ho sake. Albums/artists/playlists/user
  /// abhi bhi dummy data pe hi rahenge jab tak apna Go backend ready nahi
  /// hota. Backend aane par: isse false kar do aur useDummyData bhi false,
  /// baaki code (services/repositories/providers) already handle karega.
  ///
  /// Set to false to use the local 500-song dummy catalog
  /// (assets/dummy/songs.json) with YouTube-resolved playback instead.
  static const bool useAudiusForSongs = false;
}