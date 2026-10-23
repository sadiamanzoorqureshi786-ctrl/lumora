// src/components/UserList.js
import React, { useState, useEffect } from 'react';
import axios from 'axios';

function UserList({ token }) {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchUsers = async () => {
      try {
        const response = await axios.get('/api/users', {
          headers: { Authorization: `Bearer ${token}` }
        });
        setUsers(response.data);
      } catch (err) {
        setError(err.response?.data?.error || 'Failed to load users');
      } finally {
        setLoading(false);
      }
    };

    fetchUsers();
  }, [token]);

  if (loading) {
    return (
      <div style={{
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        minHeight: '100vh',
        background: '#000',
        color: '#0F0',
        fontFamily: 'monospace',
        fontSize: '24px'
      }}>
        ⏳ LOADING USERS...
      </div>
    );
  }

  if (error) {
    return (
      <div style={{
        padding: '20px',
        background: 'rgba(255, 0, 0, 0.2)',
        border: '2px solid #F00',
        borderRadius: '8px',
        color: '#F00',
        fontFamily: 'monospace',
        margin: '20px'
      }}>
        ⚠️ {error}
      </div>
    );
  }

  return (
    <div style={{
      padding: '20px',
      background: 'rgba(0, 0, 0, 0.8)',
      border: '2px solid #0F0',
      borderRadius: '12px',
      minHeight: '100vh'
    }}>
      <h2 style={{
        fontSize: '28px',
        fontWeight: '900',
        color: '#0F0',
        fontFamily: 'monospace',
        marginBottom: '24px',
        textAlign: 'center'
      }}>
        👥 ALL REGISTERED USERS
      </h2>

      {users.length === 0 ? (
        <div style={{
          textAlign: 'center',
          color: 'rgba(0, 255, 0, 0.7)',
          fontFamily: 'monospace',
          fontSize: '18px',
          padding: '40px'
        }}>
          No users found.
        </div>
      ) : (
        <div style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))',
          gap: '24px'
        }}>
          {users.map(user => (
            <div
              key={user._id}
              style={{
                background: 'rgba(0, 255, 0, 0.05)',
                border: '2px solid #0F0',
                borderRadius: '12px',
                padding: '20px',
                transition: 'all 0.3s ease'
              }}
              onMouseEnter={(e) => {
                e.currentTarget.style.transform = 'translateY(-4px)';
                e.currentTarget.style.boxShadow = '0 8px 32px rgba(0, 255, 0, 0.2)';
              }}
              onMouseLeave={(e) => {
                e.currentTarget.style.transform = 'translateY(0)';
                e.currentTarget.style.boxShadow = 'none';
              }}
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '16px' }}>
                {user.profilePic ? (
                  <img
                    src={user.profilePic}
                    alt="Profile"
                    style={{
                      width: '64px',
                      height: '64px',
                      borderRadius: '50%',
                      border: '2px solid #0F0'
                    }}
                  />
                ) : (
                  <div
                    style={{
                      width: '64px',
                      height: '64px',
                      borderRadius: '50%',
                      background: 'rgba(0, 255, 0, 0.2)',
                      border: '2px solid #0F0',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      color: '#0F0',
                      fontSize: '24px',
                      fontWeight: '900',
                      fontFamily: 'monospace'
                    }}
                  >
                    {user.username?.[0]?.toUpperCase() || 'U'}
                  </div>
                )}
                <div>
                  <div
                    style={{
                      fontSize: '18px',
                      fontWeight: '900',
                      color: '#0F0',
                      fontFamily: 'monospace'
                    }}
                  >
                    {user.username}
                  </div>
                </div>
              </div>

              <div
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  fontSize: '12px',
                  color: 'rgba(0, 255, 0, 0.6)',
                  fontFamily: 'monospace'
                }}
              >
                <span>Joined: {new Date(user.createdAt).toLocaleDateString()}</span>
                <span>Role: {user.role || 'User'}</span>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

export default UserList;
