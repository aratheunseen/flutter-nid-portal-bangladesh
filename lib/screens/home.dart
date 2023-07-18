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
import '../constants.dart';

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

  // Start :: BannerAd --------------------------------------------------------

  BannerAd? _bannerAd;

  void loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd?;
          });
          widget.analytics.logEvent(
            name: "home_bannerad_loaded",
            parameters: {
              "full_text": "Home BannerAd loaded successfully!",
            },
          );
        },
        onAdFailedToLoad: (ad, err) {
          _bannerAd = null;
          ad.dispose();
          widget.analytics.logEvent(
            name: "home_bannerad_failedtoload",
            parameters: {
              "full_text": err.toString(),
            },
          );
        },
      ),
    )..load();
    // End :: BannerAd --------------------------------------------------------
  }

  @override
  void initState() {
    super.initState();

    FirebaseAnalytics.instance.logScreenView(
      screenName: 'HomePage',
    );

    loadBannerAd();
  }

  // Start :: Dispose Ad ------------------------------------------------------
  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
    widget.analytics.logEvent(
      name: "home_bannerad_dispose",
      parameters: {
        "full_text": "Home BannerAd disposed successfully!",
      },
    );
  }
  // End :: Dispose Ad --------------------------------------------------------

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
                  // Start :: BannerAd -----------------------------------------
                  if (_bannerAd != null)
                    Container(
                      height: 60,
                      color: Colors.transparent,
                      child: SizedBox(
                        height: 60,
                        child: AdWidget(ad: _bannerAd!),
                      ),
                    ),
                  // End :: BannerAd -------------------------------------------

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
                                    ConnectivityResult.ethernet ||
                                connectivityResult == ConnectivityResult.vpn) {
                              if (index == 2) {
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
