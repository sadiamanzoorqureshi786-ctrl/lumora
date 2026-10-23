const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const authMiddleware = require('../middleware/authMiddleware');

// Helper function to extract user ID securely
const getUserId = (req) => {
    if (req.user) {
        return req.user.userId || req.user.id || req.user._id;
    }
    // Fallback to extracting from token directly
    const token = req.headers.authorization?.split(' ')[1];
    if (token) {
        try {
            const decoded = jwt.verify(token, process.env.JWT_SECRET);
            return decoded.userId || decoded.id;
        } catch (e) {
            return null;
        }
    }
    return null;
};

// Ensure uploads directory exists
const uploadDir = path.join(__dirname, '..', 'uploads', 'profiles');
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, uploadDir),
    filename: (req, file, cb) => {
        // Fallback to .jpg if extension is missing (common in Flutter Web)
        const ext = path.extname(file.originalname) || '.jpg';
        const userId = getUserId(req) || 'unknown';
        cb(null, `user-${userId}-${Date.now()}${ext}`);
    }
});

const upload = multer({ 
    storage: storage,
    limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
    fileFilter: (req, file, cb) => {
        // Robust check: just verify it's an image mimetype
        if (file.mimetype && file.mimetype.startsWith('image/')) {
            return cb(null, true);
        }
        cb(new Error('Error: Images Only!'));
    }
});

// GET /api/settings
router.get('/', authMiddleware, async (req, res) => {
  try {
    const userId = getUserId(req);
    const user = await User.findById(userId).select('-password');
    res.json(user);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// PUT /api/settings/profile (Handles file uploads with error wrapper)
router.put('/profile', authMiddleware, (req, res, next) => {
    upload.single('profilePic')(req, res, (err) => {
        if (err) {
            // Handle Multer errors (like "Images Only!" or file size limit) safely
            return res.status(400).json({ error: err.message });
        }
        next();
    });
}, async (req, res) => {
  try {
    const userId = getUserId(req);
    const { username } = req.body;
    const user = await User.findById(userId);

    if (!user) return res.status(404).json({ error: 'User not found' });

    if (username) user.username = username;
    
    if (req.file) {
      // Delete old photo if it exists
      if (user.profilePic && user.profilePic.startsWith('/uploads/')) {
        const oldPath = path.join(__dirname, '..', user.profilePic);
        if (fs.existsSync(oldPath)) fs.unlinkSync(oldPath);
      }
      user.profilePic = `/uploads/profiles/${req.file.filename}`;
    }

    await user.save();
    
    const updatedUser = await User.findById(userId).select('-password');
    res.json(updatedUser);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// PUT /api/settings/preferences
router.put('/preferences', authMiddleware, async (req, res) => {
  try {
    const userId = getUserId(req);
    
    if (!userId) {
        return res.status(401).json({ error: 'User ID missing from token' });
    }

    const { notificationsEnabled, onlineStatusEnabled, readReceiptsEnabled } = req.body;
    
    const user = await User.findByIdAndUpdate(
      userId, 
      { 
        $set: {
          notificationsEnabled,
          onlineStatusEnabled,
          readReceiptsEnabled
        }
      },
      { new: true, runValidators: true }
    ).select('-password');

    if (!user) return res.status(404).json({ error: 'User not found' });

    res.json(user);
  } catch (error) {
    console.error('Preferences update error:', error);
    res.status(500).json({ error: error.message });
  }
});

// PUT /api/settings/password
router.put('/password', authMiddleware, async (req, res) => {
  try {
    const userId = getUserId(req);
    const { currentPassword, newPassword } = req.body;
    
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ error: 'User not found' });
    
    const isMatch = await user.comparePassword(currentPassword);
    if (!isMatch) {
      return res.status(400).json({ error: 'Current password is incorrect' });
    }

    user.password = newPassword;
    await user.save();

    res.json({ message: 'Password updated successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;