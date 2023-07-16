import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
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
  FirebaseAnalytics.instance.logEvent(name: "rate_this_app");
}

class _AboutState extends State<About> {
  @override
  void initState() {
    FirebaseAnalytics.instance.logScreenView(
      screenName: 'about-page',
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black45),
          ),
          title: const Text('About',
              style: TextStyle(color: Colors.black45, fontSize: 18)),
          actions: [
            IconButton(
              onPressed: () async {
                await launchOutside(Uri.parse(
                    'https://play.google.com/store/apps/details?id=bd.gov.nidw.portal'));
                FirebaseAnalytics.instance.logEvent(name: "top_rate_this_app");
              },
              icon: const Icon(Icons.rate_review_rounded,
                  color: Color.fromARGB(255, 65, 57, 30), size: 24),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child:
                  // app icon and version
                  Center(
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
                      'Version 1.4.24',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            // rate this app
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
                      .logEvent(name: "bottom_rate_this_app");
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
        ));
  }
}
