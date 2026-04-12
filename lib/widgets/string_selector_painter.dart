import 'package:flutter/material.dart';

class StringSelectorPainter extends CustomPainter {
  final List<int> selectedStrings;

  StringSelectorPainter({required this.selectedStrings});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double stringGap = h / 5; // Spazio verticale tra le 6 corde

    final Paint paint = Paint()..isAntiAlias = true;

    // --- SFONDO MANICO (Rettangolo Arrotondato) ---
    paint.color = const Color(0xFF1A1A1A);
    final RRect fretboardRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, h), const Radius.circular(8));
    canvas.drawRRect(fretboardRect, paint);

    // --- LOGICA SPAZIATURA TASTI (12 tasti equispaziati per selezione) ---
    double fretStep = w / 12;

    // --- DISEGNO PALLINI (INLAYS) ---
    final Paint inlayPaint = Paint()..color = Colors.white.withAlpha(40);
    for (int i = 1; i <= 12; i++) {
      if ([3, 5, 7, 9, 12].contains(i)) {
        // Calcoliamo il centro del tasto corrente (X)
        double centerX = (i * fretStep) - (fretStep / 2);
        
        if (i == 12) {
          // Doppio pallino verticale al 12esimo tasto
          // Posizionati esattamente tra 2ª-3ª corda e 4ª-5ª corda
          // Usando stringGap: 1.5 gap (tra corda 0, 1 e 2) e 3.5 gap (tra corda 3, 4 e 5)
          canvas.drawCircle(Offset(centerX, 1.5 * stringGap), 5, inlayPaint);
          canvas.drawCircle(Offset(centerX, 3.5 * stringGap), 5, inlayPaint);
        } else {
          // Pallino singolo centrale
          canvas.drawCircle(Offset(centerX, h / 2), 5, inlayPaint);
        }
      }
    }

    // --- DISEGNO BARRETTE METALLICHE DEI TASTI ---
    paint.color = const Color(0xFFC0C0C0).withAlpha(100); 
    paint.strokeWidth = 1.5;
    for (int i = 1; i <= 12; i++) {
      double x = i * fretStep;
      canvas.drawLine(Offset(x, 0), Offset(x, h), paint);
    }

    // --- DISEGNO CAPOTASTO (NUT) A SINISTRA ---
    paint.color = Colors.white;
    paint.strokeWidth = 5; 
    canvas.drawLine(const Offset(0, 0), Offset(0, h), paint);

    // --- DISEGNO CORDE ---
    for (int i = 0; i < 6; i++) {
      // i=0 -> Mi Cantino (In alto, sottile, Corda 1)
      // i=5 -> Mi Grave (In basso, spessa, Corda 6)
      int actualString = 6 - i; 

      bool isSelected = selectedStrings.contains(actualString);
      
      paint.color = isSelected ? Colors.orangeAccent : const Color(0xFFBDBDBD);
      paint.strokeWidth = _getStrokeWidth(i);
      
      // Calcolo altezza corda (Y)
      double y = i * stringGap;
      
      if (i == 0) y = 2.5; 
      if (i == 5) y = h - 2.5; 

      canvas.drawLine(Offset(0, y), Offset(w, y), paint);
    }
  }

  // Spessore variabile delle corde: aumenta scendendo verso il basso (Mi Grave)
  double _getStrokeWidth(int i) => 1.0 + (i * 0.6);

  @override
  bool shouldRepaint(covariant StringSelectorPainter oldDelegate) => true;
}