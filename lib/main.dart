import 'package:flutter/material.dart';
import 'pages/home_page.dart'; // ⬅️ Import de ta page

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CESIZen',
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}