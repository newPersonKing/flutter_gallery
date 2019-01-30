
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gallery/gallery/demos.dart';
import 'package:flutter_gallery/gallery/home.dart';
import 'package:flutter_gallery/gallery/options.dart';
import 'package:flutter_gallery/gallery/scales.dart';
import 'package:flutter_gallery/gallery/themes.dart';
import 'package:flutter_gallery/gallery/updater.dart';
import 'package:url_launcher/url_launcher.dart';

class GalleryApp extends StatefulWidget{

  final UpdateUrlFetcher updateUrlFetcher;
  final bool enablePerformanceOverlay;
  final bool enableRasterCacheImagesCheckerboard;
  final bool enableOffscreenLayersCheckerboard;
  final VoidCallback onSendFeedback;
  final bool testMode;

  /*const 常量构造哈数*/
  const GalleryApp({
    Key key,
    this.updateUrlFetcher,
    this.enablePerformanceOverlay = true,
    this.enableRasterCacheImagesCheckerboard = true,
    this.enableOffscreenLayersCheckerboard = true,
    this.onSendFeedback,
    this.testMode = false,
  }) : super(key:key);

  @override
  State<StatefulWidget> createState() {

    return _GalleryAppState();
  }
}

class _GalleryAppState extends State<GalleryApp>{

  GalleryOptions _options;
  Timer _timeDilationTimer;

  Map<String, WidgetBuilder> _buildRoutes() {
    return Map<String,WidgetBuilder>.fromIterable(
    kAllGalleryDemos,
    key: (dynamic demo) => '${demo.routeName}',
    value: (dynamic demo) => demo.buildRoute);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _options = GalleryOptions(
      theme: kLightGalleryTheme,
      textScaleFactor: kAllGalleryTextScaleValues[0],
      timeDilation: timeDilation,
      platform: defaultTargetPlatform,
    );
  }

  @override
  void dispose() {
    _timeDilationTimer?.cancel();
    _timeDilationTimer = null;
    super.dispose();
  }

  void _handleOptionsChanged(GalleryOptions newOptions) {
    setState(() {
      if (_options.timeDilation != newOptions.timeDilation) {
        _timeDilationTimer?.cancel();
        _timeDilationTimer = null;
        if (newOptions.timeDilation > 1.0) {
          // We delay the time dilation change long enough that the user can see
          // that UI has started reacting and then we slam on the brakes so that
          // they see that the time is in fact now dilated.
          _timeDilationTimer = Timer(const Duration(milliseconds: 150), () {
            timeDilation = newOptions.timeDilation;
          });
        } else {
          timeDilation = newOptions.timeDilation;
        }
      }

      _options = newOptions;
    });
  }

  Widget _applyTextScaleFactor(Widget child) {
    return Builder(
      builder: (BuildContext context) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: _options.textScaleFactor.scale,
          ),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget home = GalleryHome(
      testMode: widget.testMode,
      optionsPage: GalleryOptionsPage(
        options: _options,
        onOptionsChanged: _handleOptionsChanged,
        onSendFeedback: widget.onSendFeedback ?? () {
          launch('https://github.com/flutter/flutter/issues/new/choose', forceSafariVC: false);
        },
      ),
    );

    if (widget.updateUrlFetcher != null) {
      home = Updater(
        updateUrlFetcher: widget.updateUrlFetcher,
        child: home,
      );
    }

    return MaterialApp(
      theme: _options.theme.data.copyWith(platform: _options.platform),
      title: 'Flutter Gallery',
      color: Colors.grey,
      showPerformanceOverlay: _options.showPerformanceOverlay,
      checkerboardOffscreenLayers: _options.showOffscreenLayersCheckerboard,
      checkerboardRasterCacheImages: _options.showRasterCacheImagesCheckerboard,
      routes: _buildRoutes(),
      builder: (BuildContext context, Widget child) {/*builder 生成最终路由的外壳 child 应该是每个路由对应的view*/
        return Directionality(
          textDirection: _options.textDirection,
          child: _applyTextScaleFactor(child),
        );
      },
      home: home,
    );
  }
}