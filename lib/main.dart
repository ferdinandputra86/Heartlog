import 'package:flutter/material.dart';
import 'package:heartlog/screens/index.dart';
import 'package:heartlog/constants/index.dart';
import 'package:flutter/foundation.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Preload diary entries
  try {
    // Initialize DiaryStorageService
    // Service is automatically initialized when first accessed
    if (kDebugMode) {
      print('Diary entries service initialized');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error initializing diary entries: $e');
    }
  }
  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.backgroundVariant,
        fontFamily: 'NunitoSans',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 30,
          ),
          displayMedium: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 24,
          ),
          titleLarge: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.primaryLight,
          surface: AppColors.white,
          background: AppColors.backgroundVariant,
        ),
      ),
      home: const SplashScreen(),
      routes: {'/write': (context) => const WriteScreen()},
    );
  }
}
