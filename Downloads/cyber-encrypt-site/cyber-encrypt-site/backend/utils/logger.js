const caesarCipher = (text, shift, decrypt = false) => {
    const actualShift = decrypt ? -shift : shift;
    
    return text.split('').map(char => {
      if (char.match(/[a-z]/i)) {
        const code = char.charCodeAt(0);
        const isUpperCase = code >= 65 && code <= 90;
        const base = isUpperCase ? 65 : 97;
        return String.fromCharCode(((code - base + actualShift + 26) % 26) + base);
      }
      return char;
    }).join('');
  };
  
  const transpositionCipher = (text, key, decrypt = false) => {
    const numKey = parseInt(key);
    
    if (decrypt) {
      const cols = Math.ceil(text.length / numKey);
      let result = '';
      
      for (let i = 0; i < cols; i++) {
        for (let j = 0; j < numKey; j++) {
          const idx = j * cols + i;
          if (idx < text.length) {
            result += text[idx];
          }
        }
      }
      return result;
    } else {
      const rows = Math.ceil(text.length / numKey);
      let result = '';
      
      for (let i = 0; i < numKey; i++) {
        for (let j = 0; j < rows; j++) {
          const idx = j * numKey + i;
          if (idx < text.length) {
            result += text[idx];
          }
        }
      }
      return result;
    }
  };
  
  const substitutionCipher = (text, key, decrypt = false) => {
    const alphabet = 'abcdefghijklmnopqrstuvwxyz';
    const keyAlphabet = key.toLowerCase() + alphabet.split('').filter(char => !key.toLowerCase().includes(char)).join('');
    
    return text.split('').map(char => {
      if (char.match(/[a-z]/i)) {
        const isUpperCase = char === char.toUpperCase();
        const lowerChar = char.toLowerCase();
        const index = decrypt ? keyAlphabet.indexOf(lowerChar) : alphabet.indexOf(lowerChar);
        const newChar = decrypt ? alphabet[index] : keyAlphabet[index];
        return isUpperCase ? newChar.toUpperCase() : newChar;
      }
      return char;
    }).join('');
  };
  
  const encrypt = (text, algorithm, key) => {
    switch (algorithm) {
      case 'caesar':
        return caesarCipher(text, parseInt(key), false);
      case 'transposition':
        return transpositionCipher(text, key, false);
      case 'substitution':
        return substitutionCipher(text, key, false);
      default:
        throw new Error('Invalid algorithm');
    }
  };
  
  const decrypt = (text, algorithm, key) => {
    switch (algorithm) {
      case 'caesar':
        return caesarCipher(text, parseInt(key), true);
      case 'transposition':
        return transpositionCipher(text, key, true);
      case 'substitution':
        return substitutionCipher(text, key, true);
      default:
        throw new Error('Invalid algorithm');
    }
  };
  
  module.exports = {
    encrypt,
    decrypt,
    caesarCipher,
    transpositionCipher,
    substitutionCipher
  };