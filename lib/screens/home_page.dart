import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Text(
                      "WHAT NOTE\nIS IT?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 3
                          ..color = Colors.orangeAccent.withValues(alpha: 0.3),
                      ),
                    ),
                    const Text(
                      "WHAT NOTE\nIS IT?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
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
                const SizedBox(height: 10),
                Container(width: 60, height: 4, color: Colors.orangeAccent),
                const SizedBox(height: 60),

                _mainButton(
                  context,
                  title: "GIOCA",
                  icon: Icons.play_arrow_rounded,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
                  },
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    _secondaryButton(
                      context,
                      title: "SCORE",
                      icon: Icons.emoji_events,
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ScoresPage())),
                    ),
                    const SizedBox(width: 20),
                    _secondaryButton(
                      context,
                      title: "STATISTICHE",
                      icon: Icons.bar_chart,
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StatsPage())),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _mainButton(BuildContext context, {required String title, required IconData icon, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orangeAccent,
          foregroundColor: Colors.black,
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 30),
        label: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _secondaryButton(BuildContext context, {required String title, required IconData icon, required VoidCallback onPressed}) {
    return Expanded(
      child: SizedBox(
        height: 60,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white24, width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.orangeAccent),
          label: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

// --- SCHERMATA PUNTEGGI (SCORES) ---
class ScoresPage extends StatelessWidget {
  const ScoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text("RECORD PERSONALI", style: TextStyle(fontWeight: FontWeight.bold)),
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
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final prefs = snapshot.data!;
            
            int score = prefs.getInt("last_score") ?? 0;
            int total = prefs.getInt("last_total") ?? 0;
            int correct = prefs.getInt("last_correct") ?? 0;
            int wrong = prefs.getInt("last_wrong") ?? 0;
            int bestIndovina = prefs.getInt("best_INDOVINA_12_0") ?? 0; 

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildScoreCard("ULTIMA SESSIONE", score, total, correct, wrong),
                const SizedBox(height: 20),
                _buildScoreCard("MIGLIOR RECORD (INDOVINA 12 T.)", bestIndovina, 0, 0, 0, isBest: true),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildScoreCard(String title, int score, int total, int correct, int wrong, {bool isBest = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isBest ? Colors.orangeAccent : Colors.white10),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text("$score", style: TextStyle(color: isBest ? Colors.orangeAccent : Colors.greenAccent, fontSize: 48, fontWeight: FontWeight.bold)),
          const Text("PUNTI", style: TextStyle(color: Colors.white24, fontSize: 12)),
          if (!isBest) ...[
            const Divider(height: 30, color: Colors.white10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statMini(total.toString(), "TOTALI"),
                _statMini(correct.toString(), "ESATTE", color: Colors.green),
                _statMini(wrong.toString(), "ERRORI", color: Colors.red),
              ],
            )
          ]
        ],
      ),
    );
  }

  Widget _statMini(String value, String label, {Color color = Colors.white}) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }
}

// --- SCHERMATA STATISTICHE (CON SCORRIMENTO ORIZZONTALE) ---
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
      
      double accuracy = prefs.getDouble("stats_accuracy_$dateStr") ?? 0.0;
      
      tempSpecs.add({
        "accuracy": accuracy,
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
    const months = ["Gen", "Feb", "Mar", "Apr", "Mag", "Giu", "Lug", "Ago", "Set", "Ott", "Nov", "Dic"];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text("PROGRESSI STORICI", style: TextStyle(fontWeight: FontWeight.bold)),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text("PRECISIONE NEL TEMPO", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                  ),
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
                            isToday: data['isToday']
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Center(child: Text("Scorri per vedere i giorni precedenti", style: TextStyle(color: Colors.white24, fontSize: 12))),
                ],
              ),
            ),
      ),
    );
  }

  Widget _bar(double heightFactor, String dayName, String dayNum, String month, {bool isToday = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text("${(heightFactor * 100).toInt()}%", 
            style: TextStyle(color: isToday ? Colors.blueAccent : Colors.white10, fontSize: 10, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 5),
          Container(
            width: 35,
            height: (MediaQuery.of(context).size.height * 0.4) * heightFactor + 4, 
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isToday 
                  ? [Colors.blueAccent, Colors.blue.shade900]
                  : [Colors.blueAccent.withValues(alpha: 0.3), Colors.blueAccent.withValues(alpha: 0.1)],
              ),
              borderRadius: BorderRadius.circular(6),
              border: isToday ? Border.all(color: Colors.white24) : null,
            ),
          ),
          const SizedBox(height: 10),
          Text(dayName, style: TextStyle(color: isToday ? Colors.white : Colors.white38, fontSize: 10)),
          Text("$dayNum $month", style: TextStyle(color: isToday ? Colors.blueAccent : Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}