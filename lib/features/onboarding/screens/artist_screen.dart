import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:Melora/core/theme/app_colors.dart';
import 'package:Melora/core/routes/route_names.dart';
import 'package:Melora/features/onboarding/models/onboarding_model.dart';
import 'package:Melora/features/onboarding/provider/onboarding_provider.dart';
import 'package:Melora/features/onboarding/widgets/artist_card.dart';
import 'package:Melora/features/onboarding/widgets/option_chip.dart';
import 'package:Melora/features/onboarding/widgets/progress_indicator.dart';

class ArtistScreen extends ConsumerStatefulWidget {
  const ArtistScreen({super.key});

  @override
  ConsumerState<ArtistScreen> createState() => _ArtistScreenState();
}

class _ArtistScreenState extends ConsumerState<ArtistScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _activeFilter = 'for_you';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    // Filter chips: "For You" first, then every language the user picked
    // on the previous screen (so the list feels personalized).
    final selectedLangs = kOnboardingLanguages
        .where((l) => onboarding.selectedLanguageIds.contains(l.id))
        .toList();
    final filters = <_FilterOption>[
      const _FilterOption(id: 'for_you', label: 'For You'),
      for (final lang in selectedLangs) _FilterOption(id: lang.id, label: lang.label),
    ];

    List<OnboardingArtist> artists = kOnboardingArtists;
    if (_activeFilter != 'for_you') {
      artists = artists.where((a) => a.languageIds.contains(_activeFilter)).toList();
    } else if (onboarding.selectedLanguageIds.isNotEmpty) {
      artists = artists
          .where((a) => a.languageIds.any(onboarding.selectedLanguageIds.contains))
          .toList();
    }
    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase();
      artists = artists.where((a) => a.name.toLowerCase().contains(q)).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: OnboardingProgressIndicator(currentStep: 2, totalSteps: 3),
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Choose more artists\nyou like.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 18),
                          TextField(
                            controller: _searchController,
                            onChanged: (v) => setState(() => _query = v),
                            style: const TextStyle(color: Colors.black87),
                            decoration: InputDecoration(
                              hintText: 'Search',
                              hintStyle: const TextStyle(color: Colors.black45),
                              prefixIcon: const Icon(Icons.search, color: Colors.black54),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(28),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 40,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: filters.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 10),
                              itemBuilder: (context, index) {
                                final f = filters[index];
                                return OptionChip(
                                  label: f.label,
                                  isSelected: _activeFilter == f.id,
                                  onTap: () => setState(() => _activeFilter = f.id),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    sliver: artists.isEmpty
                        ? const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(top: 40),
                              child: Center(
                                child: Text(
                                  'No artists found',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                              ),
                            ),
                          )
                        : SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 20,
                              childAspectRatio: 0.78,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final artist = artists[index];
                                final isSelected = onboarding.selectedArtistIds.contains(artist.id);
                                return ArtistCard(
                                  name: artist.name,
                                  isSelected: isSelected,
                                  onTap: () => notifier.toggleArtist(artist.id),
                                );
                              },
                              childCount: artists.length,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        color: AppColors.background,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () => context.push(RouteNames.onboardingGenres),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              elevation: 0,
            ),
            child: const Text('Done', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}

class _FilterOption {
  final String id;
  final String label;
  const _FilterOption({required this.id, required this.label});
}