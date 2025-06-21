
const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');
const User = require('../models/User'); // Assuming your User model is in '/models/User.js'
const StorySegment = require('../models/StorySegment'); // Ensure this exists

// Middleware to verify Firebase token
const verifyToken = async (req, res, next) => {
  try {
    const idToken = req.headers.authorization?.split('Bearer ')[1];
    if (!idToken) {
      console.log('No token provided');
      return res.status(401).send('No token provided');
    }
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    req.user = decodedToken;
    next();
  } catch (error) {
    console.error('Token verification failed:', error);
    res.status(403).send('Unauthorized');
  }
};

// Create User Endpoint
router.post('/', verifyToken, async (req, res) => {
  try {
    const uid = req.user.uid;
    const { firstName, lastName, dateOfBirth } = req.body;

    let user = await User.findOne({ uid });
    if (!user) {
      user = new User({
        uid,
        email: req.user.email,
        firstName,
        lastName,
        dateOfBirth: dateOfBirth ? new Date(dateOfBirth) : undefined,
      });
      await user.save();
      res.status(201).send({ user: user.toJSON() });
    } else {
      console.log('User already exists, skipping creation:', uid);
      res.status(200).send({ user: user.toJSON() }); // Return existing user
    }
  } catch (error) {
    console.error('Error creating user:', error.message, error.stack);
    res.status(500).send('Server error');
  }
});

// Get User Profile Endpoint
router.get('/:uid', verifyToken, async (req, res) => {
  try {
    if (req.user.uid !== req.params.uid) {
      console.log('Unauthorized UID mismatch');
      return res.status(403).send('Unauthorized');
    }

    const user = await User.findOne({ uid: req.params.uid });
    if (user) {
      console.log('User fetched:', user.toJSON());
      res.status(200).send({ user: user.toJSON() });
    } else {
      console.log('User not found');
      res.status(404).send('User not found');
    }
  } catch (error) {
    console.error('Error fetching user:', error);
    res.status(500).send('Server error');
  }
});

// Save or Update User Profile Endpoint
router.post('/:uid/profile', verifyToken, async (req, res) => {
  try {
    if (req.user.uid !== req.params.uid) {
      console.log('Unauthorized UID mismatch:', { requestUid: req.params.uid, tokenUid: req.user.uid });
      return res.status(403).send('Unauthorized');
    }

    console.log('Received profile request body:', JSON.stringify(req.body, null, 2));
    const profileData = req.body || {}; // Default to empty object

    // Validate profileData
    if (typeof profileData !== 'object' || profileData === null) {
      console.error('Invalid profileData format:', profileData);
      return res.status(400).send('Invalid profile data format');
    }
    // Ensure all keys and values are strings for lifeQuestions
    const lifeQuestions = profileData.lifeQuestions || {};
    const isValid = Object.entries(lifeQuestions).every(([key, value]) => typeof key === 'string' && typeof value === 'string');
    if (!isValid) {
      console.error('Invalid lifeQuestions values:', lifeQuestions);
      return res.status(400).send('Life questions must contain string keys and values');
    }

    let user = await User.findOne({ uid: req.params.uid });
    if (!user) {
      console.log('User not found, creating new user:', req.params.uid);
      user = new User({
        uid: req.params.uid,
        email: req.user.email,
        firstName: profileData.firstName || undefined,
        lastName: profileData.lastName || undefined,
        dateOfBirth: profileData.dateOfBirth ? new Date(profileData.dateOfBirth) : undefined,
        lifeQuestions: lifeQuestions,
      });
      await user.save();
      console.log('New user created with profile:', user.toJSON());
      return res.status(201).send({ user: user.toJSON() });
    }

    // Update existing user
    if (profileData.firstName) user.firstName = profileData.firstName;
    if (profileData.lastName) user.lastName = profileData.lastName;
    if (profileData.dateOfBirth) user.dateOfBirth = new Date(profileData.dateOfBirth);
    if (Object.keys(lifeQuestions).length > 0) {
      user.lifeQuestions = { ...user.lifeQuestions, ...lifeQuestions };
    }
    await user.save();
    console.log('Profile updated successfully:', user.toJSON());
    res.status(200).send({ user: user.toJSON() });
  } catch (error) {
    console.error('Error saving profile:', error.message, error.stack);
    res.status(500).send(`Server error: ${error.message}`);
  }
});

// Save Answers Endpoint (Optional: Could be consolidated with /profile)
router.post('/:uid/answers', verifyToken, async (req, res) => {
  try {
    if (req.user.uid !== req.params.uid) {
      return res.status(403).send('Unauthorized');
    }

    const user = await User.findOne({ uid: req.params.uid });
    if (!user) {
      return res.status(404).send('User not found');
    }

    user.lifeQuestions = req.body; // Overwrites existing answers
    await user.save();
    res.status(200).send({ message: 'Answers saved successfully' });
  } catch (error) {
    console.error('Error saving answers:', error);
    res.status(500).send('Server error');
  }
});

// Logout Clear Backend Session
router.post('/logout', verifyToken, async (req, res) => {
  try {
    console.log('Token verified for logout, UID:', req.user.uid);
    res.status(200).send({ message: 'Logged out successfully' });
  } catch (error) {
    console.error('Error during logout:', error);
    res.status(500).send('Server error');
  }
});

// AI Chat Endpoint
router.post('/:uid/chat', verifyToken, async (req, res) => {
  try {
    if (req.user.uid !== req.params.uid) return res.status(403).send('Unauthorized');
    const user = await User.findOne({ uid: req.params.uid });
    if (!user) return res.status(404).send('User not found');

    user.chatHistory = req.body.messages;
    await user.save();
    res.status(200).send({ message: 'Chat saved' });
  } catch (error) {
    console.error('Error saving chat:', error);
    res.status(500).send('Server error');
  }
});

// Story Segment Endpoints
router.post('/:uid/segments', verifyToken, async (req, res) => {
  try {
    if (req.user.uid !== req.params.uid) return res.status(403).send('Unauthorized');
    const { rawContent, processedContent, category, order } = req.body;
    const segment = { uid: req.params.uid, rawContent, processedContent, category, order, timestamp: new Date() };
    await StorySegment.create(segment);
    res.status(200).send(segment);
  } catch (error) {
    console.error('Error creating story segment:', error);
    res.status(500).send('Server error');
  }
});

router.get('/:uid/story', verifyToken, async (req, res) => {
  try {
    if (req.user.uid !== req.params.uid) return res.status(403).send('Unauthorized');
    const segments = await StorySegment.find({ uid: req.params.uid }).sort('order');
    res.status(200).send(segments);
  } catch (error) {
    console.error('Error fetching story:', error);
    res.status(500).send('Server error');
  }
});

router.post('/:uid/story', verifyToken, async (req, res) => {
  try {
    if (req.user.uid !== req.params.uid) return res.status(403).send('Unauthorized');
    const { segments } = req.body;
    for (const seg of segments) {
      await StorySegment.updateOne({ _id: seg._id, uid: req.params.uid }, { processedContent: seg.processedContent });
    }
    res.status(200).send({ message: 'Story updated' });
  } catch (error) {
    console.error('Error updating story:', error);
    res.status(500).send('Server error');
  }
});

module.exports = router;