enum GameMode { apod, offline }

enum GameStatus { inProgress, won, lost }

enum KeyStatus {
  unknown,
  grey, // not used anywhere in the guess
  orange, // used somewhere in the guess
  green, // correct position of letter
}

class GameState {
  // once set, it wont be changed for a game round
  final GameMode mode; // apod or offline
  final DateTime startedAt; // when the game round started
  final String originalTitle; // raw title from APOD or random offline word
  final String normalizedAnswer; // uppercase originalTitle for logic
  final List<int> blankIndexes; // positions of blanks in normalized answer
  final String? imagePath; // image path
  final String? apodDate; // only for APOD mode

  // same no of attempts for every game
  static const int MAX_ATTEMPTS = 5;

  // change during game play
  GameStatus status;
  int attemptsUsed; // default 0
  Map<int, String>
  confirmedLetters; // greens locked in place <position, letter>
  Map<int, String>
  currentEntryLetters; // typed before Enter  <position, letter>
  Map<String, KeyStatus> keyboardStatus; // A-Z => status

  GameState({
    required this.mode,
    DateTime? startedAt,
    required this.originalTitle,
    required this.normalizedAnswer,
    required this.blankIndexes,
    this.imagePath,
    this.apodDate,

    this.status = GameStatus.inProgress,
    this.attemptsUsed = 0,
    Map<String, KeyStatus>? keyboardStatus,
    Map<int, String>? confirmedLetters,
    Map<int, String>? currentEntryLetters,
  }) : startedAt = startedAt ?? DateTime.now(),
       keyboardStatus = keyboardStatus ?? _initializeKeyboard(),
       confirmedLetters = confirmedLetters ?? {},
       currentEntryLetters = currentEntryLetters ?? {};

  /// initialize all letters as unknown
  static Map<String, KeyStatus> _initializeKeyboard() {
    final keyboard = <String, KeyStatus>{};
    for (String letter in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('')) {
      keyboard[letter] = KeyStatus.unknown;
    }
    return keyboard;
  }

  bool isWon() {
    for (int i = 0; i < normalizedAnswer.length; i++) {
      if (blankIndexes.contains(i)) {
        if (confirmedLetters[i] != normalizedAnswer[i]) {
          return false;
        }
      }
    }
    return true;
  }

  bool isLost() {
    return attemptsUsed >= MAX_ATTEMPTS && !isWon();
  }

  bool isComplete() {
    return isWon() || isLost();
  }

  // get seconds elapsed
  int getSecondsElapsed() {
    return (DateTime.now().difference(startedAt).inSeconds);
  }

  /// Update keyboard status for a letter
  void updateKeyboardStatus(String letter, KeyStatus keyStatus) {
    keyboardStatus[letter] = keyStatus;
  }

  /// Update confirmed letter at position
  void updateConfirmedLetter(int position, String letter) {
    confirmedLetters[position] = letter;
  }

  /// Update current entry letter at position
  void updateCurrentEntry(int position, String letter) {
    currentEntryLetters[position] = letter;
  }

  /// Clear current entry (after Enter pressed)
  void clearCurrentEntry() {
    currentEntryLetters.clear();
  }

  void incrementAttempts() {
    attemptsUsed++;
  }

  void markAsWon() {
    status = GameStatus.won;
  }

  void markAsLost() {
    status = GameStatus.lost;
  }
}
