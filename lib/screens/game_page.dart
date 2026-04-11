// lib/screens/game_page.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../widgets/guitar_neck_painter.dart';

class GamePage extends StatefulWidget {
  final int frets;
  final int? timer;
  final String mode; // "INDOVINA" o "TROVA"

  const GamePage({
    super.key,
    required this.frets,
    this.timer,
    required this.mode,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int correct = 0, wrong = 0, total = 0, timeLeft = 0, highScore = 0;
  Timer? _timer;
  late int currentString, currentFret;
  late String currentNoteIt;
  bool showHint = false;

  List<int> foundFrets = [];
  List<int> targetFrets = [];

  final List<int> stringOpenNotes = [4, 9, 2, 7, 11, 4];
  final List<String> notesIt = [
    "DO",
    "DO#/REb",
    "RE",
    "RE#/MIb",
    "MI",
    "FA",
    "FA#/SOLb",
    "SOL",
    "SOL#/LAb",
    "LA",
    "LA#/SIb",
    "SI"
  ];
  final List<String> notesEn = [
    "C",
    "C#/Db",
    "D",
    "D#/Eb",
    "E",
    "F",
    "F#/Gb",
    "G",
    "G#/Ab",
    "A",
    "A#/Bb",
    "B"
  ];
  final List<String> romanNumerals = ["VI", "V", "IV", "III", "II", "I"];

  @override
  void initState() {
    super.initState();
    loadHighScore();
    generateNewChallenge();
    if (widget.timer != null) startTimer();
  }

  Future<void> loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    String key = "best_${widget.mode}_${widget.frets}_${widget.timer ?? 0}";
    setState(() => highScore = prefs.getInt(key) ?? 0);
  }

  Future<void> updateHighScore() async {
    if (correct > highScore) {
      final prefs = await SharedPreferences.getInstance();
      String key = "best_${widget.mode}_${widget.frets}_${widget.timer ?? 0}";
      await prefs.setInt(key, correct);
      await prefs.setInt("${key}_correct", correct);
      await prefs.setInt("${key}_wrong", wrong);
      setState(() => highScore = correct);
    }
  }

  Future<void> _saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    final String today = DateTime.now().toString().split(' ')[0];

    await prefs.setInt("last_score", correct);
    await prefs.setInt("last_total", total);
    await prefs.setInt("last_correct", correct);
    await prefs.setInt("last_wrong", wrong);

    int savedCorrectToday = prefs.getInt("stats_correct_$today") ?? 0;
    int savedTotalToday = prefs.getInt("stats_total_$today") ?? 0;

    int currentTotalToday = savedTotalToday + total;
    int currentCorrectToday = savedCorrectToday + correct;

    double dailyAccuracy =
        currentTotalToday > 0 ? (currentCorrectToday / currentTotalToday) : 0.0;

    await prefs.setDouble("stats_accuracy_$today", dailyAccuracy);
    
    // Assicuriamoci di salvare anche i valori assoluti per la Home
    await prefs.setInt("stats_correct_$today", currentCorrectToday);
    await prefs.setInt("stats_total_$today", currentTotalToday);
  }

  Future<void> _finalizeSession() async {
    final prefs = await SharedPreferences.getInstance();
    final String today = DateTime.now().toString().split(' ')[0];

    int savedCorrectToday = prefs.getInt("stats_correct_$today") ?? 0;
    int savedTotalToday = prefs.getInt("stats_total_$today") ?? 0;

    await prefs.setInt("stats_correct_$today", savedCorrectToday + correct);
    await prefs.setInt("stats_total_$today", savedTotalToday + total);

    String? historyJson = prefs.getString("game_history");
    List<dynamic> history = historyJson != null ? jsonDecode(historyJson) : [];

    history.add({
      'score': correct,
      'correct': correct,
      'wrong': wrong,
      'date': DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
      'mode': "${widget.mode} - ${widget.frets} TASTI",
    });

    if (history.length > 50) history.removeAt(0);
    await prefs.setString("game_history", jsonEncode(history));
  }

