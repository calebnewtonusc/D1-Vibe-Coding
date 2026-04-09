# Cloudflare D1 Patterns

Patterns and examples for building on Cloudflare's stack: Workers, D1, KV, R2, and Queues. Everything here works with vibe coding workflows (Claude Code + CLAUDE.md context).

---

## D1 Fundamentals

D1 is Cloudflare's serverless SQLite database. It runs at the edge, meaning your queries execute close to your users.

### Key Constraints

- SQLite syntax (not Postgres). No `RETURNING *` in older versions, use `RETURNING` with specific columns
- 10MB max database size on free plan, 10GB on paid
- No `ALTER COLUMN` in SQLite, must recreate the table
- Queries run in the same isolate as your Worker (no network hop)
- Batch operations are atomic (all succeed or all fail)

### When to Use D1

- Read-heavy workloads at the edge
- Small-to-medium datasets (under 10GB)
- Apps where latency matters more than complex queries
- Projects where you want zero infrastructure management

### When NOT to Use D1

- Heavy write workloads (SQLite has write locks)
- Complex joins across many tables
- Full-text search at scale (use Workers AI or Algolia)
- Real-time subscriptions (use Durable Objects or Supabase)

---

## Worker + D1 Setup

### wrangler.toml

```toml
name = "my-api"
main = "src/index.ts"
compatibility_date = "2025-04-07"
compatibility_flags = ["nodejs_compat"]

[[d1_databases]]
binding = "DB"
database_name = "my-db"
database_id = "your-database-id"
migrations_dir = "migrations"
```

### Create the Database

```bash
wrangler d1 create my-db
# Copy the database_id into wrangler.toml
```

### TypeScript Env Type

```ts
interface Env {
  DB: D1Database;
  ENVIRONMENT: string;
}
```

---

## Query Patterns

### Always Use Prepared Statements

Never interpolate user input into SQL strings. Always use `.bind()`.

```ts
// CORRECT: parameterized query
const user = await env.DB.prepare("SELECT * FROM users WHERE id = ?")
  .bind(userId)
  .first();

// WRONG: SQL injection risk
const user = await env.DB.prepare(
  `SELECT * FROM users WHERE id = '${userId}'`,
).first();
```

### Single Row

```ts
const item = await env.DB.prepare(
  "SELECT id, name, status FROM items WHERE id = ?",
)
  .bind(id)
  .first<{ id: number; name: string; status: string }>();

if (!item) {
  return new Response("Not found", { status: 404 });
}
```

### Multiple Rows

```ts
const { results } = await env.DB.prepare(
  "SELECT * FROM items WHERE status = ? ORDER BY created_at DESC LIMIT ?",
)
  .bind("active", 20)
  .all<Item>();
```

### Insert with RETURNING

```ts
const newItem = await env.DB.prepare(
  "INSERT INTO items (name, description) VALUES (?, ?) RETURNING *",
)
  .bind(name, description)
  .first<Item>();
```

### Batch Operations (Atomic)

Multiple statements execute as a single transaction:

```ts
const results = await env.DB.batch([
  env.DB.prepare("INSERT INTO items (name) VALUES (?)").bind("Item A"),
  env.DB.prepare("INSERT INTO items (name) VALUES (?)").bind("Item B"),
  env.DB.prepare("UPDATE counters SET count = count + 2 WHERE name = 'items'"),
]);
// All three succeed or all three fail
```

### Pagination

```ts
async function paginate(db: D1Database, page: number, perPage: number) {
  const offset = (page - 1) * perPage;

  const [countResult, dataResult] = await db.batch([
    db.prepare("SELECT COUNT(*) as total FROM items WHERE status = 'active'"),
    db
      .prepare(
        "SELECT * FROM items WHERE status = 'active' ORDER BY created_at DESC LIMIT ? OFFSET ?",
      )
      .bind(perPage, offset),
  ]);

  return {
    data: dataResult.results,
    meta: {
      total: (countResult.results[0] as { total: number }).total,
      page,
      perPage,
    },
  };
}
```

---

## Migrations

### Creating Migrations

```bash
wrangler d1 migrations create my-db add_users_table
# Creates: migrations/0001_add_users_table.sql
```

### Migration File Format

```sql
-- migrations/0001_initial.sql
CREATE TABLE IF NOT EXISTS items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  status TEXT NOT NULL DEFAULT 'active' CHECK(status IN ('active', 'archived')),
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX items_status_idx ON items(status);
CREATE INDEX items_created_at_idx ON items(created_at DESC);
```

### Running Migrations

```bash
# Local development
wrangler d1 migrations apply my-db --local

# Production
wrangler d1 migrations apply my-db --remote
```

### Migration Best Practices

