const { caesarCipher, transpositionCipher, substitutionCipher } = require('./encryption');

const assert = (a, msg) => { if (!a) { console.error('FAIL:', msg); process.exit(1); } };

// Caesar
const c = caesarCipher('Hello, World!', 3, false);
const d = caesarCipher(c, 3, true);
console.log('Caesar enc:', c, 'dec:', d);
assert(d === 'Hello, World!', 'Caesar roundtrip');

// Transposition
const tEnc = transpositionCipher('attackatdawn', 3, false);
const tDec = transpositionCipher(tEnc, 3, true);
console.log('Transposition enc:', tEnc, 'dec:', tDec);
assert(tDec === 'attackatdawn', 'Transposition roundtrip');

// Substitution
const key = 'keyword';
const sEnc = substitutionCipher('HelloWorld', key, false);
const sDec = substitutionCipher(sEnc, key, true);
console.log('Substitution enc:', sEnc, 'dec:', sDec);
assert(sDec === 'HelloWorld', 'Substitution roundtrip');

console.log('All classical cipher tests passed ✅');
