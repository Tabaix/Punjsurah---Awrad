// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  // Lock to portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const AwradApp());
}

class AwradApp extends StatelessWidget {
  const AwradApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'پنجسورہ و اوراد (Panjsurah & Awrad)',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Start on the animated splash screen
      home: const SplashScreen(),
    );
  }
}
