import 'package:flutter/material.dart';
import 'game_page.dart';
import '../models/music_logic.dart';
// Importiamo il nuovo painter dedicato
import '../widgets/string_selector_painter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedFrets = 12;
  bool _timerEnabled = false;
  int _timerSeconds = 10;
  String _selectedMode = "INDOVINA";
  final List<int> _timerOptions = [5, 10, 20, 30];
  
  // Lista per la selezione multipla delle corde
  final List<int> _selectedStrings = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text(
          "IMPOSTAZIONI",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("SELEZIONA LE CORDE"),
              const SizedBox(height: 15),
              
              // Selettore Corde con il nuovo Painter dedicato
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (details) {
                        // Calcolo preciso sulla coordinata Y (altezza)
                        double y = details.localPosition.dy;
                        double h = constraints.maxHeight;
                        
                        // Poiché nel painter 0 è Mi Cantino e h è Mi Grave:
                        // Invertiamo il calcolo per far corrispondere il tocco visivo
                        int stringIdx = 6 - ((y / h) * 6).floor();
                        stringIdx = stringIdx.clamp(1, 6);

                        setState(() {
                          if (_selectedStrings.contains(stringIdx)) {
                            _selectedStrings.remove(stringIdx);
                          } else {
                            _selectedStrings.add(stringIdx);
                          }
                        });
                      },
                      child: CustomPaint(
                        painter: StringSelectorPainter(
                          selectedStrings: _selectedStrings,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              
              // Nomi delle corde selezionate
              Center(
                child: Text(
                  _selectedStrings.isEmpty 
                      ? "TUTTE LE CORDE" 
                      : "CORDE SELEZIONATE: ${_selectedStrings.map((s) => MusicLogic.romanNumerals[s - 1]).join(", ")}",
                  style: const TextStyle(
                    color: Colors.orangeAccent, 
                    fontWeight: FontWeight.bold,
                    fontSize: 13
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              _buildSectionTitle("MODALITÀ DI GIOCO"),
              const SizedBox(height: 10),
              Row(
                children: [
                  _modeButton("INDOVINA"),
                  const SizedBox(width: 10),
                  _modeButton("TROVA"),
                ],
              ),
              
              const SizedBox(height: 30),
              _buildSectionTitle("NUMERO TASTI"),
              const SizedBox(height: 10),
              Row(
                children: [
                  _optionButton(12, _selectedFrets, (v) => setState(() => _selectedFrets = v), " TASTI"),
                  const SizedBox(width: 10),
                  _optionButton(22, _selectedFrets, (v) => setState(() => _selectedFrets = v), " TASTI"),
                ],
              ),
              
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("TIMER SFIDA", style: TextStyle(color: Colors.white, fontSize: 16)),
                  Switch(
                    value: _timerEnabled,
                    activeTrackColor: Colors.orangeAccent.withAlpha(128),
                    activeColor: Colors.orangeAccent,
                    onChanged: (val) => setState(() => _timerEnabled = val),
                  ),
                ],
              ),
              if (_timerEnabled) ...[
                const SizedBox(height: 15),
                _buildSectionTitle("DURATA (SEC)"),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _timerOptions
                      .map((sec) => _optionButton(sec, _timerSeconds, (v) => setState(() => _timerSeconds = v), "s"))
                      .toList(),
                ),
              ],
              
              const SizedBox(height: 40),
              _buildStartButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold));
  }

  Widget _buildStartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orangeAccent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GamePage(
                frets: _selectedFrets,
                timer: _timerEnabled ? _timerSeconds : null,
                mode: _selectedMode,
                lockedStrings: _selectedStrings.isEmpty ? null : _selectedStrings,
              ),
            ),
          );
        },
        child: const Text("INIZIA", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _modeButton(String mode) {
    bool isSelected = _selectedMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orangeAccent : const Color(0xFF222222),
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? Border.all(color: Colors.white, width: 1) : null,
          ),
          child: Center(
            child: Text(
              mode,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _optionButton(int val, int groupVal, Function(int) onSelect, String unit) {
    bool isSelected = groupVal == val;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(val),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orangeAccent : const Color(0xFF222222),
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? Border.all(color: Colors.white, width: 1) : null,
          ),
          child: Center(
            child: Text(
              "$val$unit",
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}