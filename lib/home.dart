// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nid/about.dart';
import 'package:nid/ads/ads_config.dart';
import 'package:nid/browser.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:app_settings/app_settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.fullBanner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    ).load();

    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _interstitialAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          // print('Failed to load an interstitial ad: ${err.message}');
        },
      ),
    );

    // RewardedAd.load(
    //   adUnitId: AdHelper.rewardedAdUnitId,
    //   request: const AdRequest(),
    //   rewardedAdLoadCallback: RewardedAdLoadCallback(
    //     onAdLoaded: (ad) {
    //       // Keep a reference to the ad so you can show it later.
    //       _rewardedAd = ad;
    //       ad.fullScreenContentCallback = FullScreenContentCallback(
    //         onAdShowedFullScreenContent: (ad) =>
    //             print('ad onAdShowedFullScreenContent.'),
    //         onAdDismissedFullScreenContent: (ad) {
    //           print('$ad onAdDismissedFullScreenContent.');
    //           ad.dispose();
    //         },
    //         onAdFailedToShowFullScreenContent: (ad, err) {
    //           print('$ad onAdFailedToShowFullScreenContent: $err');
    //           ad.dispose();
    //         },
    //       );
    //     },
    //     onAdFailedToLoad: (err) {
    //       print('Failed to load a rewarded ad: $err');
    //     },
    //   ),
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  List<String> image = [
    'assets/images/register.png',
    'assets/images/claim.png',
    'assets/images/login.png',
    'assets/images/recovery.png',
    'assets/images/forms.png',
    'assets/images/fees.png',
  ];

  List<String> title = [
    'New Application',
    'Claim Account',
    'Manage Account',
    'Recover Account',
    'Download Forms',
    'Fees Calculator',
  ];

  List<String> descrition = [
    'আপনার জাতীয় পরিচয়পত্র না থাকলে, নতুন নিবন্ধন করুন',
    'আপনার যদি জাতীয় পরিচয়পত্র থাকে, তাহলে অ্যাকাউন্ট ক্লেইম করুন',
    'আপনার যদি অনলাইন একাউন্ট থাকে তাহলে লগইন করুন',
    'আপনার অ্যাকাউন্ট আছে, কিন্তু পাসওয়ার্ড ভুলে গিয়েছেন? পুনরুদ্ধার করুন',
    'হারানো, চুরি হওয়া বা তথ্য সংশোধনের আবেদন ফর্ম ডাউনলোড করুন',
    'কার্ডের তথ্য পরিবর্তন অথবা সংশোধন অথবা কার্ড রিইস্যু ফি হিসাব করুন',
  ];

  List<String> url = [
    'https://services.nidw.gov.bd/nid-pub/register-account',
    'https://services.nidw.gov.bd/nid-pub/claim-account',
    'https://services.nidw.gov.bd/nid-pub/#form',
    'https://services.nidw.gov.bd/nid-pub/recover-account',
    'https://services.nidw.gov.bd/nid-pub/form/download',
    'https://services.nidw.gov.bd/nid-pub/fees',
  ];

  Future<InitializationStatus> _initGoogleMobileAds() {
    return MobileAds.instance.initialize();
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
      body: Scaffold(
        body: FutureBuilder(
          future: _initGoogleMobileAds(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Column(children: [
                if (_bannerAd != null)
                  Container(
                    alignment: Alignment.center,
                    height: 60,
                    color: Colors.transparent,
                    child: SizedBox(
                      height: 60,
                      child: AdWidget(ad: _bannerAd!, key: UniqueKey()),
                    ),
                  ),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: _getCrossAxisCount(BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width)),
                    padding: const EdgeInsets.all(8.0),
                    children: List.generate(6, (index) {
                      return GestureDetector(
                        onTap: () async {
                          final connectivityResult =
                              await (Connectivity().checkConnectivity());
                          if (connectivityResult == ConnectivityResult.mobile ||
                              connectivityResult == ConnectivityResult.wifi ||
                              connectivityResult ==
                                  ConnectivityResult.ethernet ||
                              connectivityResult == ConnectivityResult.vpn) {
                            if (_interstitialAd != null) {
                              _interstitialAd!.show();
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Browser(
                                  url: url[index],
                                  title: title[index],
                                ),
                              ),
                            );
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
                                      borderRadius: BorderRadius.circular(10))),
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
              ]);
            } else {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.redAccent,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
