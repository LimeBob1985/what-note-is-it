import 'package:flutter/material.dart';

class GameScoreFooter extends StatelessWidget {
  final int correct;
  final int total;
  final int wrong;

  const GameScoreFooter({
    super.key,
    required this.correct,
    required this.total,
    required this.wrong,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      width: double.infinity,
      color: Colors.black,
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _statWithLabel("PUNTI", correct, Colors.green),
            _statWithLabel("TOTALE", total, Colors.white, isBig: true),
            _statWithLabel("ERRORI", wrong, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _statWithLabel(String label, int val, Color col, {bool isBig = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(color: col.withOpacity(0.5), fontSize: 10),
        ),
        Text(
          "$val",
          style: TextStyle(
            color: col,
            fontSize: isBig ? 28 : 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}