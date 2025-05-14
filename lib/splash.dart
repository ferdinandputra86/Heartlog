import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heartlog/navigation.dart'; // Ganti sesuai lokasi file kamu

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
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
            MaterialPageRoute(builder: (_) => const Navigation()),
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
    return Scaffold(
      backgroundColor: const Color(0xFFFFE6CC),
      body: Center(
        child: Image.asset('assets/logo.png', width: 217, height: 237),
      ),
    );
  }
}
