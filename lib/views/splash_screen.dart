import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'onboarding_screen.dart';
import 'podcast_list_screen.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_assets.dart';
import '../models/user_model.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _pulseController;

  late Animation<double> _circleScale;
  late Animation<double> _stripeSlide;
  late Animation<double> _logoOpacity;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _circleScale = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    );

    _stripeSlide = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeInOutCubic),
    );

    _logoOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _entranceController.forward();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for animations and minimum splash time
    await Future.delayed(const Duration(seconds: 4));

    if (!mounted) return;

    // Watch the provider to ensure we get the latest state
    final authState = ref.read(authViewModelProvider);

    // If still loading, we might need to wait (though 4 seconds is usually enough)
    // Ideally, we should listen to the provider.
    if (authState.isLoading) {
      // Simple polling or listening could work, but let's just check value.
      // If it's loading, it means we haven't determined auth yet.
      // Let's listen for the next state change if it's loading.
      ref.listenManual(authViewModelProvider, (previous, next) {
        if (!next.isLoading && mounted) {
          _navigateBasedOnAuth(next.value);
        }
      });
      return;
    }

    _navigateBasedOnAuth(authState.value);
  }

  void _navigateBasedOnAuth(User? user) {
    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PodcastListScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([
              _entranceController,
              _pulseController,
            ]),
            builder: (context, child) {
              return CustomPaint(
                painter: SplashBackgroundPainter(
                  entranceValue: _stripeSlide.value,
                  circleScale: _circleScale.value,
                  pulseValue: _pulseController.value,
                  color: AppColors.primary,
                ),
                size: Size.infinite,
              );
            },
          ),

          FadeTransition(
            opacity: _logoOpacity,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    AppAssets.logoIcon,
                    // height: 80,
                    // width: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  // Text(
                  //   AppStrings.appName.toUpperCase(),
                  //   style: GoogleFonts.dmSans(
                  //     fontSize: 42,
                  //     fontWeight: FontWeight.w900,
                  //     color: AppColors.primary,
                  //     letterSpacing: 1.2,
                  //   ),
                  // ),
                  const SizedBox(height: 340), // Spacing from original design
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SplashBackgroundPainter extends CustomPainter {
  final double entranceValue;
  final double circleScale;
  final double pulseValue;
  final Color color;

  SplashBackgroundPainter({
    this.entranceValue = 1.0,
    this.circleScale = 1.0,
    this.pulseValue = 0.0,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Draw background (optional if Scaffold has it, but good for completeness)
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.splashBackground,
    );

    final shapePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final double baseRadius = w * 0.49;
    final double currentRadius =
        (baseRadius + (3.0 * pulseValue)) * circleScale;

    final Offset circleCenter = Offset(w * 0.89, h * 0.83);

    final circlePath = Path();
    circlePath.addOval(
      Rect.fromCircle(center: circleCenter, radius: currentRadius),
    );

    final clawsPath = Path();

    final double slideX = -w * 0.3 * (1.0 - entranceValue);
    final double slideY = -h * 0.15 * (1.0 - entranceValue);
    final Offset slideOffset = Offset(slideX, slideY);

    final double groupOffsetX = 0.0;
    final double groupOffsetY = 0.0;

    final double strandOffsetX = w * 0.05;
    final double strandOffsetY = h * 0.13;

    Path createBaseClaw() {
      final path = Path();
      path.moveTo(0, h * 0.47);
      path.cubicTo(w * 0.2, h * 0.5, w * 0.48, h * 0.59, w * 0.65, h * 0.76);
      path.lineTo(w * 1, h * 0.93);
      path.cubicTo(w * 0.40, h * 0.79, w * 0.350, h * 0.55, 0, h * 0.475);
      path.close();
      return path;
    }

    final baseClaw = createBaseClaw();

    final s1 = baseClaw.shift(Offset(groupOffsetX, groupOffsetY));
    clawsPath.addPath(s1.shift(slideOffset), Offset.zero);

    final s2 = baseClaw.shift(
      Offset(
        groupOffsetX + (strandOffsetX * 15),
        groupOffsetY + (strandOffsetY * 0.72),
      ),
    );
    clawsPath.addPath(s2.shift(slideOffset), Offset.zero);

    final s3 = baseClaw.shift(
      Offset(
        groupOffsetX + (strandOffsetX * 5.8),
        groupOffsetY + (strandOffsetY * 0.1),
      ),
    );
    clawsPath.addPath(s3.shift(slideOffset), Offset.zero);

    final combinedPath = Path.combine(PathOperation.xor, circlePath, clawsPath);

    canvas.drawPath(combinedPath, shapePaint);
  }

  @override
  bool shouldRepaint(covariant SplashBackgroundPainter oldDelegate) {
    return oldDelegate.entranceValue != entranceValue ||
        oldDelegate.circleScale != circleScale ||
        oldDelegate.pulseValue != pulseValue;
  }
}
