import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:Melora/core/theme/app_colors.dart';
import 'package:Melora/providers/auth_provider.dart';

/// ---------------------------------------------------------------------
/// CreateFormScreen
///
/// Opened when the user taps Playlist / Collaborative playlist / Blend
/// in the Create sheet. Each type shows a slightly different form, but
/// none of this is wired to a backend yet — there's no "create playlist"
/// API in playlist_service.dart (it's dummy-data + GET only), so the
/// primary button just shows a "coming soon" confirmation instead of
/// actually saving anything.
///
/// Once a real create-playlist endpoint exists, wire the submit button
/// to call it (e.g. via a new PlaylistRepository.createPlaylist(...))
/// and this screen won't need any other changes.
/// ---------------------------------------------------------------------

enum CreateFormType { playlist, collaborative, blend }

extension on CreateFormType {
  String get title {
    switch (this) {
      case CreateFormType.playlist:
        return 'New Playlist';
      case CreateFormType.collaborative:
        return 'New Collaborative Playlist';
      case CreateFormType.blend:
        return 'New Blend';
    }
  }

  String get nameLabel {
    switch (this) {
      case CreateFormType.playlist:
        return 'Playlist name';
      case CreateFormType.collaborative:
        return 'Playlist name';
      case CreateFormType.blend:
        return 'Blend name';
    }
  }

  String get submitLabel {
    switch (this) {
      case CreateFormType.playlist:
        return 'Create playlist';
      case CreateFormType.collaborative:
        return 'Create collaborative playlist';
      case CreateFormType.blend:
        return 'Create blend';
    }
  }
}

class CreateFormScreen extends StatefulWidget {
  final CreateFormType type;
  const CreateFormScreen({super.key, required this.type});

  @override
  State<CreateFormScreen> createState() => _CreateFormScreenState();
}

class _CreateFormScreenState extends State<CreateFormScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _inviteController = TextEditingController();
  bool _isPublic = true;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _inviteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name first')),
      );
      return;
    }
    // No backend "create" endpoint exists yet (playlist_service.dart is
    // dummy-data + GET only), so this is intentionally a placeholder.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Saving isn't wired up yet — coming soon!"),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.type;

    // Blend has its own dedicated "invite friends" screen (matches the
    // reference exactly) instead of the generic name/description form.
    if (type == CreateFormType.blend) {
      return const _BlendInviteScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(type.title, style: const TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          _FieldLabel(type.nameLabel),
          _TextInput(controller: _nameController, hint: 'e.g. Sunday Chill'),
          const SizedBox(height: 20),
          const _FieldLabel('Description (optional)'),
          _TextInput(
            controller: _descriptionController,
            hint: 'Add an optional description',
            maxLines: 3,
          ),
          if (type == CreateFormType.playlist) ...[
            const SizedBox(height: 20),
            _PublicToggle(
              isPublic: _isPublic,
              onChanged: (value) => setState(() => _isPublic = value),
            ),
          ],
          if (type == CreateFormType.collaborative) ...[
            const SizedBox(height: 20),
            const _FieldLabel('Invite friends'),
            _TextInput(
              controller: _inviteController,
              hint: 'Enter usernames or emails, comma separated',
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                type.submitLabel,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _TextInput({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

class _PublicToggle extends StatelessWidget {
  final bool isPublic;
  final ValueChanged<bool> onChanged;

  const _PublicToggle({required this.isPublic, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Make playlist public',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          Switch(
            value: isPublic,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
/// ---------------------------------------------------------------------
/// "Create a Blend" — invite screen shown when the user picks Blend
/// from the Create sheet. Matches the reference exactly: two
/// overlapping avatar circles, a headline, an explanatory note, and a
/// white "Invite" pill. Actual invite-link generation isn't wired to a
/// backend yet, so tapping Invite just confirms with a SnackBar.
/// ---------------------------------------------------------------------
class _BlendInviteScreen extends ConsumerWidget {
  const _BlendInviteScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final username = (user != null && user.username.trim().isNotEmpty)
        ? user.username.trim()
        : 'Guest';
    final initial = username.isEmpty ? 'G' : username[0].toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Create a Blend',
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 32),
              SizedBox(
                width: 116,
                height: 92,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      child: Container(
                        width: 92,
                        height: 92,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [AppColors.primary, Color(0xFF8A6BFF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 22),
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: Container(
                        width: 92,
                        height: 92,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF2A2A32),
                        ),
                        alignment: Alignment.center,
                        child: const Padding(
                          padding: EdgeInsets.only(left: 22),
                          child: Icon(Icons.add_rounded, color: Colors.white70, size: 34),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Invite friends to Blend',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Invite up to 10 friends to a Blend, a shared playlist that gives '
                'you social recommendations based on all of your music tastes.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14.5, height: 1.5),
              ),
              const SizedBox(height: 16),
              Text.rich(
                TextSpan(
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12.5, height: 1.5),
                  children: const [
                    TextSpan(
                      text: 'Note: People in this Blend will be able to add their friends. '
                          "We may also create other playlists that include social "
                          "recommendations. People in social recommendations playlists "
                          "will be able to see your profile picture and username. ",
                    ),
                    TextSpan(
                      text: 'Learn more',
                      style: TextStyle(
                        color: Colors.white70,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    TextSpan(text: ' about these playlists and information they include.'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 160,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invite link copied!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Invite',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}