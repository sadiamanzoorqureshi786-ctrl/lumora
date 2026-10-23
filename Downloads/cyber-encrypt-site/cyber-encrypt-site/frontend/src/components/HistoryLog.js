import React, { useState, useEffect } from 'react';
import axios from 'axios';
import MatrixRain from './MatrixRain';

function HistoryLog({ token }) {
  const [logs, setLogs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('all');

  useEffect(() => {
    fetchLogs();
  }, []);

  const fetchLogs = async () => {
    try {
      const response = await axios.get('/api/history', {
        headers: { Authorization: `Bearer ${token}` }
      });
      setLogs(response.data);
    } catch (error) {
      console.error('Error:', error);
    } finally {
      setLoading(false);
    }
  };

  const clearHistory = async () => {
    if (!window.confirm('⚠️ Clear all history? This cannot be undone.')) return;

    try {
      await axios.delete('/api/history', {
        headers: { Authorization: `Bearer ${token}` }
      });
      setLogs([]);
      alert('✓ History cleared');
    } catch (error) {
      alert('Error clearing history');
    }
  };

  const filteredLogs = logs.filter(log => {
    if (filter === 'all') return true;
    return log.action === filter;
  });

  if (loading) {
    return (
      <div style={{ position: 'relative', minHeight: '100vh', background: '#000' }}>
      <div style={{ position: 'fixed', top: 0, left: 0, width: '100%', height: '100%', zIndex: 1 }}>
        <MatrixRain />
      </div>
      <div className="content-area" style={{ position: 'relative', zIndex: 10 }}>
          <div className="card">
            <div style={{ textAlign: 'center', padding: '60px', color: '#0F0', fontFamily: 'monospace' }}>
              <div style={{ fontSize: '48px', marginBottom: '16px' }}>⏳</div>
              <p>{'>'} LOADING HISTORY_</p>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div style={{ position: 'relative', minHeight: '100vh' }}>
      <MatrixRain />
      
      <div className="content-area" style={{ position: 'relative', zIndex: 10 }}>
        <div className="card">
          <div style={{ marginBottom: '32px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '24px' }}>
              <div>
                <h2 className="card-title" style={{ marginBottom: '4px', fontFamily: 'monospace' }}>📜 ENCRYPTION HISTORY</h2>
                <p style={{ fontSize: '14px', color: '#0F0', margin: 0, fontFamily: 'monospace' }}>
                  {'>'} View and manage your encryption activity_
                </p>
              </div>
              {logs.length > 0 && (
                <button
                  onClick={clearHistory}
                  className="btn btn-secondary"
                  style={{ color: '#F00', borderColor: '#F00', fontFamily: 'monospace' }}
                >
                  🗑️ CLEAR ALL
                </button>
              )}
            </div>

            {logs.length > 0 && (
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '16px', marginBottom: '24px' }}>
                <div style={{ background: 'rgba(0, 255, 0, 0.1)', border: '2px solid #0F0', borderRadius: '12px', padding: '20px', textAlign: 'center' }}>
                  <div style={{ fontSize: '32px', fontWeight: '700', color: '#0F0', marginBottom: '8px', fontFamily: 'monospace' }}>{logs.length}</div>
                  <div style={{ fontSize: '14px', color: '#0F0', fontFamily: 'monospace' }}>TOTAL OPS</div>
                </div>
                <div style={{ background: 'rgba(0, 255, 0, 0.1)', border: '2px solid #0F0', borderRadius: '12px', padding: '20px', textAlign: 'center' }}>
                  <div style={{ fontSize: '32px', fontWeight: '700', color: '#0F0', marginBottom: '8px', fontFamily: 'monospace' }}>{logs.filter(l => l.action === 'encrypt').length}</div>
                  <div style={{ fontSize: '14px', color: '#0F0', fontFamily: 'monospace' }}>ENCRYPTIONS</div>
                </div>
                <div style={{ background: 'rgba(0, 255, 0, 0.1)', border: '2px solid #0F0', borderRadius: '12px', padding: '20px', textAlign: 'center' }}>
                  <div style={{ fontSize: '32px', fontWeight: '700', color: '#0F0', marginBottom: '8px', fontFamily: 'monospace' }}>{logs.filter(l => l.action === 'decrypt').length}</div>
                  <div style={{ fontSize: '14px', color: '#0F0', fontFamily: 'monospace' }}>DECRYPTIONS</div>
                </div>
              </div>
            )}
          </div>

          {logs.length > 0 && (
            <div style={{ display: 'inline-flex', gap: '8px', padding: '6px', background: 'rgba(0, 255, 0, 0.1)', border: '2px solid #0F0', borderRadius: '8px', marginBottom: '24px' }}>
              <button onClick={() => setFilter('all')} className={filter === 'all' ? 'btn btn-primary' : 'btn btn-secondary'} style={{ padding: '8px 16px', fontSize: '13px', fontFamily: 'monospace' }}>
                ALL ({logs.length})
              </button>
              <button onClick={() => setFilter('encrypt')} className={filter === 'encrypt' ? 'btn btn-primary' : 'btn btn-secondary'} style={{ padding: '8px 16px', fontSize: '13px', fontFamily: 'monospace' }}>
                🔐 ENCRYPT ({logs.filter(l => l.action === 'encrypt').length})
              </button>
              <button onClick={() => setFilter('decrypt')} className={filter === 'decrypt' ? 'btn btn-primary' : 'btn btn-secondary'} style={{ padding: '8px 16px', fontSize: '13px', fontFamily: 'monospace' }}>
                🔓 DECRYPT ({logs.filter(l => l.action === 'decrypt').length})
              </button>
            </div>
          )}

          {logs.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '60px 20px', color: '#0F0', fontFamily: 'monospace' }}>
              <div style={{ fontSize: '64px', marginBottom: '16px' }}>📜</div>
              <p style={{ fontSize: '18px', marginBottom: '8px' }}>NO HISTORY YET</p>
              <p style={{ fontSize: '14px' }}>{'>'} Start encrypting or decrypting text_</p>
            </div>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              {filteredLogs.map((log) => (
                <div
                  key={log._id}
                  style={{
                    padding: '16px',
                    background: 'rgba(0, 0, 0, 0.8)',
                    border: '2px solid #0F0',
                    borderRadius: '8px',
                    borderLeft: `4px solid ${log.action === 'encrypt' ? '#0F0' : 'rgba(0, 255, 0, 0.5)'}`
                  }}
                >
                  <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '12px', fontFamily: 'monospace' }}>
                    <div style={{ display: 'flex', gap: '8px' }}>
                      <span style={{ padding: '6px 12px', fontSize: '12px', background: log.action === 'encrypt' ? 'rgba(0, 255, 0, 0.2)' : 'rgba(0, 255, 0, 0.1)', border: '1px solid #0F0', color: '#0F0', fontWeight: '600', borderRadius: '4px' }}>
                        {log.action === 'encrypt' ? '🔐 ENCRYPT' : '🔓 DECRYPT'}
                      </span>
                      <span style={{ padding: '6px 12px', fontSize: '12px', background: 'rgba(0, 0, 0, 0.8)', borderRadius: '4px', color: '#0F0', fontWeight: '500' }}>
                        {log.algorithm?.toUpperCase()}
                      </span>
                    </div>
                    <span style={{ fontSize: '12px', color: 'rgba(0, 255, 0, 0.7)' }}>
                      {new Date(log.timestamp).toLocaleString()}
                    </span>
                  </div>

                  <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: '16px' }}>
                    <div>
                      <div style={{ fontSize: '11px', color: 'rgba(0, 255, 0, 0.7)', marginBottom: '8px', fontWeight: '600', fontFamily: 'monospace' }}>
                        INPUT
                      </div>
                      <div className="output-box" style={{ minHeight: '80px', fontSize: '12px', maxHeight: '120px', overflowY: 'auto', fontFamily: 'monospace' }}>
                        {log.inputText || 'N/A'}
                      </div>
                    </div>
                    <div>
                      <div style={{ fontSize: '11px', color: 'rgba(0, 255, 0, 0.7)', marginBottom: '8px', fontWeight: '600', fontFamily: 'monospace' }}>
                        OUTPUT
                      </div>
                      <div className="output-box" style={{ minHeight: '80px', fontSize: '12px', maxHeight: '120px', overflowY: 'auto', fontFamily: 'monospace' }}>
                        {log.outputText || 'N/A'}
                      </div>
                    </div>
                  </div>

                  {log.key && (
                    <div style={{ marginTop: '12px', padding: '8px 12px', background: 'rgba(0, 0, 0, 0.8)', borderRadius: '6px', fontSize: '12px', color: '#0F0', fontFamily: 'monospace' }}>
                      {'>'} KEY: <span style={{ fontWeight: '600' }}>{log.key}</span>
                    </div>
                  )}
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default HistoryLog;