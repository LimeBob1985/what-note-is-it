import 'package:flutter/material.dart';

class GuitarNeckPainter extends CustomPainter {
  final int frets;
  final int currentString; // 1 = VI (Sinistra), 6 = I (Destra)
  final int currentFret;
  final bool showAllNotes; // Se true, evidenzia le posizioni per l'aiuto
  final int targetNoteIndex;
  final int openNoteIndex;
  final List<int> foundFrets; // Tasti già indovinati in modalità TROVA

  GuitarNeckPainter({
    required this.frets,
    required this.currentString,
    required this.currentFret,
    this.showAllNotes = false,
    this.targetNoteIndex = -1,
    this.openNoteIndex = -1,
    this.foundFrets = const [],
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    const Color neckWood = Color(0xFFF3E5AB);
    const Color fretboardWood = Color(0xFF1A1A1A);
    const Color nutColor = Colors.white;
    const Color fretMetal = Color(0xFFC0C0C0);
    const Color stringMetal = Color(0xFFBDBDBD);
    final Paint paint = Paint()..isAntiAlias = true;

    final double padX = width * 0.22;
    final double usableW = width - (padX * 2);
    final double nutY = height * 0.05;
    final double stringGap = usableW / 5;

    final double spacingFactor = frets > 12 ? 0.96 : 0.9438;

    // --- DISEGNO LEGNO MANICO E TASTIERA ---
    paint.color = neckWood;
    canvas.drawRRect(
        RRect.fromLTRBR(padX - 4, 0, width - padX + 4, height, const Radius.circular(8)),
        paint);
    paint.color = fretboardWood;
    canvas.drawRect(Rect.fromLTWH(padX, nutY, usableW, height - nutY), paint);

    // --- CAPOTASTO ---
    paint.color = nutColor;
    paint.strokeWidth = 6;
    canvas.drawLine(Offset(padX, nutY), Offset(width - padX, nutY), paint);

    // --- LOGICA TASTI SCALATI ---
    List<double> fretPositions = [nutY];
    double currentPos = nutY;
    double totalRelativeScale = 0;
    double tempLength = 1.0;

    for (int i = 0; i < frets; i++) {
      totalRelativeScale += tempLength;
      tempLength *= spacingFactor;
    }

    double unit = (height - nutY - (height * 0.03)) / totalRelativeScale;
    double currentFretStep = unit;

    for (int i = 1; i <= frets; i++) {
      currentPos += currentFretStep;
      fretPositions.add(currentPos);

      paint.color = fretMetal;
      paint.strokeWidth = 2.5;
      canvas.drawLine(Offset(padX, currentPos), Offset(width - padX, currentPos), paint);

      // --- INLAYS (Punti di riferimento) ---
      double centerY = currentPos - (currentFretStep / 2);
      if ([3, 5, 7, 9, 15, 17, 19, 21].contains(i)) {
        canvas.drawCircle(Offset(width / 2, centerY), 5, Paint()..color = Colors.white24);
      } else if (i == 12) {
        canvas.drawCircle(Offset(padX + (1.5 * stringGap), centerY), 5, Paint()..color = Colors.white24);
        canvas.drawCircle(Offset(padX + (3.5 * stringGap), centerY), 5, Paint()..color = Colors.white24);
      }
      currentFretStep *= spacingFactor;
    }

    // --- DISEGNO CORDE ---
    for (int i = 0; i < 6; i++) {
      double x = padX + (i * stringGap);
      paint.color = stringMetal;
      paint.strokeWidth = 3.5 - (i * 0.5);
      canvas.drawLine(Offset(x, 0), Offset(x, height), paint);
    }

    // --- FUNZIONE PER IL DISEGNO DEI PALLINI (NOTE) ---
    void drawNoteDot(double x, double y, Color color) {
      canvas.drawCircle(Offset(x, y), 14, Paint()..color = color.withOpacity(0.3));
      canvas.drawCircle(Offset(x, y), 10, Paint()..color = color);
      canvas.drawCircle(
          Offset(x, y),
          10,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
    }

    double dotX = padX + ((currentString - 1) * stringGap);

    // 1. DISEGNO I TASTI GIÀ INDOVINATI (PALLINI VERDI)
    for (int f in foundFrets) {
      double dotY = (f == 0)
          ? nutY / 2
          : fretPositions[f - 1] + (fretPositions[f] - fretPositions[f - 1]) / 2;
      drawNoteDot(dotX, dotY, Colors.greenAccent);
    }

    // 2. LOGICA HINT (AIUTO LAMPADINA)
    if (showAllNotes && openNoteIndex != -1 && targetNoteIndex != -1) {
      for (int f = 0; f <= frets; f++) {
        if ((openNoteIndex + f) % 12 == targetNoteIndex) {
          double dotY = (f == 0)
              ? nutY / 2
              : fretPositions[f - 1] + (fretPositions[f] - fretPositions[f - 1]) / 2;
          drawNoteDot(dotX, dotY, Colors.yellowAccent);
        }
      }
    } 
    // 3. LOGICA NOTA SINGOLA (MODALITÀ INDOVINA)
    else if (currentFret >= 0) {
      double dotY = (currentFret == 0)
          ? nutY / 2
          : fretPositions[currentFret - 1] + (fretPositions[currentFret] - fretPositions[currentFret - 1]) / 2;
      drawNoteDot(dotX, dotY, Colors.redAccent);
    }
  }

  @override
  bool shouldRepaint(covariant GuitarNeckPainter oldDelegate) {
    return oldDelegate.currentFret != currentFret ||
        oldDelegate.currentString != currentString ||
        oldDelegate.showAllNotes != showAllNotes ||
        oldDelegate.foundFrets.length != foundFrets.length ||
        oldDelegate.frets != frets;
  }
}