  void startTimer() {
    timeLeft = widget.timer!;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft > 0) {
        if (mounted) setState(() => timeLeft--);
      } else {
        handleTimeout();
      }
    });
  }

  void handleGameOver() {
    _timer?.cancel();
    _saveStats();
    _finalizeSession();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF222222),
        title: const Text(
          "GAME OVER",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Hai commesso 3 errori.\nPunteggio finale: $correct",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              "TORNA AL MENU",
              style: TextStyle(color: Colors.orangeAccent),
            ),
          ),
        ],
      ),
    );
  }

  void handleTimeout() {
    setState(() {
      wrong++;
      total++;
      _saveStats();
      if (wrong >= 3) {
        handleGameOver();
      } else {
        generateNewChallenge();
        if (widget.timer != null) startTimer();
      }
    });
  }

  void generateNewChallenge() {
    setState(() {
      showHint = false;
      foundFrets.clear();
      currentString = Random().nextInt(6) + 1;
      currentFret = Random().nextInt(widget.frets + 1);

      int openNoteIndex = stringOpenNotes[currentString - 1];
      int noteIndex = (openNoteIndex + currentFret) % 12;
      currentNoteIt = notesIt[noteIndex];

      targetFrets.clear();
      for (int f = 0; f <= widget.frets; f++) {
        if ((openNoteIndex + f) % 12 == noteIndex) {
          targetFrets.add(f);
        }
      }
    });
  }

  void checkAnswer(dynamic answer) {
    if (widget.mode == "INDOVINA") {
      bool isCorrect = (answer as String) == currentNoteIt;
      setState(() {
        total++;
        if (isCorrect) {
          correct++;
          updateHighScore();
          _saveStats();
          generateNewChallenge();
          if (widget.timer != null) startTimer();
        } else {
          wrong++;
          _saveStats();
          if (wrong >= 3) {
            handleGameOver();
          }
        }
      });
    } else {
      int pressedFret = answer as int;
      if (targetFrets.contains(pressedFret)) {
        if (!foundFrets.contains(pressedFret)) {
          setState(() {
            foundFrets.add(pressedFret);
            if (foundFrets.length == targetFrets.length) {
              total++;
              correct++;
              updateHighScore();
              _saveStats();
              generateNewChallenge();
              if (widget.timer != null) startTimer();
            }
          });
        }
      } else {
        setState(() {
          total++;
          wrong++;
          _saveStats();
          if (wrong >= 3) {
            handleGameOver();
          }
        });
      }
    }
  }

  int _getFretFromY(double relativeY, double nutYRatio) {
    if (relativeY < nutYRatio) return 0;
    double currentPos = nutYRatio;
    double spacingFactor = widget.frets > 12 ? 0.96 : 0.9438;
    double tempLength = 1.0;
    double totalRelativeScale = 0;
    for (int i = 0; i < widget.frets; i++) {
      totalRelativeScale += tempLength;
      tempLength *= spacingFactor;
    }
    double unit = (1.0 - nutYRatio - 0.03) / totalRelativeScale;
    double currentFretStep = unit;
    for (int i = 1; i <= widget.frets; i++) {
      double nextPos = currentPos + currentFretStep;
      if (relativeY >= currentPos && relativeY <= nextPos) return i;
      currentPos = nextPos;
      currentFretStep *= spacingFactor;
    }
    return widget.frets;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String headerIndovina = "CHE NOTA È?";
    String headerTrova = "${romanNumerals[currentString - 1]} CORDA";

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      _saveStats();
                      _finalizeSession();
                      Navigator.pop(context);
                    },
                  ),
                  const Spacer(),
                  if (widget.mode == "INDOVINA")
                    Text(
                      showHint ? "NOTA: $currentNoteIt" : headerIndovina,
                      style: TextStyle(
                        color: showHint ? Colors.yellow : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  if (widget.mode == "TROVA")
                    Expanded(
                      child: Text(
                        headerTrova,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (widget.timer != null)
                    Text(
                      "⏳ $timeLeft",
                      style: TextStyle(
                        color: timeLeft <= 3 ? Colors.red : Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  IconButton(
                    icon: Icon(
                      Icons.lightbulb,
                      color: showHint ? Colors.yellow : Colors.white24,
                    ),
                    onPressed: () {
                      if (!showHint) {
                        setState(() {
                          showHint = true;
                          total++;
                          _saveStats();
                          Future.delayed(const Duration(milliseconds: 1500), () {
                            if (mounted) generateNewChallenge();
                          });
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return GestureDetector(
                          onTapDown: (details) {
                            if (widget.mode == "TROVA") {
                              double relY =
                                  details.localPosition.dy / constraints.maxHeight;
                              int clickedFret = _getFretFromY(relY, 0.05);
                              checkAnswer(clickedFret);
                            }
                          },
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: GuitarNeckPainter(
                              frets: widget.frets,
                              currentString: currentString,
                              currentFret:
                                  (widget.mode == "TROVA") ? -1 : currentFret,
                              showAllNotes:
                                  (widget.mode == "TROVA" && showHint),
                              targetNoteIndex: notesIt.indexOf(currentNoteIt),
                              openNoteIndex:
                                  stringOpenNotes[currentString - 1],
                              foundFrets: foundFrets,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(right: 15, top: 5, bottom: 5),
                      child: Column(
                        children: List.generate(12, (i) {
                          bool isTarget = notesIt[i] == currentNoteIt;
                          return Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 2),
                              child: Opacity(
                                opacity: (widget.mode == "TROVA" && !isTarget)
                                    ? 0.3
                                    : 1.0,
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFF222222),
                                      side: (widget.mode == "TROVA" &&
                                              isTarget)
                                          ? const BorderSide(
                                              color: Colors.orangeAccent,
                                              width: 2,
                                            )
                                          : BorderSide.none,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                    onPressed: widget.mode == "INDOVINA"
                                        ? () => checkAnswer(notesIt[i])
                                        : null,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          notesIt[i],
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          notesEn[i],
                                          style: const TextStyle(
                                            fontSize: 9,
                                            color: Colors.white38,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildFooterWithScore(),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterWithScore() {
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
          style: TextStyle(
            color: col.withOpacity(0.5),
            fontSize: 10,
          ),
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