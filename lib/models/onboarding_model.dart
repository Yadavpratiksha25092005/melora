import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------
/// Data models for the onboarding flow (language -> artists -> genres).
/// Kept intentionally simple / local — no network dependency and no
/// image assets, so onboarding always works offline. Language cards
/// are plain gradient color boxes.
/// ---------------------------------------------------------------------

class OnboardingLanguage {
  final String id;
  final String label;
  final List<Color> gradient;

  const OnboardingLanguage({
    required this.id,
    required this.label,
    required this.gradient,
  });
}

class OnboardingArtist {
  final String id;
  final String name;
  final List<String> languageIds;

  const OnboardingArtist({
    required this.id,
    required this.name,
    required this.languageIds,
  });
}

class OnboardingGenre {
  final String id;
  final String label;

  const OnboardingGenre({required this.id, required this.label});
}

/// ---------------------------------------------------------------------
/// Static catalogs. Swap for a real API later — the provider only
/// depends on the shape of these classes, not on where they come from.
/// ---------------------------------------------------------------------

const List<OnboardingLanguage> kOnboardingLanguages = [
  OnboardingLanguage(id: 'hindi', label: 'Hindi', gradient: [Color(0xFFEB4635), Color(0xFF6E0F0F)]),
  OnboardingLanguage(id: 'international', label: 'International', gradient: [Color(0xFFF0A01E), Color(0xFF6E3705)]),
  OnboardingLanguage(id: 'punjabi', label: 'Punjabi', gradient: [Color(0xFFAF32BE), Color(0xFF3C0A50)]),
  OnboardingLanguage(id: 'tamil', label: 'Tamil', gradient: [Color(0xFFEBBE3C), Color(0xFF78500A)]),
  OnboardingLanguage(id: 'telugu', label: 'Telugu', gradient: [Color(0xFF1EBE82), Color(0xFF054637)]),
  OnboardingLanguage(id: 'malayalam', label: 'Malayalam', gradient: [Color(0xFF6EAF96), Color(0xFF1E4137)]),
  OnboardingLanguage(id: 'marathi', label: 'Marathi', gradient: [Color(0xFFBE6E28), Color(0xFF4B280A)]),
  OnboardingLanguage(id: 'gujarati', label: 'Gujarati', gradient: [Color(0xFFE15A8C), Color(0xFF641937)]),
  OnboardingLanguage(id: 'bengali', label: 'Bengali', gradient: [Color(0xFF3C82E1), Color(0xFF0A2864)]),
  OnboardingLanguage(id: 'kannada', label: 'Kannada', gradient: [Color(0xFFE1372D), Color(0xFF5A0A0A)]),
];

const List<OnboardingArtist> kOnboardingArtists = [
  OnboardingArtist(id: 'arijit_singh', name: 'Arijit Singh', languageIds: ['hindi']),
  OnboardingArtist(id: 'ar_rahman', name: 'A.R. Rahman', languageIds: ['tamil', 'hindi', 'telugu']),
  OnboardingArtist(id: 'sid_sriram', name: 'Sid Sriram', languageIds: ['tamil', 'telugu']),
  OnboardingArtist(id: 'devi_sri_prasad', name: 'Devi Sri Prasad', languageIds: ['telugu']),
  OnboardingArtist(id: 'thaman_s', name: 'Thaman S', languageIds: ['telugu']),
  OnboardingArtist(id: 'mm_manasi', name: 'M.M.Manasi', languageIds: ['telugu']),
  OnboardingArtist(id: 'baba_sehgal', name: 'Baba Sehgal', languageIds: ['hindi']),
  OnboardingArtist(id: 'ramajogayya_sastry', name: 'Ramajogayya Sastry', languageIds: ['telugu']),
  OnboardingArtist(id: 'kasarla_shyam', name: 'Kasarla Shyam', languageIds: ['telugu']),
  OnboardingArtist(id: 'deepak_blue', name: 'Deepak Blue', languageIds: ['telugu']),
  OnboardingArtist(id: 'vaishali_samant', name: 'Vaishali Samant', languageIds: ['marathi']),
  OnboardingArtist(id: 'ajay_atul', name: 'Ajay-Atul', languageIds: ['marathi', 'hindi']),
  OnboardingArtist(id: 'justin_bieber', name: 'Justin Bieber', languageIds: ['international']),
  OnboardingArtist(id: 'diljit_dosanjh', name: 'Diljit Dosanjh', languageIds: ['punjabi']),
  OnboardingArtist(id: 'guru_randhawa', name: 'Guru Randhawa', languageIds: ['punjabi', 'hindi']),
  OnboardingArtist(id: 'anirudh', name: 'Anirudh Ravichander', languageIds: ['tamil']),
  OnboardingArtist(id: 'shreya_ghoshal', name: 'Shreya Ghoshal', languageIds: ['hindi', 'bengali']),
  OnboardingArtist(id: 'lata_mangeshkar', name: 'Lata Mangeshkar', languageIds: ['hindi', 'marathi']),
  OnboardingArtist(id: 'ed_sheeran', name: 'Ed Sheeran', languageIds: ['international']),
  OnboardingArtist(id: 'taylor_swift', name: 'Taylor Swift', languageIds: ['international']),
];

const List<OnboardingGenre> kOnboardingGenres = [
  OnboardingGenre(id: 'romantic', label: 'Romantic'),
  OnboardingGenre(id: 'party', label: 'Party'),
  OnboardingGenre(id: 'lofi_chill', label: 'Lofi / Chill'),
  OnboardingGenre(id: 'devotional', label: 'Devotional'),
  OnboardingGenre(id: 'hiphop', label: 'Hip-Hop'),
  OnboardingGenre(id: 'classical', label: 'Classical'),
  OnboardingGenre(id: 'indie', label: 'Indie'),
  OnboardingGenre(id: 'workout', label: 'Workout'),
  OnboardingGenre(id: 'sad', label: 'Sad / Heartbreak'),
  OnboardingGenre(id: 'folk', label: 'Folk'),
  OnboardingGenre(id: 'pop', label: 'Pop'),
  OnboardingGenre(id: 'rock', label: 'Rock'),
];