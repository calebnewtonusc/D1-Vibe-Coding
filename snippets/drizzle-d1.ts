/**
 * Drizzle ORM + D1 Snippet
 *
 * Complete schema + query example for Cloudflare D1 with Drizzle.
 * Used by VibeSDK and recommended for type-safe D1 access.
 *
 * Install: npm install drizzle-orm drizzle-kit
 */

import { sqliteTable, text, integer } from "drizzle-orm/sqlite-core";
import { sql } from "drizzle-orm";
import { drizzle } from "drizzle-orm/d1";
import { eq, desc, like, and } from "drizzle-orm";

// --- Schema Definition ---

export const users = sqliteTable("users", {
  id: integer("id").primaryKey({ autoIncrement: true }),
  email: text("email").notNull().unique(),
  name: text("name").notNull(),
  avatarUrl: text("avatar_url"),
  createdAt: text("created_at")
    .notNull()
    .default(sql`(datetime('now'))`),
});

export const items = sqliteTable("items", {
  id: integer("id").primaryKey({ autoIncrement: true }),
  name: text("name").notNull(),
  description: text("description"),
  status: text("status", { enum: ["active", "archived"] })
    .notNull()
    .default("active"),
  ownerId: integer("owner_id").references(() => users.id),
  createdAt: text("created_at")
    .notNull()
    .default(sql`(datetime('now'))`),
  updatedAt: text("updated_at")
    .notNull()
    .default(sql`(datetime('now'))`),
});

// --- Type Exports ---

export type User = typeof users.$inferSelect;
export type NewUser = typeof users.$inferInsert;
export type Item = typeof items.$inferSelect;
export type NewItem = typeof items.$inferInsert;

// --- Usage in a Worker ---

interface Env {
  DB: D1Database;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const db = drizzle(env.DB);

    // List active items with pagination
    const page = 1;
    const perPage = 20;
    const activeItems = await db
      .select()
      .from(items)
      .where(eq(items.status, "active"))
      .orderBy(desc(items.createdAt))
      .limit(perPage)
      .offset((page - 1) * perPage);

    // Search items
    const searchResults = await db
      .select()
      .from(items)
      .where(
        and(eq(items.status, "active"), like(items.name, "%search term%")),
      );

    // Insert
    const [newItem] = await db
      .insert(items)
      .values({ name: "New Item", ownerId: 1 })
      .returning();

    // Update
    await db
      .update(items)
      .set({ status: "archived", updatedAt: sql`(datetime('now'))` })
      .where(eq(items.id, 1));

    // Join
    const itemsWithOwners = await db
      .select({
        itemName: items.name,
        ownerName: users.name,
        ownerEmail: users.email,
      })
      .from(items)
      .leftJoin(users, eq(items.ownerId, users.id))
      .where(eq(items.status, "active"));

    return Response.json({ data: activeItems });
  },
};