- One migration per schema change
- Never modify an existing migration that's been applied
- Always include IF NOT EXISTS / IF EXISTS guards
- Add indexes in the same migration as the table they reference
- Use CHECK constraints for enum-like columns (SQLite doesn't have enums)

---

## Drizzle ORM with D1

Cloudflare's VibeSDK uses Drizzle as the ORM layer. Here's the pattern:

### Schema Definition

```ts
import { sqliteTable, text, integer } from "drizzle-orm/sqlite-core";

export const items = sqliteTable("items", {
  id: integer("id").primaryKey({ autoIncrement: true }),
  name: text("name").notNull(),
  description: text("description"),
  status: text("status", { enum: ["active", "archived"] })
    .notNull()
    .default("active"),
  createdAt: text("created_at")
    .notNull()
    .default(sql`(datetime('now'))`),
  updatedAt: text("updated_at")
    .notNull()
    .default(sql`(datetime('now'))`),
});
```

### Query with Drizzle

```ts
import { drizzle } from "drizzle-orm/d1";
import { eq } from "drizzle-orm";
import * as schema from "./schema";

export default {
  async fetch(request: Request, env: Env) {
    const db = drizzle(env.DB, { schema });

    // Select
    const allItems = await db
      .select()
      .from(schema.items)
      .where(eq(schema.items.status, "active"));

    // Insert
    const [newItem] = await db
      .insert(schema.items)
      .values({ name: "New Item" })
      .returning();

    // Update
    await db
      .update(schema.items)
      .set({ status: "archived" })
      .where(eq(schema.items.id, 1));

    return Response.json(allItems);
  },
};
```

---

## Worker Patterns

### Request Router (No Framework)

```ts
export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    const { pathname, searchParams } = url;
    const method = request.method;

    // CORS preflight
    if (method === "OPTIONS") {
      return new Response(null, {
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE",
          "Access-Control-Allow-Headers": "Content-Type",
        },
      });
    }

    // Route matching
    if (pathname === "/api/items" && method === "GET") {
      return handleListItems(env, searchParams);
    }

    const match = pathname.match(/^\/api\/items\/(\d+)$/);
    if (match) {
      const id = parseInt(match[1], 10);
      if (method === "GET") return handleGetItem(env, id);
      if (method === "PUT") return handleUpdateItem(env, id, request);
      if (method === "DELETE") return handleDeleteItem(env, id);
    }

    return Response.json({ error: "Not found" }, { status: 404 });
  },
} satisfies ExportedHandler<Env>;
```

### Using Hono (Lightweight Framework)

```ts
import { Hono } from "hono";
import { cors } from "hono/cors";

const app = new Hono<{ Bindings: Env }>();

app.use("*", cors());

app.get("/api/items", async (c) => {
  const { results } = await c.env.DB.prepare(
    "SELECT * FROM items WHERE status = 'active'",
  ).all();
  return c.json({ data: results });
});

app.get("/api/items/:id", async (c) => {
  const id = c.req.param("id");
  const item = await c.env.DB.prepare("SELECT * FROM items WHERE id = ?")
    .bind(id)
    .first();
  if (!item) return c.json({ error: "Not found" }, 404);
  return c.json({ data: item });
});

export default app;
```

---

## D1 + KV + R2 Together

### KV for Caching D1 Queries

```ts
async function getCachedItems(env: Env): Promise<Item[]> {
  const cached = await env.CACHE.get("items:active", "json");
  if (cached) return cached as Item[];

  const { results } = await env.DB.prepare(
    "SELECT * FROM items WHERE status = 'active'",
  ).all<Item>();

  await env.CACHE.put("items:active", JSON.stringify(results), {
    expirationTtl: 300, // 5 minutes
  });

  return results;
}
```

### R2 for File Storage

```ts
app.post("/api/upload", async (c) => {
  const formData = await c.req.formData();
  const file = formData.get("file") as File;

  const key = `uploads/${Date.now()}-${file.name}`;
  await c.env.STORAGE.put(key, file.stream(), {
    httpMetadata: { contentType: file.type },
  });

  // Store reference in D1
  await c.env.DB.prepare(
    "INSERT INTO files (name, r2_key, size) VALUES (?, ?, ?)",
  )
    .bind(file.name, key, file.size)
    .run();

  return c.json({ key });
});
```

---

## Deployment

### Local Development

```bash
wrangler dev
# Starts local server with D1 access at http://localhost:8787
```

### Deploy to Production

```bash
wrangler deploy
# Deploys to your Workers subdomain: my-api.your-subdomain.workers.dev
```

### Custom Domains

Add in `wrangler.toml`:

```toml
routes = [
  { pattern = "api.yourdomain.com", custom_domain = true }
]
```

---

## Further Reading

- [Cloudflare D1 Docs](https://developers.cloudflare.com/d1/)
- [Cloudflare Workers Docs](https://developers.cloudflare.com/workers/)
- [Drizzle ORM D1 Guide](https://orm.drizzle.team/docs/get-started/d1-new)
- [Hono Framework](https://hono.dev/)
- [VibeSDK Source](https://github.com/cloudflare/vibesdk)
