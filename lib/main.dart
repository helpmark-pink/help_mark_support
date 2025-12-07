import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
          primary: Color(0xFFFDE047),
          onPrimary: Color(0xFF422006),
          secondary: Color(0xFFFACC15),
          onSecondary: Color(0xFF422006),
          error: Color(0xFFFCA5A5),
          onError: Color(0xFF422006),
          surface: Color(0xFFFFFEF0),
          onSurface: Color(0xFF422006),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFEF0),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFDE047),
          foregroundColor: Color(0xFF422006),
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}