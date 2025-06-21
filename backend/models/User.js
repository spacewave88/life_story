const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  uid: { type: String, required: true, unique: true },
  email: { type: String },
  firstName: { type: String },
  lastName: { type: String },
  dateOfBirth: { type: Date },
  lifeQuestions: { type: Map, of: String, default: {} }, // Must be a Map
  chatHistory: [{ role: String, content: String, timestamp: { type: Date, default: Date.now } }],
  settings: { postProcessStory: { type: Boolean, default: true } },
});

module.exports = mongoose.model('User', userSchema);