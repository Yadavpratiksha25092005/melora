import 'package:flutter/material.dart';

import 'package:Melora/core/constants/artist_photos.dart';

/// ---------------------------------------------------------------------
/// ArtistAvatar
///
/// Drop-in circular avatar for anywhere an artist's name is shown
/// (Library rows/grid/detail, Home "Artists" category, onboarding artist
/// picker, search, ...).
///
/// Uses the bundled local photo for [name] from artistPhotoAssets if one
/// exists. If there's no local photo for that artist yet, it falls back
/// to a generated gradient "initials" avatar so the UI is never broken.
///
/// Sizes itself to whatever box it's given (works inside a fixed
/// SizedBox, an AspectRatio grid cell, etc).
/// ---------------------------------------------------------------------
class ArtistAvatar extends StatelessWidget {
  final String name;
  final String? fallbackImageUrl;

  const ArtistAvatar({
    super.key,
    required this.name,
    this.fallbackImageUrl,
  });

  static const List<List<Color>> _palettes = [
    [Color(0xFF7C4DFF), Color(0xFF8A6BFF)],
    [Color(0xFFFF6B6B), Color(0xFFB33939)],
    [Color(0xFF00E5C7), Color(0xFF0F9B8E)],
    [Color(0xFFFFA940), Color(0xFFC96A00)],
    [Color(0xFF5B8DEF), Color(0xFF2E5BB8)],
    [Color(0xFFE066C4), Color(0xFF9C2E82)],
  ];

  String get _initials {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    return words.take(2).map((w) => w[0].toUpperCase()).join();
  }

  List<Color> get _palette {
    final sum = name.codeUnits.fold<int>(0, (a, b) => a + b);
    return _palettes[sum % _palettes.length];
  }

  Widget _initialsAvatar(double size) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _palette,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials.isEmpty ? '?' : _initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: (size * 0.34).clamp(11.0, 34.0),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : (constraints.maxHeight.isFinite ? constraints.maxHeight : 96.0);

        final localAsset = artistPhotoAssetFor(name);

        return ClipOval(
          child: localAsset != null
              ? Image.asset(
                  localAsset,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => _initialsAvatar(size),
                )
              : (fallbackImageUrl != null && fallbackImageUrl!.isNotEmpty)
                  ? Image.network(
                      fallbackImageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (_, __, ___) => _initialsAvatar(size),
                    )
                  : _initialsAvatar(size),
        );
      },
    );
  }
}