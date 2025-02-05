const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');
const User = require('../models/User'); // Assuming your User model is in '/models/User.js'

// Create User Endpoint
router.post('/', async (req, res) => {
  try {
    const idToken = req.headers.authorization?.split(' ')[1]; // Assumes 'Bearer <token>'
    if (!idToken) {
      return res.status(401).send('No token provided');
    }

    const decodedToken = await admin.auth().verifyIdToken(idToken);
    const uid = decodedToken.uid;

    // Check if user already exists
    let user = await User.findOne({ uid });
    if (!user) {
      user = new User({
        uid: uid,
        email: decodedToken.email,
        name: decodedToken.name || 'Anonymous',
      });
      await user.save();
    }

    res.status(201).send({ user: user.toJSON() });
  } catch (error) {
    console.error('Error creating user:', error);
    res.status(403).send('Unauthorized');
  }
});

// Get User Profile Endpoint
router.get('/:uid', async (req, res) => {
  try {
    const idToken = req.headers.authorization?.split(' ')[1];
    if (!idToken) {
      return res.status(401).send('No token provided');
    }

    await admin.auth().verifyIdToken(idToken);

    const user = await User.findOne({ uid: req.params.uid });
    if (user) {
      res.status(200).send(user.toJSON());
    } else {
      res.status(404).send('User not found');
    }
  } catch (error) {
    console.error('Error fetching user:', error);
    res.status(403).send('Unauthorized');
  }
});

// Logout Clear Backend Session
router.post('/logout', async (req, res) => {
    try {
      const idToken = req.headers.authorization?.split(' ')[1];
      if (idToken) {
        await admin.auth().verifyIdToken(idToken); // This will throw if token is invalid or expired
        // Clear session or user-specific data from MongoDB if necessary
        await UserSessionModel.deleteOne({ userId: decodedToken.uid }); // Assuming you have a UserSession model
        res.status(200).send({ message: 'Logged out successfully' });
      } else {
        res.status(401).send('No token provided');
      }
    } catch (error) {
      res.status(403).send('Unauthorized');
    }
  });
module.exports = router;