import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:nid/firebase_options.dart';
import 'package:nid/home.dart';
import 'package:nid/admanager.dart';

// Start :: AppOpenAd
AppOpenAd? _appOpenAd;
bool _isShowingAd = false;

Future<void> loadAd() async {
  await AppOpenAd.load(
    adUnitId: AdManager.appOpenAdUnitId,
    orientation: AppOpenAd.orientationPortrait,
    request: const AdRequest(),
    adLoadCallback: AppOpenAdLoadCallback(onAdLoaded: (ad) {
      _appOpenAd = ad;
      _appOpenAd!.show();
      FirebaseAnalytics.instance.logEvent(
        name: 'app_open_ad_loaded',
        parameters: {
          "full_text": "App Open Ad Loaded",
        },
      );
    }, onAdFailedToLoad: (error) {
      _appOpenAd = null;
      FirebaseAnalytics.instance.logEvent(
        name: 'app_open_ad_failed_to_load',
        parameters: {
          "full_text": "App Open Ad Failed To Load",
        },
      );
    }),
  );
}

void showAd() {
  if (_appOpenAd == null) {
    loadAd();
    FirebaseAnalytics.instance.logEvent(
      name: 'app_open_ad_null',
      parameters: {
        "full_text": "App Open Ad Null",
      },
    );
    return;
  }
  if (_isShowingAd) {
    FirebaseAnalytics.instance.logEvent(
      name: 'app_open_ad_already_showing',
      parameters: {
        "full_text": "App Open Ad Already Showing",
      },
    );
    return;
  }
  _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
    onAdShowedFullScreenContent: (ad) {
      _isShowingAd = true;
      FirebaseAnalytics.instance.logEvent(
        name: 'app_open_ad_show',
        parameters: {
          "full_text": "App Open Ad Show",
        },
      );
    },
    onAdFailedToShowFullScreenContent: (ad, error) {
      _isShowingAd = false;
      ad.dispose();
      _appOpenAd = null;
      FirebaseAnalytics.instance.logEvent(
        name: 'app_open_ad_failed_to_show',
        parameters: {
          "full_text": "App Open Ad Failed To Show",
        },
      );
    },
    onAdDismissedFullScreenContent: (ad) {
      _isShowingAd = false;
      ad.dispose();
      _appOpenAd = null;
      FirebaseAnalytics.instance.logEvent(
        name: 'app_open_ad_dismissed',
        parameters: {
          "full_text": "App Open Ad Dismissed",
        },
      );
    },
  );
  _appOpenAd!.show();
}
// End :: AppOpenAd

// Start :: Main
Future<void> main() async {
  // Ensure that plugin services are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Google Mobile Ads SDK and Firebase
  MobileAds.instance.initialize(); // Initialize Google Mobile Ads SDK
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await loadAd(); // Load AppOpenAd

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Firebase Analytics
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NID Portal',
      debugShowCheckedModeBanner: false,
      navigatorObservers: <NavigatorObserver>[observer],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 1, 49, 122)),
        useMaterial3: true,
      ),
      home: HomePage(
        title: 'NID Portal',
        analytics: analytics,
        observer: observer,
      ), // Route to Home Page
    );
  }
}
// End :: Main
