import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lumigen/splashScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const Color primaryColor = Color(0xFFDBAD6A);
  static const Color secondaryColor = Color(0xFF89A9C0);
  static const Color accentColor = Color(0xFF2BA84A);
  static const Color backgroundColor = Color(0xFF2D3A32);
  static const Color surfaceColor = Color(0xFF248232);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Raleway',
        colorScheme: const ColorScheme(
            primary: primaryColor,
            secondary: secondaryColor,
            surface: surfaceColor,
            background: backgroundColor,
            error: Colors.red,
            onPrimary: Colors.black,
            onSecondary: Colors.black,
            onBackground: Colors.white,
            onSurface: Colors.white,
            onError: Colors.white,
            brightness: Brightness.light
        ),

        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}