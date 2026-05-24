import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// PENTING: Pastikan nama package di bawah ini sesuai dengan nama di pubspec.yaml Anda.
// Jika di pubspec.yaml name: factify, maka gunakan 'package:factify/main.dart'
// Jika masih default, mungkin 'package:myapp/main.dart'
import 'package:factify/main.dart';

void main() {
  testWidgets('App starts with Splash Screen smoke test',
      (WidgetTester tester) async {
    // 1. Jalankan aplikasi (MyApp)
    await tester.pumpWidget(const MyApp());

    // 2. Karena aplikasi dimulai dengan SplashScreen, kita cek apakah
    // Ikon Logo (Icons.verified_user_rounded) muncul di layar.
    expect(find.byIcon(Icons.verified_user_rounded), findsOneWidget);

    // Kita tidak mengecek teks "Factify" langsung karena di Splash Screen
    // teks tersebut muncul menggunakan animasi (AnimatedOpacity),
    // jadi mungkin belum terbaca di milidetik pertama render.
  });
}
