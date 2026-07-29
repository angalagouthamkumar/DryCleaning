import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'router.dart';

class DryCleaningApp extends StatelessWidget {
  const DryCleaningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DryCleaning App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRouter.initialRoute,
      routes: AppRouter.routes,
    );
  }
}
