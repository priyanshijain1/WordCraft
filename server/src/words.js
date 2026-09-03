'use strict';

// Curated word list shared across multiplayer rounds.
// Words are short (4-7 letters) and unambiguous for a scramble game.

const WORDS = [
  'tiger', 'eagle', 'snake', 'whale', 'panda', 'horse', 'camel', 'zebra',
  'raven', 'koala', 'pizza', 'salad', 'sushi', 'bread', 'tacos', 'grape',
  'melon', 'mango', 'train', 'plane', 'hotel', 'beach', 'cruise', 'trunk',
  'sunset', 'river', 'mountain', 'forest', 'ocean', 'valley', 'canyon',
  'meadow', 'stream', 'glacier', 'tennis', 'golf', 'rugby', 'soccer',
  'boxing', 'cricket', 'rowing', 'archery', 'jogging', 'jousts', 'kayak',
  'mosaic', 'nectar', 'orbit', 'puzzle', 'quartz', 'rhythm', 'spiral',
  'tundra', 'umbrella', 'vortex', 'winter', 'yellow', 'zephyr',
];

// Pick a random word without repeating the previous one.
function randomWord(previous = null) {
  let word;
  do {
    word = WORDS[Math.floor(Math.random() * WORDS.length)];
  } while (word === previous);
  return word;
}

// Scramble a word so it always differs from the original order.
function scramble(word) {
  let letters = word.split('');
  let candidate = word;
  let attempts = 0;
  while (candidate === word && attempts < 20) {
    letters = shuffle(letters.slice());
    candidate = letters.join('');
    attempts++;
  }
  return candidate;
}

function shuffle(arr) {
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr;
}

module.exports = { WORDS, randomWord, scramble, shuffle };
