import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _glowController;
  late AnimationController _fadeController;

  // "She" animations
  late Animation<double> _sheSlide;
  late Animation<double> _sheFade;
  late Animation<double> _sheScale;

  // "Flow" animations
  late Animation<double> _flowSlide;
  late Animation<double> _flowFade;
  late Animation<double> _flowScale;

  // Tagline
  late Animation<double> _taglineFade;

  // Glow pulse
  late Animation<double> _glowAnimation;

  // Overall fade out
  late Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();

    // Main logo animation controller (2 seconds)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Glow pulsing
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Fade out before navigation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // "She" - slides in from left, fades in, scales up
    _sheSlide = Tween<double>(begin: -80, end: 0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );
    _sheFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    _sheScale = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    // "Flow" - slides in from right, fades in, scales up (delayed)
    _flowSlide = Tween<double>(begin: 80, end: 0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.25, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _flowFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.25, 0.6, curve: Curves.easeIn),
      ),
    );
    _flowScale = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.25, 0.7, curve: Curves.elasticOut),
      ),
    );

    // Tagline fade
    _taglineFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    // Glow animation
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Fade out
    _fadeOut = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    _glowController.repeat(reverse: true);

    // Wait for animation + display time, then navigate
    await Future.delayed(const Duration(milliseconds: 3500));
    await _fadeController.forward();
    _navigate();
  }

  void _navigate() async {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();

    // Ensure we don't route while SharedPreferences is still loading
    while (auth.isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
    }

    if (auth.isLoggedIn) {
      if (auth.isFirstTimeUser) {
        Navigator.of(context).pushReplacementNamed('/questionnaire');
      } else {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _glowController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_logoController, _glowController, _fadeController]),
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeOut,
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.splashGradient,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Glowing circle behind logo
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow effect
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary
                                    .withValues(alpha: _glowAnimation.value * 0.3),
                                blurRadius: 80,
                                spreadRadius: 30,
                              ),
                              BoxShadow(
                                color: AppColors.lavender
                                    .withValues(alpha: _glowAnimation.value * 0.2),
                                blurRadius: 100,
                                spreadRadius: 50,
                              ),
                            ],
                          ),
                        ),
                        // Flower icon
                        Opacity(
                          opacity: _sheFade.value,
                          child: Transform.scale(
                            scale: _sheScale.value,
                            child: Icon(
                              Icons.local_florist_rounded,
                              size: 80,
                              color: AppColors.primary.withValues(alpha: 0.15),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Logo text: "She" + "Flow"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // "She" - deep pink, slides from left
                        Transform.translate(
                          offset: Offset(_sheSlide.value, 0),
                          child: Opacity(
                            opacity: _sheFade.value,
                            child: Transform.scale(
                              scale: _sheScale.value,
                              child: Text(
                                'She',
                                style: GoogleFonts.poppins(
                                  fontSize: 52,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.logoShe,
                                  letterSpacing: 1,
                                  shadows: [
                                    Shadow(
                                      color: AppColors.primary.withValues(alpha: 0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // "Flow" - lavender, slides from right
                        Transform.translate(
                          offset: Offset(_flowSlide.value, 0),
                          child: Opacity(
                            opacity: _flowFade.value,
                            child: Transform.scale(
                              scale: _flowScale.value,
                              child: Text(
                                'Flow',
                                style: GoogleFonts.poppins(
                                  fontSize: 52,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.logoFlow,
                                  letterSpacing: 1,
                                  shadows: [
                                    Shadow(
                                      color: AppColors.lavender.withValues(alpha: 0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Tagline
                    Opacity(
                      opacity: _taglineFade.value,
                      child: Text(
                        'Your cycle, your rhythm ✨',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textMedium,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    // Loading dots
                    Opacity(
                      opacity: _taglineFade.value,
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
