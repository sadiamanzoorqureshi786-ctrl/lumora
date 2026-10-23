// backend/models/History.js
const mongoose = require('mongoose');

const historySchema = new mongoose.Schema({
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
        enum: ['caesar', 'transposition', 'substitution', 'AES-256', 'RSA'],
        required: true
    },
    inputText: {
        type: String,
        required: true
    },
    outputText: {
        type: String,
        required: true
    },
    key: {
        type: String,
        required: true
    },
    timestamp: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('History', historySchema);