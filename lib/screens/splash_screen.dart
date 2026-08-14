import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_background_painter.dart';
import '../widgets/aipe_logo.dart';
import 'main_navigation_screen.dart';

/// SplashScreen implements Phase 1 of AIPE LAB.
/// Features a student-friendly, modern, AI-inspired educational design
/// with smooth staggered entrance animations and automatic navigation to MainNavigationScreen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;

  // Staggered Animations
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subjectFade;
  late Animation<double> _badgeFade;
  late Animation<Offset> _badgeSlide;
  late Animation<double> _loaderFade;

  bool _isNavigated = false;

  @override
  void initState() {
    super.initState();

    // 1. Initialize Main Entrance Animation Controller (2.4 seconds total)
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // 2. Initialize Continuous Ambient Pulse Controller (Background & Loader)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // 3. Configure Staggered Animation Intervals
    // Logo entrance (0ms to 800ms)
    _logoScale = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
      ),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.40, curve: Curves.easeIn),
      ),
    );

    // App Title entrance (400ms to 1200ms)
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.20, 0.60, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.20, 0.60, curve: Curves.easeOutCubic),
      ),
    );

    // Subject Name entrance (600ms to 1600ms)
    _subjectFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
      ),
    );

    // Subject Code & Academic Info entrance (1000ms to 2000ms)
    _badgeFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.50, 0.85, curve: Curves.easeOut),
      ),
    );
    _badgeSlide = Tween<Offset>(
      begin: const Offset(0, 0.30),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.50, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    // Loading Indicator entrance (1400ms to 2400ms)
    _loaderFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.65, 1.0, curve: Curves.easeIn),
      ),
    );

    // Start Main Animation Sequence
    _mainController.forward();

    // 4. Trigger Navigation after delay (~3.6 seconds total)
    _scheduleNavigation();
  }

  void _scheduleNavigation() async {
    await Future.delayed(const Duration(milliseconds: 3600));
    if (mounted && !_isNavigated) {
      _isNavigated = true;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MainNavigationScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Stack(
        children: [
          // 1. Dynamic Neural Network Background & Ambient Lighting
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return CustomPaint(
                size: size,
                painter: AIBackgroundPainter(
                  animationValue: _pulseController.value,
                ),
              );
            },
          ),

          // 2. Main Responsive Content Layer
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20), // Top padding balance

                          // CENTER BRANDING BLOCK
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // A. App Logo with Scale & Fade Entrance
                              ScaleTransition(
                                scale: _logoScale,
                                child: FadeTransition(
                                  opacity: _logoFade,
                                  child: const AipeLogo(size: 110),
                                ),
                              ),
                              const SizedBox(height: 28),

                              // B. Main App Title ("AIPE LAB")
                              SlideTransition(
                                position: _titleSlide,
                                child: FadeTransition(
                                  opacity: _titleFade,
                                  child: Column(
                                    children: [
                                      ShaderMask(
                                        shaderCallback: (bounds) =>
                                            AppTheme.titleGradient
                                                .createShader(bounds),
                                        child: Text(
                                          'AIPE LAB',
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 38,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 3.5,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      // Decorative Cyan Accent Bar below title
                                      Container(
                                        width: 50,
                                        height: 3,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                          gradient: AppTheme.logoGradient,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // C. Subject Title ("Artificial Intelligence with Prompt Engineering")
                              FadeTransition(
                                opacity: _subjectFade,
                                child: Text(
                                  'Artificial Intelligence\nwith Prompt Engineering',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryCyan,
                                    height: 1.35,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // D. Subject Code & Branch Information Badges
                              SlideTransition(
                                position: _badgeSlide,
                                child: FadeTransition(
                                  opacity: _badgeFade,
                                  child: Column(
                                    children: [
                                      // Subject Code Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.surfaceCard,
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          border: Border.all(
                                            color: AppTheme.primaryCyan
                                                .withValues(alpha: 0.4),
                                            width: 1.0,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.primaryCyan
                                                  .withValues(alpha: 0.1),
                                              blurRadius: 12,
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.code_rounded,
                                              size: 14,
                                              color: AppTheme.primaryCyan,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'CODE: DI05016011',
                                              style: GoogleFonts.spaceGrotesk(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.textPrimary,
                                                letterSpacing: 1.2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      // Branch & Program Tag
                                      Text(
                                        'DIPLOMA • INFORMATION TECHNOLOGY',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.inter(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textSecondary,
                                          letterSpacing: 1.8,
                                        ),
                                      ),
                                      const SizedBox(height: 6),

                                      // Semester Pill
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.school_outlined,
                                            size: 12,
                                            color: AppTheme.academicGold,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '5TH SEMESTER',
                                            style: GoogleFonts.inter(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.academicGold,
                                              letterSpacing: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // BOTTOM LOADING INDICATOR & COMPANION TAGLINE
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FadeTransition(
                                opacity: _loaderFade,
                                child: Column(
                                  children: [
                                    // Custom Sleek Animated Progress Bar
                                    SizedBox(
                                      width: 140,
                                      height: 3,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(2),
                                        child: LinearProgressIndicator(
                                          backgroundColor: Colors.white
                                              .withValues(alpha: 0.1),
                                          valueColor:
                                              const AlwaysStoppedAnimation<Color>(
                                            AppTheme.primaryCyan,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // Loading Text
                                    Text(
                                      'Preparing your AIPE Lab...',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.textMuted,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Bottom Academic Companion Credit
                              Text(
                                'AIPE LAB',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary.withValues(alpha: 0.9),
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Academic Learning Companion',
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w400,
                                  color: AppTheme.textMuted.withValues(alpha: 0.8),
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
