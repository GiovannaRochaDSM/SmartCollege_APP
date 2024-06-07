import 'package:flutter/material.dart';
import 'package:smart_college/app/pages/login_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartCollege',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      // home: ResetPasswordModal(token: '', email: ''),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
