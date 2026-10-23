// frontend/src/components/MessageBox.js
import React, { useState, useEffect } from 'react';
import axios from 'axios';

function MessageBox({ token, user }) {
  const [messages, setMessages] = useState([]);
  const [sentMessages, setSentMessages] = useState([]);
  const [receivedMessages, setReceivedMessages] = useState([]);
  const [activeTab, setActiveTab] = useState('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [searchResults, setSearchResults] = useState([]);
  const [selectedUser, setSelectedUser] = useState(null);
  const [newMessage, setNewMessage] = useState('');
  const [algorithm, setAlgorithm] = useState('caesar');
  const [key, setKey] = useState('');
  const [loading, setLoading] = useState(false);
  const [decryptedMessages, setDecryptedMessages] = useState({});
  const [error, setError] = useState('');
  const [searchError, setSearchError] = useState('');
  const [successMessage, setSuccessMessage] = useState('');

  useEffect(() => {
    fetchMessages();
  }, []);

  const fetchMessages = async () => {
    try {
      setError('');
      
      const [receivedRes, sentRes] = await Promise.all([
        axios.get('http://localhost:5001/api/messages/received', {
          headers: { Authorization: `Bearer ${token}` }
        }),
        axios.get('http://localhost:5001/api/messages/sent', {
          headers: { Authorization: `Bearer ${token}` }
        })
      ]);

      setReceivedMessages(receivedRes.data || []);
      setSentMessages(sentRes.data || []);
      
      const allMsgs = [...(receivedRes.data || []), ...(sentRes.data || [])]
        .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
      
      setMessages(allMsgs);
    } catch (error) {
      console.error('Error fetching messages:', error);
      setError(error.response?.data?.error || 'Failed to load messages. Please try again.');
    }
  };

  const searchUsers = async (query) => {
    setSearchQuery(query);
    setSearchError('');
    if (query.length < 2) {
      setSearchResults([]);
      return;
    }

    try {
      const response = await axios.get(`http://localhost:5001/api/users/search?query=${query}`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setSearchResults(response.data || []);
    } catch (error) {
      console.error('Error searching users:', error);
      setSearchError(error.response?.data?.error || 'Failed to search users. Please try again.');
      setSearchResults([]);
    }
  };

  const sendMessage = async () => {
    if (!selectedUser || !newMessage.trim() || !key.trim()) {
      setError('Please fill in all fields: recipient, message, and key');
      return;
    }

    setLoading(true);
    setError('');
    setSuccessMessage('');
    
    try {
      if (algorithm === 'AES-256' && key.length !== 32) {
        setError('AES-256 requires a 32-character key (UTF-8).');
        setLoading(false);
        return;
      }

      const sentKey = key;
      const sentAlgorithm = algorithm;
      const sentRecipient = selectedUser.username;

      await axios.post(
        'http://localhost:5001/api/messages/send',
        { 
          recipient: selectedUser.username,
          message: newMessage,
          algorithm: algorithm,
          key: key 
        },
        { headers: { Authorization: `Bearer ${token}` } }
      );
      
      setSuccessMessage(`✓ Message sent to ${sentRecipient}! Share the key "${sentKey}" with them securely.`);
      
      window.lastSentKey = sentKey;
      window.lastSentAlgorithm = sentAlgorithm;
      
      setNewMessage('');
      setKey('');
      setSelectedUser(null);
      fetchMessages();
      
      setTimeout(() => {
        setSuccessMessage('');
        window.lastSentKey = null;
        window.lastSentAlgorithm = null;
      }, 10000);
    } catch (error) {
      console.error('Error sending message:', error);
      setError(error.response?.data?.error || error.message || 'Failed to send message. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const decryptMessage = async (messageId, messageKey) => {
    const decryptKey = prompt(`Enter the decryption key:\n\nHint: The sender should have shared this key with you.`);
    if (!decryptKey) return;

    try {
      setError('');
      const response = await axios.post(
        `http://localhost:5001/api/messages/decrypt`,
        { messageId, key: decryptKey },
        { headers: { Authorization: `Bearer ${token}` } }
      );
      setDecryptedMessages({
        ...decryptedMessages,
        [messageId]: response.data.decryptedText
      });
    } catch (error) {
      console.error('Error decrypting message:', error);
      setError(error.response?.data?.error || 'Failed to decrypt message. Please check your key and try again.');
    }
  };

  const copyToClipboard = (text, label) => {
    navigator.clipboard.writeText(text);
    alert(`${label} copied to clipboard!`);
  };

  const getFilteredMessages = () => {
    if (activeTab === 'received') return receivedMessages;
    if (activeTab === 'sent') return sentMessages;
    return messages;
  };

  const displayMessages = getFilteredMessages();

  return (
    <div style={{ maxWidth: '1200px', margin: '0 auto' }}>
      <div className="card" style={{ marginBottom: '24px' }}>
        <h2 className="card-title" style={{ marginBottom: '24px', fontFamily: 'monospace' }}>📤 SEND ENCRYPTED MESSAGE</h2>
        
        <div className="form-group">
          <label className="form-label" style={{ color: '#0F0', fontFamily: 'monospace' }}>RECIPIENT</label>
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => searchUsers(e.target.value)}
            className="form-input"
            placeholder="Search users..."
            style={{ fontFamily: 'monospace' }}
          />
          {searchResults.length > 0 && (
            <div style={{ marginTop: '8px', background: 'rgba(0, 0, 0, 0.8)', borderRadius: '8px', border: '2px solid #0F0', maxHeight: '200px', overflowY: 'auto' }}>
              {searchResults.map(u => (
                <button
                  key={u._id}
                  onClick={() => {
                    setSelectedUser(u);
                    setSearchResults([]);
                    setSearchQuery('');
                  }}
                  style={{
                    width: '100%',
                    padding: '12px 16px',
                    background: 'transparent',
                    border: 'none',
                    color: '#0F0',
                    cursor: 'pointer',
                    textAlign: 'left',
                    fontSize: '14px',
                    fontFamily: 'monospace',
                    borderBottom: '1px solid rgba(0, 255, 0, 0.2)'
                  }}
                  onMouseEnter={(e) => e.target.style.background = 'rgba(0, 255, 0, 0.1)'}
                  onMouseLeave={(e) => e.target.style.background = 'transparent'}
                >
                  {'>'} {u.username}
                </button>
              ))}
            </div>
          )}
        </div>

        {selectedUser && (
          <div style={{ padding: '12px', background: 'rgba(0, 255, 0, 0.1)', border: '1px solid #0F0', borderRadius: '6px', marginBottom: '16px', fontFamily: 'monospace', color: '#0F0' }}>
            {'>'} SENDING TO: <strong>{selectedUser.username}</strong>
            <button onClick={() => setSelectedUser(null)} style={{ marginLeft: '12px', background: 'transparent', border: 'none', color: '#0F0', cursor: 'pointer', fontSize: '16px' }}>✕</button>
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
            marginBottom: '16px'
          }}>
            ⚠️ {error}
          </div>
        )}

        {successMessage && (
          <div style={{
            padding: '16px',
            background: 'rgba(0, 255, 0, 0.2)',
            border: '2px solid #0F0',
            borderRadius: '8px',
            color: '#0F0',
            fontFamily: 'monospace',
            fontSize: '13px',
            marginBottom: '16px'
          }}>
            <div style={{ marginBottom: '12px' }}>{successMessage}</div>
            <div style={{ 
              display: 'flex', 
              alignItems: 'center', 
              gap: '8px',
              padding: '8px',
              background: 'rgba(0, 0, 0, 0.5)',
              borderRadius: '6px'
            }}>
              <span>📧 Share key via:</span>
              <button
                onClick={() => {
                  const sentKey = window.lastSentKey || 'your-key';
                  const sentAlgorithm = window.lastSentAlgorithm || 'caesar';
                  const message = `Hi! I sent you an encrypted message on CyberEncrypt. Use this key to decrypt it: ${sentKey}\n\nAlgorithm: ${sentAlgorithm}`;
                  navigator.clipboard.writeText(message);
                  alert('Message copied to clipboard! You can now paste and send it to the recipient.');
                }}
                style={{
                  padding: '4px 12px',
                  background: '#0F0',
                  border: 'none',
                  borderRadius: '4px',
                  color: '#000',
                  fontSize: '11px',
                  fontWeight: '700',
                  cursor: 'pointer',
                  fontFamily: 'monospace'
                }}
              >
                📋 COPY MESSAGE
              </button>
            </div>
          </div>
        )}

        <div className="grid-2">
          <div className="form-group">
            <label className="form-label" style={{ color: '#0F0', fontFamily: 'monospace' }}>ALGORITHM</label>
            <select value={algorithm} onChange={(e) => setAlgorithm(e.target.value)} className="form-select" style={{ fontFamily: 'monospace' }}>
              <option value="caesar">Caesar</option>
              <option value="transposition">Transposition</option>
              <option value="substitution">Substitution</option>
              <option value="AES-256">AES-256</option>
            </select>
          </div>
          <div className="form-group">
            <label className="form-label" style={{ color: '#0F0', fontFamily: 'monospace' }}>KEY (Share this with recipient!)</label>
            <input
              type={algorithm === 'substitution' || algorithm === 'AES-256' ? 'text' : 'number'}
              value={key}
              onChange={(e) => setKey(e.target.value)}
              className="form-input"
              placeholder={algorithm === 'AES-256' ? '32-character key (UTF-8)' : 'Enter key...'}
              style={{ fontFamily: 'monospace' }}
            />
          </div>
        </div>

        <div className="form-group">
          <label className="form-label" style={{ color: '#0F0', fontFamily: 'monospace' }}>MESSAGE</label>
          <textarea
            value={newMessage}
            onChange={(e) => setNewMessage(e.target.value)}
            className="form-textarea"
            placeholder="Type your secret message..."
            rows="4"
            style={{ fontFamily: 'monospace' }}
          />
        </div>

        <button
          onClick={sendMessage}
          disabled={loading || !selectedUser || !newMessage.trim() || !key.trim()}
          className="btn btn-primary btn-full"
          style={{ fontFamily: 'monospace', fontWeight: '900' }}
        >
          {loading ? '⏳ SENDING...' : '📤 SEND ENCRYPTED MESSAGE'}
        </button>
      </div>

      <div className="card">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
          <h2 className="card-title" style={{ margin: 0, fontFamily: 'monospace' }}>💬 YOUR MESSAGES</h2>
          
          <div style={{ display: 'flex', gap: '8px' }}>
            {['all', 'received', 'sent'].map(tab => (
              <button
                key={tab}
                onClick={() => setActiveTab(tab)}
                style={{
                  padding: '8px 16px',
                  background: activeTab === tab ? 'rgba(0, 255, 0, 0.2)' : 'transparent',
                  border: '2px solid #0F0',
                  borderRadius: '6px',
                  color: '#0F0',
                  fontFamily: 'monospace',
                  fontSize: '12px',
                  fontWeight: '700',
                  cursor: 'pointer',
                  textTransform: 'uppercase'
                }}
              >
                {tab} ({tab === 'all' ? messages.length : tab === 'received' ? receivedMessages.length : sentMessages.length})
              </button>
            ))}
          </div>
        </div>
        
        {displayMessages.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '60px 20px', color: '#0F0', fontFamily: 'monospace' }}>
            <div style={{ fontSize: '64px', marginBottom: '16px' }}>📭</div>
            <p style={{ fontSize: '16px' }}>NO MESSAGES YET</p>
            <p style={{ fontSize: '14px' }}>{'>'} Send your first encrypted message above_</p>
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            {displayMessages.map(msg => {
              const senderId = msg.sender?._id || msg.sender;
              const recipientId = msg.recipient?._id || msg.recipient;
              const userId = user?.id || user?._id;
              
              const isSent = senderId && (senderId.toString() === userId?.toString());
              const isDecrypted = decryptedMessages[msg._id];
              
              const senderUsername = msg.sender?.username || 'Unknown User';
              const recipientUsername = msg.recipient?.username || 'Unknown User';

              return (
                <div
                  key={msg._id}
                  style={{
                    padding: '16px',
                    background: 'rgba(0, 0, 0, 0.8)',
                    border: `2px solid ${isSent ? '#0F0' : 'rgba(0, 255, 0, 0.5)'}`,
                    borderRadius: '8px',
                    borderLeft: `4px solid ${isSent ? '#0F0' : 'rgba(0, 255, 0, 0.5)'}`
                  }}
                >
                  <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '12px', fontFamily: 'monospace' }}>
                    <div>
                      <span style={{ fontSize: '14px', fontWeight: '600', color: '#0F0' }}>
                        {isSent ? '📤 TO: ' : '📥 FROM: '}{isSent ? recipientUsername : senderUsername}
                      </span>
                      {isSent && (
                        <div style={{ fontSize: '12px', color: 'rgba(0, 255, 0, 0.7)', marginTop: '4px' }}>
                          🔑 Key: {msg.key}
                          <button
                            onClick={() => copyToClipboard(msg.key, 'Key')}
                            style={{
                              marginLeft: '8px',
                              padding: '2px 8px',
                              background: 'rgba(0, 255, 0, 0.1)',
                              border: '1px solid #0F0',
                              borderRadius: '4px',
                              color: '#0F0',
                              fontSize: '10px',
                              cursor: 'pointer',
                              fontFamily: 'monospace'
                            }}
                          >
                            📋 COPY
                          </button>
                        </div>
                      )}
                    </div>
                    <div style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
                      <span style={{ fontSize: '11px', padding: '4px 8px', background: 'rgba(0, 255, 0, 0.2)', borderRadius: '4px', color: '#0F0' }}>
                        {msg.algorithm}
                      </span>
                      <span style={{ fontSize: '12px', color: 'rgba(0, 255, 0, 0.7)' }}>
                        {new Date(msg.createdAt).toLocaleString()}
                      </span>
                    </div>
                  </div>

                  <div className="output-box" style={{ marginBottom: '12px', fontSize: '12px', fontFamily: 'monospace' }}>
                    {msg.encryptedText}
                  </div>

                  {isDecrypted && (
                    <div style={{ padding: '12px', background: 'rgba(0, 255, 0, 0.1)', border: '1px solid #0F0', borderRadius: '6px', marginBottom: '12px', fontFamily: 'monospace' }}>
                      <div style={{ fontSize: '11px', color: '#0F0', marginBottom: '4px', fontWeight: '600' }}>
                        ✓ DECRYPTED:
                      </div>
                      <div style={{ fontSize: '14px', color: '#0F0' }}>
                        {isDecrypted}
                      </div>
                    </div>
                  )}

                  <button
                    onClick={() => decryptMessage(msg._id, isSent ? msg.key : null)}
                    className="btn btn-secondary"
                    style={{ padding: '8px 16px', fontSize: '13px', fontFamily: 'monospace' }}
                    disabled={isDecrypted}
                  >
                    {isDecrypted ? '✓ DECRYPTED' : '🔓 DECRYPT MESSAGE'}
                  </button>
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}

export default MessageBox;