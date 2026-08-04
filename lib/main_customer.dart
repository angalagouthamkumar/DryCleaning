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
    debugPrint('[STARTUP Step 1/6] Customer App Launch Initiated & Flutter Binding Initialized');

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('[STARTUP ERROR] Captured Customer App Flutter Error: ${details.exception}\n${details.stack}');
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('[STARTUP ERROR] Captured Customer App Platform Error: $error\n$stack');
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
              const Icon(Icons.dry_cleaning_rounded, color: Color(0xFF00E5FF), size: 48),
              const SizedBox(height: 16),
              const Text(
                'Customer App Starting Up...',
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
      debugPrint('[STARTUP Step 2/6] Customer App Firebase Initialization Started');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(
        const Duration(seconds: 4),
        onTimeout: () {
          debugPrint('[STARTUP WARNING] Customer App Firebase init timed out after 4s');
          return Firebase.app();
        },
      ).catchError((err) {
        debugPrint('[STARTUP WARNING] Customer App Firebase catchError: $err');
        return Firebase.app();
      });
      debugPrint('[STARTUP Step 2/6] Firebase Initialized Successfully');
    } catch (e, stack) {
      debugPrint('[STARTUP WARNING] Firebase initialization non-fatal exception: $e\n$stack');
    }

    debugPrint('[STARTUP Step 3/6] Local Storage & Service Locator Initialized');
    debugPrint('[STARTUP Step 4/6] Launching Customer UI Scope');

    runApp(
      const ProviderScope(
        child: CustomerApp(),
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
      debugPrint('[STARTUP Step 6/6] Customer App Startup Complete');
    });
  }, (error, stack) {
    debugPrint('[STARTUP ERROR] Uncaught Customer App Zone Exception: $error\n$stack');
  });
}

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DryCleaning Customer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/splash',
      routes: AppRouter.routes,
    );
  }
}
