import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../widgets/score_card.dart';

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
        title: const Text("SCORE STORICI", style: TextStyle(fontWeight: FontWeight.bold)),
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
                            showSeparator = _isNewDay(history[index - 1]['date'] ?? "", game['date'] ?? "");
                          }

                          return Column(
                            children: [
                              if (showSeparator) _buildDateSeparator(game['date'] ?? ""),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ScoreCard(
                                  title: game['date'] ?? "Data sconosciuta",
                                  score: game['score'] ?? 0,
                                  correct: game['correct'] ?? 0,
                                  wrong: game['wrong'] ?? 0,
                                  mode: (game['mode'] ?? "N.D.").toString().toUpperCase(),
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