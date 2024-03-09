
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:connectivity/connectivity.dart';
import 'no_internet.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

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
      return _buildWebView();
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
                  url: Uri.parse('https://channelmyanmar.org/'),
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
