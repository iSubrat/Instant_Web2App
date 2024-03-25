import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity/connectivity.dart';
import 'no_internet.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  InAppWebViewController? _webViewController;
  late ConnectivityResult _connectivityResult;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;

  // Define your custom user agent here
  String defaultUserAgent =
      "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.193 Mobile Safari/537.36";

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _setupConnectivityListener();
  }

  // Check connectivity
  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = result;
    });
  }

  // Set up connectivity listener
  void _setupConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _connectivityResult = result;
      });

      // If the connectivity changes to a state with internet, reload the WebView
      if (_connectivityResult != ConnectivityResult.none) {
        _webViewController?.reload();
      } else {
        _showNoInternetMessage();
      }
    });
  }

  // Show no internet message
  void _showNoInternetMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No internet connection'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Show exit confirmation dialog
  Future<bool> _showExitConfirmationDialog() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Are you sure you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false; // Return false if the dialog is dismissed
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_connectivityResult == ConnectivityResult.none) {
      // Display the custom No Internet screen
      return const NoInternetScreen();
    } else {
      // Display the WebView when there is an internet connection
      return Container(
        color: const Color(0xFFE72A73), // Background color
        child: Column(
          children: [
            Expanded(
              child: _buildWebView(),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       const Text(
            //         'Get this app live on Play Store',
            //         style: TextStyle(color: Colors.white, fontSize: 16.0),
            //       ),
            //       const SizedBox(width: 8),
            //       // Adjust spacing between text and button
            //       ElevatedButton(
            //         onPressed: () async {
            //           const url = 'https://appcollection.in/InstantWeb2App/publish.html';
            //           if (await canLaunch(url)) {
            //             await launch(url);
            //           } else {
            //             throw 'Could not launch $url';
            //           }
            //         },
            //         child: Text("Publish Now", style: TextStyle(fontSize: 16.0)),
            //       ),
            //
            //     ],
            //   ),
            // ),
          ],
        ),
      );
    }
  }

  // Build app bar
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(0.0),
      child: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.blue,
      ),
    );
  }

  // Build web view
  Widget _buildWebView() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              InAppWebView(
                initialUrlRequest: URLRequest(
                  url: Uri.parse('https://infinity.icicibank.com/corp/AuthenticationController?FORMSGROUP_ID__=AuthenticationFG&__START_TRAN_FLAG__=Y&FG_BUTTONS__=LOAD&ACTION.LOAD=Y&AuthenticationFG.LOGIN_FLAG=1&BANK_ID=ICI&ITM=nli_personalb_NRI_login_btn&_gl=1*jftn50*_ga*MTgzMDcxOTY5Ni4xNjIwMDM5NDU0*_ga_SKB78GHTFV*MTYyODIzNDM4NC43Ny4xLjE2MjgyMzQ0NzEuNjA.&_ga=2.53055592.151335549.1698035816-1973315115.1690798212&_gac=1.6934150.1697523963.EAIaIQobChMI-7jpvrn8gQMVt6lmAh1nywMHEAAYASAAEgKBxfD_BwE?ITM=nli_personalb_nri_banking_mobile'),
                ),
                initialOptions: _getInAppWebViewOptions(),
                onWebViewCreated: _onWebViewCreated,
                onLoadStop: (controller, url) {
                  // Set _isLoading to false when the page finishes loading
                  setState(() {
                    _isLoading = false;
                  });
                },
              ),
              // Show loading wheel if the page is still loading
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Get InAppWebViewOptions
  InAppWebViewGroupOptions _getInAppWebViewOptions() {
    return InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        userAgent: defaultUserAgent,
        allowFileAccessFromFileURLs: true,
        allowUniversalAccessFromFileURLs: true,
        cacheEnabled: true,
        clearCache: false,
        javaScriptEnabled: true,
        preferredContentMode: UserPreferredContentMode.MOBILE,
        mediaPlaybackRequiresUserGesture: false,
        javaScriptCanOpenWindowsAutomatically: true,
        useOnLoadResource: true,
        useShouldInterceptAjaxRequest: true,
        useShouldInterceptFetchRequest: true,
      ),
      android: AndroidInAppWebViewOptions(useHybridComposition: true),
    );
  }

  // WebView created callback
  void _onWebViewCreated(InAppWebViewController controller) {
    _webViewController = controller;
  }

  // Will pop callback
  Future<bool> _onWillPop() async {
    // Set _isLoading to false when the user tries to exit
    setState(() {
      _isLoading = false;
    });

    if (_webViewController != null) {
      // Check if the WebView can go back
      final canGoBack = await _webViewController!.canGoBack();
      if (canGoBack) {
        // If yes, go back in WebView
        _webViewController!.goBack();
        return false; // Do not exit the app
      }
    }

    // If WebView cannot go back or doesn't exist, show confirmation popup
    return _showExitConfirmationDialog();
  }
}
