import 'package:flutter/material.dart';
import 'pages/home_page.dart'; // ⬅️ Import de ta page

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // ✅ propre aussi ici

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CESIZen',
      home: HomePage(), // ✅ usage constant
      debugShowCheckedModeBanner: false,
    );
  }
}
