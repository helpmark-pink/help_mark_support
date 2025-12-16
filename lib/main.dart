import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  await NotificationService().requestPermission();
  runApp(const HelpMarkSupportApp());
}

class HelpMarkSupportApp extends StatelessWidget {
  const HelpMarkSupportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ヘルプマークサポート',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFFE8B4B8),
          onPrimary: Color(0xFF5D4E4E),
          secondary: Color(0xFFB8D4E3),
          onSecondary: Color(0xFF4E5A5D),
          tertiary: Color(0xFFD4E3B8),
          onTertiary: Color(0xFF4E5D4E),
          error: Color(0xFFE3B8B8),
          onError: Color(0xFF5D4E4E),
          surface: Color(0xFFFAF8F5),
          onSurface: Color(0xFF5D4E4E),
        ),
        scaffoldBackgroundColor: const Color(0xFFFAF8F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFE8B4B8),
          foregroundColor: Color(0xFF5D4E4E),
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFE8B4B8),
          foregroundColor: Color(0xFF5D4E4E),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}