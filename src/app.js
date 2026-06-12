const express = require('express');
const path = require('path');
const usersRouter = require('./routes/users');

const app = express();

// Middleware
app.use(express.json());

// Serve static files (CSS, JS, images)
app.use(express.static(path.join(__dirname, 'public')));

// Routes
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

app.use('/api/users', usersRouter);

module.exports = app;
