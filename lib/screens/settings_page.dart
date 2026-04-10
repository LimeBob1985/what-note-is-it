import 'package:flutter/material.dart';
// Corretto il percorso dell'import per la struttura a cartelle
import 'game_page.dart'; 

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedFrets = 12;
  bool _timerEnabled = false;
  int _timerSeconds = 10;
  String _selectedMode = "INDOVINA"; // Nuova variabile per la modalità
  final List<int> _timerOptions = [5, 10, 20, 30];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text(
          "IMPOSTAZIONI", 
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SEZIONE MODALITÀ ---
              const Text("MODALITÀ DI GIOCO", style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 10),
              Row(
                children: [ 
                  _modeButton("INDOVINA"), 
                  const SizedBox(width: 10), 
                  _modeButton("TROVA"),
                ]
              ),
              const SizedBox(height: 30),

              // --- SEZIONE TASTI ---
              const Text("NUMERO TASTI", style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 10),
              Row(
                children: [ 
                  _optionButton(12, _selectedFrets, (v) => _selectedFrets = v, " TASTI"), 
                  const SizedBox(width: 10), 
                  _optionButton(22, _selectedFrets, (v) => _selectedFrets = v, " TASTI")
                ]
              ),
              const SizedBox(height: 30),
              
              // --- SEZIONE TIMER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                children: [
                  const Text("TIMER SFIDA", style: TextStyle(color: Colors.white, fontSize: 16)),
                  Switch(
                    value: _timerEnabled, 
                    activeThumbColor: Colors.orangeAccent, 
                    onChanged: (val) => setState(() => _timerEnabled = val)
                  ),
                ]
              ),
              
              if (_timerEnabled) ...[
                const SizedBox(height: 15),
                const Text("DURATA TIMER (SEC)", style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _timerOptions.map((sec) => _optionButton(sec, _timerSeconds, (v) => _timerSeconds = v, "s")).toList(),
                ),
              ],
              
              const Spacer(),
              
              // --- BOTTONE START ---
              SizedBox(
                width: double.infinity, 
                height: 60, 
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent, 
                    foregroundColor: Colors.black, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  onPressed: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => GamePage(
                          frets: _selectedFrets, 
                          timer: _timerEnabled ? _timerSeconds : null,
                          mode: _selectedMode, // Passiamo la modalità scelta
                        )
                      )
                    );
                  },
                  child: const Text("INIZIA ALLENAMENTO", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget per i bottoni della modalità (Indovina/Trova)
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
                fontWeight: FontWeight.bold
              )
            )
          ),
        ),
      ),
    );
  }

  // Il tuo widget originale per i bottoni opzione (Tasti/Timer)
  Widget _optionButton(int val, int groupVal, Function(int) onSelect, String unit) {
    bool isSelected = groupVal == val;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => onSelect(val)),
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
                fontWeight: FontWeight.bold
              )
            )
          ),
        ),
      ),
    );
  }
}