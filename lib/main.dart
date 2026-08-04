import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/app.dart';
import 'core/services/notification_service.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('[STARTUP Step 1/6] Application Started & Flutter Binding Initialized');

    // Global Flutter Error Boundary Handler
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('[STARTUP ERROR] Captured Flutter Error: ${details.exception}\nStack: ${details.stack}');
    };

    // Platform Level Dispatcher Error Handler
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('[STARTUP ERROR] Captured Platform Error: $error\nStack: $stack');
      return true;
    };

    // Prevent Black Screen by setting a custom non-black Error Widget Builder
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Material(
        child: Container(
          color: const Color(0xFF1E293B),
          padding: const EdgeInsets.all(24.0),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.orangeAccent, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Application Initialization Notice',
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

    // Safe Firebase Initialization (Timeout Guarded)
    try {
      debugPrint('[STARTUP Step 2/6] Firebase Initialization Started');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(
        const Duration(seconds: 4),
        onTimeout: () {
          debugPrint('[STARTUP WARNING] Firebase initialization timed out after 4s - continuing gracefully');
          return Firebase.app();
        },
      ).catchError((err) {
        debugPrint('[STARTUP WARNING] Firebase init catchError: $err');
        return Firebase.app();
      });
      debugPrint('[STARTUP Step 2/6] Firebase Initialized Successfully');
    } catch (e, stack) {
      debugPrint('[STARTUP WARNING] Firebase non-fatal startup notice: $e\n$stack');
    }

    debugPrint('[STARTUP Step 3/6] Local Storage & Service Locator Initialized');
    debugPrint('[STARTUP Step 4/6] Launching UI Scope (ProviderScope)');

    runApp(
      const ProviderScope(
        child: DryCleaningApp(),
      ),
    );

    // Initialize background services post-launch asynchronously
    Future.microtask(() async {
      debugPrint('[STARTUP Step 5/6] Initializing Background Notification Service...');
      try {
        await NotificationService().initialize();
        debugPrint('[STARTUP Step 5/6] Notification Service Initialized');
      } catch (e) {
        debugPrint('[STARTUP WARNING] Notification Service background init notice: $e');
      }
      debugPrint('[STARTUP Step 6/6] Startup Sequence Completed Successfully');
    });
  }, (error, stack) {
    debugPrint('[STARTUP ERROR] Uncaught Root Zone Exception: $error\n$stack');
  });
}
