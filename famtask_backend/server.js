const express = require('express');
const cors = require('cors');
const path = require('path');
const routes = require('./routes');
const database = require('./database');

const app = express();
const PORT = process.env.PORT || 3000;

// Enable CORS so the Flutter client can connect
app.use(cors());

// Parse JSON request body
app.use(express.json());

// Main API Router
app.use('/api', routes);

// Simple diagnostic page
app.get('/', (req, res) => {
  res.json({
    name: 'FAMTASK Backend Server',
    status: 'Running',
    database: 'SQLite Connected',
    time: new Date().toISOString()
  });
});

// Start express server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`=========================================`);
  console.log(` FAMTASK BACKEND SERVER RUNNING`);
  console.log(` Port: ${PORT}`);
  console.log(` URL: http://localhost:${PORT}`);
  console.log(` Access locally or over network`);
  console.log(`=========================================`);
});
