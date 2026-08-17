import 'dart:math';
import 'package:spacefill_game/models/apod.dart';
import 'package:spacefill_game/models/game_state.dart';
import 'package:spacefill_game/models/offline.dart';

class GameLogic {
  static const List<Offline> offlinePuzzles = [
    Offline(title: 'GALAXY', imagePath: 'lib/assets/galaxy.png'),
    Offline(title: 'NEBULA', imagePath: 'lib/assets/nebula.png'),
    Offline(title: 'SATURN', imagePath: 'lib/assets/SATURN.png'),
    Offline(title: 'MOON', imagePath: 'lib/assets/MOON.png'),
    Offline(title: 'ASTEROID', imagePath: 'lib/assets/ASTEROID.png'),
    Offline(title: 'ROCKET', imagePath: 'lib/assets/ROCKET.png'),
    Offline(title: 'SATELLITE', imagePath: 'lib/assets/SATELLITE.png'),
    Offline(title: 'ASTRONAUT', imagePath: 'lib/assets/ASTRONAUT.png'),
    Offline(title: 'ECLIPSE', imagePath: 'lib/assets/ECLIPSE.png'),
  ];

  static List<int> makeBlankIndexes(String title) {
    final String normalized = title.toUpperCase();
    final List<int> alphabetIndexes = [];

    for (int i = 0; i < normalized.length; i++) {
      if (RegExp(r'[A-Z]').hasMatch(normalized[i])) {
        alphabetIndexes.add(i);
      }
    }

    int targetCount = (alphabetIndexes.length / 2).floor();
    final List<int> blankIndexes = [];

    int step = 3; // start picking every 3 letters

    while (blankIndexes.length < targetCount) {
      for (int i = 0; i < alphabetIndexes.length; i++) {
        if (blankIndexes.length >= targetCount) break;

        if (i % step == 0 && !blankIndexes.contains(alphabetIndexes[i])) {
          blankIndexes.add(alphabetIndexes[i]);
        }
      }
      step = 2; // switches to 2 after first loop
    }

    blankIndexes.sort();
    return blankIndexes;
  }

  static GameState createOfflineGame() {
    Random random = Random();
    int randomInt = random.nextInt(offlinePuzzles.length);

    return GameState(
      mode: GameMode.offline,
      startedAt: DateTime.now(),
      originalTitle: offlinePuzzles[randomInt].title,
      normalizedAnswer: offlinePuzzles[randomInt].title.toUpperCase(),
      blankIndexes: makeBlankIndexes(offlinePuzzles[randomInt].title),
      imagePath: offlinePuzzles[randomInt].imagePath,
    );
  }

  static GameState createAPODGame(APOD apod) {
    return GameState(
      mode: GameMode.apod,
      startedAt: DateTime.now(),
      originalTitle: apod.title,
      normalizedAnswer: apod.title.toUpperCase(),
      blankIndexes: makeBlankIndexes(apod.title),
      apodDate: apod.date,
      imagePath: apod.localMediaPath,
    );
  }

  static void inputLetter(GameState state, String letter) {
    for (final index in state.blankIndexes) {
      final isConfirmed = state.confirmedLetters.containsKey(index);
      final isTyped = state.currentEntryLetters.containsKey(index);

      if (!isConfirmed && !isTyped) {
        state.updateCurrentEntry(index, letter.toUpperCase());
        return;
      }
    }
  }

  static void backspace(GameState state) {
    if (state.currentEntryLetters.isEmpty) return;

    final lastIndex = state.currentEntryLetters.keys.last;
    state.currentEntryLetters.remove(lastIndex);
  }

  static bool _hasRemainingBlankForLetter(GameState state, String letter) {
    for (final index in state.blankIndexes) {
      final needsLetter = state.normalizedAnswer[index] == letter;
      final isConfirmed = state.confirmedLetters[index] == letter;

      if (needsLetter && !isConfirmed) {
        return true;
      }
    }
    return false;
  }

  static void submitGuess(GameState state) {
    //confirm all correct letters
    for (final index in state.blankIndexes) {
      final typed = state.currentEntryLetters[index];
      final actual = state.normalizedAnswer[index];

      if (typed == null) continue;

      if (typed == actual) {
        state.updateConfirmedLetter(index, typed);
      }
    }

    for (final index in state.blankIndexes) {
      final typed = state.currentEntryLetters[index];
      final actual = state.normalizedAnswer[index];

      if (typed == null) continue;

      if (typed != actual) {
        if (state.normalizedAnswer.contains(typed) &&
            _hasRemainingBlankForLetter(state, typed)) {
          state.updateKeyboardStatus(typed, KeyStatus.orange);
        } else {
          state.updateKeyboardStatus(typed, KeyStatus.grey);
        }
      }
    }

    state.confirmedLetters.forEach((key, value) {
      if (_hasRemainingBlankForLetter(state, value)) {
        state.updateKeyboardStatus(value, KeyStatus.orange);
      } else {
        state.updateKeyboardStatus(value, KeyStatus.green);
      }
    });

    state.incrementAttempts();
    state.clearCurrentEntry();

    if (state.isComplete()) {
      if (state.isWon()) {
        state.markAsWon();
      } else {
        state.markAsLost();
      }
    }
  }
}
