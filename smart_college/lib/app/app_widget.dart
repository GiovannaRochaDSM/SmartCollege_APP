import 'package:flutter/material.dart';
import 'package:smart_college/app/pages/splash_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartCollege',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const SplashPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
