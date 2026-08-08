import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:Melora/core/routes/route_names.dart';
import 'package:Melora/core/theme/app_colors.dart';
import 'package:Melora/core/theme/text_styles.dart';
import 'package:Melora/core/utils/validators.dart';
import 'package:Melora/providers/auth_provider.dart';
import 'package:Melora/features/onboarding/provider/onboarding_provider.dart';
import 'package:Melora/features/onboarding/widgets/common/app_text_field.dart';
import 'package:Melora/features/onboarding/widgets/common/primary_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _submitSendOtp() async {
    if (!_phoneFormKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).sendOtp(phone: _phoneController.text.trim());
  }

  Future<void> _submitVerifyOtp() async {
    if (!_otpFormKey.currentState!.validate()) return;
    final success = await ref.read(authProvider.notifier).verifyOtp(
          phone: _phoneController.text.trim(),
          otp: _otpController.text.trim(),
        );
    if (success && mounted) {
      final name = _nameController.text.trim();
      if (name.isNotEmpty) {
        // Fire-and-continue: save the name entered on this screen, but
        // don't block navigation on it — failing to save the name
        // shouldn't stop the user from getting into the app.
        await ref.read(authProvider.notifier).updateProfile(username: name);
      }
      if (!mounted) return;
      final onboardingDone = await ref.read(onboardingCompleteProvider.future);
      if (!mounted) return;
      context.go(onboardingDone ? RouteNames.home : RouteNames.onboardingWelcome);
    }
  }

  void _changeNumber() {
    ref.read(authProvider.notifier).resetOtpFlow();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 64),
              Text('Welcome back', style: AppTextStyles.heading1),
              const SizedBox(height: 8),
              Text(
                authState.otpSent ? 'Enter the code sent to your phone' : 'Log in with your name and phone number',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 32),
              if (!authState.otpSent)
                Form(
                  key: _phoneFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        controller: _nameController,
                        label: 'Name',
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name cannot be empty';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _phoneController,
                        label: 'Phone number',
                        keyboardType: TextInputType.phone,
                        validator: Validators.phone,
                      ),
                      if (authState.error != null) ...[
                        const SizedBox(height: 12),
                        Text(authState.error!, style: const TextStyle(color: AppColors.error)),
                      ],
                      const SizedBox(height: 24),
                      PrimaryButton(label: 'Send OTP', isLoading: authState.isLoading, onPressed: _submitSendOtp),
                    ],
                  ),
                )
              else
                Form(
                  key: _otpFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_phoneController.text, style: AppTextStyles.body),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _otpController,
                        label: 'OTP (hint: 123456)',
                        keyboardType: TextInputType.number,
                        validator: Validators.otp,
                      ),
                      if (authState.error != null) ...[
                        const SizedBox(height: 12),
                        Text(authState.error!, style: const TextStyle(color: AppColors.error)),
                      ],
                      const SizedBox(height: 24),
                      PrimaryButton(label: 'Verify & Log In', isLoading: authState.isLoading, onPressed: _submitVerifyOtp),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: _changeNumber,
                          child: const Text('Change phone number', style: TextStyle(color: AppColors.textSecondary)),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}