import React, { useState, useEffect } from 'react';
import axios from 'axios';
import AuthForm from './components/AuthForm';
import Dashboard from './pages/Dashboard';
import './App.css';

function App() {
  const [token, setToken] = useState('');
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  // 🔹 1. Initialize token from localStorage OR URL
  useEffect(() => {
    const storedToken = localStorage.getItem('token');
    let initialToken = storedToken;

    // Check URL for token (from Google OAuth redirect)
    if (!initialToken) {
      const urlParams = new URLSearchParams(window.location.search);
      const tokenFromUrl = urlParams.get('token');

      if (tokenFromUrl) {
        localStorage.setItem('token', tokenFromUrl);
        initialToken = tokenFromUrl;
        // Clean URL
        window.history.replaceState({}, document.title, window.location.pathname);
      }
    }

    if (initialToken) {
      setToken(initialToken);
    } else {
      setLoading(false);
    }
  }, []); // Run once on mount

  // 🔹 2. Fetch user when token is available
  useEffect(() => {
    if (token) {
      fetchUserData();
    }
  }, [token]);

  const fetchUserData = async () => {
    try {
      const response = await axios.get(
        'http://localhost:5001/api/auth/me',
        {
          headers: { Authorization: `Bearer ${token}` }
        }
      );
      setUser(response.data);
      setLoading(false);
    } catch (error) {
      console.error('Auth error:', error);
      // Invalid token? Clear it
      localStorage.removeItem('token');
      setToken('');
      setUser(null);
      setLoading(false);
    }
  };

  const handleLogin = (newToken, userData) => {
    localStorage.setItem('token', newToken);
    setToken(newToken);
    setUser(userData || {});
  };

  const handleLogout = () => {
    localStorage.removeItem('token');
    setToken('');
    setUser(null);
  };

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
        ⏳ LOADING SYSTEM_
      </div>
    );
  }

  return (
    <div className="App">
      {token && user ? (
        <Dashboard token={token} user={user} onLogout={handleLogout} />
      ) : (
        <AuthForm onLogin={handleLogin} />
      )}
    </div>
  );
}

export default App;