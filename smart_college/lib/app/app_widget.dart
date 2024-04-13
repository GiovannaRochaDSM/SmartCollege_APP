import 'package:flutter/material.dart';
import 'package:smart_college/app/pages/subject_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu App Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SubjectScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
