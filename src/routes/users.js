const express = require('express');
const router = express.Router();

let users = [
  { id: 1, name: 'Alice Johnson', email: 'alice@example.com', role: 'admin' },
  { id: 2, name: 'Bob Smith', email: 'bob@example.com', role: 'developer' },
  { id: 3, name: 'Carol White', email: 'carol@example.com', role: 'designer' },
];

let nextId = 4;

router.get('/', (req, res) => {
  res.json({ users, total: users.length });
});

router.get('/:id', (req, res) => {
  const id = parseInt(req.params.id, 10);
  const user = users.find((u) => u.id === id);
  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }
  res.json(user);
});

router.post('/', (req, res) => {
  const { name, email, role } = req.body;
  if (!name || !email) {
    return res.status(400).json({ error: 'Name and email are required' });
  }
  const newUser = { id: nextId++, name, email, role: role || 'developer' };
  users.push(newUser);
  res.status(201).json(newUser);
});

router.delete('/:id', (req, res) => {
  const id = parseInt(req.params.id, 10);
  const index = users.findIndex((u) => u.id === id);
  if (index === -1) {
    return res.status(404).json({ error: 'User not found' });
  }
  users.splice(index, 1);
  res.json({ message: 'User deleted successfully' });
});

module.exports = router;
