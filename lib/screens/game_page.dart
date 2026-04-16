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
  final List<int>? lockedStrings;

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

class _GamePageState extends State<GamePage> with SingleTickerProviderStateMixin {
  int correct = 0, wrong = 0, total = 0, timeLeft = 0, highScore = 0;
  Timer? _timer;
  late int currentString, currentFret;
  late String currentNoteIt;
  bool showHint = false;

  List<int> foundFrets = [];
  List<int> targetFrets = [];

  late AnimationController _animationController;
  int _fretFoundIdx = -1; 
  int _stringFoundIdx = -1; 
  bool _isAnimatingFound = false;

  @override
  void initState() {
    super.initState();
    loadHighScore();
    generateNewChallenge();
    if (widget.timer != null) startTimer();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(() => setState(() {}));

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _isAnimatingFound = false;
            _fretFoundIdx = -1;
            _stringFoundIdx = -1;
            _animationController.reset();
          });
        }
      }
    });
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
      
      // Salva il punteggio totale
      await prefs.setInt(key, correct);
      
      // SALVATAGGIO PARAMETRI DETTAGLIATI RECORD
      await prefs.setInt("${key}_correct", correct);
      await prefs.setInt("${key}_wrong", wrong);
      
      setState(() => highScore = correct);
    }
  }

  Future<void> _saveStats(bool isCorrect) async {
    final prefs = await SharedPreferences.getInstance();
    final String today = DateTime.now().toString().split(' ')[0];
    int savedCorrectToday = prefs.getInt("stats_correct_$today") ?? 0;
    int savedTotalToday = prefs.getInt("stats_total_$today") ?? 0;

    await prefs.setInt("stats_correct_$today", isCorrect ? savedCorrectToday + 1 : savedCorrectToday);
    await prefs.setInt("stats_total_$today", savedTotalToday + 1);
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
    updateHighScore(); // Assicura che l'ultimo record sia salvato prima di chiudere
    _finalizeSession();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF222222),
        title: const Text(
          "GAME OVER", 
          textAlign: TextAlign.center, 
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
        ),
        content: Text(
          "Hai commesso 3 errori.\nPunteggio finale: $correct", 
          textAlign: TextAlign.center, 
          style: const TextStyle(color: Colors.white)
        ),
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
          updateHighScore(); // Aggiorna per includere l'errore nel record se il punteggio era alto
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
          updateHighScore();
          if (wrong >= 3) handleGameOver();
        }
      }
    });
  }

  int _getFretFromY(double relativeY, double nutYRatio) {
    if (relativeY < nutYRatio) return 0;
    double currentPos = nutYRatio;
    double spacingFactor = widget.frets > 12 ? 0.962 : 0.945;
    double tempLength = 1.0;
    double totalRelativeScale = 0;
    for (int i = 0; i < widget.frets; i++) {
      totalRelativeScale += tempLength;
      tempLength *= spacingFactor;
    }
    double unit = (1.0 - nutYRatio - 0.01) / totalRelativeScale;
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String headerTrova = "${MusicLogic.romanNumerals[currentString - 1]} CORDA";

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        bottom: false, 
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
                      ? (showHint ? "NOTA: $currentNoteIt" : "CHE NOTA È?")
                      : headerTrova,
                    style: TextStyle(
                      color: showHint ? Colors.yellow : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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
                              final double x = details.localPosition.dx;
                              final double y = details.localPosition.dy;
                              final double w = constraints.maxWidth;
                              final double h = constraints.maxHeight;

                              int clickedFret = _getFretFromY(y / h, 0.04);
                              double relY = y / h;
                              double nutWidth = w * 0.45;
                              double baseWidth = nutWidth * 1.07;
                              double currentNeckWidth = nutWidth + (baseWidth - nutWidth) * relY;
                              double currentXStart = (w - currentNeckWidth) / 2;
                              
                              int clickedString = 1;
                              double minDistance = double.infinity;
                              
                              for (int i = 0; i < 6; i++) {
                                double sX = currentXStart + (i * (currentNeckWidth / 5));
                                double dist = (x - sX).abs();
                                if (dist < minDistance) {
                                  minDistance = dist;
                                  clickedString = i + 1;
                                }
                              }

                              setState(() {
                                _fretFoundIdx = clickedFret;
                                _stringFoundIdx = clickedString;
                                _isAnimatingFound = true;
                                _animationController.forward(from: 0.0);
                              });

                              if (clickedString == currentString) {
                                checkAnswer(clickedFret);
                              } else {
                                _triggerVibration(false);
                                setState(() {
                                  wrong++;
                                  total++;
                                  _saveStats(false);
                                  updateHighScore(); // Salva errori nel record
                                  if (wrong >= 3) handleGameOver();
                                });
                              }
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
                              isAnimatingFound: _isAnimatingFound,
                              fretFoundIdx: _fretFoundIdx,
                              stringFoundIdx: _stringFoundIdx,
                              animationValue: _animationController.value,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF1A1A1A),
                        border: Border(left: BorderSide(color: Colors.black54, width: 1)),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(12, (i) {
                              bool isTarget = MusicLogic.notesIt[i] == currentNoteIt;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  child: Opacity(
                                    opacity: (widget.mode == "TROVA" && !isTarget) ? 0.3 : 1.0,
                                    child: SizedBox(
                                      width: 140,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF2A2A2A),
                                          elevation: 4,
                                          side: (widget.mode == "TROVA" && isTarget) 
                                              ? const BorderSide(color: Colors.orangeAccent, width: 2) 
                                              : BorderSide.none,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          padding: EdgeInsets.zero,
                                        ),
                                        onPressed: widget.mode == "INDOVINA" ? () => checkAnswer(MusicLogic.notesIt[i]) : null,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(MusicLogic.notesIt[i], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                                            Text(MusicLogic.notesEn[i], style: const TextStyle(fontSize: 10, color: Colors.white38)),
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
                    ),
                  ),
                ],
              ),
            ),
            
            GameScoreFooter(
              correct: correct, 
              total: total, 
              wrong: wrong,
            ),
          ],
        ),
      ),
    );
  }
}