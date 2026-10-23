import React, { useState } from 'react';

function Header({ user, onLogout }) {
  const [showMenu, setShowMenu] = useState(false);

  return (
    <div className="topbar">
      <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
        <h2 style={{ fontSize: '24px', fontWeight: '700', margin: 0 }}>
          Dashboard
        </h2>
        <div style={{
          padding: '4px 12px',
          background: 'rgba(0, 208, 132, 0.1)',
          border: '1px solid var(--success)',
          borderRadius: '6px',
          fontSize: '12px',
          color: 'var(--success)',
          fontWeight: '600'
        }}>
          ● Online
        </div>
      </div>

      <div style={{ position: 'relative' }}>
        <div 
          className="user-menu" 
          onClick={() => setShowMenu(!showMenu)}
          style={{ cursor: 'pointer' }}
        >
          <div className="user-avatar">
            {user?.username?.[0]?.toUpperCase() || 'U'}
          </div>
          <div>
            <div style={{ fontSize: '14px', fontWeight: '600' }}>
              {user?.username}
            </div>
            <div style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>
              Premium Account
            </div>
          </div>
        </div>

        {showMenu && (
          <div style={{
            position: 'absolute',
            right: 0,
            top: '100%',
            marginTop: '8px',
            background: 'var(--bg-secondary)',
            border: '1px solid var(--border-color)',
            borderRadius: '12px',
            minWidth: '220px',
            boxShadow: '0 8px 32px rgba(0,0,0,0.4)',
            zIndex: 1000,
            overflow: 'hidden'
          }}>
            <div style={{ 
              padding: '16px', 
              borderBottom: '1px solid var(--border-color)',
              background: 'rgba(0, 217, 255, 0.05)'
            }}>
              <div style={{ fontSize: '14px', fontWeight: '600', marginBottom: '4px', color: 'var(--text-primary)' }}>
                {user?.username}
              </div>
              <div style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>
                {user?.email}
              </div>
            </div>
            
            <button
              onClick={() => {
                setShowMenu(false);
                onLogout();
              }}
              style={{
                width: '100%',
                padding: '14px 16px',
                background: 'transparent',
                border: 'none',
                color: 'var(--error)',
                cursor: 'pointer',
                fontSize: '14px',
                fontWeight: '600',
                textAlign: 'left',
                display: 'flex',
                alignItems: 'center',
                gap: '12px',
                transition: 'all 0.2s'
              }}
              onMouseEnter={(e) => e.target.style.background = 'rgba(255, 71, 87, 0.1)'}
              onMouseLeave={(e) => e.target.style.background = 'transparent'}
            >
              <span style={{ fontSize: '18px' }}>🚪</span>
              Logout
            </button>
          </div>
        )}
      </div>
    </div>
  );
}

export default Header;