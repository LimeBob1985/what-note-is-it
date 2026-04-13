import 'package:flutter/material.dart';

class StringSelectorPainter extends CustomPainter {
  final List<int> selectedStrings;

  StringSelectorPainter({required this.selectedStrings});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    
    // Calcoliamo il gap basandoci sull'altezza effettiva disponibile
    final double stringGap = h / 5; 

    final Paint paint = Paint()..isAntiAlias = true;

    // --- SFONDO MANICO ---
    paint.color = const Color(0xFF1A1A1A);
    final RRect fretboardRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, h), const Radius.circular(8));
    canvas.drawRRect(fretboardRect, paint);

    // --- LOGICA SPAZIATURA TASTI ---
    double fretStep = w / 12;

    // --- DISEGNO PALLINI (INLAYS) ---
    // Ridotto leggermente il raggio (da 5 a 4) per stare meglio nel manico compresso
    final Paint inlayPaint = Paint()..color = Colors.white.withAlpha(40);
    for (int i = 1; i <= 12; i++) {
      if ([3, 5, 7, 9, 12].contains(i)) {
        double centerX = (i * fretStep) - (fretStep / 2);
        
        if (i == 12) {
          canvas.drawCircle(Offset(centerX, 1.5 * stringGap), 4, inlayPaint);
          canvas.drawCircle(Offset(centerX, 3.5 * stringGap), 4, inlayPaint);
        } else {
          canvas.drawCircle(Offset(centerX, h / 2), 4, inlayPaint);
        }
      }
    }

    // --- DISEGNO BARRETTE METALLICHE ---
    paint.color = const Color(0xFFC0C0C0).withAlpha(100); 
    paint.strokeWidth = 1.2; // Leggermente più sottile per pulizia visiva
    for (int i = 1; i <= 12; i++) {
      double x = i * fretStep;
      canvas.drawLine(Offset(x, 0), Offset(x, h), paint);
    }

    // --- DISEGNO CAPOTASTO (NUT) ---
    paint.color = Colors.white;
    paint.strokeWidth = 4; 
    canvas.drawLine(const Offset(0, 0), Offset(0, h), paint);

    // --- DISEGNO CORDE ---
    for (int i = 0; i < 6; i++) {
      int actualString = 6 - i; 
      bool isSelected = selectedStrings.contains(actualString);
      
      paint.color = isSelected ? Colors.orangeAccent : const Color(0xFFBDBDBD);
      paint.strokeWidth = _getStrokeWidth(i);
      
      double y = i * stringGap;
      
      // Padding dinamico per non tagliare le corde esterne
      if (i == 0) y = 2.0; 
      if (i == 5) y = h - 2.0; 

      canvas.drawLine(Offset(0, y), Offset(w, y), paint);
    }
  }

  double _getStrokeWidth(int i) => 0.8 + (i * 0.5);

  @override
  bool shouldRepaint(covariant StringSelectorPainter oldDelegate) => true;
}