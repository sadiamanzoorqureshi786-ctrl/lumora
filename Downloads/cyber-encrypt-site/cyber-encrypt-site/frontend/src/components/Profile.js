import React, { useState, useEffect } from 'react';
import axios from 'axios';

function Profile({ token, user }) {
  const [users, setUsers] = useState([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchAllUsers();
  }, []);

  const fetchAllUsers = async () => {
    try {
      const response = await axios.get('/api/users/all', {
        headers: { Authorization: `Bearer ${token}` }
      });
      setUsers(response.data);
    } catch (error) {
      console.error('Error fetching users:', error);
    } finally {
      setLoading(false);
    }
  };

  const searchUsers = async (query) => {
    setSearchQuery(query);
    if (query.length < 2) {
      fetchAllUsers();
      return;
    }

    try {
      const response = await axios.get(`/api/users/search?query=${query}`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setUsers(response.data);
    } catch (error) {
      console.error('Error:', error);
    }
  };

  const filteredUsers = users.filter(u => 
    u._id !== user?.id && u._id !== user?._id
  );

  return (
    <div style={{ maxWidth: '1200px', margin: '0 auto' }}>
      <div className="card">
        <h2 className="card-title" style={{ marginBottom: '8px', fontFamily: 'monospace' }}>
          👥 USER DIRECTORY
        </h2>
        <p style={{ fontSize: '14px', color: 'rgba(0, 255, 0, 0.7)', margin: '0 0 24px 0', fontFamily: 'monospace' }}>
          {'>'} Browse users and start secure conversations_
        </p>

        {/* Search Bar */}
        <div className="form-group">
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => searchUsers(e.target.value)}
            placeholder="Search users by name ..."
            className="form-input"
            style={{ 
              fontFamily: 'monospace',
              fontSize: '16px',
              padding: '16px'
            }}
          />
        </div>

        {loading ? (
          <div style={{ textAlign: 'center', padding: '60px', color: '#0F0', fontFamily: 'monospace' }}>
            <div style={{ fontSize: '48px', marginBottom: '16px' }}>⏳</div>
            <p>LOADING USERS...</p>
          </div>
        ) : filteredUsers.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '60px', color: '#0F0', fontFamily: 'monospace' }}>
            <div style={{ fontSize: '64px', marginBottom: '16px' }}>👥</div>
            <p style={{ fontSize: '18px' }}>NO USERS FOUND</p>
          </div>
        ) : (
          <div style={{ 
            display: 'grid', 
            gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))', 
            gap: '24px',
            marginTop: '24px'
          }}>
            {filteredUsers.map(usr => (
              <div
                key={usr._id}
                style={{
                  background: 'rgba(0, 0, 0, 0.8)',
                  border: '2px solid #0F0',
                  borderRadius: '16px',
                  padding: '24px',
                  textAlign: 'center',
                  transition: 'all 0.3s ease',
                  cursor: 'pointer'
                }}
                onMouseEnter={(e) => {
                  e.currentTarget.style.transform = 'translateY(-4px)';
                  e.currentTarget.style.boxShadow = '0 8px 24px rgba(0, 255, 0, 0.4)';
                }}
                onMouseLeave={(e) => {
                  e.currentTarget.style.transform = 'translateY(0)';
                  e.currentTarget.style.boxShadow = 'none';
                }}
              >
                {/* Avatar */}
                <div style={{
                  width: '80px',
                  height: '80px',
                  borderRadius: '50%',
                  background: 'rgba(0, 255, 0, 0.2)',
                  border: '3px solid #0F0',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontSize: '32px',
                  fontWeight: '900',
                  color: '#0F0',
                  fontFamily: 'monospace',
                  margin: '0 auto 16px',
                  boxShadow: '0 0 20px rgba(0, 255, 0, 0.3)'
                }}>
                  {usr.username?.[0]?.toUpperCase() || 'U'}
                </div>

                {/* Username */}
                <div style={{
                  fontSize: '20px',
                  fontWeight: '900',
                  color: '#0F0',
                  fontFamily: 'monospace',
                  marginBottom: '8px',
                  textShadow: '0 0 10px rgba(0, 255, 0, 0.8)'
                }}>
                  {usr.username}
                </div>
                {/* Status Badge */}
                <div style={{
                  display: 'inline-flex',
                  alignItems: 'center',
                  gap: '6px',
                  padding: '6px 12px',
                  background: 'rgba(0, 255, 0, 0.1)',
                  border: '1px solid #0F0',
                  borderRadius: '6px',
                  fontSize: '12px',
                  color: '#0F0',
                  fontFamily: 'monospace',
                  fontWeight: '600',
                  marginBottom: '16px'
                }}>
                  <span style={{ fontSize: '8px' }}>●</span> Available
                </div>

                {/* Send Message Button */}
                <button
                  onClick={() => {
                    // Navigate to messages with this user selected
                    alert(`Start conversation with ${usr.username}`);
                  }}
                  style={{
                    width: '100%',
                    padding: '12px',
                    background: '#0F0',
                    color: '#000',
                    border: 'none',
                    borderRadius: '8px',
                    fontFamily: 'monospace',
                    fontWeight: '900',
                    fontSize: '14px',
                    cursor: 'pointer',
                    transition: 'all 0.3s ease',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    gap: '8px'
                  }}
                  onMouseEnter={(e) => {
                    e.target.style.background = '#00FF00';
                    e.target.style.boxShadow = '0 0 20px rgba(0, 255, 0, 0.8)';
                  }}
                  onMouseLeave={(e) => {
                    e.target.style.background = '#0F0';
                    e.target.style.boxShadow = 'none';
                  }}
                >
                  <span>📤</span> SEND MESSAGE
                </button>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Current User Info */}
      <div className="card" style={{ marginTop: '24px' }}>
        <h2 className="card-title" style={{ marginBottom: '16px', fontFamily: 'monospace' }}>
          👤 YOUR PROFILE
        </h2>
        
        <div style={{ display: 'flex', gap: '24px', alignItems: 'center' }}>
          <div style={{
            width: '80px',
            height: '80px',
            borderRadius: '50%',
            background: 'rgba(0, 255, 0, 0.2)',
            border: '3px solid #0F0',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontSize: '32px',
            fontWeight: '900',
            color: '#0F0',
            fontFamily: 'monospace',
            boxShadow: '0 0 20px rgba(0, 255, 0, 0.5)'
          }}>
            {user?.username?.[0]?.toUpperCase() || 'U'}
          </div>

          <div style={{ flex: 1 }}>
            <div style={{ fontSize: '24px', fontWeight: '900', color: '#0F0', fontFamily: 'monospace', marginBottom: '8px' }}>
              {user?.username || 'User'}
            </div>
            <div style={{ fontSize: '14px', color: 'rgba(0, 255, 0, 0.7)', fontFamily: 'monospace', marginBottom: '12px' }}>
              {user?.email || 'N/A'}
            </div>
            <div style={{ display: 'flex', gap: '12px' }}>
              <div style={{ padding: '6px 12px', background: 'rgba(0, 255, 0, 0.1)', border: '1px solid #0F0', borderRadius: '6px', fontSize: '12px', color: '#0F0', fontFamily: 'monospace' }}>
                <span style={{ fontSize: '8px' }}>●</span> ONLINE
              </div>
              <div style={{ padding: '6px 12px', background: 'rgba(0, 255, 0, 0.1)', border: '1px solid #0F0', borderRadius: '6px', fontSize: '12px', color: '#0F0', fontFamily: 'monospace' }}>
                👑 PREMIUM
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default Profile;