// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:audio_service/audio_service.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'services/quran_audio_service.dart';
import 'widgets/quran_mini_player.dart';

late QuranAudioHandler audioHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();

  audioHandler = await AudioService.init(
    builder: () => QuranAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.awrad_app.channel.audio',
      androidNotificationChannelName: 'Quran Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );

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
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 60), // Above banner ad which is usually at bottom
                child: QuranMiniPlayer(),
              ),
            ),
          ],
        );
      },
      // Start on the animated splash screen
      home: const SplashScreen(),
    );
  }
}
