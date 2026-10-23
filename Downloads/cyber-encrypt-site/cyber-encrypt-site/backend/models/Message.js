const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema({
  sender: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  recipient: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  originalText: {
    type: String,
    required: true
  },
  encryptedText: {
    type: String,
    required: true
  },
  algorithm: {
    type: String,
    enum: ['caesar', 'transposition', 'substitution', 'AES-256', 'RSA'],
    required: true
  },
  key: {
    type: String,
    required: true
  },
  iv: {
    type: String,
    required: false
  },
  isRead: {
    type: Boolean,
    default: false
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Message', messageSchema);