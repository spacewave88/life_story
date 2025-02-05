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
  name: {
    type: String,
    required: false
  },
  // Add other fields as needed
});

// Export the model
module.exports = mongoose.model('User', userSchema);