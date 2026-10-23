const express = require('express');
const crypto = require('crypto');

const router = express.Router();

// RSA Key generation helper
function generateRSAKeyPair() {
  const { publicKey, privateKey } = crypto.generateKeyPairSync('rsa', {
    modulusLength: 2048,
    publicKeyEncoding: { type: 'spki', format: 'pem' },
    privateKeyEncoding: { type: 'pkcs8', format: 'pem' }
  });
  return { publicKey, privateKey };
}

// In-memory RSA keys (for demo). Replace with persistent storage in production.
let rsaKeys = generateRSAKeyPair();

// POST /api/encrypt
router.post('/encrypt', async (req, res) => {
  try {
    const { text, algorithm, key } = req.body;
    if (!text) return res.status(400).json({ error: 'Text is required' });

    let result;

    if (algorithm === 'AES-256') {
      if (!key || key.length !== 32) {
        return res.status(400).json({ error: 'AES-256 requires a 32-character key' });
      }

      const iv = crypto.randomBytes(16);
      const cipher = crypto.createCipheriv('aes-256-cbc', Buffer.from(key, 'utf8'), iv);
      let encrypted = cipher.update(text, 'utf8', 'base64');
      encrypted += cipher.final('base64');

      result = { encrypted, iv: iv.toString('base64'), algorithm: 'AES-256' };
    } else if (algorithm === 'RSA') {
      if (req.body.generateKeys) rsaKeys = generateRSAKeyPair();

      const encryptedBuffer = crypto.publicEncrypt(
        {
          key: rsaKeys.publicKey,
          padding: crypto.constants.RSA_PKCS1_OAEP_PADDING,
          oaepHash: 'sha256'
        },
        Buffer.from(text, 'utf8')
      );

      result = { encrypted: encryptedBuffer.toString('base64'), publicKey: rsaKeys.publicKey, algorithm: 'RSA' };
    } else {
      return res.status(400).json({ error: 'Unsupported algorithm. Use AES-256 or RSA' });
    }

    res.json({ success: true, ...result });
  } catch (err) {
    console.error('Encryption error:', err);
    res.status(500).json({ error: 'Encryption failed', details: err.message });
  }
});

// POST /api/decrypt
router.post('/decrypt', async (req, res) => {
  try {
    const { encrypted, algorithm, key, iv } = req.body;
    if (!encrypted) return res.status(400).json({ error: 'Encrypted text is required' });

    let decrypted;

    if (algorithm === 'AES-256') {
      if (!key || !iv) return res.status(400).json({ error: 'AES-256 requires both key and IV' });

      const decipher = crypto.createDecipheriv('aes-256-cbc', Buffer.from(key, 'utf8'), Buffer.from(iv, 'base64'));
      decrypted = decipher.update(encrypted, 'base64', 'utf8');
      decrypted += decipher.final('utf8');
    } else if (algorithm === 'RSA') {
      const decryptedBuffer = crypto.privateDecrypt(
        {
          key: rsaKeys.privateKey,
          padding: crypto.constants.RSA_PKCS1_OAEP_PADDING,
          oaepHash: 'sha256'
        },
        Buffer.from(encrypted, 'base64')
      );

      decrypted = decryptedBuffer.toString('utf8');
    } else {
      return res.status(400).json({ error: 'Unsupported algorithm' });
    }

    res.json({ success: true, decrypted, algorithm });
  } catch (err) {
    console.error('Decryption error:', err);
    res.status(500).json({ error: 'Decryption failed', details: err.message });
  }
});

// GET /api/rsa-key
router.get('/rsa-key', (req, res) => {
  res.json({ publicKey: rsaKeys.publicKey, keyGenerated: true });
});

// POST /api/rsa-key/generate
router.post('/rsa-key/generate', (req, res) => {
  rsaKeys = generateRSAKeyPair();
  res.json({ publicKey: rsaKeys.publicKey, message: 'New RSA key pair generated' });
});

module.exports = router;
