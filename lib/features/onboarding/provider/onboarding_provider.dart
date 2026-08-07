import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kOnboardingCompleteKey = 'onboarding_complete';

/// ---------------------------------------------------------------------
/// Immutable state carried across the 5 onboarding screens.
/// ---------------------------------------------------------------------
class OnboardingState {
  final Set<String> selectedLanguageIds;
  final Set<String> selectedArtistIds;
  final Set<String> selectedGenreIds;

  const OnboardingState({
    this.selectedLanguageIds = const {},
    this.selectedArtistIds = const {},
    this.selectedGenreIds = const {},
  });

  OnboardingState copyWith({
    Set<String>? selectedLanguageIds,
    Set<String>? selectedArtistIds,
    Set<String>? selectedGenreIds,
  }) {
    return OnboardingState(
      selectedLanguageIds: selectedLanguageIds ?? this.selectedLanguageIds,
      selectedArtistIds: selectedArtistIds ?? this.selectedArtistIds,
      selectedGenreIds: selectedGenreIds ?? this.selectedGenreIds,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final Ref _ref;
  OnboardingNotifier(this._ref) : super(const OnboardingState());

  void toggleLanguage(String id) {
    final next = {...state.selectedLanguageIds};
    next.contains(id) ? next.remove(id) : next.add(id);
    state = state.copyWith(selectedLanguageIds: next);
  }

  void toggleArtist(String id) {
    final next = {...state.selectedArtistIds};
    next.contains(id) ? next.remove(id) : next.add(id);
    state = state.copyWith(selectedArtistIds: next);
  }

  void toggleGenre(String id) {
    final next = {...state.selectedGenreIds};
    next.contains(id) ? next.remove(id) : next.add(id);
    state = state.copyWith(selectedGenreIds: next);
  }

  bool get hasLanguageSelection => state.selectedLanguageIds.isNotEmpty;
  bool get hasGenreSelection => state.selectedGenreIds.isNotEmpty;

  /// Persists completion so the splash screen skips onboarding next
  /// time the app opens.
  Future<void> markComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingCompleteKey, true);
    _ref.invalidate(onboardingCompleteProvider);
  }

  void reset() {
    state = const OnboardingState();
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(ref),
);

/// Checked once from the splash screen at app start.
final onboardingCompleteProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_kOnboardingCompleteKey) ?? false;
});