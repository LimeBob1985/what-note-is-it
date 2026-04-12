import 'dart:math';

class MusicLogic {
  static const List<int> stringOpenNotes = [4, 9, 2, 7, 11, 4];
  
  static const List<String> notesIt = [
    "DO", "DO#/REb", "RE", "RE#/MIb", "MI", "FA", 
    "FA#/SOLb", "SOL", "SOL#/LAb", "LA", "LA#/SIb", "SI"
  ];

  static const List<String> notesEn = [
    "C", "C#/Db", "D", "D#/Eb", "E", "F", 
    "F#/Gb", "G", "G#/Ab", "A", "A#/Bb", "B"
  ];

  static const List<String> romanNumerals = ["VI", "V", "IV", "III", "II", "I"];

  // Calcola l'indice della nota (0-11) data corda e tasto
  static int getNoteIndex(int stringIndex, int fret) {
    int openNoteIndex = stringOpenNotes[stringIndex - 1];
    return (openNoteIndex + fret) % 12;
  }
}