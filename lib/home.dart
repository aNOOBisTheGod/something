import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:interview/wrong-phones-screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? url;
  RemoteConfigUpdate? update;
  StreamSubscription? subscription;
  bool wrongDevice = false;

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> _initConfig() async {
    SharedPreferences instance = await SharedPreferences.getInstance();
    Map deviceInfo = (await DeviceInfoPlugin().deviceInfo).data;

    if (instance.getString('url') == null) {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 1),
        minimumFetchInterval: const Duration(seconds: 10),
      ));
      await _remoteConfig.fetchAndActivate();
      if (_remoteConfig.getString('url').isNotEmpty) {
        setState(() {
          url = _remoteConfig.getString('url');
        });
        instance.setString('url', url!);
      }
    } else {
      setState(() {
        url = instance.getString('url');
      });
    }
    if (deviceInfo['isPhysicalDevice'] == false ||
        deviceInfo['brand'] == 'google' ||
        url == null) {
      setState(() {
        wrongDevice = true;
      });
    }
  }

  @override
  void initState() {
    _initConfig();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !wrongDevice
          ? url != null
              ? WebViewWidgetUrl(
                  url: url!,
                )
              : const Center(
                  child: CircularProgressIndicator(),
                )
          : const WrongPhonesScreen(),
    );
  }
}

// ignore: must_be_immutable
class WebViewWidgetUrl extends StatelessWidget {
  String url;
  WebViewWidgetUrl({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    // WebViewController controller = WebViewController()
    //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
    //   ..setBackgroundColor(const Color(0x00000000))
    //   ..setNavigationDelegate(
    //     NavigationDelegate(
    //       onProgress: (int progress) {},
    //       onPageStarted: (String url) {},
    //       onPageFinished: (String url) {},
    //       onWebResourceError: (WebResourceError error) {},
    //     ),
    //   )
    //   ..loadRequest(Uri.parse(url));
    InAppWebViewController? webViewController;

    return WillPopScope(
        onWillPop: () async {
          if (webViewController == null) {
            return false;
          }
          if (await webViewController!.canGoBack()) {
            webViewController!.goBack();
          }
          return false;
        },
        child: InAppWebView(
          onWebViewCreated: (controller) async {
            webViewController = controller;
          },
          initialUrlRequest: URLRequest(url: Uri.parse(url)),
        ));
  }
}
