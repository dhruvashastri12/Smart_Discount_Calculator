import 'package:flutter/foundation.dart'; // Required for PlatformDispatcher
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/main_navigation/presentation/screens/main_navigation_screen.dart';
import 'core/services/data_service.dart';
import 'core/constants/app_strings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart'; // This is the file the wizard just generated!

/// Entry point of the application.
/// Initializes app services and runs the root widget.
void main() async {
  // Required for accessing platform services like SharedPreferences during startup
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize persistence and data management
  await dataService.init();

  // Initialize Firebase using the auto-generated configurations
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 1. Pass all unhandled asynchronous errors to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // 2. Pass all unhandled Flutter framework UI errors to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(const AntigravityFirstSyncApp());
}

/// Global notifier for managing the application's theme mode (Light/Dark).
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

/// Root widget of the Smart Discount Calculator application.
class AntigravityFirstSyncApp extends StatelessWidget {
  const AntigravityFirstSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentMode, _) {
        return MaterialApp(
          // Fetch application title from centralized string file
          title: AppStrings.appName,

          // Use centralized theme definitions
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,

          // Set main navigation screen as the root screen
          home: const MainNavigationScreen(),

          // Remove debug banner for a cleaner premium look
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
