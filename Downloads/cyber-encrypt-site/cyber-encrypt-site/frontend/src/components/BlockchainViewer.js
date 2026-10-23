import React, { useState, useEffect } from 'react';
import axios from 'axios';

function BlockchainViewer({ token }) {
  const [blockchain, setBlockchain] = useState(null);
  const [loading, setLoading] = useState(true);
  const [selectedBlock, setSelectedBlock] = useState(null);

  useEffect(() => {
    fetchBlockchain();
  }, []);

  const fetchBlockchain = async () => {
    try {
      const response = await axios.get('/api/blockchain/chain', {
        headers: { Authorization: `Bearer ${token}` }
      });
      setBlockchain(response.data);
    } catch (error) {
      console.error('Error fetching blockchain:', error);
    } finally {
      setLoading(false);
    }
  };

  const verifyBlockchain = async () => {
    try {
      const response = await axios.get('/api/blockchain/verify', {
        headers: { Authorization: `Bearer ${token}` }
      });
      alert(response.data.message);
    } catch (error) {
      alert('Error verifying blockchain');
    }
  };

  if (loading) {
    return (
      <div style={{ textAlign: 'center', padding: '60px', color: '#0F0', fontFamily: 'monospace' }}>
        <div style={{ fontSize: '48px', marginBottom: '16px' }}>⏳</div>
        <p>LOADING BLOCKCHAIN...</p>
      </div>
    );
  }

  return (
    <div style={{ maxWidth: '1200px', margin: '0 auto' }}>
      <div className="card">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
          <div>
            <h2 className="card-title" style={{ marginBottom: '4px', fontFamily: 'monospace' }}>
              ⛓️ BLOCKCHAIN LEDGER
            </h2>
            <p style={{ fontSize: '14px', color: 'rgba(0, 255, 0, 0.7)', margin: 0, fontFamily: 'monospace' }}>
              {'>'} Immutable record of all encrypted messages_
            </p>
          </div>
          <button
            onClick={verifyBlockchain}
            className="btn btn-primary"
            style={{ fontFamily: 'monospace', fontWeight: '900' }}
          >
            🔍 VERIFY INTEGRITY
          </button>
        </div>

        {/* Stats */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '16px', marginBottom: '24px' }}>
          <div style={{ background: 'rgba(0, 255, 0, 0.1)', border: '2px solid #0F0', borderRadius: '12px', padding: '20px', textAlign: 'center' }}>
            <div style={{ fontSize: '32px', fontWeight: '700', color: '#0F0', marginBottom: '8px', fontFamily: 'monospace' }}>
              {blockchain?.length || 0}
            </div>
            <div style={{ fontSize: '14px', color: '#0F0', fontFamily: 'monospace' }}>TOTAL BLOCKS</div>
          </div>
          
          <div style={{ background: 'rgba(0, 255, 0, 0.1)', border: '2px solid #0F0', borderRadius: '12px', padding: '20px', textAlign: 'center' }}>
            <div style={{ fontSize: '32px', fontWeight: '700', color: '#0F0', marginBottom: '8px', fontFamily: 'monospace' }}>
              {blockchain?.isValid ? '✓' : '✗'}
            </div>
            <div style={{ fontSize: '14px', color: '#0F0', fontFamily: 'monospace' }}>
              {blockchain?.isValid ? 'VALID' : 'INVALID'}
            </div>
          </div>
          
          <div style={{ background: 'rgba(0, 255, 0, 0.1)', border: '2px solid #0F0', borderRadius: '12px', padding: '20px', textAlign: 'center' }}>
            <div style={{ fontSize: '32px', fontWeight: '700', color: '#0F0', marginBottom: '8px', fontFamily: 'monospace' }}>
              SHA-256
            </div>
            <div style={{ fontSize: '14px', color: '#0F0', fontFamily: 'monospace' }}>HASH ALGORITHM</div>
          </div>
        </div>

        {/* Blockchain Visualization */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
          {blockchain?.chain.map((block, index) => (
            <div
              key={index}
              onClick={() => setSelectedBlock(selectedBlock === index ? null : index)}
              style={{
                background: 'rgba(0, 0, 0, 0.8)',
                border: '2px solid #0F0',
                borderRadius: '12px',
                padding: '20px',
                cursor: 'pointer',
                transition: 'all 0.3s ease',
                borderLeft: `6px solid ${index === 0 ? '#FFD700' : '#0F0'}`
              }}
              onMouseEnter={(e) => {
                e.currentTarget.style.boxShadow = '0 0 20px rgba(0, 255, 0, 0.4)';
              }}
              onMouseLeave={(e) => {
                e.currentTarget.style.boxShadow = 'none';
              }}
            >
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '12px' }}>
                <div style={{ display: 'flex', gap: '12px', alignItems: 'center' }}>
                  <span style={{ 
                    fontSize: '24px', 
                    padding: '8px 16px', 
                    background: 'rgba(0, 255, 0, 0.2)', 
                    border: '2px solid #0F0', 
                    borderRadius: '8px',
                    fontFamily: 'monospace',
                    fontWeight: '900',
                    color: '#0F0'
                  }}>
                    #{block.index}
                  </span>
                  {index === 0 && (
                    <span style={{ 
                      padding: '4px 12px', 
                      background: 'rgba(255, 215, 0, 0.2)', 
                      border: '1px solid #FFD700', 
                      borderRadius: '6px',
                      fontSize: '12px',
                      color: '#FFD700',
                      fontFamily: 'monospace',
                      fontWeight: '700'
                    }}>
                      GENESIS BLOCK
                    </span>
                  )}
                </div>
                <span style={{ fontSize: '12px', color: 'rgba(0, 255, 0, 0.7)', fontFamily: 'monospace' }}>
                  {new Date(block.timestamp).toLocaleString()}
                </span>
              </div>

              <div style={{ marginBottom: '12px' }}>
                <div style={{ fontSize: '11px', color: 'rgba(0, 255, 0, 0.7)', marginBottom: '4px', fontFamily: 'monospace' }}>
                  HASH:
                </div>
                <div style={{ 
                  fontSize: '13px', 
                  color: '#0F0', 
                  fontFamily: 'monospace', 
                  wordBreak: 'break-all',
                  background: 'rgba(0, 0, 0, 0.5)',
                  padding: '8px',
                  borderRadius: '6px',
                  border: '1px solid rgba(0, 255, 0, 0.3)'
                }}>
                  {block.hash}
                </div>
              </div>

              {selectedBlock === index && (
                <>
                  <div style={{ marginBottom: '12px' }}>
                    <div style={{ fontSize: '11px', color: 'rgba(0, 255, 0, 0.7)', marginBottom: '4px', fontFamily: 'monospace' }}>
                      PREVIOUS HASH:
                    </div>
                    <div style={{ 
                      fontSize: '13px', 
                      color: '#0F0', 
                      fontFamily: 'monospace', 
                      wordBreak: 'break-all',
                      background: 'rgba(0, 0, 0, 0.5)',
                      padding: '8px',
                      borderRadius: '6px',
                      border: '1px solid rgba(0, 255, 0, 0.3)'
                    }}>
                      {block.previousHash}
                    </div>
                  </div>

                  <div style={{ marginBottom: '12px' }}>
                    <div style={{ fontSize: '11px', color: 'rgba(0, 255, 0, 0.7)', marginBottom: '4px', fontFamily: 'monospace' }}>
                      DATA:
                    </div>
                    <div style={{ 
                      fontSize: '13px', 
                      color: '#0F0', 
                      fontFamily: 'monospace',
                      background: 'rgba(0, 0, 0, 0.5)',
                      padding: '12px',
                      borderRadius: '6px',
                      border: '1px solid rgba(0, 255, 0, 0.3)'
                    }}>
                      <pre style={{ margin: 0, whiteSpace: 'pre-wrap', wordBreak: 'break-all' }}>
                        {JSON.stringify(block.data, null, 2)}
                      </pre>
                    </div>
                  </div>

                  <div style={{ display: 'flex', gap: '12px' }}>
                    <div style={{ flex: 1, padding: '8px', background: 'rgba(0, 255, 0, 0.05)', border: '1px solid #0F0', borderRadius: '6px' }}>
                      <div style={{ fontSize: '11px', color: 'rgba(0, 255, 0, 0.7)', fontFamily: 'monospace' }}>NONCE:</div>
                      <div style={{ fontSize: '14px', fontWeight: '700', color: '#0F0', fontFamily: 'monospace' }}>{block.nonce}</div>
                    </div>
                    <div style={{ flex: 1, padding: '8px', background: 'rgba(0, 255, 0, 0.05)', border: '1px solid #0F0', borderRadius: '6px' }}>
                      <div style={{ fontSize: '11px', color: 'rgba(0, 255, 0, 0.7)', fontFamily: 'monospace' }}>TIMESTAMP:</div>
                      <div style={{ fontSize: '14px', fontWeight: '700', color: '#0F0', fontFamily: 'monospace' }}>{block.timestamp}</div>
                    </div>
                  </div>
                </>
              )}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

export default BlockchainViewer;