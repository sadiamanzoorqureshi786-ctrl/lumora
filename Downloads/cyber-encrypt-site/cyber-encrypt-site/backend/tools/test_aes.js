const { encrypt, decrypt } = require('../utils/encryption');

const key = '12345678901234567890123456789012';
const plain = 'hello world';

try {
  const enc = encrypt(plain, 'AES-256', key);
  console.log('Encrypted result:', enc);
  const decrypted = decrypt(enc.encrypted, 'AES-256', key, enc.iv);
  console.log('Decrypted:', decrypted);
  console.log('Match:', decrypted === plain);
} catch (err) {
  console.error('Error during AES test:', err.message);
}
