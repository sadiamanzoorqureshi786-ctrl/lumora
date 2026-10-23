const express = require('express');
const router = express.Router();
const crypto = require('crypto'); // Required for the improved verify route
const auth = require('../middleware/authMiddleware');
const Block = require('../models/Block');
const { blockchainInstance } = require('../blockchain/Blockchain');

// Save blockchain to MongoDB
const saveBlockchainToMongo = async () => {
  try {
    // Clear existing blocks
    await Block.deleteMany({});

    // Save all blocks from in-memory blockchain
    const blocks = blockchainInstance.chain.map((block, index) => ({
      index: index,
      timestamp: block.timestamp,
      data: block.data,
      previousHash: block.previousHash,
      hash: block.hash,
      nonce: block.nonce || 0
    }));

    await Block.insertMany(blocks);
  } catch (error) {
    console.error('Save blockchain error:', error);
  }
};

// Get full blockchain
router.get('/chain', auth, async (req, res) => {
  try {
    // Get from MongoDB
    const blocks = await Block.find().sort({ index: 1 });

    res.json({
      chain: blocks.length > 0 ? blocks : blockchainInstance.chain,
      length: blocks.length > 0 ? blocks.length : blockchainInstance.chain.length
    });
  } catch (error) {
    console.error('Blockchain fetch error:', error);
    res.status(500).json({ error: 'Failed to fetch blockchain' });
  }
});

// Verify blockchain integrity (IMPROVED - reads directly from DB)
router.get('/verify', auth, async (req, res) => {
  try {
    const blocks = await Block.find().sort({ index: 1 });
    let isValid = true;

    for (let i = 1; i < blocks.length; i++) {
      const current = blocks[i];
      const previous = blocks[i - 1];

      // Recalculate hash from DB data
      const recalculatedHash = crypto.createHash('sha256')
        .update(current.index + current.previousHash + current.timestamp + JSON.stringify(current.data) + (current.nonce || 0))
        .digest('hex');

      // If the stored hash doesn't match recalculated hash, or if links are broken
      if (current.hash !== recalculatedHash || current.previousHash !== previous.hash) {
        isValid = false;
        break;
      }
    }

    res.json({ 
      valid: isValid, 
      message: isValid ? 'Blockchain is valid' : 'Blockchain has been tampered with' 
    });
  } catch (error) {
    console.error('Blockchain verify error:', error);
    res.status(500).json({ error: 'Failed to verify blockchain' });
  }
});

// Add new block (called automatically when message is sent)
router.post('/add-block', auth, async (req, res) => {
  try {
    const { data } = req.body;

    blockchainInstance.addBlock(data);

    // Save to MongoDB
    await saveBlockchainToMongo();

    res.json({
      success: true,
      block: blockchainInstance.getLatestBlock()
    });
  } catch (error) {
    console.error('Add block error:', error);
    res.status(500).json({ error: 'Failed to add block' });
  }
});

module.exports = router;