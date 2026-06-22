import 'package:flutter/material.dart';

import 'home_screen.dart';

void main() {
  runApp(const AksharizeApp());
}

class AksharizeApp extends StatelessWidget {
  const AksharizeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aksharize OCR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
