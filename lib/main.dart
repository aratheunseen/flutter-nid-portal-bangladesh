import 'package:flutter/material.dart';
import 'package:nid/home.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nid/ads_config.dart';

AppOpenAd? _appOpenAd;
bool _isShowingAd = false;

Future<void> loadAd() async {
  await AppOpenAd.load(
    adUnitId: AdHelper.appOpenAdUnitId,
    orientation: AppOpenAd.orientationPortrait,
    request: const AdRequest(),
    adLoadCallback: AppOpenAdLoadCallback(onAdLoaded: (ad) {
      _appOpenAd = ad;
      _appOpenAd!.show();
    }, onAdFailedToLoad: (error) {
      // print('AppOpenAd failed to load: $error');
    }),
  );
}

void showAd() {
  if (_appOpenAd == null) {
    // print('Tried to show ad before available.');
    loadAd();
    return;
  }
  if (_isShowingAd) {
    // print('Tried to show ad while already showing an ad.');
    return;
  }
  // Set the fullScreenContentCallback and show the ad.
  _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
    onAdShowedFullScreenContent: (ad) {
      _isShowingAd = true;
      // print('$ad onAdShowedFullScreenContent');
    },
    onAdFailedToShowFullScreenContent: (ad, error) {
      // print('$ad onAdFailedToShowFullScreenContent: $error');
      _isShowingAd = false;
      ad.dispose();
      _appOpenAd = null;
    },
    onAdDismissedFullScreenContent: (ad) {
      // print('$ad onAdDismissedFullScreenContent');
      _isShowingAd = false;
      ad.dispose();
      _appOpenAd = null;
    },
  );
  _appOpenAd!.show();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  await loadAd();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NID Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 1, 49, 122)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
