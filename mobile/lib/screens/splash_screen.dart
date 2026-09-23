import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();
    _startTimer();
  }

  void _startTimer() {
    Timer(const Duration(milliseconds: 2300), () {
      if (!mounted) return;
      _navigateToHome();
    });
  }

  void _navigateToHome() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    // If still loading data, wait a tiny bit more
    if (provider.isLoading) {
      Timer(const Duration(milliseconds: 400), _navigateToHome);
      return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainTabNavigator(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0A101D) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF111B2D) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Background ambient gradient glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF0D9488).withOpacity(isDark ? 0.25 : 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFF59E0B).withOpacity(isDark ? 0.20 : 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Center Animated Content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ornate Emblem Icon
                      Container(
                        width: 108,
                        height: 108,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF0D9488),
                              Color(0xFF14B8A6),
                              Color(0xFF0F766E),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0D9488).withOpacity(0.4),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xFFF59E0B).withOpacity(0.6),
                            width: 2.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          size: 52,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Arabic Title
                      const Text(
                        'أَلْفُ حَدِيثٍ وَحَدِيثٌ',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF14B8A6),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Gold Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withOpacity(0.16),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFF59E0B).withOpacity(0.45),
                            width: 1.2,
                          ),
                        ),
                        child: const Text(
                          '1001 AUTHENTIC HADITH',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFF59E0B),
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Subtitle
                      Text(
                        'Thematic Compendium of Prophetic Traditions',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Compiler Attribution Card
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.06)
                                : Colors.black.withOpacity(0.06),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified_rounded,
                              size: 16,
                              color: Color(0xFF14B8A6),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Compiled by Ibrahim Sharif Abubakar',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Loading Indicator & Edition Tag
          Positioned(
            bottom: 36,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '1st Edition (2026) • Verified via Maktaba Shamela',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
