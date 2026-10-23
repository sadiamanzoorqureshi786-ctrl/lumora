import React, { useState } from 'react';
import axios from 'axios';
import MatrixRain from './MatrixRain';

function AuthForm({ onLogin }) {
  const [isLogin, setIsLogin] = useState(true);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [username, setUsername] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      // ✅ CORRECT
const endpoint = isLogin 
? 'http://localhost:5001/api/auth/signin' 
: 'http://localhost:5001/api/auth/signup';
          const payload = isLogin 
        ? { email, password }
        : { username, email, password };

      const response = await axios.post(endpoint, payload);
      
      if (response.data.token) {
        onLogin(response.data.token, response.data.user);
      }
    } 
    catch (err) {
      setError(err.response?.data?.error || 'Authentication failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ 
      position: 'relative', 
      minHeight: '100vh', 
      background: '#000',
      overflow: 'hidden'
    }}>
      {/* Matrix Rain Background - z-index: 0 */}
      <div style={{ 
        position: 'fixed', 
        top: 0, 
        left: 0, 
        width: '100%', 
        height: '100%', 
        zIndex: 0,
        pointerEvents: 'none'
      }}>
        <MatrixRain />
      </div>

      {/* Content - z-index: 1 */}
      <div style={{ 
        position: 'relative', 
        zIndex: 1,
        minHeight: '100vh',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '20px'
      }}>
        {/* Header Section with 3 Boxes */}
        <div style={{ 
          textAlign: 'center', 
          marginBottom: '48px',
          width: '100%',
          maxWidth: '1200px'
        }}>
          <h1 style={{
            fontSize: '64px',
            fontWeight: '900',
            color: '#0F0',
            fontFamily: 'monospace',
            textShadow: '0 0 20px rgba(0, 255, 0, 0.8)',
            marginBottom: '16px',
            letterSpacing: '4px'
          }}>
            CYBERENCRYPT
          </h1>
          <p style={{
            fontSize: '18px',
            color: 'rgba(0, 255, 0, 0.8)',
            fontFamily: 'monospace',
            marginBottom: '48px'
          }}>
            {'>'} Secure messaging with military-grade encryption_
          </p>

          {/* 3 Feature Boxes */}
          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))',
            gap: '24px',
            marginBottom: '48px'
          }}>
            {/* Box 1: 256-BIT */}
            <div style={{
              background: 'rgba(0, 0, 0, 0.8)',
              border: '2px solid #0F0',
              borderRadius: '16px',
              padding: '32px',
              textAlign: 'center',
              transition: 'all 0.3s ease',
              cursor: 'default'
            }}
            onMouseEnter={(e) => {
              e.currentTarget.style.transform = 'translateY(-8px)';
              e.currentTarget.style.boxShadow = '0 8px 32px rgba(0, 255, 0, 0.4)';
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.transform = 'translateY(0)';
              e.currentTarget.style.boxShadow = 'none';
            }}>
              <div style={{ fontSize: '48px', marginBottom: '16px' }}>🔒</div>
              <h3 style={{
                fontSize: '28px',
                fontWeight: '900',
                color: '#0F0',
                fontFamily: 'monospace',
                marginBottom: '8px'
              }}>
                256-BIT
              </h3>
              <p style={{
                fontSize: '14px',
                color: 'rgba(0, 255, 0, 0.7)',
                fontFamily: 'monospace'
              }}>
                ENCRYPTION
              </p>
            </div>

            {/* Box 2: INSTANT */}
            <div style={{
              background: 'rgba(0, 0, 0, 0.8)',
              border: '2px solid #0F0',
              borderRadius: '16px',
              padding: '32px',
              textAlign: 'center',
              transition: 'all 0.3s ease',
              cursor: 'default'
            }}
            onMouseEnter={(e) => {
              e.currentTarget.style.transform = 'translateY(-8px)';
              e.currentTarget.style.boxShadow = '0 8px 32px rgba(0, 255, 0, 0.4)';
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.transform = 'translateY(0)';
              e.currentTarget.style.boxShadow = 'none';
            }}>
              <div style={{ fontSize: '48px', marginBottom: '16px' }}>⚡</div>
              <h3 style={{
                fontSize: '28px',
                fontWeight: '900',
                color: '#0F0',
                fontFamily: 'monospace',
                marginBottom: '8px'
              }}>
                INSTANT
              </h3>
              <p style={{
                fontSize: '14px',
                color: 'rgba(0, 255, 0, 0.7)',
                fontFamily: 'monospace'
              }}>
                PROCESSING
              </p>
            </div>

            {/* Box 3: 100% SECURE */}
            <div style={{
              background: 'rgba(0, 0, 0, 0.8)',
              border: '2px solid #0F0',
              borderRadius: '16px',
              padding: '32px',
              textAlign: 'center',
              transition: 'all 0.3s ease',
              cursor: 'default'
            }}
            onMouseEnter={(e) => {
              e.currentTarget.style.transform = 'translateY(-8px)';
              e.currentTarget.style.boxShadow = '0 8px 32px rgba(0, 255, 0, 0.4)';
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.transform = 'translateY(0)';
              e.currentTarget.style.boxShadow = 'none';
            }}>
              <div style={{ fontSize: '48px', marginBottom: '16px' }}>🛡️</div>
              <h3 style={{
                fontSize: '28px',
                fontWeight: '900',
                color: '#0F0',
                fontFamily: 'monospace',
                marginBottom: '8px'
              }}>
                100%
              </h3>
              <p style={{
                fontSize: '14px',
                color: 'rgba(0, 255, 0, 0.7)',
                fontFamily: 'monospace'
              }}>
                SECURE
              </p>
            </div>
          </div>
        </div>

        {/* Login/Signup Form */}
        <div style={{
          background: 'rgba(0, 0, 0, 0.85)',
          border: '2px solid #0F0',
          borderRadius: '16px',
          padding: '40px',
          width: '100%',
          maxWidth: '480px',
          boxShadow: '0 8px 32px rgba(0, 255, 0, 0.3)'
        }}>
          <div style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            marginBottom: '32px'
          }}>
            <div style={{ fontSize: '64px', marginRight: '16px' }}>🔐</div>
            <div>
              <h2 style={{
                fontSize: '24px',
                fontWeight: '900',
                color: '#0F0',
                fontFamily: 'monospace',
                marginBottom: '4px'
              }}>
                CYBERENCRYPT
              </h2>
              <p style={{
                fontSize: '12px',
                color: 'rgba(0, 255, 0, 0.7)',
                fontFamily: 'monospace',
                margin: 0
              }}>
                {'>'} Secure messaging with military-grade encryption_
              </p>
            </div>
          </div>

          {/* Toggle Buttons */}
          <div style={{
            display: 'flex',
            gap: '12px',
            marginBottom: '32px'
          }}>
            <button
              onClick={() => setIsLogin(true)}
              style={{
                flex: 1,
                padding: '14px',
                background: isLogin ? '#0F0' : 'transparent',
                color: isLogin ? '#000' : '#0F0',
                border: '2px solid #0F0',
                borderRadius: '8px',
                fontFamily: 'monospace',
                fontWeight: '900',
                fontSize: '14px',
                cursor: 'pointer',
                transition: 'all 0.3s ease'
              }}
            >
              🔓 SIGN IN
            </button>
            <button
              onClick={() => setIsLogin(false)}
              style={{
                flex: 1,
                padding: '14px',
                background: !isLogin ? '#0F0' : 'transparent',
                color: !isLogin ? '#000' : '#0F0',
                border: '2px solid #0F0',
                borderRadius: '8px',
                fontFamily: 'monospace',
                fontWeight: '900',
                fontSize: '14px',
                cursor: 'pointer',
                transition: 'all 0.3s ease'
              }}
            >
              📝 SIGN UP
            </button>
          </div>

          {/* Form */}
          <form onSubmit={handleSubmit}>
            {!isLogin && (
              <div style={{ marginBottom: '20px' }}>
                <label style={{
                  display: 'block',
                  color: '#0F0',
                  fontFamily: 'monospace',
                  fontSize: '13px',
                  fontWeight: '700',
                  marginBottom: '8px'
                }}>
                  USERNAME
                </label>
                <input
                  type="text"
                  value={username}
                  onChange={(e) => setUsername(e.target.value)}
                  placeholder="your@email.com"
                  required={!isLogin}
                  style={{
                    width: '100%',
                    padding: '14px',
                    background: 'rgba(0, 0, 0, 0.8)',
                    border: '2px solid #0F0',
                    borderRadius: '8px',
                    color: '#0F0',
                    fontFamily: 'monospace',
                    fontSize: '14px'
                  }}
                />
              </div>
            )}

            <div style={{ marginBottom: '20px' }}>
              <label style={{
                display: 'block',
                color: '#0F0',
                fontFamily: 'monospace',
                fontSize: '13px',
                fontWeight: '700',
                marginBottom: '8px'
              }}>
                EMAIL
              </label>
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="your@email.com"
                required
                style={{
                  width: '100%',
                  padding: '14px',
                  background: 'rgba(0, 0, 0, 0.8)',
                  border: '2px solid #0F0',
                  borderRadius: '8px',
                  color: '#0F0',
                  fontFamily: 'monospace',
                  fontSize: '14px'
                }}
              />
            </div>

            <div style={{ marginBottom: '24px' }}>
              <label style={{
                display: 'block',
                color: '#0F0',
                fontFamily: 'monospace',
                fontSize: '13px',
                fontWeight: '700',
                marginBottom: '8px'
              }}>
                PASSWORD
              </label>
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••"
                required
                style={{
                  width: '100%',
                  padding: '14px',
                  background: 'rgba(0, 0, 0, 0.8)',
                  border: '2px solid #0F0',
                  borderRadius: '8px',
                  color: '#0F0',
                  fontFamily: 'monospace',
                  fontSize: '14px'
                }}
              />
            </div>

            {isLogin && (
              <div style={{
                textAlign: 'right',
                marginBottom: '24px'
              }}>
                <a href="#" style={{
                  color: '#0F0',
                  fontFamily: 'monospace',
                  fontSize: '12px',
                  textDecoration: 'none'
                }}>
                  Forgot Password?
                </a>
              </div>
            )}

            {error && (
              <div style={{
                padding: '12px',
                background: 'rgba(255, 0, 0, 0.2)',
                border: '2px solid #F00',
                borderRadius: '8px',
                color: '#F00',
                fontFamily: 'monospace',
                fontSize: '13px',
                marginBottom: '20px'
              }}>
                ⚠️ {error}
              </div>
            )}

            <button
              type="submit"
              disabled={loading}
              style={{
                width: '100%',
                padding: '16px',
                background: '#0F0',
                color: '#000',
                border: 'none',
                borderRadius: '8px',
                fontFamily: 'monospace',
                fontWeight: '900',
                fontSize: '16px',
                cursor: loading ? 'not-allowed' : 'pointer',
                opacity: loading ? 0.7 : 1,
                transition: 'all 0.3s ease'
              }}
            >
              {loading ? '⏳ PROCESSING...' : (isLogin ? '🔓 SIGN IN' : '📝 SIGN UP')}
            </button>

            <div style={{
              marginTop: '24px',
              textAlign: 'center',
              color: 'rgba(0, 255, 0, 0.7)',
              fontFamily: 'monospace',
              fontSize: '12px'
            }}>
              OR
            </div>
            <button
  type="button"
  onClick={() => {
    window.location.href = 'http://localhost:5001/api/auth/google';
  }}
  style={{
    width: '100%',
    padding: '16px',
    background: 'transparent',
    color: '#0F0',
    border: '2px solid #0F0',
    borderRadius: '8px',
    fontFamily: 'monospace',
    fontWeight: '900',
    fontSize: '14px',
    cursor: 'pointer',
    marginTop: '12px',
    transition: 'all 0.3s ease'
  }}
>
  🔐 CONTINUE WITH GOOGLE
</button>
          </form>
        </div>
      </div>
    </div>
  );
}

export default AuthForm;