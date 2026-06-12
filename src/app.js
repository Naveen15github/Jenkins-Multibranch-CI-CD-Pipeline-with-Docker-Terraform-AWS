const express = require('express');
const usersRouter = require('./routes/users');

const app = express();

app.use(express.json());

app.get('/', (req, res) => {
  res.json({ message: 'Hello from CI/CD Pipeline' });
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok', uptime: process.uptime() });
});

app.use('/api/users', usersRouter);

module.exports = app;
