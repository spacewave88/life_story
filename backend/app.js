// app.js
// Load environment variables
require('dotenv').config();

// Firebase Admin SDK Initialization
const admin = require('firebase-admin');
const serviceAccount = require(process.env.FIREBASE_SERVICE_ACCOUNT_KEY);
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

// Express initialization
const express = require('express');
const app = express();
const cors = require('cors');

app.use(cors({
  origin: 'http://localhost:8080', // Your web app's origin
  methods: ['GET', 'POST', 'PUT', 'DELETE'], // Allowed methods
  allowedHeaders: ['Content-Type', 'Authorization'] // Allowed headers
}));

app.use(express.json()); // for parsing application/json

// Morgan for logging
const morgan = require('morgan');
app.use(morgan('combined'));

// MongoDB Atlas Connection
const mongoose = require('mongoose');
mongoose.connect('mongodb+srv://spacewave88:Bigbluesea3%23@freecluster.mwb07.mongodb.net/?retryWrites=true&w=majority&appName=FreeCluster', {
  useNewUrlParser: true,
  useUnifiedTopology: true
})
.then(() => console.log('MongoDB connected...'))
.catch(err => console.log('MongoDB connection error:', err));

// User Schema Definition
const User = require('./models/User');

//Import User Routes
const userRoutes = require('./routes/userRoutes'); // Import user routes
app.use('/api/users', userRoutes);

// Set port
const PORT = process.env.PORT || 3000;

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

// Placeholder for your routes (CRUD operations)
app.get('/', (req, res) => {
  res.send('Hello World!');
});

// Example of a CRUD route - GET
app.get('/items', (req, res) => {
  // Logic to fetch items from database would go here
  res.json({ message: 'Fetch Items' });
});

// POST - Create
app.post('/items', (req, res) => {
  // Logic to create a new item
  res.json({ message: 'Item Created', data: req.body });
});
// Use admin where needed
//app.post('/someRoute', (req, res) => {
  // Example usage
 // admin.auth().verifyIdToken(...);
//});

// PUT - Update
app.put('/items/:id', (req, res) => {
  // Logic to update item by ID
  res.json({ message: 'Item Updated', id: req.params.id, data: req.body });
});

// DELETE - Delete
app.delete('/items/:id', (req, res) => {
  // Logic to delete item by ID
  res.json({ message: 'Item Deleted', id: req.params.id });
});

