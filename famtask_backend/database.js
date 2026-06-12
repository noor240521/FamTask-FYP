const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const dbPath = path.resolve(__dirname, 'famtask.db');

const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('Error opening database:', err.message);
  } else {
    console.log('Connected to SQLite database at:', dbPath);
    initializeTables();
  }
});

function initializeTables() {
  db.serialize(() => {
    // Families table
    db.run(`
      CREATE TABLE IF NOT EXISTS families (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        invite_code TEXT UNIQUE NOT NULL
      )
    `);

    // Users table
    db.run(`
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        family_id TEXT,
        role TEXT,
        avatar TEXT,
        availability TEXT DEFAULT 'free',
        FOREIGN KEY (family_id) REFERENCES families (id)
      )
    `);

    // Tasks table
    db.run(`
      CREATE TABLE IF NOT EXISTS tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        due_date TEXT,
        location_name TEXT,
        latitude REAL,
        longitude REAL,
        assignee_id TEXT,
        family_id TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        is_urgent INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        locked_by_id TEXT,
        locked_by_name TEXT,
        locked_at TEXT,
        geofence_radius INTEGER DEFAULT 500,
        FOREIGN KEY (family_id) REFERENCES families (id),
        FOREIGN KEY (assignee_id) REFERENCES users (id)
      )
    `);

    // Shopping list items
    db.run(`
      CREATE TABLE IF NOT EXISTS shopping_items (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        quantity TEXT,
        is_urgent INTEGER DEFAULT 0,
        is_completed INTEGER DEFAULT 0,
        family_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (family_id) REFERENCES families (id)
      )
    `);

    // Activities log
    db.run(`
      CREATE TABLE IF NOT EXISTS activities (
        id TEXT PRIMARY KEY,
        family_id TEXT NOT NULL,
        user_name TEXT NOT NULL,
        description TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (family_id) REFERENCES families (id)
      )
    `);

    // Task Chat Messages table (GAP 7)
    db.run(`
      CREATE TABLE IF NOT EXISTS task_messages (
        id TEXT PRIMARY KEY,
        task_id TEXT NOT NULL,
        sender_id TEXT NOT NULL,
        sender_name TEXT NOT NULL,
        text TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (task_id) REFERENCES tasks (id)
      )
    `);

    // Migration helper: Alter tables if columns do not exist
    db.run("ALTER TABLE users ADD COLUMN availability TEXT DEFAULT 'free'", (err) => {
      if (err) {
        // Column probably already exists, ignore error
      } else {
        console.log("Migration: Added availability column to users.");
      }
    });

    db.run("ALTER TABLE tasks ADD COLUMN locked_by_id TEXT", (err) => { if (!err) console.log("Migration: Added locked_by_id to tasks."); });
    db.run("ALTER TABLE tasks ADD COLUMN locked_by_name TEXT", (err) => { if (!err) console.log("Migration: Added locked_by_name to tasks."); });
    db.run("ALTER TABLE tasks ADD COLUMN locked_at TEXT", (err) => { if (!err) console.log("Migration: Added locked_at to tasks."); });
    db.run("ALTER TABLE tasks ADD COLUMN geofence_radius INTEGER DEFAULT 500", (err) => { if (!err) console.log("Migration: Added geofence_radius to tasks."); });

    console.log('SQLite tables initialized successfully.');
  });
}

// Helper query function returning promises
function query(sql, params = []) {
  return new Promise((resolve, reject) => {
    db.all(sql, params, (err, rows) => {
      if (err) reject(err);
      else resolve(rows);
    });
  });
}

function run(sql, params = []) {
  return new Promise((resolve, reject) => {
    db.run(sql, params, function (err) {
      if (err) reject(err);
      else resolve(this);
    });
  });
}

function get(sql, params = []) {
  return new Promise((resolve, reject) => {
    db.get(sql, params, (err, row) => {
      if (err) reject(err);
      else resolve(row);
    });
  });
}

module.exports = {
  db,
  query,
  run,
  get
};
