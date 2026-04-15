// lib/widgets/guitar_neck_painter.dart
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class GuitarNeckPainter extends CustomPainter {
  final int frets;
  final int currentString; 
  final int currentFret;
  final bool showAllNotes;
  final int targetNoteIndex;
  final int openNoteIndex;
  final List<int> foundFrets;

  // Parametri per l'animazione chicca
  final bool isAnimatingFound;
  final int fretFoundIdx; 
  final int stringFoundIdx; 
  final double animationValue; 

  GuitarNeckPainter({
    required this.frets,
    required this.currentString,
    required this.currentFret,
    this.showAllNotes = false,
    this.targetNoteIndex = -1,
    this.openNoteIndex = -1,
    this.foundFrets = const [],
    this.isAnimatingFound = false,
    this.fretFoundIdx = -1,
    this.stringFoundIdx = -1,
    this.animationValue = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    
    // --- COLORI DEFINITI ---
    const Color fretboardWood = Color(0xFF1A110D); 
    const Color nutColor = Color(0xFFE8E4D9); 
    
    final Paint paint = Paint()..isAntiAlias = true;
    
    final double nutWidth = width * 0.45; 
    final double scaleFactor = 1.07; 
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

    // --- 1. SFONDO LATERALE (GRADIENTE BLU SFUMATO DALL'ICONA) ---
    paint.shader = ui.Gradient.linear(
      const Offset(0, 0),
      Offset(0, height),
      [
        const Color(0xFF030A14), // Blu molto scuro (alto)
        const Color(0xFF062136), // Blu petrolio sfumato (basso)
      ],
    );
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);
    paint.shader = null; // Reset shader per gli altri elementi

    // --- 2. TASTIERA ---
    paint.color = fretboardWood;
    Path fretboardPath = Path();
    fretboardPath.moveTo(nutXStart, 0);
    fretboardPath.lineTo(nutXStart + nutWidth, 0);
    fretboardPath.lineTo(baseXStart + baseWidth, height);
    fretboardPath.lineTo(baseXStart, height);
    fretboardPath.close();
    canvas.drawPath(fretboardPath, paint);

    // Sfumatura bordi tastiera (3D effect)
    paint.shader = ui.Gradient.linear(
      Offset(nutXStart, 0),
      Offset(nutXStart + nutWidth, 0),
      [
        Colors.black.withOpacity(0.5), 
        Colors.transparent, 
        Colors.transparent, 
        Colors.black.withOpacity(0.5)
      ],
      [0.0, 0.05, 0.95, 1.0],
    );
    canvas.drawPath(fretboardPath, paint);
    paint.shader = null;

    // --- 3. LOGICA TASTI E INLAYS ---
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

      // --- INLAYS (Madreperla) ---
      if ([3, 5, 7, 9, 12, 15, 17, 19, 21, 24].contains(i)) {
        final double centerY = previousPos + (currentFretStep / 2);
        final double centerW = getWidthAtY(centerY);
        final double centerX = getXStartAtY(centerY);
        final double gapAtY = centerW / 5;

        void drawInlay(Offset center) {
          final Paint inlayPaint = Paint()
            ..shader = ui.Gradient.radial(
              center,
              centerW / 12, // Dimensione proporzionale
              [Colors.white.withOpacity(0.6), Colors.white.withOpacity(0.1)],
              [0.1, 1.0],
            );
          canvas.drawCircle(center, 5, inlayPaint);
        }
        
        if (i == 12 || i == 24) {
          drawInlay(Offset(centerX + (1.5 * gapAtY), centerY));
          drawInlay(Offset(centerX + (3.5 * gapAtY), centerY));
        } else {
          drawInlay(Offset(width / 2, centerY));
        }
      }

      // --- TASTI (Linee Metalliche) ---
      paint.color = Colors.black.withOpacity(0.6);
      paint.strokeWidth = 1.0;
      canvas.drawLine(Offset(currentX, currentPos + 1), Offset(currentX + currentW, currentPos + 1), paint);
      
      paint.shader = LinearGradient(
        colors: [const Color(0xFF808080), const Color(0xFFE0E0E0), const Color(0xFF808080)],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(currentX, currentPos - 1, currentW, 2));
      
      paint.strokeWidth = 2.5;
      canvas.drawLine(Offset(currentX, currentPos), Offset(currentX + currentW, currentPos), paint);
      paint.shader = null;
      
      currentFretStep *= spacingFactor;
    }

    // --- 4. NUT (Capotasto) ---
    paint.color = nutColor;
    paint.strokeWidth = 7;
    canvas.drawLine(Offset(nutXStart, nutY), Offset(nutXStart + nutWidth, nutY), paint);

    // --- 5. CORDE E ANIMAZIONE CHICCA ---
    for (int i = 0; i < 6; i++) {
      double xNut = nutXStart + (i * (nutWidth / 5));
      double xBase = baseXStart + (i * (baseWidth / 5));
      double sWidth = 4.0 - (i * 0.5);

      bool isAnimatedString = isAnimatingFound && (i + 1 == stringFoundIdx);

      if (!isAnimatedString) {
        canvas.drawLine(
          Offset(xNut + 2.5, 0), Offset(xBase + 2.5, height),
          Paint()..color = Colors.black.withOpacity(0.5)..strokeWidth = sWidth..isAntiAlias = true
        );

        paint.shader = ui.Gradient.linear(
          Offset(xNut - 2, 0), Offset(xNut + 2, 0),
          [const Color(0xFF707070), const Color(0xFFE0E0E0), const Color(0xFF707070)],
          const [0.0, 0.5, 1.0],
        );
        paint.strokeWidth = sWidth;
        canvas.drawLine(Offset(xNut, 0), Offset(xBase, height), paint);
        paint.shader = null;
      } else {
        double startY;
        if (fretFoundIdx == 0) {
          startY = nutY / 2;
        } else {
          double prevP = fretPositions[fretFoundIdx - 1];
          double currP = fretPositions[fretFoundIdx];
          startY = prevP + (currP - prevP) / 2;
        }

        paint.color = const Color(0xFFBDBDBD);
        paint.strokeWidth = sWidth;
        canvas.drawLine(Offset(xNut, 0), Offset(xNut, startY), paint);

        paint.shader = ui.Gradient.linear(
          Offset(xNut, startY),
          Offset(xBase, height),
          [const Color(0xFFE0E0E0).withOpacity(1.0 - animationValue), Colors.transparent],
          const [0.0, 1.0],
        );
        paint.strokeWidth = sWidth * 2.0 * (1.0 - animationValue / 2.0); 
        canvas.drawLine(Offset(xNut, startY), Offset(xBase, height), paint);
        paint.shader = null;
      }
    }

    // --- 6. NOTE (PUNTI DI GIOCO) ---
    _drawGameNotes(canvas, nutXStart, nutWidth, baseXStart, baseWidth, nutY, fretPositions);
  }

  void _drawGameNotes(Canvas canvas, double nutX, double nutW, double baseX, double baseW, double nutY, List<double> fretPositions) {
    if (currentString < 1 || currentString > 6) return;

    void drawNoteDot(double x, double y, Color color) {
      canvas.drawCircle(Offset(x, y), 14, Paint()..color = color.withOpacity(0.3));
      canvas.drawCircle(Offset(x, y), 10, Paint()..color = color);
      canvas.drawCircle(Offset(x, y), 10, Paint()..color = Colors.white.withOpacity(0.8)..style = PaintingStyle.stroke..strokeWidth = 2);
    }

    double getXForStringAtY(int stringIdx, double y) {
      double xNut = nutX + (stringIdx * (nutW / 5));
      double xBase = baseX + (stringIdx * (baseW / 5));
      double totalH = fretPositions.isEmpty ? 1 : fretPositions.last;
      return xNut + (xBase - xNut) * (y / totalH);
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
  bool shouldRepaint(covariant GuitarNeckPainter oldDelegate) {
    return true; 
  }
}