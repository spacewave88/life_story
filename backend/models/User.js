// ~/life_app/backend/models/User.js

const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  uid: {
    type: String,
    required: true,
    unique: true,
  },
  email: {
    type: String,
    required: true, 
    unique: true,
    sparse: true, // Allows multiple null values
  },
  firstName: {
    type: String,
    required: false, // Changed to optional
  },
  lastName: {
    type: String,
    required: false, // Changed to optional
  },
  dateOfBirth: {
    type: Date,
    required: false, // Changed to optional
  },
  lifeQuestions: {
    type: Map,
    of: String,
    default: {}, // Matches client data (e.g., {"What is your favorite childhood memory?": "Playing outside"})
  },
});

// Export the model
module.exports = mongoose.model('User', userSchema);