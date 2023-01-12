import 'package:flutter/material.dart';
import 'package:inspireui/widgets/platform_error/platform_error.dart';
//import 'package:client/inspireui.dart' show PlatformError;
import 'package:webview_flutter/webview_flutter.dart';

import '../../common/constants.dart';
import '../common/app_bar_mixin.dart';

class StaticSite extends StatefulWidget {
  final String? data;

  const StaticSite({this.data});

  @override
  State<StaticSite> createState() => _StaticSiteState();
}

class _StaticSiteState extends State<StaticSite> with AppBarMixin {
  @override
  Widget build(BuildContext context) {
    return renderScaffold(
      routeName: RouteList.html,
      body: !isMobile
          ? const PlatformError()
          : SafeArea(
              child: WebView(
                onWebViewCreated: (controller) async {
                  await controller
                      .loadUrl('data:text/html;base64,${widget.data}');
                },
              ),
            ),
    );
  }
}
