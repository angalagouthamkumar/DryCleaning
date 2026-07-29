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

class AppRouter {
  static const String initialRoute = '/splash';

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
    };
  }
}
