import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:icarus/const/youtube_handler.dart';

class YoutubeView extends StatefulWidget {
  const YoutubeView({
    super.key,
    required this.youtubeLink,
  });
  final String youtubeLink;

  @override
  State<YoutubeView> createState() => _YoutubeViewState();
}

class _YoutubeViewState extends State<YoutubeView>
    with AutomaticKeepAliveClientMixin {
  late final String _viewId;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final videoParam = YoutubeHandler.extractYoutubeIdWithTimestamp(
      widget.youtubeLink,
    );
    _viewId = 'yt-iframe-${identityHashCode(this)}';
    ui_web.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      return html.IFrameElement()
        ..src = 'https://www.youtube.com/embed/$videoParam'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..setAttribute(
          'allow',
          'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture',
        )
        ..allowFullscreen = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return HtmlElementView(viewType: _viewId);
  }
}
