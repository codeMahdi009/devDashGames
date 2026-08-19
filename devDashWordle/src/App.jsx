import React, { useState, useEffect, useCallback } from 'react';
import { OBFUSCATED_WORDS } from './wordleWordBank';
import WordleGrid from './components/wordleGrid';
import Keyboard from './components/keyboard';

const GAME_LAUNCH_TIME = new Date('2026-01-01').getTime();
const MAX_GUESSES = 6;
const WORD_LENGTH = 5;

export default function App() {
  const [solution, setSolution] = useState('');
  const [guesses, setGuesses] = useState(Array(MAX_GUESSES).fill(''));
  const [currentGuess, setCurrentGuess] = useState('');
  const [currentRow, setCurrentRow] = useState(0);
  const [gameStatus, setGameStatus] = useState('IN_PROGRESS');

  // Time calculations determine exactly which word index decrypts natively today
  useEffect(() => {
    const timePassed = new Date().getTime() - GAME_LAUNCH_TIME;
    const daysSinceLaunch = Math.floor(timePassed / (1000 * 60 * 60 * 24));
    const targetIndex = Math.abs(daysSinceLaunch % OBFUSCATED_WORDS.length);
    
    const decrypted = atob(OBFUSCATED_WORDS[targetIndex]).toUpperCase();
    setSolution(decrypted);
  }, []);

  // Core central typing controller used by both physical keys and onscreen button clicks
  const handleInputAction = useCallback((key) => {
    if (gameStatus !== 'IN_PROGRESS') return;

    if (key === 'ENTER') {
      if (currentGuess.length !== WORD_LENGTH) return;
      
      const newGuesses = [...guesses];
      newGuesses[currentRow] = currentGuess;
      setGuesses(newGuesses);

      if (currentGuess === solution) {
        setGameStatus('WON');
      } else if (currentRow === MAX_GUESSES - 1) {
        setGameStatus('LOST');
      } else {
        setCurrentRow(currentRow + 1);
        setCurrentGuess('');
      }
      return;
    }

    if (key === 'BACKSPACE') {
      setCurrentGuess(prev => prev.slice(0, -1));
      return;
    }

    if (/^[A-Z]$/.test(key) && currentGuess.length < WORD_LENGTH) {
      setCurrentGuess(prev => prev + key);
    }
  }, [currentGuess, currentRow, gameStatus, guesses, solution]);

  // Bind physical keyboard listeners
  useEffect(() => {
    const handleKeyDown = (e) => {
      const key = e.key.toUpperCase();
      handleInputAction(key);
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [handleInputAction]);

  return (
    <div className="flex flex-col items-center justify-center min-h-screen text-white px-2 py-4 select-none">
      <header className="border-b border-zinc-800 w-full max-w-md text-center py-2 mb-6">
        <h1 className="text-3xl font-black tracking-widest text-zinc-100">WORDLE</h1>
      </header>

      {/* Dev Debug Output Header */}
      <div className="mb-4 text-xs text-green-400 bg-zinc-900 border border-zinc-800 px-3 py-1 rounded">
        Secure Answer: <span className="font-bold underline">{solution}</span>
      </div>

      {/* Visual Game Matrix Board */}
      <WordleGrid 
        guesses={guesses} 
        currentGuess={currentGuess} 
        currentRow={currentRow} 
        solution={solution} 
      />

      {/* Onscreen Alphabet Keyboard Segment */}
      <Keyboard 
        onKeyPress={handleInputAction} 
        guesses={guesses} 
        currentRow={currentRow} 
        solution={solution} 
      />

      {/* Dynamic Messaging Box */}
      <div className="h-10 mt-4 flex items-center justify-center">
        {gameStatus === 'WON' && <div className="text-xl font-bold text-green-400 animate-bounce">🎉 Brilliant! You won!</div>}
        {gameStatus === 'LOST' && <div className="text-xl font-bold text-red-400">Game Over! The word was {solution}</div>}
      </div>
    </div>
  );
}