// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar styling
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:           Colors.transparent,
    statusBarIconBrightness:  Brightness.light,
    systemNavigationBarColor: Color(0xFF080810),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialise singleton API client
  ApiClient.instance.init();

  runApp(const ApexSpeechApp());
}

class ApexSpeechApp extends StatelessWidget {
  const ApexSpeechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title:            'Apex Speech',
      debugShowCheckedModeBanner: false,
      theme:            AppTheme.dark,
      routerConfig:     AppRouter.router,
    );
  }
}
