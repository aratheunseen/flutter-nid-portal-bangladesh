// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nid/screens/browser.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:nid/admanager.dart';

class LoginPageBrowser extends StatefulWidget {
  const LoginPageBrowser(
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
  State<LoginPageBrowser> createState() => _LoginPageBrowserState();
}

class _LoginPageBrowserState extends State<LoginPageBrowser>
    with TickerProviderStateMixin {
  late final WebViewController _controller;

  // Start :: BannerAd ---------------------------------------------------------

  BannerAd? _bannerAd;

  void loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _bannerAd = ad as BannerAd?;
          });
          widget.analytics!.logEvent(
            name: "browser_banner_ad_loaded",
            parameters: {
              "full_text": "Browser's Banner Ad Loaded",
            },
          );
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          widget.analytics!.logEvent(
            name: "browser_banner_ad_failed_to_load",
            parameters: {
              "full_text": "Browser's Banner Ad Failed To Load",
            },
          );
          ad.dispose();
        },
        onAdOpened: (Ad ad) {
          widget.analytics!.logEvent(
            name: "browser_banner_ad_opened",
            parameters: {
              "full_text": "Browser's Banner Ad Opened",
            },
          );
        },
        onAdClosed: (Ad ad) {
          widget.analytics!.logEvent(
            name: "browser_banner_ad_closed",
            parameters: {
              "full_text": "Browser's Banner Ad Closed",
            },
          );
        },
      ),
    );
    _bannerAd!.load();
  }
  // End :: BannerAd -----------------------------------------------------------

  // Start :: InterstitialAd ---------------------------------------------------

  InterstitialAd? _interstitialAd;

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdManager.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          widget.analytics!.logEvent(
            name: "browser_interstitialad_loaded_and_shown",
            parameters: {
              "full_text": "Browser's InterstitialAd Loaded And Shown",
            },
          );
        },
        onAdFailedToLoad: (err) {
          widget.analytics!.logEvent(
            name: "browser_interstitialad_failed_to_load",
            parameters: {
              "full_text": "Browser's InterstitialAd Failed To Load",
            },
          );
        },
      ),
    );
  }
  // End :: InterstitialAd -----------------------------------------------------

  // Declare :: ProgressController ---------------------------------------------
  late AnimationController progressController;
  bool determinate = false;

  @override
  void initState() {
    super.initState();

    FirebaseAnalytics.instance.logScreenView(
      screenName: 'LoginPageBrowser',
    );
    FirebaseAnalytics.instance
        .logEvent(name: widget.title, parameters: {"url": widget.url});

    loadBannerAd();
    loadInterstitialAd();

    // Start :: ProgressController ----------------------------
    progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..addListener(() {
        setState(() {});
      });
    progressController.repeat();
    // End :: ProgressController ------------------------------

    // Start :: UrlLauncher -----------------------------------
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
    // End :: UrlLauncher -------------------------------------

    // Start :: WebViewController -----------------------------
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
            final String url = widget.url;
            if (!url
                .allMatches("https://services.nidw.gov.bd/nid-pub/")
                .isNotEmpty) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Browser(
                            title: "Nid Portal",
                            url: url,
                          )));
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
    // End :: WebViewController -------------------------------
  }

  // Start :: RemoveHeader&Footer ------------------------------
  Future<void> _cleanUI() async {
    await _controller.runJavaScript(
        "javascript:(function() { document.getElementsByClassName('top-bar')[0].style.display='none'; document.getElementsByClassName('footer')[0].style.display='none'; document.getElementsByClassName('banner')[0].style.display='none'; document.getElementsByClassName('claim-mobile')[0].style.display='none'; document.getElementsByClassName('register-mobile')[0].style.display='none'; document.getElementsByClassName('ui header title')[0].style.display='none';  document.getElementsByClassName('forgot')[0].style.display='none'; document.getElementsByClassName('faq')[0].style.display='none'; document.getElementsByClassName('info')[0].style.display='none'; document.getElementsByClassName('feedback-mobile')[0].style.display='none'; document.getElementsByClassName('page-title')[0].style.display='none'; document.getElementsByClassName('right-col')[0].style.display='none';})()");
  }
  // End :: RemoveHeader&Footer -------------------------------

  void moreHandler(value) {
    switch (value) {
      case 'reload':
        {
          _controller.reload();
        }
        break;
      case 'change_password':
        {
          _controller.loadRequest(Uri.parse(
              'https://services.nidw.gov.bd/nid-pub/citizen-home/reset-password/'));
        }
        break;
      case 'update_phone':
        {
          _controller.loadRequest(Uri.parse(
              'https://services.nidw.gov.bd/nid-pub/citizen-home/update-mobile/'));
        }
        break;
      case 'logout':
        {
          late final WebViewCookieManager cookieManager =
              WebViewCookieManager();
          void clearCookies() async {
            await cookieManager.clearCookies();
          }
          _interstitialAd?.show();
          clearCookies();
          _controller.reload();
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).popUntil((route) => route.isFirst);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black45),
            onPressed: () async {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
          title: Text(widget.title,
              style: const TextStyle(color: Colors.black45, fontSize: 15)),
          actions: <Widget>[
            IconButton(
                icon: Image.asset('assets/images/bn.png',
                    width: 25, height: 25, color: Colors.black45),
                onPressed: () {
                  _interstitialAd?.show();
                  if (widget.url.contains("locale=en")) {
                    final String url =
                        widget.url.replaceAll("locale=en", "locale=bn");
                    _controller.loadRequest(Uri.parse(url));
                  } else {
                    final String url = widget.url
                        .replaceAll(widget.url, "${widget.url}?locale=bn");
                    _controller.loadRequest(Uri.parse(url));
                  }
                }),
            PopupMenuButton(
              onSelected: moreHandler,
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem(
                    value: 'reload',
                    child: Text(
                      'Reload',
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'change_password',
                    child: Text(
                      'Change Password',
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'update_phone',
                    child: Text('Update Phone Number'),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Text('Logout'),
                  ),
                ];
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Start :: LinearProgressIndicator -----------------------------
            LinearProgressIndicator(
              value: progressController.value,
            ),
            // End :: LinearProgressIndicator -------------------------------

            // Start :: WebView ---------------------------------------------
            Expanded(
              child: WebViewWidget(controller: _controller),
            ),
            // End :: WebView -----------------------------------------------

            const LinearProgressIndicator(
              value: 0,
              backgroundColor: Colors.black12,
            ),

            // Start :: BannerAd --------------------------------------------
            if (_bannerAd != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
            // End :: BannerAd ----------------------------------------------
          ],
        ),
      ),
    );
  }
}
