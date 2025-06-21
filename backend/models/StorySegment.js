// ~/life_app/backend/models/StorySegment.js

const mongoose = require('mongoose');

const StorySegmentSchema = new mongoose.Schema({
    _id: String, // Unique segment ID
    uid: String,
    content: String, // Raw user input
    processedContent: String, // Post-processed story
    category: String, // e.g., "childhood", "adulthood"
    timestamp: Date,
    order: Number // For chronological sorting (e.g., 1 for earliest event)
});

// Export the model
module.exports = mongoose.model('StorySegment', StorySegmentSchema);