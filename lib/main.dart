import 'package:flutter/material.dart';
import 'package:tononkira_mobile/config/app_theme.dart';
import 'package:tononkira_mobile/features/home/page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Tononkira'),
    );
  }
}
