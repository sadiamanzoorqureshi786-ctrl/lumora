import React, { useState } from 'react';
import axios from 'axios';
import MatrixRain from './MatrixRain';

function Settings({ token, user }) {
  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState({ type: '', text: '' });

  const handlePasswordChange = async (e) => {
    e.preventDefault();
    
    if (newPassword !== confirmPassword) {
      setMessage({ type: 'error', text: 'Passwords do not match' });
      return;
    }

    if (newPassword.length < 6) {
      setMessage({ type: 'error', text: 'Password must be 6+ characters' });
      return;
    }

    setLoading(true);
    setMessage({ type: '', text: '' });

    try {
      await axios.put(
        '/api/settings/password',
        { currentPassword, newPassword },
        { headers: { Authorization: `Bearer ${token}` } }
      );
      
      setMessage({ type: 'success', text: '✓ Password updated successfully!' });
      setCurrentPassword('');
      setNewPassword('');
      setConfirmPassword('');
    } catch (error) {
      setMessage({ type: 'error', text: error.response?.data?.error || 'Failed' });
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
        <div className="card" style={{ marginBottom: '24px' }}>
          <h2 className="card-title" style={{ marginBottom: '24px', fontFamily: 'monospace' }}>👤 ACCOUNT INFORMATION</h2>
          
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '16px' }}>
            <div style={{ background: 'rgba(0, 255, 0, 0.1)', border: '2px solid #0F0', borderRadius: '12px', padding: '20px' }}>
              <div style={{ fontSize: '12px', color: 'rgba(0, 255, 0, 0.7)', marginBottom: '8px', fontWeight: '600', fontFamily: 'monospace' }}>
                USERNAME
              </div>
              <div style={{ fontSize: '18px', fontWeight: '700', color: '#0F0', fontFamily: 'monospace' }}>
                {user?.username || 'N/A'}
              </div>
            </div>

            <div style={{ background: 'rgba(0, 255, 0, 0.1)', border: '2px solid #0F0', borderRadius: '12px', padding: '20px' }}>
              <div style={{ fontSize: '12px', color: 'rgba(0, 255, 0, 0.7)', marginBottom: '8px', fontWeight: '600', fontFamily: 'monospace' }}>
                EMAIL
              </div>
              <div style={{ fontSize: '16px', fontWeight: '600', color: '#0F0', fontFamily: 'monospace', wordBreak: 'break-all' }}>
                {user?.email || 'N/A'}
              </div>
            </div>

            <div style={{ background: 'rgba(0, 255, 0, 0.1)', border: '2px solid #0F0', borderRadius: '12px', padding: '20px' }}>
              <div style={{ fontSize: '12px', color: 'rgba(0, 255, 0, 0.7)', marginBottom: '8px', fontWeight: '600', fontFamily: 'monospace' }}>
                STATUS
              </div>
              <div style={{ fontSize: '16px', fontWeight: '700', color: '#0F0', display: 'flex', alignItems: 'center', gap: '6px', fontFamily: 'monospace' }}>
                <span style={{ fontSize: '8px' }}>●</span> ACTIVE
              </div>
            </div>
          </div>

          <div style={{ marginTop: '20px', padding: '16px', background: 'rgba(0, 255, 0, 0.05)', border: '2px solid #0F0', borderRadius: '8px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
              <div style={{ fontSize: '32px' }}>👑</div>
              <div>
                <div style={{ fontSize: '14px', fontWeight: '600', color: '#0F0', fontFamily: 'monospace' }}>
                  PREMIUM ACCOUNT
                </div>
                <div style={{ fontSize: '12px', color: 'rgba(0, 255, 0, 0.7)', fontFamily: 'monospace' }}>
                  {'>'} Member since {user?.createdAt ? new Date(user.createdAt).toLocaleDateString() : 'N/A'}
                </div>
              </div>
            </div>
          </div>
        </div>

        <div className="card">
          <div style={{ marginBottom: '24px' }}>
            <h2 className="card-title" style={{ marginBottom: '4px', fontFamily: 'monospace' }}>🔐 SECURITY SETTINGS</h2>
            <p style={{ fontSize: '14px', color: '#0F0', margin: 0, fontFamily: 'monospace' }}>
              {'>'} Update your password to keep account secure_
            </p>
          </div>
          
          {message.text && (
            <div style={{
              padding: '12px 16px',
              background: message.type === 'success' ? 'rgba(0, 255, 0, 0.1)' : 'rgba(255, 0, 0, 0.1)',
              border: `1px solid ${message.type === 'success' ? '#0F0' : '#F00'}`,
              borderRadius: '6px',
              marginBottom: '20px',
              color: message.type === 'success' ? '#0F0' : '#F00',
              fontFamily: 'monospace'
            }}>
              {message.text}
            </div>
          )}

          <form onSubmit={handlePasswordChange}>
            <div className="form-group">
              <label className="form-label" style={{ color: '#0F0', fontFamily: 'monospace' }}>CURRENT PASSWORD</label>
              <input
                type="password"
                value={currentPassword}
                onChange={(e) => setCurrentPassword(e.target.value)}
                className="form-input"
                placeholder="Enter current password"
                style={{ fontFamily: 'monospace' }}
                required
              />
            </div>

            <div className="grid-2">
              <div className="form-group">
                <label className="form-label" style={{ color: '#0F0', fontFamily: 'monospace' }}>NEW PASSWORD</label>
                <input
                  type="password"
                  value={newPassword}
                  onChange={(e) => setNewPassword(e.target.value)}
                  className="form-input"
                  placeholder="Enter new password"
                  style={{ fontFamily: 'monospace' }}
                  required
                />
                <div style={{ fontSize: '11px', color: 'rgba(0, 255, 0, 0.7)', marginTop: '4px', fontFamily: 'monospace' }}>
                  {'>'} Minimum 6 characters
                </div>
              </div>

              <div className="form-group">
                <label className="form-label" style={{ color: '#0F0', fontFamily: 'monospace' }}>CONFIRM PASSWORD</label>
                <input
                  type="password"
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                  className="form-input"
                  placeholder="Confirm new password"
                  style={{ fontFamily: 'monospace' }}
                  required
                />
              </div>
            </div>

            <button 
              type="submit" 
              disabled={loading}
              className="btn btn-primary"
              style={{ fontSize: '15px', padding: '12px 32px', fontFamily: 'monospace', fontWeight: '900' }}
            >
              {loading ? '⏳ UPDATING...' : '💾 UPDATE PASSWORD'}
            </button>
          </form>

          <div style={{ marginTop: '24px', padding: '16px', background: 'rgba(0, 255, 0, 0.05)', border: '2px solid #0F0', borderRadius: '8px' }}>
            <div style={{ fontSize: '13px', fontWeight: '600', marginBottom: '12px', color: '#0F0', fontFamily: 'monospace' }}>
              {'>'} PASSWORD SECURITY TIPS_
            </div>
            <ul style={{ margin: 0, paddingLeft: '20px', fontSize: '12px', color: '#0F0', lineHeight: '1.8', fontFamily: 'monospace' }}>
              <li>Use a combination of uppercase, lowercase, numbers, and symbols</li>
              <li>Avoid common patterns like "123456" or "password"</li>
              <li>Change your password regularly</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
}

export default Settings;