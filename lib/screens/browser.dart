// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nid/home.dart';
import 'package:nid/screens/login_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:nid/admanager.dart';

class Browser extends StatefulWidget {
  const Browser(
      {Key? key,
      required this.title,
      required this.url,
      this.analytics,
      this.observer})
      : super(key: key);

  final String title;
  final String url;
  final FirebaseAnalytics? analytics;
  final FirebaseAnalyticsObserver? observer;

  @override
  State<Browser> createState() => _BrowserState();
}

class _BrowserState extends State<Browser> with TickerProviderStateMixin {
  // Declare WebView Controller
  late final WebViewController _controller;

  // Declare Ad variables
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;

  // Declare ProgressController
  late AnimationController progressController;
  bool determinate = false;

  @override
  void initState() {
    FirebaseAnalytics.instance.logScreenView(
      screenName: 'browswer-page',
    );
    FirebaseAnalytics.instance
        .logEvent(name: widget.title, parameters: {"url": widget.url});

    // Start :: LoadAd
    BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.fullBanner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
          widget.analytics!.logEvent(
            name: "browser_banner_ad_loaded",
            parameters: {
              "full_text": "Browser's Banner Ad Loaded",
            },
          );
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          widget.analytics!.logEvent(
            name: "browser_banner_ad_failed_to_load",
            parameters: {
              "full_text": "Browser's Banner Ad Failed To Load",
            },
          );
        },
      ),
    ).load();

    InterstitialAd.load(
      adUnitId: AdManager.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _interstitialAd = ad;
          });
          widget.analytics!.logEvent(
            name: "browser_interstitial_ad_loaded",
            parameters: {
              "full_text": "Browser's Interstitial Ad Loaded",
            },
          );
        },
        onAdFailedToLoad: (err) {
          _interstitialAd = null;
          widget.analytics!.logEvent(
            name: "browser_interstitial_ad_failed_to_load",
            parameters: {
              "full_text": "Browser's Interstitial Ad Failed To Load",
            },
          );
        },
      ),
    );
    // End :: LoadAd

    // Start :: ProgressController
    progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..addListener(() {
        setState(() {});
      });
    progressController.repeat();
    super.initState();
    // End :: ProgressController

    // Start :: UrlLauncher
    Future<void> launchOutside(Uri url) async {
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception('Could not launch $url');
      }
      widget.analytics!.logEvent(
        name: "browser_launch_outside",
        parameters: {
          "full_text": "Go OutSide: $url",
        },
      );
    }
    // End :: UrlLauncher

    // Start :: WebViewController
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
            _cleanUI();
            progressController.value = progress / 100;
          },
          onPageStarted: (String url) {
            progressController.value = 0;
            if (url
                .allMatches("https://services.nidw.gov.bd/nid-pub/")
                .isNotEmpty) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LoginPageBrowser(
                            title: "Manage Account",
                            url: "https://services.nidw.gov.bd/nid-pub/",
                          )), (r) {
                return false;
              });
            }
          },
          onPageFinished: (String url) {
            progressController.value = 0;
          },
          onWebResourceError: (WebResourceError error) {
            SnackBar(
                content: const Text('Something went wrong!'),
                backgroundColor: Colors.black54,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)));
          },

          // Handle Requests
          onNavigationRequest: (NavigationRequest request) async {
            if (request.url.startsWith('https://play.google.com')) {
              final Uri url = Uri.parse(request.url);
              await FirebaseAnalytics.instance.logEvent(
                name: "go_to_playstore",
                parameters: {
                  "full_text": request.url,
                },
              );
              launchOutside(url);
              return NavigationDecision.prevent;
            }
            if (request.url.startsWith('https://apps.apple.com')) {
              final Uri url = Uri.parse(request.url);
              await FirebaseAnalytics.instance.logEvent(
                name: "go_to_appstore",
                parameters: {
                  "full_text": request.url,
                },
              );
              launchOutside(url);
              return NavigationDecision.prevent;
            }
            if (request.url.contains(".pdf")) {
              final Uri url = Uri.parse(request.url);
              FirebaseAnalytics.instance.logEvent(
                  name: "download_pdf", parameters: {"full_text": request.url});

              launchOutside(url);
              return NavigationDecision.prevent;
            }
            if (request.url.contains("download")) {
              final Uri url = Uri.parse(request.url);
              launchOutside(url);
              await FirebaseAnalytics.instance.logEvent(
                name: "download_from_page",
                parameters: {
                  "full_text": request.url,
                },
              );
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            // debugPrint('url change to ${change.url}');
            FirebaseAnalytics.instance.logEvent(
              name: "browser_url_change",
              parameters: {
                "full_text": "Url change to ${change.url}",
              },
            );
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
    // End :: WebViewController
  }

  // Start :: RemoveHeader&Footer
  Future<void> _cleanUI() async {
    await _controller.runJavaScript(
        "javascript:(function() { document.getElementsByClassName('top-bar')[0].style.display='none'; document.getElementsByClassName('footer')[0].style.display='none'; document.getElementsByClassName('page-title')[0].style.display='none'; document.getElementsByClassName('right-col')[0].style.display='none';document.getElementsByClassName('banner')[0].style.display='none';})()");
  }
  // End :: RemoveHeader&Footer

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return HomePage(
              title: 'NID Portal',
              analytics: FirebaseAnalytics.instance,
              observer: FirebaseAnalyticsObserver(
                  analytics: FirebaseAnalytics.instance));
        }));
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black45),
            onPressed: () {
              // Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return HomePage(
                    title: 'NID Portal',
                    analytics: FirebaseAnalytics.instance,
                    observer: FirebaseAnalyticsObserver(
                        analytics: FirebaseAnalytics.instance));
              }));
            },
          ),
          title: Text(widget.title,
              style: const TextStyle(color: Colors.black45, fontSize: 15)),
          actions: <Widget>[
            IconButton(
              icon: Image.asset('assets/images/bn.png',
                  width: 25, height: 25, color: Colors.black45),
              onPressed: () {
                if (widget.url.contains("locale=en")) {
                  final String url =
                      widget.url.replaceAll("locale=en", "locale=bn");
                  _controller.loadRequest(Uri.parse(url));
                }
                if (_interstitialAd != null) {
                  _interstitialAd!.show();
                  FirebaseAnalytics.instance.logEvent(
                    name: "browser_interstitialad_show",
                    parameters: {
                      "full_text":
                          "Browser InterstitialAd showed successfully!",
                    },
                  );
                } else {
                  FirebaseAnalytics.instance.logEvent(
                    name: "browser_interstitialad_null",
                    parameters: {
                      "full_text": "Browser InterstitialAd is null!",
                    },
                  );
                }
                // else if (widget.url.contains("locale=bn")) {
                //   final String url =
                //       widget.url.replaceAll("locale=bn", "locale=en");
                //   _controller.loadRequest(Uri.parse(url));
                // }
              },
            ),
            IconButton(
                icon: const Icon(Icons.refresh_outlined, color: Colors.black45),
                onPressed: () {
                  _controller.reload();
                })
          ],
        ),
        body: Column(
          children: [
            LinearProgressIndicator(
              value: progressController.value,
            ),
            // Text(widget.url),
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
        // floatingActionButton: FloatingActionButton(
        //   child: const Icon(Icons.refresh_outlined),
        //   onPressed: () {
        //     _controller.reload();
        //   },
        // ),
      ),
    );
  }
}
