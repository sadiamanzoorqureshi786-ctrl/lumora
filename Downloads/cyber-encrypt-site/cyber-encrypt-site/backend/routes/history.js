// backend/routes/history.js
const express = require('express');
const router = express.Router();
const auth = require('../middleware/authMiddleware');
const Message = require('../models/Message');

// Get user's encryption history
router.get('/', auth, async (req, res) => {
  try {
    // Get both sent and received messages
    const sentMessages = await Message.find({ sender: req.user._id })
      .populate('recipient', 'username')
      .sort({ createdAt: -1 })
      .limit(100);

    const receivedMessages = await Message.find({ recipient: req.user._id })
      .populate('sender', 'username')
      .sort({ createdAt: -1 })
      .limit(100);

    // Combine and sort by date
    const allMessages = [...sentMessages, ...receivedMessages]
      .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

    // Format the history
    const history = allMessages.map(msg => ({
      _id: msg._id,
      type: msg.sender._id.toString() === req.user._id.toString() ? 'sent' : 'received',
      sender: msg.sender.username,
      recipient: msg.recipient.username,
      algorithm: msg.algorithm,
      encryptedText: msg.encryptedText,
      createdAt: msg.createdAt
    }));

    res.json(history);
  } catch (error) {
    console.error('History fetch error:', error);
    res.status(500).json({ error: 'Failed to fetch history' });
  }
});

module.exports = router;