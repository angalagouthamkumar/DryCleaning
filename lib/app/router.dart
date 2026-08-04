import 'package:flutter/material.dart';
import '../core/navigation/main_wrapper.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/welcome_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/otp_screen.dart';
import '../features/auth/screens/customer_onboarding_screen.dart';
import '../features/auth/screens/location_permission_screen.dart';
import '../features/search/screens/search_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/rider/screens/rider_splash_screen.dart';
import '../features/rider/screens/rider_login_screen.dart';
import '../features/rider/screens/rider_otp_screen.dart';
import '../features/rider/screens/rider_main_screen.dart';
import '../features/rider/screens/rider_task_detail_screen.dart';

class AppRouter {
  static const String initialRoute = '/rider-splash';

  static Map<String, WidgetBuilder> get routes {
    return {
      '/splash': (context) => const SplashScreen(),
      '/onboarding': (context) => const WelcomeScreen(),
      '/login': (context) => const LoginScreen(),
      '/otp': (context) {
        final phoneNumber = ModalRoute.of(context)?.settings.arguments as String? ?? '';
        return OtpScreen(phoneNumber: phoneNumber);
      },
      '/onboarding-details': (context) => const CustomerOnboardingScreen(),
      '/location': (context) => const LocationPermissionScreen(),
      '/main': (context) => const MainWrapper(),
      '/search': (context) => const SearchScreen(),
      '/profile': (context) => const ProfileScreen(),

      '/rider-splash': (context) => const RiderSplashScreen(),
      '/rider-login': (context) => const RiderLoginScreen(),
      '/rider-otp': (context) => const RiderOtpScreen(),
      '/rider-main': (context) => const RiderMainScreen(),
      '/rider-task-detail': (context) {
        final raw = ModalRoute.of(context)?.settings.arguments;
        Map<String, dynamic> orderMap = {};
        if (raw is Map) {
          orderMap = Map<String, dynamic>.from(raw);
        }
        return RiderTaskDetailScreen(order: orderMap);
      },
    };
  }
}
