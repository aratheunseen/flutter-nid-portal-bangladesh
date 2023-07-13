// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nid/ads_config.dart';
import 'package:nid/home.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
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
  InterstitialAd? _interstitialAd;

  late AnimationController progressController;
  bool determinate = false;

  @override
  void initState() {
    progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..addListener(() {
        setState(() {});
      });
    progressController.repeat();
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

    Future<void> launchOutside(Uri url) async {
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception('Could not launch $url');
      }
    }

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

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            _cleanRegistrationPage();
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
            SnackBar(
                content: const Text('Something went wrong!'),
                backgroundColor: Colors.black54,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)));

            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const HomePage()));
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
            if (request.url.contains("download")) {
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

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
  }

  // remove header and footer by injecting javascript code
  Future<void> _cleanRegistrationPage() async {
    await _controller.runJavaScript(
        "javascript:(function() { document.getElementsByClassName('top-bar')[0].style.display='none'; document.getElementsByClassName('page-title')[0].style.display='none'; document.getElementsByClassName('right-col')[0].style.display='none'; document.getElementsByClassName('footer')[0].style.display='none'; document.getElementsById('container')[0].classList.remove=' wrapper-padding-bottom';})()");
  }

  Future<void> _cleanLoginPage() async {
    await _controller.runJavaScript(
        "javascript:(function() { document.getElementsBySelector('div.seven:nth-child(2) > p:nth-child(1)')[0].style.display='none';document.getElementsByClassName('feedback-circle-mobile feedback-circle-absolute')[0].style.display='none'; document.getElementsByClassName('banner')[0].style.display='none'; document.getElementsByClassName('segment-claim-register-mobile')[0].style.display='none'; document.getElementsByClassName('info')[0].style.display='none'; document.getElementsByClassName('footer')[0].style.display='none';})()");
  }

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
              style: const TextStyle(color: Colors.black45, fontSize: 15)),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black45),
            onPressed: () {
              if (_interstitialAd != null) _interstitialAd!.show();
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
        ],
      ),
    );
  }
}
