const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');
const User = require('../models/User'); // Assuming your User model is in '/models/User.js'

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

// Create User Endpoint (Not typically used for profile creation post-registration)
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
    }
    res.status(201).send({ user: user.toJSON() });
  } catch (error) {
    console.error('Error creating user:', error);
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

// Save or Update User Profile Endpoint (NEW - Fixes 404)
router.post('/:uid/profile', verifyToken, async (req, res) => {
  try {
    if (req.user.uid !== req.params.uid) {
      return res.status(403).send('Unauthorized');
    }

    const user = await User.findOne({ uid: req.params.uid });
    const profileData = req.body; // Expecting tempProfile data (e.g., answers)

    if (!user) {
      // Create new user if not found
      const newUser = new User({
        uid: req.params.uid,
        email: req.user.email,
        lifeQuestions: profileData, // Store answers directly
      });
      await newUser.save();
      return res.status(201).send({ user: newUser.toJSON() });
    }

    // Update existing user's profile with answers
    user.lifeQuestions = { ...user.lifeQuestions, ...profileData };
    await user.save();
    res.status(200).send({ user: user.toJSON() });
  } catch (error) {
    console.error('Error saving profile:', error);
    res.status(500).send('Server error');
  }
});

// Save Answers Endpoint (Existing, unchanged for now)
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
    // Add logic here if you need to clear server-side session data
    res.status(200).send({ message: 'Logged out successfully' });
  } catch (error) {
    console.error('Error during logout:', error);
    res.status(500).send('Server error');
  }
});

module.exports = router;