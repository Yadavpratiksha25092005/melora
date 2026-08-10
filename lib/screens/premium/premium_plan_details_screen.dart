import 'package:flutter/material.dart';

import 'package:Melora/core/theme/app_colors.dart';

/// ---------------------------------------------------------------------
/// PremiumPlanDetailsScreen
///
/// Opened when the user taps "Get Premium Standard" on the Premium
/// tab. Shows the plan's price breakdown, what's included, and billing
/// terms before confirming. Swap `_onConfirm` for your real purchase
/// flow once payments are wired up.
/// ---------------------------------------------------------------------
class PremiumPlanDetailsScreen extends StatelessWidget {
  const PremiumPlanDetailsScreen({super.key});

  static const List<_FeatureData> _features = [
    _FeatureData(icon: Icons.volume_off_rounded, label: 'Ad-free music listening'),
    _FeatureData(icon: Icons.shuffle_rounded, label: 'Play songs in any order'),
    _FeatureData(icon: Icons.headphones_rounded, label: 'Very high audio quality'),
    _FeatureData(icon: Icons.download_rounded, label: 'Download to listen offline'),
    _FeatureData(icon: Icons.devices_rounded, label: 'Listen on any device'),
  ];

  void _onConfirm(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Starting Premium checkout…'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Premium Standard', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF3A2C7A), Color(0xFF121016)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
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
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '12 months of Premium Standard',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '₹799 total · billed once · then ₹119/month',
                    style: TextStyle(color: Colors.white60, fontSize: 13),
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
                        Icon(Icons.notifications_active_outlined, color: AppColors.primary, size: 16),
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
            const SizedBox(height: 24),
            const Text(
              "What's included",
              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < _features.length; i++) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: _FeatureRow(data: _features[i]),
                    ),
                    if (i != _features.length - 1)
                      Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Billing terms',
              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            const Text(
              'You\'ll be charged ₹799 for the first 12 months. After that, the plan '
              'renews automatically at ₹119/month until cancelled. You can cancel '
              'anytime from your account settings.',
              style: TextStyle(color: Colors.white38, fontSize: 12.5, height: 1.5),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _onConfirm(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text(
                  'Confirm ₹799',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
        Icon(data.icon, color: Colors.white, size: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            data.label,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}