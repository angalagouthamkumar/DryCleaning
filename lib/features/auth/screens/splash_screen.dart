import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/content_service.dart';
import '../../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    debugPrint('[STARTUP] Customer SplashScreen Loaded');
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    final startTime = DateTime.now();

    try {
      debugPrint('[STARTUP] Customer Auth & Content check started');
      // Fetch live content in parallel with auth check
      try {
        final dio = ref.read(dioProvider);
        ref.read(contentStateProvider.notifier).fetchLiveContent(dio);
      } catch (contentErr) {
        debugPrint('Live content fetch non-fatal notice: $contentErr');
      }

      await ref.read(authStateProvider.notifier).checkInitialAuthStatus().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint('Auth check timed out after 3s, proceeding with cached/unauthenticated state');
        },
      );

      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      if (elapsed < 1200) {
        await Future.delayed(Duration(milliseconds: 1200 - elapsed));
      }
    } catch (e, stack) {
      debugPrint('Splash screen auth check exception: $e\n$stack');
    } finally {
      _performNavigation();
    }
  }

  void _performNavigation() {
    if (_navigated || !mounted) return;
    _navigated = true;

    try {
      final authState = ref.read(authStateProvider);
      debugPrint('[STARTUP] Navigating Customer App. Auth status: ${authState.status}');

      if (authState.status == AuthStatus.authenticated) {
        final user = authState.user;
        final userName = user?['name']?.toString().trim() ?? '';
        final isOnboarded = user?['isOnboarded'] == true;
        final isRegistered = userName.isNotEmpty || isOnboarded;

        if (isRegistered) {
          Navigator.pushReplacementNamed(context, '/main');
        } else {
          Navigator.pushReplacementNamed(context, '/onboarding-details');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    } catch (navErr) {
      debugPrint('Navigation exception fallback to /onboarding: $navErr');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(contentStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.cardFill,
                  borderRadius: AppRadius.md,
                ),
                child: const Icon(
                  Icons.local_laundry_service_rounded,
                  size: 54,
                  color: AppColors.darkNavy,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                ContentService.t('customer.auth.splash_discover', 'Discover'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ContentService.t('customer.auth.splash_tagline', 'Our Fastest Drycleaning Service'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkNavy,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
