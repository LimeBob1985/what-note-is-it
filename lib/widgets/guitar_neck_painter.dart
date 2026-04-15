import 'package:flutter/material.dart';

class GuitarNeckPainter extends CustomPainter {
  final int frets;
  final int currentString; 
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
    
    // --- CALCOLO PROPORZIONI (PIÙ DRITTO) ---
    final double nutWidth = width * 0.38; 
    // Ridotto scaleFactor da 1.32 a 1.18 per rendere il manico meno trapezoidale
    final double scaleFactor = 1.18; 
    final double baseWidth = nutWidth * scaleFactor;

    final double nutXStart = (width - nutWidth) / 2;
    final double baseXStart = (width - baseWidth) / 2;
    
    final double nutY = height * 0.04; 

    double getWidthAtY(double y) {
      double relativePos = (y - nutY) / (height - nutY);
      if (relativePos < 0) relativePos = 0;
      return nutWidth + (baseWidth - nutWidth) * relativePos;
    }

    double getXStartAtY(double y) {
      return (width - getWidthAtY(y)) / 2;
    }

    // --- LEGNO MANICO ---
    paint.color = neckWood;
    Path neckPath = Path();
    neckPath.moveTo(getXStartAtY(0), 0);
    neckPath.lineTo(getXStartAtY(0) + getWidthAtY(0), 0);
    neckPath.lineTo(baseXStart + baseWidth, height);
    neckPath.lineTo(baseXStart, height);
    neckPath.close();
    canvas.drawPath(neckPath, paint);
        
    // --- TASTIERA ---
    paint.color = fretboardWood;
    Path fretboardPath = Path();
    fretboardPath.moveTo(nutXStart, nutY);
    fretboardPath.lineTo(nutXStart + nutWidth, nutY);
    fretboardPath.lineTo(baseXStart + baseWidth, height);
    fretboardPath.lineTo(baseXStart, height);
    fretboardPath.close();
    canvas.drawPath(fretboardPath, paint);

    // --- CAPOTASTO ---
    paint.color = nutColor;
    paint.strokeWidth = 6;
    canvas.drawLine(Offset(nutXStart, nutY), Offset(nutXStart + nutWidth, nutY), paint);

    // --- LOGICA TASTI ---
    List<double> fretPositions = [nutY];
    double currentPos = nutY;
    final double spacingFactor = frets > 12 ? 0.962 : 0.945; 
    double totalRelativeScale = 0;
    double tempLength = 1.0;
    for (int i = 0; i < frets; i++) {
      totalRelativeScale += tempLength;
      tempLength *= spacingFactor;
    }
    double unit = (height - nutY - (height * 0.01)) / totalRelativeScale;
    double currentFretStep = unit;

    for (int i = 1; i <= frets; i++) {
      double previousPos = currentPos;
      currentPos += currentFretStep;
      fretPositions.add(currentPos);

      double currentW = getWidthAtY(currentPos);
      double currentX = getXStartAtY(currentPos);

      // --- INLAYS ---
      if ([3, 5, 7, 9, 12, 15, 17, 19, 21, 24].contains(i)) {
        final double centerY = previousPos + (currentFretStep / 2);
        final double centerW = getWidthAtY(centerY);
        final double centerX = getXStartAtY(centerY);
        final double gapAtY = centerW / 5;
        final Paint inlayPaint = Paint()..color = Colors.white.withAlpha(40);
        
        if (i == 12 || i == 24) {
          canvas.drawCircle(Offset(centerX + (1.5 * gapAtY), centerY), 4, inlayPaint);
          canvas.drawCircle(Offset(centerX + (3.5 * gapAtY), centerY), 4, inlayPaint);
        } else {
          canvas.drawCircle(Offset(width / 2, centerY), 4, inlayPaint);
        }
      }

      paint.color = fretMetal;
      paint.strokeWidth = 2.2;
      canvas.drawLine(Offset(currentX, currentPos), Offset(currentX + currentW, currentPos), paint);
      currentFretStep *= spacingFactor;
    }

    // --- CORDE ---
    for (int i = 0; i < 6; i++) {
      double xNut = nutXStart + (i * (nutWidth / 5));
      double xBase = baseXStart + (i * (baseWidth / 5));
      paint.color = stringMetal;
      paint.strokeWidth = 3.5 - (i * 0.5); 
      canvas.drawLine(Offset(xNut, 0), Offset(xBase, height), paint);
    }

    _drawGameNotes(canvas, nutXStart, nutWidth, baseXStart, baseWidth, nutY, fretPositions);
  }

  void _drawGameNotes(Canvas canvas, double nutX, double nutW, double baseX, double baseW, double nutY, List<double> fretPositions) {
    if (currentString < 1 || currentString > 6) return;

    void drawNoteDot(double x, double y, Color color) {
      canvas.drawCircle(Offset(x, y), 13, Paint()..color = color.withAlpha(70));
      canvas.drawCircle(Offset(x, y), 9, Paint()..color = color);
      canvas.drawCircle(Offset(x, y), 9, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.5);
    }

    double getXForStringAtY(int stringIdx, double y) {
      double xNut = nutX + (stringIdx * (nutW / 5));
      double xBase = baseX + (stringIdx * (baseW / 5));
      return xNut + (xBase - xNut) * (y / fretPositions.last);
    }

    int sIdx = currentString - 1;

    for (int f in foundFrets) {
      double dotY = (f == 0) ? nutY / 2 : fretPositions[f - 1] + (fretPositions[f] - fretPositions[f - 1]) / 2;
      drawNoteDot(getXForStringAtY(sIdx, dotY), dotY, Colors.greenAccent);
    }

    if (showAllNotes && openNoteIndex != -1 && targetNoteIndex != -1) {
      for (int f = 0; f <= frets; f++) {
        if ((openNoteIndex + f) % 12 == targetNoteIndex) {
          double dotY = (f == 0) ? nutY / 2 : fretPositions[f - 1] + (fretPositions[f] - fretPositions[f - 1]) / 2;
          drawNoteDot(getXForStringAtY(sIdx, dotY), dotY, Colors.yellowAccent);
        }
      }
    } else if (currentFret >= 0) {
      double dotY = (currentFret == 0) ? nutY / 2 : fretPositions[currentFret - 1] + (fretPositions[currentFret] - fretPositions[currentFret - 1]) / 2;
      drawNoteDot(getXForStringAtY(sIdx, dotY), dotY, Colors.redAccent);
    }
  }

  @override
  bool shouldRepaint(covariant GuitarNeckPainter oldDelegate) => true;
}