import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../widgets/score_card.dart';

class ScoresPage extends StatefulWidget {
  const ScoresPage({super.key});

  @override
  State<ScoresPage> createState() => _ScoresPageState();
}

class _ScoresPageState extends State<ScoresPage> {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    String? historyJson = prefs.getString("game_history");
    if (historyJson != null) {
      List<dynamic> decoded = jsonDecode(historyJson);
      setState(() {
        _history = decoded.map((e) => Map<String, dynamic>.from(e)).toList().reversed.toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteScore(int index) async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _history.removeAt(index);
    });

    List<Map<String, dynamic>> originalOrder = _history.reversed.toList();
    await prefs.setString("game_history", jsonEncode(originalOrder));
  }

  bool _isNewDay(String prev, String next) {
    return prev.split(" ")[0] != next.split(" ")[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text("SCORE", style: TextStyle(fontWeight: FontWeight.bold)),
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
            if (!snapshot.hasData || _isLoading) return const Center(child: CircularProgressIndicator());
            
            final prefs = snapshot.data!;
            int bestScore = prefs.getInt("best_INDOVINA_12_0") ?? 0;
            int bestCorrect = prefs.getInt("best_INDOVINA_12_0_correct") ?? 0;
            int bestWrong = prefs.getInt("best_INDOVINA_12_0_wrong") ?? 0;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ScoreCard(
                    title: "MIGLIOR RECORD",
                    score: bestScore,
                    correct: bestCorrect,
                    wrong: bestWrong,
                    mode: "INDOVINA - 12 TASTI",
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
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      final game = _history[index];
                      bool showSeparator = false;
                      if (index > 0) {
                        showSeparator = _isNewDay(_history[index - 1]['date'] ?? "", game['date'] ?? "");
                      }

                      return Column(
                        children: [
                          if (showSeparator) _buildDateSeparator(game['date'] ?? ""),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Dismissible(
                              key: Key(game['date'] ?? index.toString()),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20), // Corretto qui
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withValues(alpha: 0.2), // Corretto qui
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
                              ),
                              onDismissed: (direction) => _deleteScore(index),
                              child: ScoreCard(
                                title: game['date'] ?? "Data sconosciuta",
                                score: game['score'] ?? 0,
                                correct: game['correct'] ?? 0,
                                wrong: game['wrong'] ?? 0,
                                mode: (game['mode'] ?? "N.D.").toString().toUpperCase(),
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildDateSeparator(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Colors.orangeAccent, thickness: 0.5)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              date.split(" ")[0],
              style: const TextStyle(color: Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const Expanded(child: Divider(color: Colors.orangeAccent, thickness: 0.5)),
        ],
      ),
    );
  }
}