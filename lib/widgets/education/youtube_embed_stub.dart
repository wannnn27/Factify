import 'package:flutter/material.dart';

void registerYouTubeIframe(String viewId, String? videoId) {}

Widget buildYouTubeView(String viewId) {
  return const ColoredBox(
    color: Colors.black,
    child: Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Pemutar YouTube tersedia di versi web. Untuk perangkat ini, gunakan video lokal.',
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}
