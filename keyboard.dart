import 'package:flutter/material.dart';
import 'package:spacefill_game/models/game_state.dart';

class GameKeyboard extends StatelessWidget {
  const GameKeyboard({
    super.key,
    required this.keyboardStatus,
    required this.onLetterTap,
    required this.onEnterTap,
    required this.onBackspaceTap,
  });

  final Map<String, KeyStatus> keyboardStatus;
  final ValueChanged<String> onLetterTap;
  final VoidCallback onEnterTap;
  final VoidCallback onBackspaceTap;

  static const rows = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
  ];

  Color _keyColor(String letter) {
    switch (keyboardStatus[letter] ?? KeyStatus.unknown) {
      case KeyStatus.green:
        return Colors.green;
      case KeyStatus.orange:
        return Colors.orange;
      case KeyStatus.grey:
        return const Color.fromARGB(255, 42, 42, 42);
      case KeyStatus.unknown:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1);

    final keyWidth = 32.0 * scale;
    final keyHeight = 42.0 * scale;
    final fontSize = 18.0 * scale;

    return SafeArea(
      child: Column(
        children: [
          for (final row in rows)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((letter) {
                return SizedBox(
                  width: keyWidth,
                  height: keyHeight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _keyColor(letter),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () {
                      if (keyboardStatus[letter] != KeyStatus.grey) {
                        onLetterTap(letter);
                      }
                    },
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontSize: fontSize,
                        color: Colors.tealAccent,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: onEnterTap, child: const Text('ENTER')),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: onBackspaceTap,
                child: const Icon(Icons.backspace_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
