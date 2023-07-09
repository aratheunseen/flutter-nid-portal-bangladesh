import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nid/ad_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BannerAd? _bannerAd;

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
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  List<String> image = [
    'https://img.freepik.com/premium-vector/give-blood-icon-vector-illustration_449764-150.jpg?w=826',
    'https://img.freepik.com/premium-vector/give-blood-icon-vector-illustration_449764-150.jpg?w=827',
    'https://img.freepik.com/premium-vector/give-blood-icon-vector-illustration_449764-150.jpg?w=826',
    'https://img.freepik.com/premium-vector/give-blood-icon-vector-illustration_449764-150.jpg?w=829',
    'https://img.freepik.com/premium-vector/give-blood-icon-vector-illustration_449764-150.jpg?w=826',
    'https://img.freepik.com/premium-vector/give-blood-icon-vector-illustration_449764-150.jpg?w=830',
  ];

  List<String> title = [
    'Blood Donation',
    'Blood Request',
    'Blood Bank',
    'Blood Camp',
    'Blood Donor',
    'Blood Group',
  ];

  List<String> descrition = [
    'Donate blood and save life',
    'Request blood and save life',
    'Blood bank information',
    'Blood camp information',
    'Blood donor information',
    'Blood group information',
  ];

  Future<InitializationStatus> _initGoogleMobileAds() {
    return MobileAds.instance.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo-ec.png',
          fit: BoxFit.cover,
          height: 24,
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
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
                      crossAxisCount: 2,
                      childAspectRatio:
                          0.7, // Adjust this value to control the item aspect ratio
                      padding: const EdgeInsets.all(16.0),
                      children: List.generate(6, (index) {
                        return GestureDetector(
                          onTap: () {
                            // Handle the click event
                          },
                          child: Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.network(
                                  image[index],
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(height: 8.0),
                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Text(
                                    title[index],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Text(
                                    descrition[index],
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12.0,
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
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
