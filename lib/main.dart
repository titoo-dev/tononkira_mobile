import 'package:flutter/material.dart';
import 'package:tononkira_mobile/config/app_theme.dart';
import 'package:tononkira_mobile/config/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Tononkira',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      // Use the router configuration from AppRoutes
      routerConfig: AppRoutes.router,
    );
  }
}
