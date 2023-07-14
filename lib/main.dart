import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:nid/firebase_options.dart';
import 'package:nid/home.dart';
import 'package:nid/admanager.dart';

typedef ScreenNameExtractor = String? Function(RouteSettings settings);

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
    }, onAdFailedToLoad: (error) {
      _appOpenAd = null;
    }),
  );
}

void showAd() {
  if (_appOpenAd == null) {
    loadAd();
    return;
  }
  if (_isShowingAd) {
    return;
  }
  _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
    onAdShowedFullScreenContent: (ad) {
      _isShowingAd = true;
    },
    onAdFailedToShowFullScreenContent: (ad, error) {
      _isShowingAd = false;
      ad.dispose();
      _appOpenAd = null;
    },
    onAdDismissedFullScreenContent: (ad) {
      _isShowingAd = false;
      ad.dispose();
      _appOpenAd = null;
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
