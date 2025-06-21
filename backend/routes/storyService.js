const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');
const User = require('../models/StorySegment'); // Assuming your StorySegment model is in '/models/'

// Middleware to verify Firebase token
const verifyToken = async (req, res, next) => {
  try {
    const idToken = req.headers.authorization?.split('Bearer ')[1];
    if (!idToken) {
      console.log('No token provided');
      return res.status(401).send('No token provided');
    }
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    req.user = decodedToken; // Attach decoded token to request
    next();
  } catch (error) {
    console.error('Token verification failed:', error);
    res.status(403).send('Unauthorized');
  }
};

// Create Story Segment Endpoint
const axios = require('axios');
async function processStorySegment(segment) {
  const user = await User.findOne({ uid: segment.uid });
  if (!user.settings.postProcessStory) return segment.content;

  const response = await axios.post(
    'https://api.openai.com/v1/chat/completions',
    {
      model: 'gpt-3.5-turbo',
      messages: [{ role: 'system', content: `Turn this into a cohesive story snippet: "${segment.content}"` }],
    },
    { headers: { 'Authorization': `Bearer $OPENAI_KEY` } }
  );
  return response.data.choices[0].message.content;
}
module.exports = router;