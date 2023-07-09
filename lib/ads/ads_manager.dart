// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:nid/ads/ads_config.dart';

// BannerAd? _bannerAd;
// InterstitialAd? _interstitialAd;

// @override
// void initState() {
//   super.initState();
//   BannerAd(
//     adUnitId: AdHelper.bannerAdUnitId,
//     request: const AdRequest(),
//     size: AdSize.fullBanner,
//     listener: BannerAdListener(
//       onAdLoaded: (ad) {
//         setState(() {
//           _bannerAd = ad as BannerAd;
//         });
//       },
//       onAdFailedToLoad: (ad, err) {
//         ad.dispose();
//       },
//     ),
//   ).load();

//   InterstitialAd.load(
//     adUnitId: AdHelper.interstitialAdUnitId,
//     request: const AdRequest(),
//     adLoadCallback: InterstitialAdLoadCallback(
//       onAdLoaded: (ad) {
//         setState(() {
//           _interstitialAd = ad;
//         });
//         // Keep a reference to the ad so you can show it later.
//       },
//       onAdFailedToLoad: (err) {
//         // print('Failed to load an interstitial ad: ${err.message}');
//       },
//     ),
//   );

//   // RewardedAd.load(
//   //   adUnitId: AdHelper.rewardedAdUnitId,
//   //   request: const AdRequest(),
//   //   rewardedAdLoadCallback: RewardedAdLoadCallback(
//   //     onAdLoaded: (ad) {
//   //       // Keep a reference to the ad so you can show it later.
//   //       _rewardedAd = ad;
//   //       ad.fullScreenContentCallback = FullScreenContentCallback(
//   //         onAdShowedFullScreenContent: (ad) =>
//   //             print('ad onAdShowedFullScreenContent.'),
//   //         onAdDismissedFullScreenContent: (ad) {
//   //           print('$ad onAdDismissedFullScreenContent.');
//   //           ad.dispose();
//   //         },
//   //         onAdFailedToShowFullScreenContent: (ad, err) {
//   //           print('$ad onAdFailedToShowFullScreenContent: $err');
//   //           ad.dispose();
//   //         },
//   //       );
//   //     },
//   //     onAdFailedToLoad: (err) {
//   //       print('Failed to load a rewarded ad: $err');
//   //     },
//   //   ),
// }

//   // @override
//   // void dispose() {
//   //   _bannerAd?.dispose();
//   //   super.dispose();
//   // }

//   // @override
//   // void dispose() {
//   //   _interstitialAd?.dispose();
//   //   super.dispose();
//   // }
