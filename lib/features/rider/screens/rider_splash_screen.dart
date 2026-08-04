import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/rider_responsive_wrapper.dart';

class RiderSplashScreen extends StatefulWidget {
  const RiderSplashScreen({super.key});

  @override
  State<RiderSplashScreen> createState() => _RiderSplashScreenState();
}

class _RiderSplashScreenState extends State<RiderSplashScreen> {
  final _storage = const FlutterSecureStorage();
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    debugPrint('[STARTUP] Rider SplashScreen Loaded');
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    final startTime = DateTime.now();
    bool isLoggedIn = false;

    try {
      debugPrint('[STARTUP] Checking Rider authentication status');
      final val = await _storage.read(key: 'rider_is_logged_in').timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint('Rider storage read timed out after 3s');
          return null;
        },
      );
      isLoggedIn = (val == 'true');
    } catch (e, stack) {
      debugPrint('Rider splash auth check exception: $e\n$stack');
    } finally {
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      if (elapsed < 1200) {
        await Future.delayed(Duration(milliseconds: 1200 - elapsed));
      }
      _performNavigation(isLoggedIn);
    }
  }

  void _performNavigation(bool isLoggedIn) {
    if (_navigated || !mounted) return;
    _navigated = true;

    try {
      debugPrint('[STARTUP] Navigating Rider App. Is Logged In: $isLoggedIn');
      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/rider-main');
      } else {
        Navigator.pushReplacementNamed(context, '/rider-login');
      }
    } catch (navErr) {
      debugPrint('Rider navigation exception fallback to /rider-login: $navErr');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/rider-login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RiderResponsiveWrapper(
      child: Scaffold(
        backgroundColor: AppColors.darkNavy,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.two_wheeler_rounded,
                  size: 54,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'DRY CLEANING RIDER',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'PARTNER APP',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
