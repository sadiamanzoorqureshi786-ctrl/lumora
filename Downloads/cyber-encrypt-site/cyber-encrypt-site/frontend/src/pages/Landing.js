import React, { useEffect, useRef } from 'react';
import AuthForm from '../components/AuthForm';

function Landing({ onLogin }) {
  const canvasRef = useRef(null);

  useEffect(() => {
    // Matrix rain effect
    const canvas = canvasRef.current;
    const ctx = canvas.getContext('2d');

    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;

    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%^&*()_+-=[]{}|;:,.<>?/~`';
    const fontSize = 14;
    const columns = canvas.width / fontSize;
    const drops = [];

    for (let i = 0; i < columns; i++) {
      drops[i] = Math.random() * -100;
    }

    function draw() {
      ctx.fillStyle = 'rgba(0, 0, 0, 0.05)';
      ctx.fillRect(0, 0, canvas.width, canvas.height);

      ctx.fillStyle = '#0F0';
      ctx.font = `${fontSize}px monospace`;

      for (let i = 0; i < drops.length; i++) {
        const text = letters[Math.floor(Math.random() * letters.length)];
        ctx.fillText(text, i * fontSize, drops[i] * fontSize);

        if (drops[i] * fontSize > canvas.height && Math.random() > 0.95) {
          drops[i] = 0;
        }
        drops[i]++;
      }
    }

    const interval = setInterval(draw, 33);

    return () => clearInterval(interval);
  }, []);

  return (
    <div style={{ position: 'relative', minHeight: '100vh', background: '#000', overflow: 'hidden' }}>
      {/* Matrix Rain Background */}
      <canvas
        ref={canvasRef}
        style={{
          position: 'fixed',
          top: 0,
          left: 0,
          width: '100%',
          height: '100%',
          zIndex: 0
        }}
      />

      {/* Content */}
      <div style={{
        position: 'relative',
        zIndex: 1,
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '20px'
      }}>
        <div style={{ width: '100%', maxWidth: '1100px' }}>
          {/* Hero */}
          <div style={{ textAlign: 'center', marginBottom: '48px' }}>
            <h1 style={{
              fontSize: '64px',
              fontWeight: '900',
              color: '#0F0',
              textShadow: '0 0 20px #0F0, 0 0 40px #0F0',
              marginBottom: '16px',
              fontFamily: 'monospace',
              letterSpacing: '4px'
            }}>
              CYBERENCRYPT
            </h1>
            <p style={{
              fontSize: '18px',
              color: '#0F0',
              fontFamily: 'monospace',
              textShadow: '0 0 10px #0F0'
            }}>
              {'>'} MILITARY-GRADE ENCRYPTION SYSTEM_
            </p>
          </div>

          {/* Feature Boxes - 3 Cards */}
          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))',
            gap: '20px',
            marginBottom: '48px'
          }}>
            <div style={{
              background: 'rgba(0, 255, 0, 0.05)',
              border: '2px solid #0F0',
              borderRadius: '8px',
              padding: '24px',
              textAlign: 'center',
              boxShadow: '0 0 20px rgba(0, 255, 0, 0.3)'
            }}>
              <div style={{ fontSize: '48px', marginBottom: '12px' }}>🔒</div>
              <div style={{ fontSize: '32px', fontWeight: '700', color: '#0F0', marginBottom: '8px', fontFamily: 'monospace' }}>
                256-BIT
              </div>
              <div style={{ fontSize: '14px', color: '#0F0', fontFamily: 'monospace' }}>
                ENCRYPTION
              </div>
            </div>

            <div style={{
              background: 'rgba(0, 255, 0, 0.05)',
              border: '2px solid #0F0',
              borderRadius: '8px',
              padding: '24px',
              textAlign: 'center',
              boxShadow: '0 0 20px rgba(0, 255, 0, 0.3)'
            }}>
              <div style={{ fontSize: '48px', marginBottom: '12px' }}>⚡</div>
              <div style={{ fontSize: '32px', fontWeight: '700', color: '#0F0', marginBottom: '8px', fontFamily: 'monospace' }}>
                INSTANT
              </div>
              <div style={{ fontSize: '14px', color: '#0F0', fontFamily: 'monospace' }}>
                PROCESSING
              </div>
            </div>

            <div style={{
              background: 'rgba(0, 255, 0, 0.05)',
              border: '2px solid #0F0',
              borderRadius: '8px',
              padding: '24px',
              textAlign: 'center',
              boxShadow: '0 0 20px rgba(0, 255, 0, 0.3)'
            }}>
              <div style={{ fontSize: '48px', marginBottom: '12px' }}>🛡️</div>
              <div style={{ fontSize: '32px', fontWeight: '700', color: '#0F0', marginBottom: '8px', fontFamily: 'monospace' }}>
                100%
              </div>
              <div style={{ fontSize: '14px', color: '#0F0', fontFamily: 'monospace' }}>
                SECURE
              </div>
            </div>
          </div>

          {/* Auth Form */}
          <AuthForm onLogin={onLogin} />
        </div>
      </div>
    </div>
  );
}

export default Landing;