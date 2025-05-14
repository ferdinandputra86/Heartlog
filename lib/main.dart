import 'package:flutter/material.dart';
import 'package:heartlog/splash.dart';
import 'package:heartlog/diary_storage.dart';
import 'package:heartlog/write.dart';
import 'package:flutter/foundation.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Preload diary entries
  try {
    // Initialize DiaryStorage (will load entries from SharedPreferences)
    await DiaryStorage().reloadEntries();
    if (kDebugMode) {
      print('Diary entries loaded successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error loading diary entries: $e');
    }
  }

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HeartLog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xfffd745a),
        scaffoldBackgroundColor: const Color(0xFFFFF5EE),
      ),
      home: const Splash(),
      routes: {'/write': (context) => const Write()},
    );
  }
}
