// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nid/ads_config.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// #docregion platform_imports
// Import for Android features.
// ignore: depend_on_referenced_packages
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
// ignore: depend_on_referenced_packages
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class Browser extends StatefulWidget {
  const Browser({Key? key, required this.title, required this.url})
      : super(key: key);

  final String title;
  final String url;

  @override
  State<Browser> createState() => _BrowserState();
}

class _BrowserState extends State<Browser> with TickerProviderStateMixin {
  late final WebViewController _controller;
  BannerAd? _bannerAd;
  // InterstitialAd? _interstitialAd;

  late AnimationController progressController;
  bool determinate = false;

  @override
  void initState() {
    progressController = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: const Duration(seconds: 30),
    )..addListener(() {
        setState(() {});
      });
    progressController.repeat();
    super.initState();
    // ads
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

    // InterstitialAd.load(
    //   adUnitId: AdHelper.interstitialAdUnitId,
    //   request: const AdRequest(),
    //   adLoadCallback: InterstitialAdLoadCallback(
    //     onAdLoaded: (ad) {
    //       setState(() {
    //         _interstitialAd = ad;
    //       });
    //       // Keep a reference to the ad so you can show it later.
    //     },
    //     onAdFailedToLoad: (err) {
    //       // print('Failed to load an interstitial ad: ${err.message}');
    //     },
    //   ),
    // );

    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    Future<void> launchOutside(Uri url) async {
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception('Could not launch $url');
      }
    }

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            progressController.value = progress / 100;
            // debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            progressController.value = 0;
            // debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            progressController.value = 0;
            // debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            //   debugPrint('''
            //   Page resource error:
            //   code: ${error.errorCode}
            //   description: ${error.description}
            //   errorType: ${error.errorType}
            //   isForMainFrame: ${error.isForMainFrame}
            // ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://play.google.com')) {
              final Uri url = Uri.parse(request.url);
              launchOutside(url);
              return NavigationDecision.prevent;
            }
            if (request.url.startsWith('https://apps.apple.com')) {
              final Uri url = Uri.parse(request.url);
              launchOutside(url);
              return NavigationDecision.prevent;
            }
            if (request.url.contains(".pdf")) {
              final Uri url = Uri.parse(request.url);
              launchOutside(url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            // debugPrint('url change to ${change.url}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(message.message),
                backgroundColor: Colors.black54,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
          );
        },
      )
      ..loadRequest(Uri.parse(widget.url));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;
  }

  // @override
  // void initState() {
  //   super.initState();
  //   // Implement some initialization operations here.
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black45),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Center(
          child: Text(widget.title,
              style: const TextStyle(color: Colors.black45, fontSize: 18)),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black45),
            onPressed: () {
              // Implement refresh here.
              _controller.reload();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: progressController.value,
          ),
          Expanded(
            child: WebViewWidget(controller: _controller),
          ),
          if (_bannerAd != null)
            Container(
              height: 60,
              color: Colors.transparent,
              child: SizedBox(
                height: 60,
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
          // if (_interstitialAd != null)
          //   ElevatedButton(
          //     onPressed: () {
          //       _interstitialAd!.show();
          //     },
          //     child: const Text('Show Interstitial'),
          //   ),
        ],
      ),
    );
    // const Center(
    //   child: Text('This is a browser.',
    //       style: TextStyle(fontSize: 24, color: Colors.black45)),
    // ),
  }
}
