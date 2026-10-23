const mongoose = require('mongoose');

const logSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  action: {
    type: String,
    enum: ['encrypt', 'decrypt', 'message_sent', 'message_received'],
    required: true
  },
  algorithm: {
    type: String,
    enum: ['caesar', 'transposition', 'substitution']
  },
  inputText: {
    type: String
  },
  outputText: {
    type: String
  },
  key: {
    type: String
  },
  timestamp: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Log', logSchema);