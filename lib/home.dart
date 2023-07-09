import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nid/ad_helper.dart';
import 'package:nid/browser.dart';

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
          // Keep a reference to the ad so you can show it later.
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

  // @override
  // void dispose() {
  //   _bannerAd?.dispose();
  //   super.dispose();
  // }

  // @override
  // void dispose() {
  //   _interstitialAd?.dispose();
  //   super.dispose();
  // }

  List<String> image = [
    'https://cdn1.iconfinder.com/data/icons/business-and-finance-3d-s4/128/business_finance_applicant_application_job_recruitment_graduation_registration_register.png',
    'https://cdn0.iconfinder.com/data/icons/metaverse-48/128/face_scan.png',
    // 'https://cdn4.iconfinder.com/data/icons/security-339/128/Login_Page.png',
    'https://cdn2.iconfinder.com/data/icons/business-1493/128/account_profile_id_id_card_identity_person_user.png',
    'https://cdn1.iconfinder.com/data/icons/approval-2/128/Consent.png',
    'https://cdn2.iconfinder.com/data/icons/business-1772/128/Untitled_design_9.png',
  ];

  List<String> title = [
    'New Application',
    'Claim Account',
    'Manage Account',
    'Download Forms',
    'Fees Calculator',
  ];

  List<String> descrition = [
    'আপনার জাতীয় পরিচয়পত্র না থাকলে, নতুন নিবন্ধন করুন',
    'আপনার যদি জাতীয় পরিচয়পত্র থাকে, তাহলে অ্যাকাউন্ট ক্লেইম করুন',
    'আপনার যদি অনলাইন একাউন্ট থাকে তাহলে লগইন করুন',
    ' হারানো, চুরি হওয়া বা তথ্য সংশোধনের আবেদন ফর্ম ডাউনলোড করুন',
    'কার্ডের তথ্য পরিবর্তন অথবা সংশোধন অথবা কার্ড রিইস্যু ফি হিসাব করুন',
  ];

  Future<InitializationStatus> _initGoogleMobileAds() {
    return MobileAds.instance.initialize();
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
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Scaffold(
        body: FutureBuilder(
          future: _initGoogleMobileAds(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Column(
                children: [
                  if (_bannerAd != null)
                    Center(
                      child: SizedBox(
                        height: 60,
                        child: AdWidget(ad: _bannerAd!),
                      ),
                    ),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 3,
                      childAspectRatio:
                          0.7, // Adjust this value to control the item aspect ratio
                      padding: const EdgeInsets.all(8.0),
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            // Handle the click event
                            if (_interstitialAd != null) {
                              _interstitialAd!.show();
                            } else {
                              // print('Interstitial ad is still loading...');
                            }

                            // Navigator.pushNamed(context, '/browser',
                            //     arguments: {
                            //       'url': 'https://services.nidw.gov.bd/',
                            //       'title': title[index],
                            //     });
                            if (index == 0) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Browser(
                                    url:
                                        'https://services.nidw.gov.bd/nid-pub/',
                                    title: title[index],
                                  ),
                                ),
                              );
                            } else if (index == 1) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Browser(
                                    url: 'https://nidw.gov.bd/claim',
                                    title: title[index],
                                  ),
                                ),
                              );
                            } else if (index == 2) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Browser(
                                    url: 'https://nidw.gov.bd/login',
                                    title: title[index],
                                  ),
                                ),
                              );
                            } else if (index == 3) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Browser(
                                    url: 'https://nidw.gov.bd/download',
                                    title: title[index],
                                  ),
                                ),
                              );
                            } else if (index == 4) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Browser(
                                    url: 'https://nidw.gov.bd/fees',
                                    title: title[index],
                                  ),
                                ),
                              );
                            }
                          },
                          child: Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Image.network(
                                    image[index],
                                    height: 90,
                                    width: 90,
                                    // width: double.infinity,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
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
                                  padding: const EdgeInsets.only(left: 8.0),
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
                        );
                      }),
                    ),
                  ),
                ],
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
