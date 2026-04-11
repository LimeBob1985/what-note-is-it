// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Stack(
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
                ),
                const SizedBox(height: 20),
                Container(width: 60, height: 4, color: Colors.orangeAccent),
                const SizedBox(height: 60),
                _mainButton(
                  context,
                  title: "GIOCA",
                  icon: Icons.play_arrow_rounded,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsPage()),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _secondaryButton(
                  context,
                  title: "SCORE",
                  icon: Icons.emoji_events,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ScoresPage()),
                  ),
                ),
                const SizedBox(height: 20),
                _secondaryButton(
                  context,
                  title: "STATS",
                  icon: Icons.bar_chart,
                  fontSize: 11,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StatsPage()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _mainButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orangeAccent,
          foregroundColor: Colors.black,
          padding: EdgeInsets.zero,
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _secondaryButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
    double fontSize = 12,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          side: const BorderSide(color: Colors.white24, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.orangeAccent, size: 24),
            Text(
              title,
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class ScoresPage extends StatelessWidget {
  const ScoresPage({super.key});

  Future<List<Map<String, dynamic>>> _getGameHistory(SharedPreferences prefs) async {
    String? historyJson = prefs.getString("game_history");
    if (historyJson == null) return [];
    List<dynamic> decoded = jsonDecode(historyJson);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList().reversed.toList();
  }

  bool _isNewDay(String prev, String next) {
    return prev.split(" ")[0] != next.split(" ")[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text(
          "SCORE STORICI",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.orangeAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<SharedPreferences>(
          future: SharedPreferences.getInstance(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final prefs = snapshot.data!;
            int bestScore = prefs.getInt("best_INDOVINA_12_0") ?? 0;
            int bestCorrect = prefs.getInt("best_INDOVINA_12_0_correct") ?? 0;
            int bestWrong = prefs.getInt("best_INDOVINA_12_0_wrong") ?? 0;

            return Column(
              children: [
                // --- RECORD FISSO IN ALTO (Fuori dallo Scroll) ---
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildScoreCard(
                    "MIGLIOR RECORD",
                    bestScore,
                    bestCorrect,
                    bestWrong,
                    "INDOVINA - 12 TASTI",
                    isBest: true,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text("CRONOLOGIA", style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Expanded(child: Divider(color: Colors.white10)),
                    ],
                  ),
                ),
                // --- LISTA STORICO SCROLLABILE ---
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _getGameHistory(prefs),
                    builder: (context, historySnapshot) {
                      final history = historySnapshot.data ?? [];
                      return ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final game = history[index];
                          bool showSeparator = false;
                          if (index > 0) {
                            final prev = history[index - 1]['date'] ?? "";
                            final curr = game['date'] ?? "";
                            showSeparator = _isNewDay(prev, curr);
                          }

                          return Column(
                            children: [
                              if (showSeparator)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  child: Row(
                                    children: [
                                      const Expanded(child: Divider(color: Colors.orangeAccent, thickness: 0.5)),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: Text(
                                          (game['date'] ?? "").split(" ")[0],
                                          style: const TextStyle(color: Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const Expanded(child: Divider(color: Colors.orangeAccent, thickness: 0.5)),
                                    ],
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildScoreCard(
                                  game['date'] ?? "Data sconosciuta",
                                  game['score'] ?? 0,
                                  game['correct'] ?? 0,
                                  game['wrong'] ?? 0,
                                  (game['mode'] ?? "N.D.").toString().toUpperCase(),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildScoreCard(
    String title,
    int score,
    int correct,
    int wrong,
    String mode, {
    bool isBest = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isBest ? Colors.orangeAccent : Colors.white10,
          width: isBest ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: isBest ? Colors.orangeAccent : Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              if (isBest)
                const Icon(
                  Icons.star,
                  color: Colors.orangeAccent,
                  size: 14,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$score",
                    style: TextStyle(
                      color: isBest ? Colors.orangeAccent : Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  const Text(
                    "PUNTI TOTALI",
                    style: TextStyle(
                      color: Colors.white24,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    mode,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 7,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _statMini(
                        correct.toString(),
                        "ESATTE",
                        color: Colors.greenAccent,
                      ),
                      const SizedBox(width: 15),
                      _statMini(
                        wrong.toString(),
                        "ERRATE",
                        color: Colors.redAccent,
                      ),
                      const SizedBox(width: 15),
                      _statMini(
                        (correct + wrong).toString(),
                        "DATE",
                        color: Colors.blueAccent,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statMini(String value, String label, {Color color = Colors.white}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 7,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  List<Map<String, dynamic>> historicalData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistoricalStats();
  }

  Future<void> _loadHistoricalStats() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> tempSpecs = [];

    for (int i = 29; i >= 0; i--) {
      DateTime date = DateTime.now().subtract(Duration(days: i));
      String dateStr = date.toString().split(' ')[0];

      int correctToday = prefs.getInt("stats_correct_$dateStr") ?? 0;
      int totalToday = prefs.getInt("stats_total_$dateStr") ?? 0;
      double accuracy = prefs.getDouble("stats_accuracy_$dateStr") ?? 0.0;

      if (accuracy == 0 && totalToday > 0) {
        accuracy = correctToday / totalToday;
      }

      bool hasPlayed = totalToday > 0;

      tempSpecs.add({
        "accuracy": accuracy,
        "hasPlayed": hasPlayed,
        "dayName": _getDayName(date.weekday),
        "dayNumber": date.day,
        "monthName": _getMonthName(date.month),
        "isToday": i == 0,
      });
    }

    setState(() {
      historicalData = tempSpecs;
      isLoading = false;
    });
  }

  String _getDayName(int weekday) {
    const names = ["Lun", "Mar", "Mer", "Gio", "Ven", "Sab", "Dom"];
    return names[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      "Gen", "Feb", "Mar", "Apr", "Mag", "Giu",
      "Lug", "Ago", "Set", "Ott", "Nov", "Dic"
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text(
          "PROGRESSI STORICI",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        reverse: true,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: historicalData.map((data) {
                            return _bar(
                              data['accuracy'],
                              data['dayName'],
                              data['dayNumber'].toString(),
                              data['monthName'],
                              isToday: data['isToday'],
                              hasPlayed: data['hasPlayed'],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // --- GRAFICO A LINEE (Andamento temporale) ---
                    SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: CustomPaint(
                          painter: _LineChartPainter(historicalData),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        "Scorri per vedere i giorni precedenti",
                        style: TextStyle(color: Colors.white24, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _bar(
    double accuracy,
    String dayName,
    String dayNum,
    String month, {
    bool isToday = false,
    bool hasPlayed = false,
  }) {
    const double barHeight = 150.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            hasPlayed ? "${(accuracy * 100).toInt()}%" : "",
            style: TextStyle(
              color: isToday ? Colors.blueAccent : Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 30,
              height: barHeight,
              color: hasPlayed
                  ? Colors.redAccent.withOpacity(0.1)
                  : Colors.white.withOpacity(0.03),
              child: hasPlayed
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 30,
                          height: barHeight * accuracy,
                          color: Colors.blueAccent.withOpacity(0.8),
                        ),
                      ],
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            dayName,
            style: TextStyle(
              color: isToday ? Colors.white : Colors.white38,
              fontSize: 10,
            ),
          ),
          Text(
            "$dayNum $month",
            style: TextStyle(
              color: isToday ? Colors.blueAccent : Colors.white24,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  _LineChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paintLine = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintPoint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    double maxH = size.height;
    double stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      double acc = (data[i]['accuracy'] ?? 0.0).toDouble();
      double x = i * stepX;
      double y = maxH - (acc * maxH);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      
      // Disegna un cerchietto solo sui giorni in cui ha effettivamente giocato
      if (data[i]['hasPlayed']) {
        canvas.drawCircle(Offset(x, y), 3, paintPoint);
      }
    }

    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}