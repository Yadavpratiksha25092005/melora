import 'package:flutter/material.dart';

import 'package:Melora/core/theme/app_colors.dart';
import 'package:Melora/screens/premium/premium_plan_details_screen.dart';

/// ---------------------------------------------------------------------
/// NOTE
/// Layout follows the reference screenshot (collage hero header with
/// logo + headline + price + CTA, then a "Why join Premium?" feature
/// list) using Melora branding and your existing dark theme. The hero
/// background uses a purple/cyan gradient + a few blurred poster tiles
/// instead of copying real album art. Swap `_planPriceLabel` and the
/// feature list for your actual plan data, and hook `_onSubscribeTap`
/// up to your real purchase flow.
/// ---------------------------------------------------------------------

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  static const List<_FeatureData> _features = [
    _FeatureData(icon: Icons.volume_off_rounded, label: 'Ad-free music listening'),
    _FeatureData(icon: Icons.shuffle_rounded, label: 'Play songs in any order'),
    _FeatureData(icon: Icons.headphones_rounded, label: 'Very high audio quality'),
    _FeatureData(icon: Icons.download_rounded, label: 'Download to listen offline'),
    _FeatureData(icon: Icons.devices_rounded, label: 'Listen on any device'),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: _PremiumHero()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PremiumPlanDetailsScreen()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Get Premium Standard',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Text(
                  'Limited time offer. Limited eligibility. See other plans below.',
                  style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.5),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Why join Premium?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      for (int i = 0; i < _features.length; i++) ...[
                        _FeatureRow(data: _features[i]),
                        if (i != _features.length - 1)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Hero header: collage-style background + Melora logo + headline + price
/// ---------------------------------------------------------------------
class _PremiumHero extends StatelessWidget {
  const _PremiumHero();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 430,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Abstract poster-collage backdrop (gradient tiles, not real
          // album art) tilted slightly for visual interest.
          ClipRect(
            child: Transform.scale(
              scale: 1.15,
              child: Transform.rotate(
                angle: -0.05,
                child: const Row(
                  children: [
                    Expanded(child: _CollageTile(colors: [Color(0xFF6E11B0), Color(0xFF1A0730)])),
                    Expanded(child: _CollageTile(colors: [Color(0xFF2E7D32), Color(0xFF0D2B10)])),
                    Expanded(child: _CollageTile(colors: [Color(0xFF1E3A8A), Color(0xFF0A1230)])),
                    Expanded(child: _CollageTile(colors: [Color(0xFFB05A2E), Color(0xFF2A1608)])),
                  ],
                ),
              ),
            ),
          ),
          // Fade to the screen background at the bottom so it blends
          // into the rest of the page.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    AppColors.background.withValues(alpha: 0.55),
                    AppColors.background,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF00D9F5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Melora Premium',
                      style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Get 12 months of\nPremium Standard at',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '₹799',
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications_active_outlined,
                          color: AppColors.primary, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Limited time offer',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CollageTile extends StatelessWidget {
  final List<Color> colors;
  const _CollageTile({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Feature row: icon + label
/// ---------------------------------------------------------------------
class _FeatureData {
  final IconData icon;
  final String label;

  const _FeatureData({required this.icon, required this.label});
}

class _FeatureRow extends StatelessWidget {
  final _FeatureData data;
  const _FeatureRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(data.icon, color: Colors.white, size: 22),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            data.label,
            style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}