const crypto = require('crypto');
const nodemailer = require('nodemailer');
const jwt = require('jsonwebtoken');
const User = require('../models/User'); // Adjust path to your User model

// Configure Nodemailer Transporter
const transporter = nodemailer.createTransport({
  service: 'Gmail', // or use SMTP host
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

// --- 1. FORGOT PASSWORD ---
exports.forgotPassword = async (req, res) => {
  const { email } = req.body;

  try {
    const user = await User.findOne({ email });
    if (!user) {
      // For security reasons, don't reveal that the email doesn't exist
      return res.status(200).json({ message: 'If that email exists, a reset link has been sent.' });
    }

    // Generate a secure reset token
    const resetToken = crypto.randomBytes(32).toString('hex');
    const resetTokenHash = crypto.createHash('sha256').update(resetToken).digest('hex');

    // Save hashed token to user with an expiration (e.g., 10 minutes)
    user.resetPasswordToken = resetTokenHash;
    user.resetPasswordExpire = Date.now() + 10 * 60 * 1000;
    await user.save();

    // Create reset URL
    const resetUrl = `${process.env.CLIENT_URL}/reset-password/${resetToken}`;

    // Email options
    const mailOptions = {
      from: `"CyberEncrypt Support" <${process.env.EMAIL_USER}>`,
      to: user.email,
      subject: 'CyberEncrypt - Password Reset Request',
      text: `You requested a password reset. Please click the following link to reset your password: \n\n ${resetUrl} \n\n If you did not request this, please ignore this email.`,
      html: `<p>You requested a password reset.</p><p>Click <a href="${resetUrl}">here</a> to reset your password.</p><p>If you did not request this, please ignore this email.</p>`
    };

    await transporter.sendMail(mailOptions);
    res.status(200).json({ message: 'If that email exists, a reset link has been sent.' });

  } catch (error) {
    console.error('Forgot Password Error:', error);
    res.status(500).json({ message: 'Server error processing request.' });
  }
};

// --- 2. RESET PASSWORD ---
exports.resetPassword = async (req, res) => {
  const { token } = req.params;
  const { password } = req.body;

  try {
    // Hash the incoming token to match the DB
    const resetTokenHash = crypto.createHash('sha256').update(token).digest('hex');

    const user = await User.findOne({
      resetPasswordToken: resetTokenHash,
      resetPasswordExpire: { $gt: Date.now() } // Check if token is not expired
    });

    if (!user) {
      return res.status(400).json({ message: 'Invalid or expired reset token.' });
    }

    // Set new password and clear token fields
    user.password = password; // Make sure your User model pre-save hook hashes this password!
    user.resetPasswordToken = undefined;
    user.resetPasswordExpire = undefined;

    await user.save();

    res.status(200).json({ message: 'Password reset successful. You can now log in.' });

  } catch (error) {
    console.error('Reset Password Error:', error);
    res.status(500).json({ message: 'Server error resetting password.' });
  }
};

// --- 3. VERIFY EMAIL ---
exports.verifyEmail = async (req, res) => {
  const { token } = req.params;

  try {
    // Verify JWT
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findById(decoded.id);

    if (!user) {
      return res.status(400).json({ message: 'Invalid token.' });
    }

    if (user.isVerified) {
      return res.status(200).json({ message: 'Email is already verified.' });
    }

    user.isVerified = true;
    await user.save();

    res.status(200).json({ message: 'Email verified successfully! You can now log in.' });
  } catch (error) {
    console.error('Email Verification Error:', error);
    res.status(400).json({ message: 'Invalid or expired verification link.' });
  }
};

// --- 4. SEND VERIFICATION EMAIL (Call this on Signup) ---
exports.sendVerificationEmail = async (user) => {
  try {
    // Create a JWT token that expires in 1 day
    const emailToken = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: '1d' });
    
    // URL that the frontend/backend will handle
    const verificationUrl = `${process.env.CLIENT_URL}/verify-email/${emailToken}`;

    const mailOptions = {
      from: `"CyberEncrypt Support" <${process.env.EMAIL_USER}>`,
      to: user.email,
      subject: 'CyberEncrypt - Verify Your Email Address',
      html: `<p>Welcome to CyberEncrypt!</p><p>Please verify your email by clicking <a href="${verificationUrl}">here</a>.</p><p>This link will expire in 24 hours.</p>`
    };

    await transporter.sendMail(mailOptions);
  } catch (error) {
    console.error('Send Verification Email Error:', error);
  }
};