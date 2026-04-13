import 'package:flutter/material.dart';
import 'game_page.dart';
import '../models/music_logic.dart';
import '../widgets/string_selector_painter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedFrets = 12;
  bool _timerEnabled = false;
  int _timerSeconds = 5;
  String _selectedMode = "INDOVINA";
  
  final List<int> _timerOptions = [3, 5, 10, 15];
  final List<int> _selectedStrings = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text(
          "IMPOSTAZIONI",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("SELEZIONA LE CORDE"),
              const SizedBox(height: 10),
              
              Container(
                height: 100, 
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
                        double y = details.localPosition.dy;
                        double h = constraints.maxHeight;
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
              const SizedBox(height: 8),
              
              Center(
                child: Text(
                  _selectedStrings.isEmpty 
                      ? "TUTTE LE CORDE" 
                      : "CORDE SELEZIONATE: ${_selectedStrings.map((s) => MusicLogic.romanNumerals[s - 1]).join(", ")}",
                  style: const TextStyle(
                    color: Colors.orangeAccent, 
                    fontWeight: FontWeight.bold,
                    fontSize: 12
                  ),
                ),
              ),
              
              const SizedBox(height: 15),
              _buildSectionTitle("MODALITÀ DI GIOCO"),
              const SizedBox(height: 8),
              Row(
                children: [
                  _modeButton("INDOVINA"),
                  const SizedBox(width: 10),
                  _modeButton("TROVA"),
                ],
              ),
              
              const SizedBox(height: 15),
              _buildSectionTitle("NUMERO TASTI"),
              const SizedBox(height: 8),
              Row(
                children: [
                  _optionButton(12, _selectedFrets, (v) => setState(() => _selectedFrets = v), " TASTI"),
                  const SizedBox(width: 10),
                  _optionButton(22, _selectedFrets, (v) => setState(() => _selectedFrets = v), " TASTI"),
                ],
              ),
              
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("TIMER SFIDA", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: _timerEnabled,
                      activeTrackColor: Colors.orangeAccent.withAlpha(128),
                      // CORRETTO: Usato activeThumbColor invece di activeColor
                      activeThumbColor: Colors.orangeAccent,
                      onChanged: (val) => setState(() => _timerEnabled = val),
                    ),
                  ),
                ],
              ),
              
              if (_timerEnabled) ...[
                _buildSectionTitle("DURATA (SEC)"),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _timerOptions
                      .map((sec) => _optionButton(sec, _timerSeconds, (v) => setState(() => _timerSeconds = v), "s"))
                      .toList(),
                ),
              ],
              
              const Spacer(),
              _buildStartButton(context),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1));
  }

  Widget _buildStartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orangeAccent,
          foregroundColor: Colors.black,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
        // CORRETTO: FontWeight.w900 invece di .black
        child: const Text("INIZIA", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
      ),
    );
  }

  Widget _modeButton(String mode) {
    bool isSelected = _selectedMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orangeAccent : const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              mode,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white60,
                fontWeight: FontWeight.bold,
                fontSize: 13,
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
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orangeAccent : const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              "$val$unit",
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white60,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}