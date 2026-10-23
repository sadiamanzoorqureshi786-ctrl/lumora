const fetch = global.fetch || require('node-fetch');

const BASE = 'http://localhost:5001';

async function post(path, body) {
  const res = await fetch(BASE + path, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  const json = await res.json();
  return { status: res.status, body: json };
}

(async () => {
  try {
    console.log('Checking /api/health...');
    const h = await fetch(BASE + '/api/health');
    console.log('health status:', h.status);

    // AES test
    const aesKey = '12345678901234567890123456789012';
    const plainAes = 'hello world';
    console.log('\nTesting AES-256 encrypt...');
    const encRes = await post('/api/encrypt', { text: plainAes, algorithm: 'AES-256', key: aesKey });
    console.log('encrypt response:', encRes.status, encRes.body);
    if (!encRes.body.success) throw new Error('AES encrypt failed');

    console.log('Testing AES-256 decrypt...');
    const decRes = await post('/api/decrypt', { encrypted: encRes.body.encrypted, algorithm: 'AES-256', key: aesKey, iv: encRes.body.iv });
    console.log('decrypt response:', decRes.status, decRes.body);
    if (!decRes.body.success) throw new Error('AES decrypt failed');
    if (decRes.body.decrypted !== plainAes) throw new Error('AES decrypted text mismatch');

    // RSA test
    const plainRsa = 'secret message for rsa';
    console.log('\nTesting RSA encrypt...');
    const encRsa = await post('/api/encrypt', { text: plainRsa, algorithm: 'RSA' });
    console.log('rsa encrypt response:', encRsa.status, encRsa.body);
    if (!encRsa.body.success) throw new Error('RSA encrypt failed');

    console.log('Testing RSA decrypt...');
    const decRsa = await post('/api/decrypt', { encrypted: encRsa.body.encrypted, algorithm: 'RSA' });
    console.log('rsa decrypt response:', decRsa.status, decRsa.body);
    if (!decRsa.body.success) throw new Error('RSA decrypt failed');
    if (decRsa.body.decrypted !== plainRsa) throw new Error('RSA decrypted text mismatch');

    console.log('\nAll encryption smoke tests passed ✅');
    process.exit(0);
  } catch (err) {
    console.error('\nSmoke test failed:', err);
    process.exit(1);
  }
})();
