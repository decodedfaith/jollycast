import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/auth_viewmodel.dart';
import 'login_screen.dart';
import 'podcast_list_screen.dart';

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
    _initApp();
  }

  Future<void> _initApp() async {
    // Wait for animations and minimum splash time
    await Future.delayed(const Duration(seconds: 4));

    if (!mounted) return;

    // Check authentication status
    final user = await ref.read(authViewModelProvider.future);

    if (!mounted) return;

    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PodcastListScreen()),
      );
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
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
      backgroundColor: const Color(0xFF4CD964),
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
                  Image.asset("assets/icons/jollyIcon.png"),
                  SizedBox(height: 340),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF003334).withOpacity(0.6),
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

  SplashBackgroundPainter({
    this.entranceValue = 1.0,
    this.circleScale = 1.0,
    this.pulseValue = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final Color bgLime = const Color(0xFF32D74B);
    final Color darkTeal = const Color(0xFF002323);

    canvas.drawRect(Offset.zero & size, Paint()..color = bgLime);

    final shapePaint = Paint()
      ..color = darkTeal
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
