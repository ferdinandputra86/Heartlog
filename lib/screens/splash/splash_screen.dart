import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heartlog/screens/navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    // Use a safer approach to avoid the BuildContext warning
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          // Check if widget is still mounted
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const NavigationScreen()),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    // Kembalikan system UI saat keluar dari splash
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    // Calculate responsive logo size
    final double logoWidth = isSmallScreen ? 180 : 217;
    final double logoHeight = isSmallScreen ? 196 : 237;

    return Scaffold(
      backgroundColor: const Color(0xFFFFE6CC),
      body: Center(
        child: Image.asset(
          'assets/logo.png',
          width: logoWidth,
          height: logoHeight,
        ),
      ),
    );
  }
}
