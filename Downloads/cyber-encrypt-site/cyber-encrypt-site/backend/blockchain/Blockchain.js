// backend/blockchain/Blockchain.js
const crypto = require('crypto');

class Block {
  constructor(index, timestamp, data, previousHash = '') {
    this.index = index;
    this.timestamp = timestamp;
    this.data = data;
    this.previousHash = previousHash;
    this.nonce = 0;
    this.hash = this.calculateHash();
  }

  calculateHash() {
    return crypto
      .createHash('sha256')
      .update(
        this.index +
        this.previousHash +
        this.timestamp +
        JSON.stringify(this.data) +
        this.nonce
      )
      .digest('hex');
  }

  mineBlock(difficulty) {
    while (this.hash.substring(0, difficulty) !== Array(difficulty + 1).join('0')) {
      this.nonce++;
      this.hash = this.calculateHash();
    }
    console.log(`Block mined: ${this.hash}`);
  }
}

class Blockchain {
  constructor() {
    this.chain = [this.createGenesisBlock()];
    this.difficulty = 2; // Mining difficulty
    this.pendingTransactions = [];
  }

  createGenesisBlock() {
    return new Block(0, Date.now(), { message: 'Genesis Block' }, '0');
  }

  getLatestBlock() {
    return this.chain[this.chain.length - 1];
  }

  addBlock(data) {
    const newBlock = new Block(
      this.chain.length,
      Date.now(),
      data,
      this.getLatestBlock().hash
    );
    
    newBlock.mineBlock(this.difficulty);
    this.chain.push(newBlock);
    
    return newBlock;
  }

  // Add encrypted message to blockchain
  addEncryptedMessage(messageData) {
    const blockData = {
      messageId: messageData.messageId,
      sender: messageData.sender,
      recipient: messageData.recipient,
      algorithm: messageData.algorithm,
      timestamp: messageData.timestamp,
      hash: this.hashMessage(messageData.encryptedText)
    };

    return this.addBlock(blockData);
  }

  hashMessage(message) {
    return crypto.createHash('sha256').update(message).digest('hex');
  }

  // Verify blockchain integrity
  isChainValid() {
    for (let i = 1; i < this.chain.length; i++) {
      const currentBlock = this.chain[i];
      const previousBlock = this.chain[i - 1];

      // Check if current block hash is valid
      if (currentBlock.hash !== currentBlock.calculateHash()) {
        return false;
      }

      // Check if previous hash matches
      if (currentBlock.previousHash !== previousBlock.hash) {
        return false;
      }
    }
    return true;
  }

  // Get all blocks
  getAllBlocks() {
    return this.chain;
  }

  // Get block by index
  getBlock(index) {
    return this.chain[index];
  }

  // Search blockchain for message
  findMessageBlock(messageId) {
    return this.chain.find(block => 
      block.data && block.data.messageId === messageId
    );
  }
}

// Create singleton instance
const blockchainInstance = new Blockchain();

module.exports = { Blockchain, blockchainInstance };