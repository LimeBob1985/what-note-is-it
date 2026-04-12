import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necessario per bloccare l'orientamento
import 'screens/home_page.dart';

void main() {
  // 1. Assicura che i servizi Flutter siano pronti
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Blocca l'app in verticale (Portrait) per non sballare i disegni del CustomPainter
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const WhatNoteIsIt());
  });
}

class WhatNoteIsIt extends StatelessWidget {
  const WhatNoteIsIt({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'What Note Is It?',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        // Definiamo il colore primario per Switch e bottoni
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orangeAccent,
          brightness: Brightness.dark,
          surface: const Color(0xFF0F0F0F),
        ),
      ),
      home: const HomePage(),
    );
  }
}