import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/nlp_api_service.dart';
import 'services/progress_storage_service.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system status bar & navigation bar to transparent dark
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.bgDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize storage & trigger silent background Render backend warm-up without blocking runApp
  ProgressStorageService.initialize();
  NlpApiService.warmupBackend();

  runApp(const AipeLabApp());
}

/// AipeLabApp is the main root widget for the AIPE LAB educational app.
class AipeLabApp extends StatelessWidget {
  const AipeLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIPE LAB',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
