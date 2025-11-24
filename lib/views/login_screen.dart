import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'onboarding_screen.dart';

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
    _videoController = VideoPlayerController.asset('assets/mp4/loginbg.mp4');
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
              'assets/loginbg1.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          // Overlay to darken video slightly
          Container(color: Colors.black.withOpacity(0.4)),

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
          Image.asset('assets/icons/Jolly2.png', height: 80),
          const SizedBox(height: 24),
          const Text(
            'PODCASTS FOR\nAFRICA, BY AFRICANS',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 90),
          // const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.flag,
                  color: Colors.green,
                ), // Placeholder for flag
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: 'Enter your phone number',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handlePhoneSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003334),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: const BorderSide(color: Color(0xFFA3CB43), width: 1),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const Text(
            'By proceeding, you agree to our T&C',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.normal,
              // decoration: TextDecoration.underline,
              decorationColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {},
            child: const Text(
              'BECOME A PODCAST CREATOR',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white,
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
          Image.asset('assets/icons/Jolly2.png', height: 60),
          const SizedBox(height: 24),
          Text(
            _usePassword
                ? 'Enter your password for\n${_phoneController.text}'
                : 'Enter the 6 digit code sent to your\nphone number ${_phoneController.text}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.5,
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _otpController,
              keyboardType: _usePassword
                  ? TextInputType.text
                  : TextInputType.number,
              obscureText: _usePassword,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: _usePassword ? 'Enter Password' : 'Enter code',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Use Password', style: TextStyle(color: Colors.white)),
              Switch(
                value: _usePassword,
                onChanged: (value) {
                  setState(() {
                    _usePassword = value;
                    _otpController.clear();
                  });
                },
                activeColor: const Color(0xFFA3CB43),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : _handleOtpSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003334),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: const BorderSide(color: Color(0xFFA3CB43), width: 1),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
