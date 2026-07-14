import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // Real IDs from AdMob console
  static const String _androidBannerAdUnitId = 'ca-app-pub-9797202524330784/3231953598';
  
  static String get bannerAdUnitId {
    if (kDebugMode) {
      // Use test ID in debug mode to avoid account suspension
      return Platform.isAndroid 
          ? 'ca-app-pub-3940256099942544/6300978111' 
          : 'ca-app-pub-3940256099942544/2934735716';
    }
    
    if (Platform.isAndroid) {
      return _androidBannerAdUnitId;
    } else if (Platform.isIOS) {
      // Return real iOS ID here if available
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    throw UnsupportedError('Unsupported platform');
  }

  static Future<void> init() async {
    await MobileAds.instance.initialize();
  }
}
