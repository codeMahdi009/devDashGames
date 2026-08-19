import React from 'react';

const WORD_LENGTH = 5;

export default function WordleGrid({ guesses, currentGuess, currentRow, solution }) {
  
  // Clean color assignment function for submitted rows
  const getTileColor = (char, index, isSubmitted) => {
    if (!isSubmitted) return 'border-zinc-600 bg-transparent text-white';
    if (solution[index] === char) return 'bg-green-600 border-green-600 text-white';
    if (solution.includes(char)) return 'bg-yellow-500 border-yellow-500 text-white';
    return 'bg-zinc-700 border-zinc-700 text-white';
  };

  return (
    <div className="grid grid-rows-6 gap-1.5 w-full max-w-82.5 aspect-5/6 mb-8">
      {guesses.map((guess, rowIndex) => {
        const isCurrentRow = rowIndex === currentRow;
        const isSubmitted = rowIndex < currentRow;
        
        // Build out full 5 letter string segments even if incomplete
        const rowText = isCurrentRow 
          ? currentGuess.padEnd(WORD_LENGTH, ' ') 
          : guess.padEnd(WORD_LENGTH, ' ');

        return (
          <div key={rowIndex} className="grid grid-cols-5 gap-1.5">
            {Array.from({ length: WORD_LENGTH }).map((_, colIndex) => {
              const char = rowText[colIndex]?.trim() || '';
              const colorClass = getTileColor(char, colIndex, isSubmitted);

              return (
                <div
                  key={colIndex}
                  className={`flex items-center justify-center text-2xl font-extrabold uppercase border-2 rounded-xs transition-all duration-300 ${colorClass}`}
                >
                  {char}
                </div>
              );
            })}
          </div>
        );
      })}
    </div>
  );
}