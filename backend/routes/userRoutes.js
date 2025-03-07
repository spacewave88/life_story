const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');
const User = require('../models/User'); // Assuming your User model is in '/models/User.js'

// Create User Endpoint
router.post('/', async (req, res) => {
  try {
    const idToken = req.headers.authorization?.split(' ')[1]; // Assumes 'Bearer <token>'
    if (!idToken) {
      console.log('No token provided');
      return res.status(401).send('No token provided');
    }

    const decodedToken = await admin.auth().verifyIdToken(idToken);
    const uid = decodedToken.uid;

    // Extract additional fields from request body
    const { firstName, lastName, dateOfBirth } = req.body;

    // Check if user already exists
    let user = await User.findOne({ uid });
    if (!user) {
      user = new User({
        uid: uid,
        email: decodedToken.email,
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: new Date(dateOfBirth), // Ensure it's stored as a Date object
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
      console.log('No token provided');
      return res.status(401).send('No token provided');
    }

    const decodedToken = await admin.auth().verifyIdToken(idToken);
    console.log('Token verified, UID:', decodedToken.uid);

    // Optional: Check if the requesting user matches the requested UID
    if (decodedToken.uid !== req.params.uid) {
      console.log('Unauthorized UID mismatch');
      return res.status(403).send('Unauthorized');
    }

    const user = await User.findOne({ uid: req.params.uid });
    if (user) {
      console.log('User fetched:', user.toJSON());
      res.status(200).send({ user: user.toJSON() }); // Wrap user data in "user" object
    } else {
      console.log('User not found');
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
    if (!idToken) {
      console.log('No token provided');
      return res.status(401).send('No token provided');
    }

    const decodedToken = await admin.auth().verifyIdToken(idToken); // Define decodedToken here
    console.log('Token verified for logout, UID:', decodedToken.uid);

    // Clear session or user-specific data from MongoDB if necessary
    // Assuming you have a UserSessionModel (commented out if not applicable)
    // await UserSessionModel.deleteOne({ userId: decodedToken.uid });
    res.status(200).send({ message: 'Logged out successfully' });
  } catch (error) {
    console.error('Error during logout:', error);
    res.status(403).send('Unauthorized');
  }
});

// Save Answers Endpoint
router.post('/:uid/answers', async (req, res) => {
  try {
    const idToken = req.headers.authorization?.split(' ')[1];
    if (!idToken) return res.status(401).send('No token provided');
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    if (decodedToken.uid !== req.params.uid) return res.status(403).send('Unauthorized');

    const user = await User.findOne({ uid: req.params.uid });
    if (!user) return res.status(404).send('User not found');

    user.lifeQuestions = req.body; // Store answers in lifeQuestions field
    await user.save();
    res.status(200).send({ message: 'Answers saved successfully' });
  } catch (error) {
    console.error('Error saving answers:', error);
    res.status(403).send('Unauthorized');
  }
});
module.exports = router;