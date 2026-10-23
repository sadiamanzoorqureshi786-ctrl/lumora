const crypto = require('crypto');

const caesarCipher = (text, shift, decrypt = false) => {
  const s = Number(shift);
  const offset = Number.isFinite(s) ? ((s % 26) + 26) % 26 : 0;
  const actualShift = decrypt ? (26 - offset) % 26 : offset;

  return String(text).split('').map(char => {
    if (/[a-z]/i.test(char)) {
      const code = char.charCodeAt(0);
      const isUpperCase = code >= 65 && code <= 90;
      const base = isUpperCase ? 65 : 97;
      return String.fromCharCode(((code - base + actualShift) % 26) + base);
    }
    return char;
  }).join('');
};
  
const transpositionCipher = (text, key, decrypt = false) => {
  const numKey = parseInt(key, 10);
  if (!Number.isFinite(numKey) || numKey <= 0) return String(text);

  if (decrypt) {
    const cols = Math.ceil(text.length / numKey);
    let result = '';

    for (let i = 0; i < cols; i++) {
      for (let j = 0; j < numKey; j++) {
        const idx = j * cols + i;
        if (idx < text.length) result += text[idx];
      }
    }
    return result;
  } else {
    const rows = Math.ceil(text.length / numKey);
    let result = '';

    for (let i = 0; i < numKey; i++) {
      for (let j = 0; j < rows; j++) {
        const idx = j * numKey + i;
        if (idx < text.length) result += text[idx];
      }
    }
    return result;
  }
};
  
const substitutionCipher = (text, key, decrypt = false) => {
  const alphabet = 'abcdefghijklmnopqrstuvwxyz';
  const keyLower = String(key || '').toLowerCase();
  const keyAlphabet = (keyLower + alphabet.split('').filter(c => !keyLower.includes(c)).join(''));

  return String(text).split('').map(char => {
    if (/[a-z]/i.test(char)) {
      const isUpperCase = char === char.toUpperCase();
      const lowerChar = char.toLowerCase();
      const index = decrypt ? keyAlphabet.indexOf(lowerChar) : alphabet.indexOf(lowerChar);
      if (index === -1) return char; // safety: leave unknown chars unchanged
      const newChar = decrypt ? alphabet[index] : keyAlphabet[index];
      return isUpperCase ? newChar.toUpperCase() : newChar;
    }
    return char;
  }).join('');
};
  
const generateRSAKeyPair = () => {
  const { publicKey, privateKey } = crypto.generateKeyPairSync('rsa', {
    modulusLength: 2048,
    publicKeyEncoding: { type: 'spki', format: 'pem' },
    privateKeyEncoding: { type: 'pkcs8', format: 'pem' }
  });
  return { publicKey, privateKey };
};

const encrypt = (text, algorithm, key) => {
  switch (algorithm) {
    case 'caesar':
      return caesarCipher(text, parseInt(key), false);
    case 'transposition':
      return transpositionCipher(text, key, false);
    case 'substitution':
      return substitutionCipher(text, key, false);
    case 'AES-256': {
      if (!key || key.length !== 32) throw new Error('AES-256 requires a 32-character key');
      const iv = crypto.randomBytes(16);
      const cipher = crypto.createCipheriv('aes-256-cbc', Buffer.from(key, 'utf8'), iv);
      let encrypted = cipher.update(text, 'utf8', 'base64');
      encrypted += cipher.final('base64');
      return { encrypted, iv: iv.toString('base64') };
    }
    case 'RSA': {
      // For RSA, use a generated in-memory keypair for demo purposes
      const { publicKey } = generateRSAKeyPair();
      const encryptedBuffer = crypto.publicEncrypt(
        {
          key: publicKey,
          padding: crypto.constants.RSA_PKCS1_OAEP_PADDING,
          oaepHash: 'sha256'
        },
        Buffer.from(text, 'utf8')
      );
      return { encrypted: encryptedBuffer.toString('base64'), publicKey };
    }
    default:
      throw new Error('Invalid algorithm');
  }
};

const decrypt = (text, algorithm, key, iv) => {
  switch (algorithm) {
    case 'caesar':
      return caesarCipher(text, parseInt(key), true);
    case 'transposition':
      return transpositionCipher(text, key, true);
    case 'substitution':
      return substitutionCipher(text, key, true);
    case 'AES-256': {
      if (!key || !iv) throw new Error('AES-256 requires both key and IV');
      const decipher = crypto.createDecipheriv('aes-256-cbc', Buffer.from(key, 'utf8'), Buffer.from(iv, 'base64'));
      let decrypted = decipher.update(text, 'base64', 'utf8');
      decrypted += decipher.final('utf8');
      return decrypted;
    }
    case 'RSA': {
      throw new Error('RSA decrypt not implemented in utils (use server RSA endpoints)');
    }
    default:
      throw new Error('Invalid algorithm');
  }
};

module.exports = {
  encrypt,
  decrypt,
  caesarCipher,
  transpositionCipher,
  substitutionCipher,
  generateRSAKeyPair
};