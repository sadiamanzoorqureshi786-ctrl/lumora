const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const session = require('express-session');
const passport = require('passport');
const path = require('path'); // <-- ADDED: Required for serving static files
require('dotenv').config();

const authRoutes = require('./routes/auth');
const messageRoutes = require('./routes/messages');
const historyRoutes = require('./routes/history');
const settingsRoutes = require('./routes/settings');
const userRoutes = require('./routes/users');
const encryptionRoutes = require('./routes/encryption');
const blockchainRoutes = require('./routes/blockchain');

const app = express();

// ── CORS ────────────────────────────────────────────────────────────────
const allowedOrigins = [
  // 'https://your-production-domain.com',
];

app.use(cors({
  origin: (origin, callback) => {
    const isLocalDev = !origin || /^http:\/\/(localhost|127\.0\.0\.1|192\.168\.\d+\.\d+|10\.\d+\.\d+\.\d+):\d+$/.test(origin);
    if (isLocalDev || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ── SERVE STATIC FILES ──────────────────────────────────────────────────
// <-- ADDED: This allows the Flutter app to fetch uploaded profile pictures
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Session middleware
app.use(session({
  secret: process.env.SESSION_SECRET || 'fallback_secret',
  resave: false,
  saveUninitialized: false,
  cookie: { secure: false, maxAge: 24 * 60 * 60 * 1000 }
}));

// Passport middleware
app.use(passport.initialize());
app.use(passport.session());

// MongoDB Connection
mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log('✅ MongoDB Connected'))
  .catch(err => console.error('❌ MongoDB Connection Error:', err));

// Initialize Blockchain
const { blockchainInstance } = require('./blockchain/Blockchain');
console.log('✅ Blockchain Initialized');
console.log('✅ Genesis Block Hash:', blockchainInstance.getLatestBlock().hash);

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/messages', messageRoutes);
app.use('/api/history', historyRoutes);
app.use('/api/settings', settingsRoutes);
app.use('/api/users', userRoutes);
app.use('/api/blockchain', blockchainRoutes);
app.use('/api', encryptionRoutes);

// Health check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'OK',
    message: 'Server is running',
    blockchain: {
      blocks: blockchainInstance.chain.length,
      valid: blockchainInstance.isChainValid(),
      latestHash: blockchainInstance.getLatestBlock().hash
    }
  });
});

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

const PORT = process.env.PORT || 5001;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`⛓️  Blockchain Status: ACTIVE`);
  console.log(`📦 Total Blocks: ${blockchainInstance.chain.length}`);
});