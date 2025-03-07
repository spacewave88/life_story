// ~/life_app/backend/models/User.js

const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  uid: {
    type: String,
    required: true,
    unique: true
  },
  email: {
    type: String,
    required: true,
    unique: true
  },
  firstName: {
    type: String,
    required: true
  },
  lastName: {
    type: String,
    required: true
  },
  dateOfBirth: {
    type: Date,
    required: true
  },
  lifeQuestions: { 
    type: Map, of: String
  }, 
  // Add other fields as needed
});

// Export the model
module.exports = mongoose.model('User', userSchema);