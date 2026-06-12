const request = require('supertest');
const app = require('../src/app');

describe('GET /', () => {
  it('should return landing page HTML', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toBe(200);
    expect(res.type).toBe('text/html');
    expect(res.text).toContain('<!DOCTYPE html>');
    expect(res.text).toContain('CI/CD Pipeline');
  });
});

describe('GET /health', () => {
  it('should return status ok and uptime', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('ok');
    expect(typeof res.body.uptime).toBe('number');
  });
});

describe('GET /api/users', () => {
  it('should return list of users', async () => {
    const res = await request(app).get('/api/users');
    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('users');
    expect(res.body).toHaveProperty('total');
    expect(Array.isArray(res.body.users)).toBe(true);
    expect(res.body.users.length).toBeGreaterThan(0);
  });

  it('should return correct user structure', async () => {
    const res = await request(app).get('/api/users');
    const user = res.body.users[0];
    expect(user).toHaveProperty('id');
    expect(user).toHaveProperty('name');
    expect(user).toHaveProperty('email');
    expect(user).toHaveProperty('role');
  });
});

describe('GET /api/users/:id', () => {
  it('should return a single user by id', async () => {
    const res = await request(app).get('/api/users/1');
    expect(res.statusCode).toBe(200);
    expect(res.body.id).toBe(1);
    expect(res.body.name).toBe('Alice Johnson');
  });

  it('should return 404 for non-existent user', async () => {
    const res = await request(app).get('/api/users/9999');
    expect(res.statusCode).toBe(404);
    expect(res.body).toEqual({ error: 'User not found' });
  });
});

describe('POST /api/users', () => {
  it('should create a new user with valid data', async () => {
    const newUser = { name: 'Dave Brown', email: 'dave@example.com', role: 'tester' };
    const res = await request(app).post('/api/users').send(newUser);
    expect(res.statusCode).toBe(201);
    expect(res.body).toHaveProperty('id');
    expect(res.body.name).toBe('Dave Brown');
    expect(res.body.email).toBe('dave@example.com');
    expect(res.body.role).toBe('tester');
  });

  it('should default role to developer if not provided', async () => {
    const newUser = { name: 'Eve Green', email: 'eve@example.com' };
    const res = await request(app).post('/api/users').send(newUser);
    expect(res.statusCode).toBe(201);
    expect(res.body.role).toBe('developer');
  });

  it('should return 400 if name is missing', async () => {
    const res = await request(app).post('/api/users').send({ email: 'noname@example.com' });
    expect(res.statusCode).toBe(400);
    expect(res.body).toEqual({ error: 'Name and email are required' });
  });

  it('should return 400 if email is missing', async () => {
    const res = await request(app).post('/api/users').send({ name: 'No Email' });
    expect(res.statusCode).toBe(400);
    expect(res.body).toEqual({ error: 'Name and email are required' });
  });
});

describe('DELETE /api/users/:id', () => {
  it('should delete an existing user', async () => {
    const created = await request(app)
      .post('/api/users')
      .send({ name: 'Temp User', email: 'temp@example.com' });
    const id = created.body.id;
    const res = await request(app).delete(`/api/users/${id}`);
    expect(res.statusCode).toBe(200);
    expect(res.body).toEqual({ message: 'User deleted successfully' });
  });

  it('should return 404 when deleting non-existent user', async () => {
    const res = await request(app).delete('/api/users/99999');
    expect(res.statusCode).toBe(404);
    expect(res.body).toEqual({ error: 'User not found' });
  });
});
