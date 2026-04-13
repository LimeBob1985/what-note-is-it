import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  List<Map<String, dynamic>> historicalData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistoricalStats();
  }

  Future<void> _loadHistoricalStats() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> tempSpecs = [];

    // Carichiamo gli ultimi 30 giorni
    for (int i = 29; i >= 0; i--) {
      DateTime date = DateTime.now().subtract(Duration(days: i));
      String dateStr = date.toString().split(' ')[0];

      int correctToday = prefs.getInt("stats_correct_$dateStr") ?? 0;
      int totalToday = prefs.getInt("stats_total_$dateStr") ?? 0;
      int wrongToday = totalToday - correctToday;
      double accuracy = totalToday > 0 ? correctToday / totalToday : 0.0;

      tempSpecs.add({
        "correct": correctToday,
        "wrong": wrongToday,
        "total": totalToday,
        "accuracy": accuracy,
        "hasPlayed": totalToday > 0,
        "dayName": _getDayName(date.weekday),
        "dayNumber": date.day,
        "monthName": _getMonthName(date.month),
        "fullDate": "$dateStr",
        "isToday": i == 0,
      });
    }

    setState(() {
      historicalData = tempSpecs;
      isLoading = false;
    });
  }

  String _getDayName(int weekday) {
    const names = ["Lun", "Mar", "Mer", "Gio", "Ven", "Sab", "Dom"];
    return names[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = ["Gen", "Feb", "Mar", "Apr", "Mag", "Giu", "Lug", "Ago", "Set", "Ott", "Nov", "Dic"];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text("STATS STORICI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.orangeAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
          : SingleChildScrollView( 
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // MODIFICATO: Rimossa dicitura (Corrette vs Errate)
                  _buildSectionTitle("PRECISIONE GIORNALIERA"),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 250,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: historicalData.map((data) => _buildStackedBar(data)).toList(),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  // MODIFICATO: Rimossa percentuale %
                  _buildSectionTitle("ANDAMENTO ACCURACY"),
                  const SizedBox(height: 10),
                  
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 150,
                            width: historicalData.length * 50.0, 
                            child: CustomPaint(
                              painter: _LineChartPainter(historicalData),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: historicalData.map((data) => SizedBox(
                              width: 50,
                              child: Text("${data['dayNumber']}\n${data['dayName']}", 
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white24, fontSize: 8),
                              ),
                            )).toList(),
                          )
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 50),
                  const Center(
                    child: Text("Scorri lateralmente i grafici per la cronologia", 
                      style: TextStyle(color: Colors.white24, fontSize: 11, fontStyle: FontStyle.italic)),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    );
  }

  Widget _buildStackedBar(Map<String, dynamic> data) {
    final bool hasPlayed = data['hasPlayed'];
    if (!hasPlayed) {
      return _buildEmptyBar(data);
    }

    final int correct = data['correct'];
    final int wrong = data['wrong'];
    final int total = data['total'];
    
    double maxHeight = 160.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text("$total", style: const TextStyle(color: Colors.white38, fontSize: 9)),
          const SizedBox(height: 4),
          Container(
            width: 28,
            height: maxHeight,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Column(
                children: [
                  Expanded(
                    flex: wrong,
                    child: Container(color: Colors.redAccent.withOpacity(0.8)),
                  ),
                  Expanded(
                    flex: correct,
                    child: Container(color: Colors.greenAccent.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(data['dayName'], style: TextStyle(color: data['isToday'] ? Colors.orangeAccent : Colors.white38, fontSize: 10)),
          Text("${data['dayNumber']}", style: TextStyle(color: data['isToday'] ? Colors.white : Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEmptyBar(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(height: 13),
          Container(
            width: 28,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(4)
            ),
          ),
          const SizedBox(height: 8),
          Text(data['dayName'], style: const TextStyle(color: Colors.white12, fontSize: 10)),
          Text("${data['dayNumber']}", style: const TextStyle(color: Colors.white12, fontSize: 10)),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  _LineChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paintLine = Paint()
      ..color = Colors.orangeAccent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintFill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.orangeAccent.withOpacity(0.2), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();
    
    double stepX = 50.0;

    for (int i = 0; i < data.length; i++) {
      double acc = (data[i]['accuracy'] as num).toDouble();
      double x = i * stepX + (stepX / 2);
      double y = size.height - (acc * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
      
      if (i == data.length - 1) {
        fillPath.lineTo(x, size.height);
        fillPath.close();
      }

      if (data[i]['hasPlayed']) {
        canvas.drawCircle(Offset(x, y), 4, Paint()..color = Colors.orangeAccent);
        canvas.drawCircle(Offset(x, y), 2, Paint()..color = Colors.white);
      }
    }
    
    canvas.drawPath(fillPath, paintFill);
    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}