import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'helpers/app_colors.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/playback_screen.dart';
import 'screens/recordings_screen.dart';
import 'screens/progress_dashboard_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/recording_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.obsidian,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const ApexSpeechApp());
}

class ApexSpeechApp extends StatelessWidget {
  const ApexSpeechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Apex Speech',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.obsidian,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.purpleLight,
          onPrimary: Colors.white,
          secondary: AppColors.goldRoyal,
          surface: AppColors.cardDark,
          onSurface: AppColors.textPrimary,
        ),
        textTheme: GoogleFonts.outfitTextTheme().apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surfaceDark,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.purpleLight),
          titleTextStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.purpleLight,
            letterSpacing: 1.2,
          ),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderDark),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.purpleLight, width: 1.5),
          ),
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          hintStyle: const TextStyle(color: AppColors.textMuted),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.purpleLight,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.cardDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.borderDark),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/':           (context) => const SplashScreen(),
        '/login':      (context) => const LoginScreen(),
        '/signup':     (context) => const SignupScreen(),
        '/home':       (context) => const HomeScreen(),
        '/feedback':   (context) => const FeedbackScreen(),
        '/playback':   (context) => const PlaybackScreen(),
        '/recordings': (context) => const RecordingsScreen(),
        '/progress':   (context) => const ProgressDashboardScreen(),
        '/profile':    (context) => const ProfileScreen(),
      },
    );
  }
}
