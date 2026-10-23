import React, { useState, useEffect } from 'react';
import axios from 'axios';
import MatrixRain from './MatrixRain';

function EncryptionTool({ token }) {
  const [inputText, setInputText] = useState('');
  const [algorithm, setAlgorithm] = useState('caesar');
  const [key, setKey] = useState('');
  const [output, setOutput] = useState('');
  const [error, setError] = useState('');
  const [mode, setMode] = useState('encrypt');
  const [iv, setIv] = useState('');
  const [loading, setLoading] = useState(false);

  const caesarCipher = (text, shift, decrypt = false) => {
    const s = decrypt ? (26 - shift) : shift;
    return text.split('').map(char => {
      if (/[a-z]/i.test(char)) {
        const code = char.charCodeAt(0);
        const isUpper = code >= 65 && code <= 90;
        const base = isUpper ? 65 : 97;
        return String.fromCharCode(((code - base + s) % 26) + base);
      }
      return char;
    }).join('');
  };

  const transpositionCipher = (text, keyNum, decrypt = false) => {
    const k = parseInt(keyNum) || 3;
    if (decrypt) {
      const cols = Math.ceil(text.length / k);
      let result = '';
      for (let row = 0; row < cols; row++) {
        for (let col = 0; col < k; col++) {
          const idx = col * cols + row;
          if (idx < text.length) result += text[idx];
        }
      }
      return result;
    } else {
      const rows = Math.ceil(text.length / k);
      let result = '';
      for (let col = 0; col < k; col++) {
        for (let row = 0; row < rows; row++) {
          const idx = row * k + col;
          if (idx < text.length) result += text[idx];
        }
      }
      return result;
    }
  };

  const substitutionCipher = (text, keyStr, decrypt = false) => {
    const alphabet = 'abcdefghijklmnopqrstuvwxyz';
    const keyLower = (keyStr || '').toLowerCase();
    const keyAlphabet = (keyLower + alphabet.split('').filter(c => !keyLower.includes(c)).join(''));

    return text.split('').map(char => {
      const isUpper = char === char.toUpperCase();
      const lowerChar = char.toLowerCase();

      if (alphabet.includes(lowerChar)) {
        const index = decrypt ? keyAlphabet.indexOf(lowerChar) : alphabet.indexOf(lowerChar);
        const newChar = decrypt ? alphabet[index] : keyAlphabet[index];
        return isUpper ? newChar.toUpperCase() : newChar;
      }
      return char;
    }).join('');
  };

  const saveToHistory = async (action, algorithm, inputText, outputText, key) => {
    try {
      await axios.post(
        'http://localhost:5001/api/history/add',
        {
          action,
          algorithm: algorithm.toLowerCase(),
          inputText,
          outputText,
          key: key.toString()
        },
        { headers: { Authorization: `Bearer ${token}` } }
      );
    } catch (error) {
      console.error('Failed to save history:', error);
    }
  };

  const handleProcess = async () => {
    setError('');
    setOutput('');

    if (!inputText.trim()) {
      setError('Please enter text');
      return;
    }

    setLoading(true);

    try {
      let result = '';

      if (algorithm === 'caesar') {
        const shift = parseInt(key) || 3;
        result = caesarCipher(inputText, shift, mode === 'decrypt');
        setOutput(result);
        await saveToHistory(mode, algorithm, inputText, result, key);
      }
      else if (algorithm === 'transposition') {
        result = transpositionCipher(inputText, key, mode === 'decrypt');
        setOutput(result);
        await saveToHistory(mode, algorithm, inputText, result, key);
      }
      else if (algorithm === 'substitution') {
        result = substitutionCipher(inputText, key, mode === 'decrypt');
        setOutput(result);
        await saveToHistory(mode, algorithm, inputText, result, key);
      }
      else if (algorithm === 'AES-256' || algorithm === 'RSA') {
        const endpoint = mode === 'encrypt' ? '/api/encrypt' : '/api/decrypt';
        const payload = mode === 'encrypt'
          ? { text: inputText, algorithm, key }
          : { encrypted: inputText, algorithm, key, iv };

        const response = await axios.post(`http://localhost:5001${endpoint}`, payload, {
          headers: { Authorization: `Bearer ${token}` }
        });

        if (response.data.success) {
          if (mode === 'encrypt') {
            result = response.data.encrypted;
            setOutput(result);
            if (response.data.iv) setIv(response.data.iv);
            await saveToHistory(mode, algorithm, inputText, result, key);
          } else {
            result = response.data.decrypted;
            setOutput(result);
            await saveToHistory(mode, algorithm, inputText, result, key);
          }
        }
      }
    } catch (err) {
      console.error('Error:', err);
      setError(err.response?.data?.error || 'Operation failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ position: 'relative', minHeight: '100vh', background: '#000' }}>
      <div style={{ position: 'fixed', top: 0, left: 0, width: '100%', height: '100%', zIndex: 1 }}>
        <MatrixRain />
      </div>

      <div className="content-area" style={{ position: 'relative', zIndex: 10 }}>
        <div className="card" style={{ background: 'rgba(0, 0, 0, 0.85)', border: '2px solid #0F0' }}>
          <h2 className="card-title" style={{ marginBottom: '24px', fontFamily: 'monospace', color: '#0F0' }}>
            🔐 ENCRYPTION TOOL
          </h2>

          <div style={{ display: 'flex', gap: '12px', marginBottom: '24px', justifyContent: 'center' }}>
            <button
              onClick={() => setMode('encrypt')}
              className={mode === 'encrypt' ? 'btn btn-primary' : 'btn btn-secondary'}
              style={{ fontFamily: 'monospace', fontWeight: '900' }}
            >
              🔒 ENCRYPT
            </button>
            <button
              onClick={() => setMode('decrypt')}
              className={mode === 'decrypt' ? 'btn btn-primary' : 'btn btn-secondary'}
              style={{ fontFamily: 'monospace', fontWeight: '900' }}
            >
              🔓 DECRYPT
            </button>
          </div>

          <div className="form-group">
            <label className="form-label" style={{ color: '#0F0', fontFamily: 'monospace' }}>ALGORITHM</label>
            <select
              value={algorithm}
              onChange={(e) => setAlgorithm(e.target.value)}
              className="form-select"
              style={{ fontFamily: 'monospace', background: 'rgba(0, 0, 0, 0.8)', border: '2px solid #0F0', color: '#0F0' }}
            >
              <option value="caesar">Caesar Cipher</option>
              <option value="transposition">Transposition</option>
              <option value="substitution">Substitution</option>
              <option value="AES-256">AES-256</option>
              <option value="RSA">RSA</option>
            </select>
          </div>

          {algorithm !== 'RSA' && (
            <div className="form-group">
              <label className="form-label" style={{ color: '#0F0', fontFamily: 'monospace' }}>
                {algorithm === 'caesar' ? 'SHIFT (1-25)' :
                  algorithm === 'AES-256' ? 'SECRET KEY (32 chars)' : 'KEY'}
              </label>
              <input
                type="text"
                value={key}
                onChange={(e) => setKey(e.target.value)}
                className="form-input"
                style={{ fontFamily: 'monospace', background: 'rgba(0, 0, 0, 0.8)', border: '2px solid #0F0', color: '#0F0' }}
                placeholder={algorithm === 'AES-256' ? '32-character key' : 'Enter key'}
              />
            </div>
          )}

          {algorithm === 'AES-256' && mode === 'decrypt' && (
            <div className="form-group">
              <label className="form-label" style={{ color: '#0F0', fontFamily: 'monospace' }}>IV (FROM ENCRYPTION)</label>
              <input
                type="text"
                value={iv}
                onChange={(e) => setIv(e.target.value)}
                className="form-input"
                style={{ fontFamily: 'monospace', background: 'rgba(0, 0, 0, 0.8)', border: '2px solid #0F0', color: '#0F0' }}
                placeholder="Paste IV here"
              />
            </div>
          )}

          <div className="form-group">
            <label className="form-label" style={{ color: '#0F0', fontFamily: 'monospace' }}>INPUT TEXT</label>
            <textarea
              value={inputText}
              onChange={(e) => setInputText(e.target.value)}
              className="form-textarea"
              style={{ fontFamily: 'monospace', background: 'rgba(0, 0, 0, 0.8)', border: '2px solid #0F0', color: '#0F0' }}
              placeholder={mode === 'encrypt' ? 'Enter text to encrypt' : 'Enter encrypted text'}
              rows="4"
            />
          </div>

          <button
            onClick={handleProcess}
            disabled={loading || !inputText.trim()}
            className="btn btn-primary btn-full"
            style={{ fontFamily: 'monospace', fontWeight: '900', background: '#0F0', color: '#000', border: 'none' }}
          >
            {loading ? '⏳ PROCESSING...' : mode === 'encrypt' ? '🔒 ENCRYPT' : '🔓 DECRYPT'}
          </button>

          {error && (
            <div style={{ marginTop: '16px', padding: '12px', background: 'rgba(255, 0, 0, 0.2)', border: '2px solid #F00', borderRadius: '8px', color: '#F00', fontFamily: 'monospace' }}>
              ⚠️ {error}
            </div>
          )}

          {output && (
            <div className="form-group" style={{ marginTop: '16px' }}>
              <label className="form-label" style={{ color: '#0F0', fontFamily: 'monospace' }}>OUTPUT</label>
              <textarea
                value={output}
                readOnly
                className="form-textarea output-box"
                style={{ fontFamily: 'monospace', background: 'rgba(0, 0, 0, 0.8)', border: '2px solid #0F0', color: '#0F0' }}
                rows="4"
              />
              {iv && mode === 'encrypt' && (
                <div style={{ marginTop: '12px', padding: '12px', background: 'rgba(255, 255, 0, 0.2)', border: '2px solid #FF0', borderRadius: '8px', color: '#FF0', fontFamily: 'monospace' }}>
                  <strong>⚠️ SAVE THIS IV:</strong> {iv}
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default EncryptionTool;