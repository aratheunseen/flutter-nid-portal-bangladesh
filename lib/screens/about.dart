import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

Future<void> launchOutside(Uri url) async {
  if (!await launchUrl(
    url,
    mode: LaunchMode.externalApplication,
  )) {
    throw Exception('Could not launch $url');
  }
}

class _AboutState extends State<About> {
  @override
  void initState() {
    FirebaseAnalytics.instance.logScreenView(
      screenName: 'AboutPage',
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black45),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('About',
              style: TextStyle(color: Colors.black45, fontSize: 18)),
          actions: [
            IconButton(
              onPressed: () async {
                await launchOutside(Uri.parse(
                    'https://play.google.com/store/apps/details?id=bd.gov.nidw.portal'));
                FirebaseAnalytics.instance
                    .logEvent(name: "rate_this_app_top_icon");
              },
              icon: const Icon(Icons.rate_review_rounded,
                  color: Color.fromARGB(255, 65, 57, 30), size: 24),
            ),
          ],
        ),
        body: WillPopScope(
          onWillPop: () async {
            return Navigator.canPop(context);
          },
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/icon.png',
                        width: 100,
                        height: 100,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'NID Portal: Bangladesh',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Version 1.4.35',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(60),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    await launchOutside(Uri.parse(
                        'https://play.google.com/store/apps/details?id=bd.gov.nidw.portal'));
                    FirebaseAnalytics.instance
                        .logEvent(name: "rate_this_app_bottom_button");
                  },
                  child: const Text(
                    'Rate this application',
                    style: TextStyle(
                        fontSize: 16, color: Color.fromARGB(255, 65, 57, 30)),
                    textAlign: TextAlign.center,
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
