import 'package:flutter/material.dart';

import 'package:Melora/core/theme/app_colors.dart';

/// ---------------------------------------------------------------------
/// ManageStorageScreen
///
/// Shows a simple breakdown of what's using storage (downloaded songs,
/// cached artwork/streams, app data) with a "Clear cache" action.
/// ---------------------------------------------------------------------
class ManageStorageScreen extends StatefulWidget {
  const ManageStorageScreen({super.key});

  @override
  State<ManageStorageScreen> createState() => _ManageStorageScreenState();
}

class _ManageStorageScreenState extends State<ManageStorageScreen> {
  double _cacheMb = 128;
  final double _downloadsMb = 340;
  final double _appDataMb = 42;

  double get _totalMb => _cacheMb + _downloadsMb + _appDataMb;

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1C1C24),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _clearCache() {
    setState(() => _cacheMb = 0);
    _showSnack('Cache cleared');
  }

  String _fmt(double mb) => mb >= 1024 ? '${(mb / 1024).toStringAsFixed(1)} GB' : '${mb.toStringAsFixed(0)} MB';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Manage storage', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Total used: ${_fmt(_totalMb)}',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 10,
                child: Row(
                  children: [
                    Expanded(
                      flex: _downloadsMb.round().clamp(1, 100000),
                      child: Container(color: AppColors.primary),
                    ),
                    Expanded(
                      flex: _cacheMb.round().clamp(1, 100000),
                      child: Container(color: AppColors.accent),
                    ),
                    Expanded(
                      flex: _appDataMb.round().clamp(1, 100000),
                      child: Container(color: Colors.white24),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _StorageRow(color: AppColors.primary, label: 'Downloaded songs', value: _fmt(_downloadsMb)),
            _StorageRow(color: AppColors.accent, label: 'Cache (streams & artwork)', value: _fmt(_cacheMb)),
            _StorageRow(color: Colors.white24, label: 'App data', value: _fmt(_appDataMb)),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _cacheMb == 0 ? null : _clearCache,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white38),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: Text(_cacheMb == 0 ? 'Cache cleared' : 'Clear cache'),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Downloaded songs stay on your device — clearing cache only removes temporary streaming and artwork data.',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _StorageRow extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _StorageRow({required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14))),
          Text(value, style: const TextStyle(color: Colors.white54, fontSize: 13)),
        ],
      ),
    );
  }
}