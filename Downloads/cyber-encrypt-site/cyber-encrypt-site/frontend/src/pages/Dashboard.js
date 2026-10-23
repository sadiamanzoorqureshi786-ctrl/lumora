import React, { useState, useEffect } from 'react';
import MatrixRain from '../components/MatrixRain';
import Header from '../components/Header';
import EncryptionTool from '../components/EncryptionTool';
import MessageBox from '../components/MessageBox';
import HistoryLog from '../components/HistoryLog';
import Settings from '../components/Settings';
import Profile from '../components/Profile';
import BlockchainViewer from '../components/BlockchainViewer';

function Dashboard({ token, user, onLogout }) {
  const [currentPage, setCurrentPage] = useState('encryption');
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const [showNotifications, setShowNotifications] = useState(false);
  const [unreadCount, setUnreadCount] = useState(0);

  // Check for new messages every 30 seconds
  useEffect(() => {
    const checkNewMessages = async () => {
      try {
        const response = await fetch('http://localhost:5001/api/messages/unread-count', {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        const data = await response.json();
        setUnreadCount(data.count || 0);
      } catch (error) {
        console.error('Error checking notifications:', error);
      }
    };

    checkNewMessages();
    const interval = setInterval(checkNewMessages, 30000);

    return () => clearInterval(interval);
  }, [token]);

  const renderPage = () => {
    switch (currentPage) {
      case 'encryption':
        return <EncryptionTool token={token} />;
      case 'messages':
        return <MessageBox token={token} user={user} />;
      case 'history':
        return <HistoryLog token={token} />;
      case 'blockchain':
        return <BlockchainViewer token={token} />;
      case 'settings':
        return <Settings token={token} user={user} />;
      case 'profile':
        return <Profile token={token} user={user} />;
      default:
        return <EncryptionTool token={token} />;
    }
  };

  return (
    <div style={{ 
      position: 'relative', 
      minHeight: '100vh', 
      background: '#000',
      display: 'flex',
      flexDirection: 'column',
      overflow: 'hidden'
    }}>
      {/* Matrix Rain Background */}
      <div style={{ 
        position: 'fixed', 
        top: 0, 
        left: 0, 
        width: '100%', 
        height: '100%', 
        zIndex: 1,
        pointerEvents: 'none'
      }}>
        <MatrixRain />
      </div>

      {/* Dashboard Content */}
      <div style={{ 
        position: 'relative', 
        zIndex: 10,
        display: 'flex', 
        flexDirection: 'column', 
        minHeight: '100vh' 
      }}>
  
        {/* Header */}
        <div style={{
          background: 'rgba(0, 0, 0, 0.95)',
          borderBottom: '2px solid #0F0',
          padding: '16px 24px',
          display: 'flex',
          alignItems: 'center',
          gap: '20px',
          flexShrink: 0,
          position: 'relative',
          zIndex: 100
        }}>
          {/* Hamburger Button */}
          <button
            onClick={() => setSidebarOpen(!sidebarOpen)}
            style={{
              background: 'transparent',
              border: '2px solid #0F0',
              borderRadius: '8px',
              padding: '10px 14px',
              color: '#0F0',
              fontSize: '24px',
              cursor: 'pointer',
              transition: 'all 0.3s ease',
              position: 'relative',
              zIndex: 1
            }}
            onMouseEnter={(e) => {
              e.target.style.background = 'rgba(0, 255, 0, 0.1)';
            }}
            onMouseLeave={(e) => {
              e.target.style.background = 'transparent';
            }}
          >
            ☰
          </button>

          {/* Page Title */}
          <div style={{ flex: 1 }}>
            <h2 style={{
              fontSize: '24px',
              fontWeight: '700',
              margin: 0,
              color: '#0F0',
              fontFamily: 'monospace',
              textShadow: '0 0 10px rgba(0, 255, 0, 0.8)'
            }}>
              {currentPage === 'encryption' && '🔐 ENCRYPTION TOOL'}
              {currentPage === 'messages' && '💬 MESSAGES'}
              {currentPage === 'history' && '📜 HISTORY'}
              {currentPage === 'blockchain' && '⛓️ BLOCKCHAIN'}
              {currentPage === 'settings' && '⚙️ SETTINGS'}
              {currentPage === 'profile' && '👤 PROFILE'}
            </h2>
          </div>

          {/* User Info */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            {/* Online Status */}
            <div style={{
              padding: '4px 12px',
              background: 'rgba(0, 255, 0, 0.1)',
              border: '1px solid #0F0',
              borderRadius: '6px',
              fontSize: '12px',
              color: '#0F0',
              fontFamily: 'monospace'
            }}>
              ● ONLINE
            </div>

            {/* Notification Bell */}
            <button
              onClick={() => setShowNotifications(!showNotifications)}
              style={{
                position: 'relative',
                background: 'transparent',
                border: '2px solid #0F0',
                borderRadius: '50%',
                width: '40px',
                height: '40px',
                color: '#0F0',
                fontSize: '18px',
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center'
              }}
            >
              🔔
              {unreadCount > 0 && (
                <span style={{
                  position: 'absolute',
                  top: '-5px',
                  right: '-5px',
                  background: '#F00',
                  color: '#FFF',
                  borderRadius: '50%',
                  width: '20px',
                  height: '20px',
                  fontSize: '11px',
                  fontWeight: '700',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center'
                }}>
                  {unreadCount}
                </span>
              )}
            </button>

            {/* Notification Dropdown */}
            {showNotifications && (
              <div style={{
                position: 'absolute',
                top: '70px',
                right: '20px',
                width: '350px',
                maxHeight: '400px',
                background: 'rgba(0, 0, 0, 0.95)',
                border: '2px solid #0F0',
                borderRadius: '12px',
                padding: '16px',
                zIndex: 1000,
                overflowY: 'auto'
              }}>
                <h3 style={{ color: '#0F0', fontFamily: 'monospace', marginBottom: '12px' }}>
                  🔔 NOTIFICATIONS ({unreadCount})
                </h3>
                {unreadCount === 0 ? (
                  <p style={{ color: 'rgba(0, 255, 0, 0.6)', fontFamily: 'monospace', fontSize: '14px' }}>
                    No new messages
                  </p>
                ) : (
                  <p style={{ color: '#0F0', fontFamily: 'monospace', fontSize: '14px' }}>
                    You have {unreadCount} new message{unreadCount !== 1 ? 's' : ''}
                  </p>
                )}
                <button
                  onClick={() => {
                    setCurrentPage('messages');
                    setShowNotifications(false);
                  }}
                  style={{
                    width: '100%',
                    marginTop: '12px',
                    padding: '8px',
                    background: '#0F0',
                    border: 'none',
                    borderRadius: '6px',
                    color: '#000',
                    fontFamily: 'monospace',
                    fontWeight: '700',
                    cursor: 'pointer'
                  }}
                >
                  VIEW MESSAGES
                </button>
              </div>
            )}

            {/* User Profile Section */}
            <div style={{
              display: 'flex',
              alignItems: 'center',
              gap: '12px',
              padding: '8px 16px',
              background: 'rgba(0, 255, 0, 0.05)',
              border: '2px solid #0F0',
              borderRadius: '8px'
            }}>
              <div style={{
                width: '40px',
                height: '40px',
                borderRadius: '50%',
                background: 'rgba(0, 255, 0, 0.2)',
                border: '2px solid #0F0',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontWeight: '900',
                color: '#0F0',
                fontSize: '18px',
                fontFamily: 'monospace'
              }}>
                {user?.username?.[0]?.toUpperCase() || 'U'}
              </div>
              <div>
                <div style={{ fontSize: '14px', fontWeight: '600', color: '#0F0', fontFamily: 'monospace' }}>
                  {user?.username || 'User'}
                </div>
                <div style={{ fontSize: '12px', color: 'rgba(0, 255, 0, 0.7)', fontFamily: 'monospace' }}>
                  Premium Account
                </div>
              </div>
              <button
                onClick={onLogout}
                style={{
                  background: 'transparent',
                  border: '2px solid #F00',
                  borderRadius: '6px',
                  padding: '8px 12px',
                  color: '#F00',
                  fontFamily: 'monospace',
                  fontWeight: '700',
                  fontSize: '12px',
                  cursor: 'pointer',
                  position: 'relative',
                  zIndex: 1
                }}
              >
                🚪 LOGOUT
              </button>
            </div>
          </div>
        </div>

        {/* Main Content Area with Sidebar */}
        <div style={{ 
          display: 'flex', 
          flex: 1,
          overflow: 'hidden',
          position: 'relative',
          zIndex: 10
        }}>
          {/* Sidebar */}
          <div style={{
            width: sidebarOpen ? '260px' : '0',
            background: 'rgba(0, 0, 0, 0.95)',
            borderRight: sidebarOpen ? '2px solid #0F0' : 'none',
            transition: 'all 0.3s ease',
            overflow: 'hidden',
            display: 'flex',
            flexDirection: 'column',
            flexShrink: 0,
            position: 'relative',
            zIndex: 50
          }}>
            {sidebarOpen && (
              <div style={{
                overflowY: 'auto',
                overflowX: 'hidden',
                height: '100%',
                padding: '24px 0'
              }}>
                <div style={{ padding: '0 20px', marginBottom: '24px' }}>
                  <div style={{
                    background: 'rgba(0, 255, 0, 0.1)',
                    border: '2px solid #0F0',
                    borderRadius: '12px',
                    padding: '16px',
                    textAlign: 'center'
                  }}>
                    <div style={{ fontSize: '48px', marginBottom: '12px' }}>🔐</div>
                    <div style={{
                      fontSize: '16px',
                      fontWeight: '900',
                      color: '#0F0',
                      fontFamily: 'monospace',
                      textShadow: '0 0 10px rgba(0, 255, 0, 0.8)'
                    }}>
                      CYBERENCRYPT
                    </div>
                    <div style={{
                      fontSize: '12px',
                      color: 'rgba(0, 255, 0, 0.7)',
                      fontFamily: 'monospace',
                      marginTop: '4px'
                    }}>
                      {'>'} MILITARY-GRADE ENCRYPTION_
                    </div>
                  </div>
                </div>

                <div style={{ marginTop: '32px' }}>
                  <div style={{
                    padding: '0 20px',
                    marginBottom: '12px',
                    fontSize: '11px',
                    fontWeight: '700',
                    color: 'rgba(0, 255, 0, 0.6)',
                    fontFamily: 'monospace',
                    letterSpacing: '1px'
                  }}>
                    MAIN MENU
                  </div>

                  {[
                    { id: 'encryption', icon: '🔐', label: 'Encryption' },
                    { id: 'messages', icon: '💬', label: 'Messages' },
                    { id: 'history', icon: '📜', label: 'History' },
                    { id: 'blockchain', icon: '⛓️', label: 'Blockchain' }
                  ].map(item => (
                    <button
                      key={item.id}
                      onClick={() => setCurrentPage(item.id)}
                      style={{
                        width: '100%',
                        padding: '14px 20px',
                        background: currentPage === item.id ? 'rgba(0, 255, 0, 0.2)' : 'transparent',
                        border: 'none',
                        borderLeft: currentPage === item.id ? '4px solid #0F0' : '4px solid transparent',
                        color: '#0F0',
                        fontFamily: 'monospace',
                        fontSize: '14px',
                        fontWeight: currentPage === item.id ? '900' : '600',
                        cursor: 'pointer',
                        textAlign: 'left',
                        display: 'flex',
                        alignItems: 'center',
                        gap: '12px',
                        transition: 'all 0.3s ease',
                        textShadow: currentPage === item.id ? '0 0 10px rgba(0, 255, 0, 0.8)' : 'none',
                        position: 'relative',
                        zIndex: 1
                      }}
                      onMouseEnter={(e) => {
                        if (currentPage !== item.id) {
                          e.target.style.background = 'rgba(0, 255, 0, 0.1)';
                          e.target.style.paddingLeft = '24px';
                        }
                      }}
                      onMouseLeave={(e) => {
                        if (currentPage !== item.id) {
                          e.target.style.background = 'transparent';
                          e.target.style.paddingLeft = '20px';
                        }
                      }}
                    >
                      <span style={{ fontSize: '20px' }}>{item.icon}</span>
                      <span>{item.label.toUpperCase()}</span>
                    </button>
                  ))}

                  <div style={{
                    padding: '0 20px',
                    marginTop: '32px',
                    marginBottom: '12px',
                    fontSize: '11px',
                    fontWeight: '700',
                    color: 'rgba(0, 255, 0, 0.6)',
                    fontFamily: 'monospace',
                    letterSpacing: '1px'
                  }}>
                    ACCOUNT
                  </div>

                  {[
                    { id: 'profile', icon: '👤', label: 'Profile' },
                    { id: 'settings', icon: '⚙️', label: 'Settings' }
                  ].map(item => (
                    <button
                      key={item.id}
                      onClick={() => setCurrentPage(item.id)}
                      style={{
                        width: '100%',
                        padding: '14px 20px',
                        background: currentPage === item.id ? 'rgba(0, 255, 0, 0.2)' : 'transparent',
                        border: 'none',
                        borderLeft: currentPage === item.id ? '4px solid #0F0' : '4px solid transparent',
                        color: '#0F0',
                        fontFamily: 'monospace',
                        fontSize: '14px',
                        fontWeight: currentPage === item.id ? '900' : '600',
                        cursor: 'pointer',
                        textAlign: 'left',
                        display: 'flex',
                        alignItems: 'center',
                        gap: '12px',
                        transition: 'all 0.3s ease',
                        textShadow: currentPage === item.id ? '0 0 10px rgba(0, 255, 0, 0.8)' : 'none',
                        position: 'relative',
                        zIndex: 1
                      }}
                      onMouseEnter={(e) => {
                        if (currentPage !== item.id) {
                          e.target.style.background = 'rgba(0, 255, 0, 0.1)';
                          e.target.style.paddingLeft = '24px';
                        }
                      }}
                      onMouseLeave={(e) => {
                        if (currentPage !== item.id) {
                          e.target.style.background = 'transparent';
                          e.target.style.paddingLeft = '20px';
                        }
                      }}
                    >
                      <span style={{ fontSize: '20px' }}>{item.icon}</span>
                      <span>{item.label.toUpperCase()}</span>
                    </button>
                  ))}
                </div>

                {/* User Info Box */}
                <div style={{
                  margin: '32px 20px 0',
                  padding: '16px',
                  background: 'rgba(0, 255, 0, 0.05)',
                  border: '2px solid #0F0',
                  borderRadius: '12px'
                }}>
                  <div style={{
                    fontSize: '12px',
                    color: 'rgba(0, 255, 0, 0.7)',
                    fontFamily: 'monospace',
                    marginBottom: '8px'
                  }}>
                    {'>'} LOGGED IN AS:
                  </div>
                  <div style={{
                    fontSize: '14px',
                    fontWeight: '900',
                    color: '#0F0',
                    fontFamily: 'monospace',
                    marginBottom: '4px'
                  }}>
                    {user?.username || 'User'}
                  </div>
                  <div style={{
                    fontSize: '10px',
                    color: 'rgba(0, 255, 0, 0.6)',
                    fontFamily: 'monospace'
                  }}>
                    {'>'} PREMIUM ACCOUNT
                  </div>
                </div>
              </div>
            )}
          </div>

          {/* Main Content */}
          <div style={{ 
            flex: 1, 
            overflowY: 'auto',
            overflowX: 'hidden',
            padding: '24px',
            position: 'relative',
            zIndex: 10
          }}>
            {renderPage()}
          </div>
        </div>
      </div>
    </div>
  );
}

export default Dashboard;