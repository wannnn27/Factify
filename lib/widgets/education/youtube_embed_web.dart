// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';

void registerYouTubeIframe(String viewId, String? videoId) {
  if (videoId == null || videoId.isEmpty) return;

  ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
    return html.IFrameElement()
      ..src =
          'https://www.youtube.com/embed/$videoId?autoplay=1&mute=0&playsinline=1&controls=1&rel=0'
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allow = 'autoplay; fullscreen; encrypted-media; picture-in-picture';
  });
}

Widget buildYouTubeView(String viewId) {
  return HtmlElementView(viewType: viewId);
}
