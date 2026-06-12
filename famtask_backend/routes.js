const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const db = require('./database');

// Helper to generate a 6-character family invite code
function generateInviteCode() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  let code = '';
  for (let i = 0; i < 6; i++) {
    code += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return code;
}

// Generate unique ID helper
function generateId() {
  return Math.random().toString(36).substring(2, 9) + Date.now().toString(36);
}

// Helper to log activities
async function logActivity(familyId, userName, description) {
  const id = generateId();
  const createdAt = new Date().toISOString();
  try {
    await db.run(
      'INSERT INTO activities (id, family_id, user_name, description, created_at) VALUES (?, ?, ?, ?, ?)',
      [id, familyId, userName, description, createdAt]
    );
  } catch (err) {
    console.error('Failed to log activity:', err);
  }
}

// ==========================================
// AUTHENTICATION ROUTES
// ==========================================

// Register
router.post('/auth/register', async (req, res) => {
  const { name, email, password, role } = req.body;
  if (!name || !email || !password) {
    return res.status(400).json({ error: 'Name, email, and password are required' });
  }

  try {
    // Check if email exists
    const existingUser = await db.get('SELECT * FROM users WHERE email = ?', [email]);
    if (existingUser) {
      return res.status(400).json({ error: 'Email already registered' });
    }

    const id = generateId();
    const passwordHash = await bcrypt.hash(password, 10);
    const defaultAvatar = name.charAt(0).toUpperCase();

    await db.run(
      'INSERT INTO users (id, name, email, password_hash, role, avatar, availability) VALUES (?, ?, ?, ?, ?, ?, \'free\')',
      [id, name, email, passwordHash, role || 'Member', defaultAvatar]
    );

    const user = { id, name, email, role, avatar: defaultAvatar, family_id: null, availability: 'free' };
    res.status(201).json({ message: 'User registered successfully', user });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Login
router.post('/auth/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  try {
    const user = await db.get('SELECT * FROM users WHERE email = ?', [email]);
    if (!user) {
      return res.status(400).json({ error: 'Invalid email or password' });
    }

    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(400).json({ error: 'Invalid email or password' });
    }

    // Get family name if family_id is set
    let familyName = null;
    let inviteCode = null;
    if (user.family_id) {
      const family = await db.get('SELECT * FROM families WHERE id = ?', [user.family_id]);
      if (family) {
        familyName = family.name;
        inviteCode = family.invite_code;
      }
    }

    const userData = {
      id: user.id,
      name: user.name,
      email: user.email,
      family_id: user.family_id,
      familyName: familyName,
      familyCode: inviteCode,
      role: user.role,
      avatar: user.avatar,
      availability: user.availability || 'free'
    };

    res.json({ message: 'Login successful', user: userData });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ==========================================
// FAMILY ROUTES
// ==========================================

// Create family
router.post('/family/create', async (req, res) => {
  const { familyName, userId, role } = req.body;
  if (!familyName || !userId) {
    return res.status(400).json({ error: 'Family name and userId are required' });
  }

  try {
    const user = await db.get('SELECT * FROM users WHERE id = ?', [userId]);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    const familyId = generateId();
    const inviteCode = generateInviteCode();

    // Create family
    await db.run('INSERT INTO families (id, name, invite_code) VALUES (?, ?, ?)', [familyId, familyName, inviteCode]);

    // Update user family_id and role
    await db.run(
      'UPDATE users SET family_id = ?, role = ? WHERE id = ?',
      [familyId, role || 'Admin', userId]
    );

    await logActivity(familyId, user.name, `created the family group "${familyName}"`);

    res.status(201).json({
      message: 'Family created successfully',
      family: { id: familyId, name: familyName, invite_code: inviteCode },
      role: role || 'Admin'
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Join family
router.post('/family/join', async (req, res) => {
  const { inviteCode, userId, role } = req.body;
  if (!inviteCode || !userId) {
    return res.status(400).json({ error: 'Invite code and userId are required' });
  }

  try {
    const family = await db.get('SELECT * FROM families WHERE invite_code = ?', [inviteCode.toUpperCase().trim()]);
    if (!family) {
      return res.status(404).json({ error: 'Invalid invite code' });
    }

    const user = await db.get('SELECT * FROM users WHERE id = ?', [userId]);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Update user family_id and role
    await db.run(
      'UPDATE users SET family_id = ?, role = ? WHERE id = ?',
      [family.id, role || 'Member', userId]
    );

    await logActivity(family.id, user.name, `joined the family group`);

    res.json({
      message: 'Joined family successfully',
      family: { id: family.id, name: family.name, invite_code: family.invite_code },
      role: role || 'Member'
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get family members
router.get('/family/members/:familyId', async (req, res) => {
  const { familyId } = req.params;
  try {
    const members = await db.query(
      'SELECT id, name, email, role, avatar, availability FROM users WHERE family_id = ?',
      [familyId]
    );
    res.json(members);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ==========================================
// TASK ROUTES
// ==========================================

// Get family tasks
router.get('/tasks/:familyId', async (req, res) => {
  const { familyId } = req.params;
  try {
    const tasks = await db.query(
      `SELECT t.*, u.name as assignee_name,
       (SELECT COUNT(*) FROM task_messages WHERE task_id = t.id) as message_count
       FROM tasks t 
       LEFT JOIN users u ON t.assignee_id = u.id 
       WHERE t.family_id = ? 
       ORDER BY t.created_at DESC`,
      [familyId]
    );
    // Convert is_urgent integer back to boolean
    const processedTasks = tasks.map(t => ({
      ...t,
      is_urgent: t.is_urgent === 1,
      message_count: t.message_count || 0
    }));
    res.json(processedTasks);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Create task
router.post('/tasks', async (req, res) => {
  const { title, description, due_date, location_name, latitude, longitude, assignee_id, family_id, is_urgent, userName, geofence_radius } = req.body;
  if (!title || !family_id) {
    return res.status(400).json({ error: 'Task title and family_id are required' });
  }

  const id = generateId();
  const createdAt = new Date().toISOString();
  const urgentVal = is_urgent ? 1 : 0;
  const radiusVal = geofence_radius ? parseInt(geofence_radius) : 500;

  try {
    await db.run(
      `INSERT INTO tasks (id, title, description, due_date, location_name, latitude, longitude, assignee_id, family_id, status, is_urgent, created_at, geofence_radius)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending', ?, ?, ?)`,
      [id, title, description, due_date, location_name, latitude, longitude, assignee_id, family_id, urgentVal, createdAt, radiusVal]
    );

    const task = {
      id,
      title,
      description,
      due_date,
      location_name,
      latitude,
      longitude,
      assignee_id,
      family_id,
      status: 'pending',
      is_urgent: !!is_urgent,
      created_at: createdAt,
      geofence_radius: radiusVal
    };

    await logActivity(family_id, userName || 'Someone', `created task: "${title}"`);

    res.status(201).json(task);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Toggle task status
router.patch('/tasks/:taskId/toggle', async (req, res) => {
  const { taskId } = req.params;
  const { userName } = req.body;

  try {
    const task = await db.get('SELECT * FROM tasks WHERE id = ?', [taskId]);
    if (!task) {
      return res.status(404).json({ error: 'Task not found' });
    }

    const newStatus = task.status === 'pending' ? 'completed' : 'pending';
    await db.run('UPDATE tasks SET status = ? WHERE id = ?', [newStatus, taskId]);

    const logMsg = newStatus === 'completed' ? `completed task: "${task.title}"` : `re-opened task: "${task.title}"`;
    await logActivity(task.family_id, userName || 'Someone', logMsg);

    res.json({ message: 'Task status updated', id: taskId, status: newStatus });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete task
router.delete('/tasks/:taskId', async (req, res) => {
  const { taskId } = req.params;
  const { userName, familyId } = req.query;

  try {
    const task = await db.get('SELECT * FROM tasks WHERE id = ?', [taskId]);
    if (!task) {
      return res.status(404).json({ error: 'Task not found' });
    }

    await db.run('DELETE FROM tasks WHERE id = ?', [taskId]);

    await logActivity(familyId || task.family_id, userName || 'Someone', `deleted task: "${task.title}"`);

    res.json({ message: 'Task deleted successfully', id: taskId });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ==========================================
// SHOPPING LIST ROUTES
// ==========================================

// Get shopping items
router.get('/shopping/:familyId', async (req, res) => {
  const { familyId } = req.params;
  try {
    const items = await db.query(
      'SELECT * FROM shopping_items WHERE family_id = ? ORDER BY created_at DESC',
      [familyId]
    );
    const processedItems = items.map(item => ({
      ...item,
      is_urgent: item.is_urgent === 1,
      is_completed: item.is_completed === 1
    }));
    res.json(processedItems);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Add shopping item
router.post('/shopping', async (req, res) => {
  const { name, quantity, is_urgent, family_id, userName } = req.body;
  if (!name || !family_id) {
    return res.status(400).json({ error: 'Item name and family_id are required' });
  }

  const id = generateId();
  const createdAt = new Date().toISOString();
  const urgentVal = is_urgent ? 1 : 0;

  try {
    await db.run(
      'INSERT INTO shopping_items (id, name, quantity, is_urgent, is_completed, family_id, created_at) VALUES (?, ?, ?, ?, 0, ?, ?)',
      [id, name, quantity || '1', urgentVal, family_id, createdAt]
    );

    const item = {
      id,
      name,
      quantity: quantity || '1',
      is_urgent: !!is_urgent,
      is_completed: false,
      family_id,
      created_at: createdAt
    };

    await logActivity(family_id, userName || 'Someone', `added "${name}" to shopping list`);

    res.status(201).json(item);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Toggle shopping item completed status
router.patch('/shopping/:itemId/toggle', async (req, res) => {
  const { itemId } = req.params;
  const { userName } = req.body;

  try {
    const item = await db.get('SELECT * FROM shopping_items WHERE id = ?', [itemId]);
    if (!item) {
      return res.status(404).json({ error: 'Item not found' });
    }

    const newCompletedVal = item.is_completed === 0 ? 1 : 0;
    await db.run('UPDATE shopping_items SET is_completed = ? WHERE id = ?', [newCompletedVal, itemId]);

    const logMsg = newCompletedVal === 1 ? `purchased "${item.name}"` : `marked "${item.name}" as pending`;
    await logActivity(item.family_id, userName || 'Someone', logMsg);

    res.json({ message: 'Shopping item updated', id: itemId, is_completed: newCompletedVal === 1 });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete shopping item
router.delete('/shopping/:itemId', async (req, res) => {
  const { itemId } = req.params;
  const { userName, familyId } = req.query;

  try {
    const item = await db.get('SELECT * FROM shopping_items WHERE id = ?', [itemId]);
    if (!item) {
      return res.status(404).json({ error: 'Item not found' });
    }

    await db.run('DELETE FROM shopping_items WHERE id = ?', [itemId]);

    await logActivity(familyId || item.family_id, userName || 'Someone', `removed "${item.name}" from shopping list`);

    res.json({ message: 'Shopping item deleted', id: itemId });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ==========================================
// ACTIVITY ROUTES
// ==========================================

// ==========================================
// TASK LOCK / UNLOCK ROUTES (GAP 2)
// ==========================================

// Lock (Accept) task
router.patch('/tasks/:taskId/lock', async (req, res) => {
  const { taskId } = req.params;
  const { userId, userName } = req.body;

  if (!userId || !userName) {
    return res.status(400).json({ error: 'userId and userName are required' });
  }

  try {
    const task = await db.get('SELECT * FROM tasks WHERE id = ?', [taskId]);
    if (!task) {
      return res.status(404).json({ error: 'Task not found' });
    }

    if (task.locked_by_id && task.locked_by_id !== userId) {
      return res.status(400).json({ 
        error: `This task is already accepted by ${task.locked_by_name}` 
      });
    }

    const lockedAt = new Date().toISOString();
    await db.run(
      'UPDATE tasks SET locked_by_id = ?, locked_by_name = ?, locked_at = ?, assignee_id = ? WHERE id = ?',
      [userId, userName, lockedAt, userId, taskId]
    );

    await logActivity(task.family_id, userName, `accepted and locked task: "${task.title}"`);

    res.json({ 
      message: 'Task locked successfully', 
      id: taskId, 
      locked_by_id: userId, 
      locked_by_name: userName, 
      locked_at: lockedAt 
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Unlock task
router.patch('/tasks/:taskId/unlock', async (req, res) => {
  const { taskId } = req.params;
  const { userName } = req.body;

  try {
    const task = await db.get('SELECT * FROM tasks WHERE id = ?', [taskId]);
    if (!task) {
      return res.status(404).json({ error: 'Task not found' });
    }

    await db.run(
      'UPDATE tasks SET locked_by_id = NULL, locked_by_name = NULL, locked_at = NULL, assignee_id = NULL WHERE id = ?',
      [taskId]
    );

    await logActivity(task.family_id, userName || 'Someone', `unlocked task: "${task.title}"`);

    res.json({ message: 'Task unlocked successfully', id: taskId });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Background Auto-Unlock Routine (Check every 5 minutes)
// Resets tasks locked for more than 30 minutes if they are still pending
setInterval(async () => {
  try {
    const thirtyMinsAgo = new Date(Date.now() - 30 * 60 * 1000).toISOString();
    const expiredTasks = await db.query(
      "SELECT * FROM tasks WHERE status = 'pending' AND locked_by_id IS NOT NULL AND locked_at < ?",
      [thirtyMinsAgo]
    );

    for (const task of expiredTasks) {
      await db.run(
        "UPDATE tasks SET locked_by_id = NULL, locked_by_name = NULL, locked_at = NULL, assignee_id = NULL WHERE id = ?",
        [task.id]
      );
      await logActivity(task.family_id, 'System', `automatically unlocked task: "${task.title}" due to 30-minute lock timeout`);
      console.log(`Auto-unlocked task ${task.id} due to lock timeout.`);
    }
  } catch (err) {
    console.error('Background auto-unlock error:', err);
  }
}, 5 * 60 * 1000); // 5 minutes check interval

// ==========================================
// TASK MESSAGES / CHAT ROUTES (GAP 7)
// ==========================================

// Get messages for a task
router.get('/tasks/:taskId/messages', async (req, res) => {
  const { taskId } = req.params;
  try {
    const messages = await db.query(
      'SELECT * FROM task_messages WHERE task_id = ? ORDER BY timestamp ASC',
      [taskId]
    );
    res.json(messages);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Send a message for a task
router.post('/tasks/:taskId/messages', async (req, res) => {
  const { taskId } = req.params;
  const { senderId, senderName, text } = req.body;

  if (!senderId || !senderName || !text) {
    return res.status(400).json({ error: 'senderId, senderName, and text are required' });
  }

  const id = generateId();
  const timestamp = new Date().toISOString();

  try {
    await db.run(
      'INSERT INTO task_messages (id, task_id, sender_id, sender_name, text, timestamp) VALUES (?, ?, ?, ?, ?, ?)',
      [id, taskId, senderId, senderName, text, timestamp]
    );

    const message = { id, task_id: taskId, sender_id: senderId, sender_name: senderName, text, timestamp };
    res.status(201).json(message);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ==========================================
// USER AVAILABILITY ROUTES (GAP 5)
// ==========================================

// Update user availability
router.patch('/users/:userId/availability', async (req, res) => {
  const { userId } = req.params;
  const { availability, userName } = req.body;

  if (!availability) {
    return res.status(400).json({ error: 'availability is required' });
  }

  try {
    const user = await db.get('SELECT * FROM users WHERE id = ?', [userId]);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    await db.run('UPDATE users SET availability = ? WHERE id = ?', [availability, userId]);

    const statusMap = {
      free: '🟢 Free',
      busy: '🔴 Busy',
      driving: '🚗 Driving',
      dnd: '🔕 Do Not Disturb'
    };
    const statusLabel = statusMap[availability] || availability;

    await logActivity(user.family_id, userName || user.name, `updated status to ${statusLabel}`);

    res.json({ message: 'Availability updated successfully', id: userId, availability });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
