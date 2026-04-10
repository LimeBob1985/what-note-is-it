import 'package:flutter/material.dart';
import 'screens/home_page.dart'; // Punta alla nuova Home

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WhatNoteIsIt());
}

class WhatNoteIsIt extends StatelessWidget {
  const WhatNoteIsIt({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'What note is it?',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
      ),
      home: const HomePage(), // Ora la Home è di nuovo attiva
    );
  }
}