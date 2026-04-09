-- D1 Migration Template
-- Copy this file to migrations/NNNN_description.sql
-- Run with: wrangler d1 migrations apply DB_NAME --local

-- Create table with standard columns
CREATE TABLE IF NOT EXISTS items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  status TEXT NOT NULL DEFAULT 'active' CHECK(status IN ('active', 'archived', 'deleted')),
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Indexes for common query patterns
CREATE INDEX IF NOT EXISTS items_status_idx ON items(status);
CREATE INDEX IF NOT EXISTS items_created_at_idx ON items(created_at DESC);

-- Composite index for filtered + sorted queries
CREATE INDEX IF NOT EXISTS items_status_created_idx ON items(status, created_at DESC);

-- Trigger to auto-update updated_at on row changes
CREATE TRIGGER IF NOT EXISTS items_updated_at
  AFTER UPDATE ON items
  FOR EACH ROW
  BEGIN
    UPDATE items SET updated_at = datetime('now') WHERE id = OLD.id;
  END;
