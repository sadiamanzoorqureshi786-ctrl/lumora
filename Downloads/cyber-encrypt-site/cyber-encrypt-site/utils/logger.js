const Log = require('../models/Log');

const createLog = async (userId, action, details = {}) => {
  try {
    const log = new Log({
      user: userId,
      action,
      algorithm: details.algorithm,
      inputText: details.inputText,
      outputText: details.outputText,
      key: details.key
    });
    
    await log.save();
    return log;
  } catch (error) {
    console.error('Error creating log:', error);
  }
};

module.exports = { createLog };