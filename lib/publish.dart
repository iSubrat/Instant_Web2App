import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class PublishScreen extends StatefulWidget {
  @override
  _PublishScreenState createState() => _PublishScreenState();
}

class _PublishScreenState extends State<PublishScreen> {
  late InAppWebViewController _webViewController;

  @override
  void dispose() {
    super.dispose();
  }

  // Launch URL in other app or browser
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publish Your App'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: Uri.parse('https://appcollection.in/InstantWeb2App/publish.html'),
                  ),
                  onWebViewCreated: (controller) {
                    _webViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                    // Launch URLs in other apps if they don't start with the specified origin
                    if (!url.toString().startsWith('https://appcollection.in/InstantWeb2App')) {
                      _launchURL(url.toString());
                      controller.stopLoading(); // Stop loading the current URL
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
