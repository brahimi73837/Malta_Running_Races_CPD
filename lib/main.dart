import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:malta_running_races/screens/navigator.dart';


final theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: const Color.fromARGB(255, 255, 165, 0)),
  textTheme: GoogleFonts.robotoCondensedTextTheme(),
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      home: const NavigatorScreen(),
    );
  }
}