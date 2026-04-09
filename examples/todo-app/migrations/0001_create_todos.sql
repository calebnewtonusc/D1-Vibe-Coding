-- Create the todos table
CREATE TABLE IF NOT EXISTS todos (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  completed INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS todos_completed_idx ON todos(completed);
CREATE INDEX IF NOT EXISTS todos_created_at_idx ON todos(created_at DESC);

-- Auto-update updated_at
CREATE TRIGGER IF NOT EXISTS todos_updated_at
  AFTER UPDATE ON todos
  FOR EACH ROW
  BEGIN
    UPDATE todos SET updated_at = datetime('now') WHERE id = OLD.id;
  END;
