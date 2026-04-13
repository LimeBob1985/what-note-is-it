import 'package:flutter/material.dart';

class GuitarNeckPainter extends CustomPainter {
  final int frets;
  final int currentString; // 1 = Mi Basso, 6 = Mi Cantino
  final int currentFret;
  final bool showAllNotes;
  final int targetNoteIndex;
  final int openNoteIndex;
  final List<int> foundFrets;

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
    
    // MODIFICA: padX ora definisce la larghezza fissa del manico dritto
    final double padX = width * 0.22;
    final double usableW = width - (padX * 2);
    final double nutY = height * 0.05;
    final double stringGap = usableW / 5;

    // --- DISEGNO LEGNO (RETTANGOLARE DRITTO) ---
    paint.color = neckWood;
    // Disegniamo il rettangolo di fondo largo quanto la tastiera
    canvas.drawRect(
        Rect.fromLTRB(padX, 0, width - padX, height),
        paint);
        
    // --- TASTIERA (RETTANGOLARE DRITTA) ---
    paint.color = fretboardWood;
    canvas.drawRect(Rect.fromLTWH(padX, nutY, usableW, height - nutY), paint);

    // --- CAPOTASTO (NUT) ---
    paint.color = nutColor;
    paint.strokeWidth = 6;
    canvas.drawLine(Offset(padX, nutY), Offset(width - padX, nutY), paint);

    // --- LOGICA TASTI (FISICA REALE) ---
    List<double> fretPositions = [nutY];
    double currentPos = nutY;
    final double spacingFactor = frets > 12 ? 0.96 : 0.9438;
    double totalRelativeScale = 0;
    double tempLength = 1.0;
    for (int i = 0; i < frets; i++) {
      totalRelativeScale += tempLength;
      tempLength *= spacingFactor;
    }
    double unit = (height - nutY - (height * 0.03)) / totalRelativeScale;
    double currentFretStep = unit;

    for (int i = 1; i <= frets; i++) {
      double previousPos = currentPos;
      currentPos += currentFretStep;
      fretPositions.add(currentPos);

      // --- INLAYS (PALLINI) ---
      if ([3, 5, 7, 9, 12].contains(i)) {
        final double centerY = previousPos + (currentFretStep / 2);
        final Paint inlayPaint = Paint()..color = Colors.white.withAlpha(50);
        
        if (i == 12) {
          canvas.drawCircle(Offset(padX + (1.5 * stringGap), centerY), 5, inlayPaint);
          canvas.drawCircle(Offset(padX + (3.5 * stringGap), centerY), 5, inlayPaint);
        } else {
          canvas.drawCircle(Offset(width / 2, centerY), 5, inlayPaint);
        }
      }

      paint.color = fretMetal;
      paint.strokeWidth = 2.5;
      canvas.drawLine(Offset(padX, currentPos), Offset(width - padX, currentPos), paint);
      currentFretStep *= spacingFactor;
    }

    // --- CORDE (SPESSORE VARIABILE) ---
    for (int i = 0; i < 6; i++) {
      double x = padX + (i * stringGap);
      paint.color = stringMetal;
      paint.strokeWidth = 3.8 - (i * 0.5); 
      canvas.drawLine(Offset(x, 0), Offset(x, height), paint);
    }

    _drawGameNotes(canvas, padX, stringGap, nutY, fretPositions);
  }

  void _drawGameNotes(Canvas canvas, double padX, double stringGap, double nutY, List<double> fretPositions) {
    if (currentString < 1 || currentString > 6) return;
    void drawNoteDot(double x, double y, Color color) {
      canvas.drawCircle(Offset(x, y), 14, Paint()..color = color.withAlpha(75));
      canvas.drawCircle(Offset(x, y), 10, Paint()..color = color);
      canvas.drawCircle(Offset(x, y), 10, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
    }
    double dotX = padX + ((currentString - 1) * stringGap);
    for (int f in foundFrets) {
      double dotY = (f == 0) ? nutY / 2 : fretPositions[f - 1] + (fretPositions[f] - fretPositions[f - 1]) / 2;
      drawNoteDot(dotX, dotY, Colors.greenAccent);
    }
    if (showAllNotes && openNoteIndex != -1 && targetNoteIndex != -1) {
      for (int f = 0; f <= frets; f++) {
        if ((openNoteIndex + f) % 12 == targetNoteIndex) {
          double dotY = (f == 0) ? nutY / 2 : fretPositions[f - 1] + (fretPositions[f] - fretPositions[f - 1]) / 2;
          drawNoteDot(dotX, dotY, Colors.yellowAccent);
        }
      }
    } else if (currentFret >= 0) {
      double dotY = (currentFret == 0) ? nutY / 2 : fretPositions[currentFret - 1] + (fretPositions[currentFret] - fretPositions[currentFret - 1]) / 2;
      drawNoteDot(dotX, dotY, Colors.redAccent);
    }
  }

  @override
  bool shouldRepaint(covariant GuitarNeckPainter oldDelegate) => true;
}