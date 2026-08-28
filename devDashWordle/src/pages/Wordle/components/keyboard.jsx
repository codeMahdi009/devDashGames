import React from 'react';

const ROWS = [
  ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
  ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
  ['ENTER', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', 'BACKSPACE']
];

export default function Keyboard({ onKeyPress, guesses, currentRow, solution }) {
  
  // Find the best matching color status for each individual letter
  const getKeyColor = (letter) => {
    if (letter === 'ENTER' || letter === 'BACKSPACE') return 'bg-zinc-500 hover:bg-zinc-400 text-xs font-bold px-2 sm:px-4';
    
    let colorClass = 'bg-zinc-600 hover:bg-zinc-500';
    let statusPriority = 0; // 0: unmapped, 1: gray, 2: yellow, 3: green

    // Scan all words submitted so far to determine this letter's layout color
    for (let i = 0; i < currentRow; i++) {
      const currentWord = guesses[i];
      
      for (let j = 0; j < currentWord.length; j++) {
        if (currentWord[j] !== letter) continue;

        if (solution[j] === letter) {
          statusPriority = 3; // Green takes top priority
        } else if (solution.includes(letter) && statusPriority < 3) {
          statusPriority = 2; // Yellow
        } else if (statusPriority < 2) {
          statusPriority = 1; // Gray
        }
      }
    }

    if (statusPriority === 3) colorClass = 'bg-green-600 hover:bg-green-500 text-white';
    if (statusPriority === 2) colorClass = 'bg-yellow-500 hover:bg-yellow-400 text-white';
    if (statusPriority === 1) colorClass = 'bg-zinc-800 text-zinc-500 pointer-events-none'; // Locks dead keys

    return colorClass;
  };

  return (
    <div className="w-full max-w-md mt-4 px-1 select-none">
      {ROWS.map((row, rowIndex) => (
        <div key={rowIndex} className="flex justify-center my-1 gap-1 touch-action-manipulation">
          {row.map((key) => {
            const dynamicStyles = getKeyColor(key);
            
            return (
              <button
                key={key}
                type="button"
                onClick={() => onKeyPress(key)}
                className={`h-14 flex-1 flex items-center justify-center rounded-xs font-extrabold uppercase transition-all active:scale-95 duration-100 cursor-pointer text-white ${dynamicStyles}`}
              >
                {key === 'BACKSPACE' ? '⌫' : key}
              </button>
            );
          })}
        </div>
      ))}
    </div>
  );
}