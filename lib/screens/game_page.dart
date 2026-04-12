// lib/screens/game_page.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart'; 

import '../models/music_logic.dart';
import '../widgets/game_score_footer.dart';
import '../widgets/guitar_neck_painter.dart';

class GamePage extends StatefulWidget {
  final int frets;
  final int? timer;
  final String mode; 
  final List<int>? lockedStrings; // MODIFICATO: Accetta una lista di corde

  const GamePage({
    super.key,
    required this.frets,
    this.timer,
    required this.mode,
    this.lockedStrings, 
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

  @override
  void initState() {
    super.initState();
    loadHighScore();
    generateNewChallenge();
    if (widget.timer != null) startTimer();
  }

  void _triggerVibration(bool isCorrect) {
    if (isCorrect) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.vibrate();
    }
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

  Future<void> _saveStats(bool isCorrect) async {
    final prefs = await SharedPreferences.getInstance();
    final String today = DateTime.now().toString().split(' ')[0];

    await prefs.setInt("last_score", correct);
    await prefs.setInt("last_total", total);
    await prefs.setInt("last_correct", correct);
    await prefs.setInt("last_wrong", wrong);

    int savedCorrectToday = prefs.getInt("stats_correct_$today") ?? 0;
    int savedTotalToday = prefs.getInt("stats_total_$today") ?? 0;

    int currentTotalToday = savedTotalToday + 1;
    int currentCorrectToday = isCorrect ? (savedCorrectToday + 1) : savedCorrectToday;

    double dailyAccuracy = currentTotalToday > 0 ? currentCorrectToday / currentTotalToday : 0.0;

    await prefs.setDouble("stats_accuracy_$today", dailyAccuracy);
    await prefs.setInt("stats_correct_$today", currentCorrectToday);
    await prefs.setInt("stats_total_$today", currentTotalToday);
  }

  Future<void> _finalizeSession() async {
    final prefs = await SharedPreferences.getInstance();
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
    _finalizeSession();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF222222),
        title: const Text("GAME OVER", textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: Text("Hai commesso 3 errori.\nPunteggio finale: $correct", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("TORNA AL MENU", style: TextStyle(color: Colors.orangeAccent)),
          ),
        ],
      ),
    );
  }

  void handleTimeout() {
    _triggerVibration(false); 
    setState(() {
      wrong++;
      total++;
      _saveStats(false);
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
      
      if (widget.lockedStrings != null && widget.lockedStrings!.isNotEmpty) {
        currentString = widget.lockedStrings![Random().nextInt(widget.lockedStrings!.length)];
      } else {
        currentString = Random().nextInt(6) + 1;
      }
      
      currentFret = Random().nextInt(widget.frets + 1);

      int noteIndex = MusicLogic.getNoteIndex(currentString, currentFret);
      currentNoteIt = MusicLogic.notesIt[noteIndex];

      targetFrets.clear();
      int openNoteIndex = MusicLogic.stringOpenNotes[currentString - 1];
      for (int f = 0; f <= widget.frets; f++) {
        if ((openNoteIndex + f) % 12 == noteIndex) {
          targetFrets.add(f);
        }
      }
    });
  }

  void checkAnswer(dynamic answer) {
    setState(() {
      if (widget.mode == "INDOVINA") {
        bool isCorrect = (answer as String) == currentNoteIt;
        _triggerVibration(isCorrect);
        total++;
        _saveStats(isCorrect);
        if (isCorrect) {
          correct++;
          updateHighScore();
          generateNewChallenge();
          if (widget.timer != null) startTimer();
        } else {
          wrong++;
          if (wrong >= 3) handleGameOver();
        }
      } else {
        int pressedFret = answer as int;
        if (targetFrets.contains(pressedFret)) {
          if (!foundFrets.contains(pressedFret)) {
            _triggerVibration(true);
            foundFrets.add(pressedFret);
            if (foundFrets.length == targetFrets.length) {
              total++;
              correct++;
              _saveStats(true);
              updateHighScore();
              generateNewChallenge();
              if (widget.timer != null) startTimer();
            }
          }
        } else {
          _triggerVibration(false);
          total++;
          wrong++;
          _saveStats(false);
          if (wrong >= 3) handleGameOver();
        }
      }
    });
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
    bool hasLockedStrings = widget.lockedStrings != null && widget.lockedStrings!.isNotEmpty;
    
    // MODIFICA RICHIESTA: In modalità INDOVINA scrivi sempre "CHE NOTA È?" in bianco.
    String headerIndovina = "CHE NOTA È?";
    String headerTrova = "${MusicLogic.romanNumerals[currentString - 1]} CORDA";

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
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    onPressed: () {
                      _finalizeSession();
                      Navigator.pop(context);
                    },
                  ),
                  const Spacer(),
                  Text(
                    widget.mode == "INDOVINA" 
                      ? (showHint ? "NOTA: $currentNoteIt" : headerIndovina)
                      : headerTrova,
                    style: TextStyle(
                      color: (widget.mode == "INDOVINA" && showHint) 
                          ? Colors.yellow 
                          : (widget.mode == "TROVA" ? Colors.orangeAccent : Colors.white),
                      fontWeight: FontWeight.bold,
                      fontSize: (widget.mode == "TROVA") ? 18 : 14,
                    ),
                  ),
                  const Spacer(),
                  if (widget.timer != null)
                    Text("⏳ $timeLeft", style: TextStyle(color: timeLeft <= 3 ? Colors.red : Colors.orange, fontWeight: FontWeight.bold, fontSize: 18)),
                  IconButton(
                    icon: Icon(Icons.lightbulb, color: showHint ? Colors.yellow : Colors.white24),
                    onPressed: () {
                      if (!showHint) {
                        HapticFeedback.heavyImpact();
                        setState(() {
                          showHint = true;
                          total++;
                          _saveStats(false);
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
                              HapticFeedback.selectionClick(); 
                              double relY = details.localPosition.dy / constraints.maxHeight;
                              int clickedFret = _getFretFromY(relY, 0.05);
                              checkAnswer(clickedFret);
                            }
                          },
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: GuitarNeckPainter(
                              frets: widget.frets,
                              currentString: currentString,
                              currentFret: (widget.mode == "TROVA") ? -1 : currentFret,
                              showAllNotes: (widget.mode == "TROVA" && showHint),
                              targetNoteIndex: MusicLogic.notesIt.indexOf(currentNoteIt),
                              openNoteIndex: MusicLogic.stringOpenNotes[currentString - 1],
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
                      padding: const EdgeInsets.only(right: 15, top: 5, bottom: 5),
                      child: Column(
                        children: List.generate(12, (i) {
                          bool isTarget = MusicLogic.notesIt[i] == currentNoteIt;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Opacity(
                                opacity: (widget.mode == "TROVA" && !isTarget) ? 0.3 : 1.0,
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF222222),
                                      side: (widget.mode == "TROVA" && isTarget) ? const BorderSide(color: Colors.orangeAccent, width: 2) : BorderSide.none,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: EdgeInsets.zero,
                                    ),
                                    onPressed: widget.mode == "INDOVINA" ? () => checkAnswer(MusicLogic.notesIt[i]) : null,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(MusicLogic.notesIt[i], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                                        Text(MusicLogic.notesEn[i], style: const TextStyle(fontSize: 9, color: Colors.white38)),
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
            GameScoreFooter(correct: correct, total: total, wrong: wrong),
          ],
        ),
      ),
    );
  }
}