import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'scores_page.dart'; 
import 'stats_page.dart';  
import '../widgets/menu_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildLogo(),
                const SizedBox(height: 50),
                MenuButton(
                  title: "GIOCA",
                  icon: Icons.play_arrow_rounded,
                  isMain: true,
                  onPressed: () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const SettingsPage())
                  ),
                ),
                const SizedBox(height: 15),
                MenuButton(
                  title: "SCORE",
                  icon: Icons.emoji_events,
                  onPressed: () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const ScoresPage())
                  ),
                ),
                const SizedBox(height: 15),
                MenuButton(
                  title: "STATS",
                  icon: Icons.bar_chart,
                  onPressed: () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const StatsPage())
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Stack(
      children: [
        Text(
          "WHAT\nNOTE\nIS IT?",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 40,
            height: 1.1,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = Colors.orangeAccent.withValues(alpha: 0.3),
          ),
        ),
        const Text(
          "WHAT\nNOTE\nIS IT?",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 40,
            height: 1.1,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            shadows: [
              Shadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 5),
              Shadow(color: Colors.orangeAccent, offset: Offset(-1, -1), blurRadius: 1),
            ],
          ),
        ),
      ],
    );
  }
}