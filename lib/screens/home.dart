// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:app_settings/app_settings.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:nid/admanager.dart';
import 'package:nid/screens/browser.dart';
import 'package:nid/screens/about.dart';
import 'package:nid/screens/login_screen.dart';
import 'package:nid/constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
    required this.title,
    required this.analytics,
    required this.observer,
  }) : super(key: key);

  final String title;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  String? defaultNameExtractor(RouteSettings settings) => settings.name;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<InitializationStatus> _initGoogleMobileAds() {
    return MobileAds.instance.initialize();
  }

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;

  /// Loads a banner ad.
  void loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          // Dispose the ad here to free resources.
          ad.dispose();
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) {},
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) {},
        // Called when an impression occurs on the ad.
        onAdImpression: (Ad ad) {},
      ),
    )..load();
  }

  /// Loads an interstitial ad.
  void loadInterstitialAd() {
    InterstitialAd.load(
        adUnitId: AdManager.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            // Keep a reference to the ad so you can show it later.
            _interstitialAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error');
          },
        ));
  }

  @override
  void initState() {
    super.initState();

    loadBannerAd();
    loadInterstitialAd();

    FirebaseAnalytics.instance.logScreenView(
      screenName: 'HomePage',
    );
  }

  int _getCrossAxisCount(BoxConstraints constraints) {
    double screenWidth = constraints.maxWidth;
    if (screenWidth > 1200) {
      return 4;
    } else if (screenWidth > 800) {
      return 3;
    } else {
      return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo-ec.png',
              fit: BoxFit.cover,
              height: 24,
            ),
            const SizedBox(width: 11.0),
            const Text(
              'NID Portal',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  overflow: TextOverflow.ellipsis,
                  color: Colors.black54),
            ),
          ],
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
              icon: const Icon(Icons.info_outline_rounded,
                  color: Colors.black45, size: 24),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const About()));
              },
            ),
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: () async => exit(0),
        child: Scaffold(
          body: FutureBuilder(
            future: _initGoogleMobileAds(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Column(children: [
                  // Start :: GridView -----------------------------------------
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: _getCrossAxisCount(BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width)),
                      padding: const EdgeInsets.all(8.0),
                      children: List.generate(8, (index) {
                        return GestureDetector(
                          onTap: () async {
                            final connectivityResult =
                                await (Connectivity().checkConnectivity());
                            if (connectivityResult ==
                                    ConnectivityResult.mobile ||
                                connectivityResult == ConnectivityResult.wifi ||
                                connectivityResult ==
                                    ConnectivityResult.ethernet) {
                              if (index == 3) {
                                _interstitialAd?.show();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginPageBrowser(
                                      url: url[index],
                                      title: title[index],
                                      analytics: widget.analytics,
                                      observer: widget.observer,
                                    ),
                                  ),
                                );
                                FirebaseAnalytics.instance.logEvent(
                                  name: "${title[index]} clicked",
                                  parameters: {
                                    "full_text": "Login Page Clicked!",
                                  },
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Browser(
                                      url: url[index],
                                      title: title[index],
                                      analytics: widget.analytics,
                                      observer: widget.observer,
                                    ),
                                  ),
                                );
                                FirebaseAnalytics.instance.logEvent(
                                  name: "${title[index]} clicked",
                                  parameters: {
                                    "full_text": "${title[index]} Clicked!",
                                  },
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        const Text('No Internet Connection!'),
                                    action: SnackBarAction(
                                      label: 'Turn on',
                                      onPressed: () {
                                        AppSettings.openAppSettings(
                                            type: AppSettingsType.wifi);
                                      },
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                              );
                            }
                          },
                          child: Card(
                            child: SizedBox(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: FractionallySizedBox(
                                      widthFactor: 1,
                                      heightFactor: .75,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                        ),
                                        child: Center(
                                          child: Image.asset(
                                            image[index],
                                            fit: BoxFit.cover,
                                            height: 90,
                                            width: 90,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(
                                      title[index],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 8.0),
                                    child: Text(
                                      descrition[index],
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 10.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  // End :: GridView -------------------------------------------

                  // Start :: BannerAd -----------------------------------------
                  const LinearProgressIndicator(
                    value: 0,
                    backgroundColor: Colors.black12,
                  ),
                  if (_bannerAd != null)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        width: _bannerAd!.size.width.toDouble(),
                        height: _bannerAd!.size.height.toDouble(),
                        child: AdWidget(ad: _bannerAd!),
                      ),
                    ),
                  // End :: BannerAd -------------------------------------------
                ]);
              } else {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 1, 49, 122),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
