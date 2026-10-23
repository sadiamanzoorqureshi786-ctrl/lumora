const express = require('express');
const router = express.Router();
const auth = require('../middleware/authMiddleware');
const Message = require('../models/Message');
const User = require('../models/User');
const { encrypt, decrypt } = require('../utils/encryption');
const { blockchainInstance } = require('../blockchain/Blockchain');

// Send encrypted message
router.post('/send', auth, async (req, res) => {
  try {
    const { recipient, message, algorithm, key } = req.body;

    // Validate inputs
    if (!recipient || !message || !algorithm || !key) {
      return res.status(400).json({ 
        error: 'Missing required fields',
        required: ['recipient', 'message', 'algorithm', 'key']
      });
    }

    // Find recipient user
    const recipientUser = await User.findOne({ username: recipient });
    if (!recipientUser) {
      return res.status(404).json({ error: 'Recipient not found' });
    }

    let encryptedText = message; // Assume client encrypted it (for classical ciphers)
    let iv = null;

    // If AES or RSA, the backend handles the encryption
    if (algorithm === 'AES-256' || algorithm === 'RSA') {
      const encryptResult = encrypt(message, algorithm, key);
      
      if (typeof encryptResult === 'object' && encryptResult.encrypted) {
        encryptedText = encryptResult.encrypted;
        iv = encryptResult.iv || null;
      } else {
        encryptedText = encryptResult;
      }
    }

    // Create message in database
    // SECURITY FIX: Removed originalText to maintain zero-knowledge architecture.
    // We also don't store the encryption key in the database; the user must provide it to decrypt.
    const newMessage = new Message({
      sender: req.user._id,
      recipient: recipientUser._id,
      encryptedText: encryptedText,
      algorithm: algorithm,
      iv: iv
    });

    await newMessage.save();

    // Add to blockchain
    blockchainInstance.addBlock({
      type: 'MESSAGE',
      sender: req.user.username,
      recipient: recipient,
      algorithm: algorithm,
      timestamp: new Date().toISOString(),
      messageId: newMessage._id.toString()
    });

    res.status(201).json({
      success: true,
      message: 'Message sent successfully',
      data: {
        id: newMessage._id,
        encryptedText: encryptedText,
        algorithm: algorithm
      }
    });

  } catch (error) {
    console.error('Message send error:', error);
    res.status(500).json({ 
      error: 'Failed to send message',
      details: error.message 
    });
  }
});

// Get received messages
router.get('/received', auth, async (req, res) => {
  try {
    const messages = await Message.find({ recipient: req.user._id })
      .populate('sender', 'username profilePic')
      .sort({ createdAt: -1 })
      .limit(50);

    res.json(messages);
  } catch (error) {
    console.error('Get messages error:', error);
    res.status(500).json({ error: 'Failed to fetch messages' });
  }
});

// Get unread message count
router.get('/unread-count', auth, async (req, res) => {
  try {
    const count = await Message.countDocuments({ 
      recipient: req.user._id,
      isRead: false 
    });
    res.json({ count });
  } catch (error) {
    console.error('Unread count error:', error);
    res.status(500).json({ error: 'Failed to get unread count' });
  }
});

// Get sent messages
router.get('/sent', auth, async (req, res) => {
  try {
    const messages = await Message.find({ sender: req.user._id })
      .populate('recipient', 'username profilePic')
      .sort({ createdAt: -1 })
      .limit(50);

    res.json(messages);
  } catch (error) {
    console.error('Get sent messages error:', error);
    res.status(500).json({ error: 'Failed to fetch sent messages' });
  }
});

// Decrypt a message
router.post('/decrypt', auth, async (req, res) => {
  try {
    const { messageId, key } = req.body;

    const message = await Message.findById(messageId);
    
    if (!message) {
      return res.status(404).json({ error: 'Message not found' });
    }

    // Check if user is sender or recipient
    if (message.sender.toString() !== req.user._id.toString() && 
        message.recipient.toString() !== req.user._id.toString()) {
      return res.status(403).json({ error: 'Unauthorized' });
    }

    // Decrypt the message (Backend only handles AES/RSA)
    const decryptedText = decrypt(
      message.encryptedText,
      message.algorithm,
      key,
      message.iv
    );

    res.json({ 
      success: true,
      decryptedText: decryptedText,
      algorithm: message.algorithm
    });

  } catch (error) {
    console.error('Decrypt error:', error);
    res.status(500).json({ 
      error: 'Failed to decrypt message',
      details: error.message 
    });
  }
});

module.exports = router;