import 'package:flutter/material.dart';

class ScoreCard extends StatelessWidget {
  final String title;
  final int score;
  final int correct;
  final int wrong;
  final String mode;
  final bool isBest;

  const ScoreCard({
    super.key,
    required this.title,
    required this.score,
    required this.correct,
    required this.wrong,
    required this.mode,
    this.isBest = false,
  });

  @override
  Widget build(BuildContext context) {
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
              Text(title.toUpperCase(),
                  style: TextStyle(
                      color: isBest ? Colors.orangeAccent : Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
              if (isBest) const Icon(Icons.star, color: Colors.orangeAccent, size: 14),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _scoreSection(),
              _statsSection(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _scoreSection() {
    // --- MODIFICA COLORE: Usiamo Colors.orangeAccent per uniformità con SCORE ---
    final Color scoreColor = isBest ? Colors.orangeAccent : const Color(0xFF448AFF); // BlueAccent standard

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$score",
            style: TextStyle(
                color: scoreColor,
                fontSize: 34,
                fontWeight: FontWeight.w900,
                height: 1)),
        const Text("PUNTI TOTALI",
            style: TextStyle(
                color: Colors.white24, fontSize: 8, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _statsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(mode,
            style: const TextStyle(
                color: Colors.white38, fontSize: 7, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(
          children: [
            // Ordine richiesto: ESATTE (verde) | DATE (bianco) | ERRATE (rosso)
            _miniStat(correct.toString(), "ESATTE", Colors.greenAccent),
            const SizedBox(width: 15),
            _miniStat((correct + wrong).toString(), "DATE", Colors.white),
            const SizedBox(width: 15),
            _miniStat(wrong.toString(), "ERRATE", Colors.redAccent),
          ],
        ),
      ],
    );
  }

  Widget _miniStat(String val, String label, Color color) {
    return Column(
      children: [
        Text(val,
            style: TextStyle(
                color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(
                color: Colors.white38, fontSize: 7, fontWeight: FontWeight.bold)),
      ],
    );
  }
}