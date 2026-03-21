# Database Rules

## Default: Supabase + PostgreSQL

```ts
// Client-side
import { createBrowserClient } from "@supabase/ssr";
const supabase = createBrowserClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
);

// Server-side (API routes, server components)
import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";

const supabase = createServerClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
  {
    cookies: {
      getAll() {
        return cookies().getAll();
      },
      setAll() {},
    },
  },
);
```

## Row-Level Security — always enable

```sql
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own posts"
  ON posts FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own posts"
  ON posts FOR INSERT
  WITH CHECK (auth.uid() = user_id);
```

Never leave a table with RLS disabled in production.

## Schema conventions

- Tables: `snake_case`, plural (`users`, `blog_posts`)
- Primary key: `id uuid DEFAULT gen_random_uuid() PRIMARY KEY`
- Timestamps: `created_at timestamptz DEFAULT now()`, `updated_at timestamptz DEFAULT now()`
- Foreign keys: `{table_singular}_id` (`user_id`, `post_id`)
- Soft delete: `deleted_at timestamptz` (null = not deleted)

## Query patterns

```ts
const { data, error } = await supabase
  .from("posts")
  .select("id, title, created_at") // never select("*")
  .eq("user_id", user.id)
  .order("created_at", { ascending: false })
  .limit(20); // always limit

if (error) throw new Error(error.message);
```

## Type safety

```bash
npx supabase gen types typescript --project-id $PROJECT_ID > src/types/supabase.ts
```

```ts
import type { Database } from "@/types/supabase";
type Post = Database["public"]["Tables"]["posts"]["Row"];
```

## Indexes

```sql
CREATE INDEX posts_user_id_idx ON posts(user_id);
CREATE INDEX posts_created_at_idx ON posts(created_at DESC);
```

Add indexes for every column used in WHERE, JOIN, or ORDER BY.

## Never Do These

- Never disable RLS without an explicit policy plan
- Never store passwords — use Supabase Auth
- Never expose the service role key to the client
- Never `select("*")` — always specify columns
- Never hard-delete user-facing data — soft delete with `deleted_at`
