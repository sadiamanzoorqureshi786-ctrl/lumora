// backend/utils/encryption.js
const crypto = require('crypto');

// Caesar Cipher
function caesarEncrypt(text, shift) {
  shift = parseInt(shift) || 3;
  return text
    .split('')
    .map(char => {
      if (char.match(/[a-z]/i)) {
        const code = char.charCodeAt(0);
        const base = code >= 65 && code <= 90 ? 65 : 97;
        return String.fromCharCode(((code - base + shift) % 26) + base);
      }
      return char;
    })
    .join('');
}

function caesarDecrypt(text, shift) {
  shift = parseInt(shift) || 3;
  return caesarEncrypt(text, 26 - shift);
}

// Transposition Cipher
function transpositionEncrypt(text, key) {
  key = parseInt(key) || 5;
  const columns = Math.ceil(text.length / key);
  const grid = Array(key).fill('').map(() => []);
  
  for (let i = 0; i < text.length; i++) {
    grid[i % key].push(text[i]);
  }
  
  return grid.map(row => row.join('')).join('');
}

function transpositionDecrypt(text, key) {
  key = parseInt(key) || 5;
  const columns = Math.ceil(text.length / key);
  const grid = Array(key).fill('').map(() => []);
  
  let index = 0;
  for (let i = 0; i < key; i++) {
    const rowLength = i < (text.length % key || key) ? columns : columns - 1;
    for (let j = 0; j < rowLength; j++) {
      grid[i].push(text[index++]);
    }
  }
  
  let result = '';
  for (let col = 0; col < columns; col++) {
    for (let row = 0; row < key; row++) {
      if (grid[row][col]) result += grid[row][col];
    }
  }
  
  return result;
}

// Substitution Cipher
function substitutionEncrypt(text, key) {
  key = key || 'zyxwvutsrqponmlkjihgfedcba';
  const alphabet = 'abcdefghijklmnopqrstuvwxyz';
  
  return text
    .split('')
    .map(char => {
      if (char.match(/[a-z]/i)) {
        const isUpper = char === char.toUpperCase();
        const index = alphabet.indexOf(char.toLowerCase());
        const newChar = key[index] || char;
        return isUpper ? newChar.toUpperCase() : newChar;
      }
      return char;
    })
    .join('');
}

function substitutionDecrypt(text, key) {
  key = key || 'zyxwvutsrqponmlkjihgfedcba';
  const alphabet = 'abcdefghijklmnopqrstuvwxyz';
  
  return text
    .split('')
    .map(char => {
      if (char.match(/[a-z]/i)) {
        const isUpper = char === char.toUpperCase();
        const index = key.indexOf(char.toLowerCase());
        const newChar = alphabet[index] || char;
        return isUpper ? newChar.toUpperCase() : newChar;
      }
      return char;
    })
    .join('');
}

// AES-256 Encryption
function aesEncrypt(text, key) {
  const iv = crypto.randomBytes(16);
  const keyBuffer = crypto.scryptSync(key, 'salt', 32);
  const cipher = crypto.createCipheriv('aes-256-cbc', keyBuffer, iv);
  
  let encrypted = cipher.update(text, 'utf8', 'hex');
  encrypted += cipher.final('hex');
  
  return {
    encryptedText: encrypted,
    iv: iv.toString('hex')
  };
}

function aesDecrypt(encryptedText, key, iv) {
  const keyBuffer = crypto.scryptSync(key, 'salt', 32);
  const decipher = crypto.createDecipheriv(
    'aes-256-cbc',
    keyBuffer,
    Buffer.from(iv, 'hex')
  );
  
  let decrypted = decipher.update(encryptedText, 'hex', 'utf8');
  decrypted += decipher.final('utf8');
  
  return decrypted;
}

// RSA Encryption
function generateRSAKeyPair() {
  const { publicKey, privateKey } = crypto.generateKeyPairSync('rsa', {
    modulusLength: 2048,
    publicKeyEncoding: { type: 'spki', format: 'pem' },
    privateKeyEncoding: { type: 'pkcs8', format: 'pem' }
  });
  
  return { publicKey, privateKey };
}

function rsaEncrypt(text, publicKey) {
  const encrypted = crypto.publicEncrypt(
    { key: publicKey, padding: crypto.constants.RSA_PKCS1_OAEP_PADDING },
    Buffer.from(text)
  );
  
  return encrypted.toString('base64');
}

function rsaDecrypt(encryptedText, privateKey) {
  const decrypted = crypto.privateDecrypt(
    { key: privateKey, padding: crypto.constants.RSA_PKCS1_OAEP_PADDING },
    Buffer.from(encryptedText, 'base64')
  );
  
  return decrypted.toString('utf8');
}

// Main encrypt function
function encryptMessage(text, algorithm, key) {
  switch (algorithm.toLowerCase()) {
    case 'caesar':
      return { encryptedText: caesarEncrypt(text, key), iv: null };
    
    case 'transposition':
      return { encryptedText: transpositionEncrypt(text, key), iv: null };
    
    case 'substitution':
      return { encryptedText: substitutionEncrypt(text, key), iv: null };
    
    case 'aes-256':
      return aesEncrypt(text, key);
    
    case 'rsa':
      return { encryptedText: rsaEncrypt(text, key), iv: null };
    
    default:
      throw new Error('Unsupported encryption algorithm');
  }
}

// Main decrypt function
function decryptMessage(encryptedText, algorithm, key, iv) {
  switch (algorithm.toLowerCase()) {
    case 'caesar':
      return caesarDecrypt(encryptedText, key);
    
    case 'transposition':
      return transpositionDecrypt(encryptedText, key);
    
    case 'substitution':
      return substitutionDecrypt(encryptedText, key);
    
    case 'aes-256':
      return aesDecrypt(encryptedText, key, iv);
    
    case 'rsa':
      return rsaDecrypt(encryptedText, key);
    
    default:
      throw new Error('Unsupported decryption algorithm');
  }
}

module.exports = {
  encryptMessage,
  decryptMessage,
  generateRSAKeyPair,
  caesarEncrypt,
  caesarDecrypt,
  transpositionEncrypt,
  transpositionDecrypt,
  substitutionEncrypt,
  substitutionDecrypt,
  aesEncrypt,
  aesDecrypt,
  rsaEncrypt,
  rsaDecrypt
};