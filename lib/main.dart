import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
<<<<<<< HEAD
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding_screen.dart';
import 'models/app_state.dart';
=======
import 'theme/app_theme.dart';
import 'screens/onboarding_screen.dart';
>>>>>>> 5fd606cb57a6114a3116f136f5cf02c2f4a7e518

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D0D1A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
<<<<<<< HEAD
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const HeroQuestApp(),
    ),
  );
=======
  runApp(const HeroQuestApp());
>>>>>>> 5fd606cb57a6114a3116f136f5cf02c2f4a7e518
}

class HeroQuestApp extends StatelessWidget {
  const HeroQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HeroQuest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const OnboardingScreen(),
    );
  }
}
