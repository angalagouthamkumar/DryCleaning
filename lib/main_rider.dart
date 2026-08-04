import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'app/router.dart';
import 'core/services/notification_service.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('[STARTUP Step 1/6] Rider App Launch Initiated & Flutter Binding Initialized');

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('[STARTUP ERROR] Captured Rider App Flutter Error: ${details.exception}\n${details.stack}');
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('[STARTUP ERROR] Captured Rider App Platform Error: $error\n$stack');
      return true;
    };

    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Material(
        child: Container(
          color: const Color(0xFF0F172A),
          padding: const EdgeInsets.all(24.0),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.two_wheeler_rounded, color: Color(0xFF00E5FF), size: 48),
              const SizedBox(height: 16),
              const Text(
                'Rider App Starting Up...',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${details.exception}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    };

    // Safe Firebase Init
    try {
      debugPrint('[STARTUP Step 2/6] Rider App Firebase Initialization Started');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(
        const Duration(seconds: 4),
        onTimeout: () {
          debugPrint('[STARTUP WARNING] Rider App Firebase init timed out after 4s');
          return Firebase.app();
        },
      ).catchError((err) {
        debugPrint('[STARTUP WARNING] Rider App Firebase catchError: $err');
        return Firebase.app();
      });
      debugPrint('[STARTUP Step 2/6] Firebase Initialized Successfully');
    } catch (e, stack) {
      debugPrint('[STARTUP WARNING] Firebase initialization non-fatal exception: $e\n$stack');
    }

    debugPrint('[STARTUP Step 3/6] Local Storage & Service Locator Initialized');
    debugPrint('[STARTUP Step 4/6] Launching Rider UI Scope');

    runApp(
      const ProviderScope(
        child: RiderApp(),
      ),
    );

    Future.microtask(() async {
      debugPrint('[STARTUP Step 5/6] Initializing background notification service...');
      try {
        await NotificationService().initialize();
        debugPrint('[STARTUP Step 5/6] Background Notification Service Initialized');
      } catch (e) {
        debugPrint('[STARTUP WARNING] Notification Service background init error: $e');
      }
      debugPrint('[STARTUP Step 6/6] Rider App Startup Complete');
    });
  }, (error, stack) {
    debugPrint('[STARTUP ERROR] Uncaught Rider App Zone Exception: $error\n$stack');
  });
}

class RiderApp extends StatelessWidget {
  const RiderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DryCleaning Partner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/rider-splash',
      routes: AppRouter.routes,
    );
  }
}
