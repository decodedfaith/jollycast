import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'onboarding_screen.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_assets.dart';
import '../widgets/common/jolly_button.dart';
import '../widgets/common/jolly_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late VideoPlayerController _videoController;
  final PageController _pageController = PageController();
  final _phoneController = TextEditingController(text: '08114227399');
  final _otpController = TextEditingController();

  bool _isVideoInitialized = false;
  bool _usePassword = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.asset(AppAssets.loginBgVideo);
    await _videoController.initialize();
    _videoController.setLooping(true);
    _videoController.play();
    if (mounted) {
      setState(() {
        _isVideoInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _pageController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _handlePhoneSubmit() {
    if (_phoneController.text.isNotEmpty) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleOtpSubmit() {
    final password = _usePassword
        ? _otpController.text.trim()
        : 'Development@101';

    ref
        .read(authViewModelProvider.notifier)
        .login(_phoneController.text.trim(), password);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AsyncValue>(authViewModelProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error.toString())));
      } else if (next is AsyncData && next.value != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Video Background
          if (_isVideoInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            )
          else
            Image.asset(
              AppAssets.loginBgImage,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          // Overlay to darken video slightly
          Container(color: Colors.black.withAlpha(102)),

          // Content
          SafeArea(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [_buildPhoneStep(), _buildOtpStep(authState.isLoading)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Image.asset(AppAssets.logo, height: 80),
          const SizedBox(height: 24),
          const Text(
            AppStrings.loginTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 90),
          // const Spacer(),
          JollyTextField(
            controller: _phoneController,
            hintText: AppStrings.enterPhoneNumber,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.flag,
          ),
          const SizedBox(height: 20),
          JollyButton(
            text: AppStrings.continueText,
            onPressed: _handlePhoneSubmit,
          ),
          const SizedBox(height: 16),
          const Text(
            AppStrings.agreeToTerms,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.normal,
              decorationColor: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {},
            child: const Text(
              AppStrings.becomeCreator,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildOtpStep(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Image.asset(AppAssets.logo, height: 60),
          const SizedBox(height: 24),
          Text(
            _usePassword
                ? '${AppStrings.enterPasswordFor}${_phoneController.text}'
                : '${AppStrings.enterCodeSentTo}${_phoneController.text}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const Spacer(),
          JollyTextField(
            controller: _otpController,
            hintText: _usePassword
                ? AppStrings.enterPassword
                : AppStrings.enterCode,
            keyboardType: _usePassword
                ? TextInputType.text
                : TextInputType.number,
            isPassword: _usePassword,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                AppStrings.usePassword,
                style: TextStyle(color: AppColors.textPrimary),
              ),
              Switch(
                value: _usePassword,
                onChanged: (value) {
                  setState(() {
                    _usePassword = value;
                    _otpController.clear();
                  });
                },
                activeThumbColor: AppColors.secondary,
              ),
            ],
          ),
          const SizedBox(height: 20),
          JollyButton(
            text: AppStrings.continueText,
            onPressed: isLoading ? null : _handleOtpSubmit,
            isLoading: isLoading,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
