import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? url;
  RemoteConfigUpdate? update;
  StreamSubscription? subscription;

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> _initConfig() async {
    SharedPreferences instance = await SharedPreferences.getInstance();
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
    // subscription = _remoteConfig.onConfigUpdated.listen((event) async {
    //   await _remoteConfig.activate();

    //   setState(() {
    //     update = event;
    //     instance.setString('url', url!);
    //   });
    // });
  }

  @override
  void initState() {
    _initConfig();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: url != null
          ? WebViewWidgetUrl(
              url: url!,
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

// ignore: must_be_immutable
class WebViewWidgetUrl extends StatelessWidget {
  String url;
  WebViewWidgetUrl({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    print("somethingsomething");
    print(url);
    WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..loadRequest(Uri.parse(url));
    return WebViewWidget(controller: controller);
  }
}
